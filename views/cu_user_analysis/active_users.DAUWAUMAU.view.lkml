include: "//dm-bpl/dm-shared/dim_date.view"
include: "/views/cu_user_analysis/guid_date_active.view"

view: yru {
  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.YRU
        (
          date DATE
          ,users INT
          ,instructors INT
          ,students INT
        )
      ;;
      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.YRU_incremental
        AS
        WITH dates AS (
          SELECT d.date_value
          FROM ${dim_date.SQL_TABLE_NAME} d
          WHERE d.date_value > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.YRU)
          AND d.date_value < CURRENT_DATE()
        )
        ,all_events_merged AS (
          SELECT DISTINCT e.user_sso_guid AS merged_guid, CASE WHEN e.user_type = 'Instructor' then TRUE ELSE FALSE END AS instructor, e.date as event_time
          FROM ${guid_date_active.SQL_TABLE_NAME} e
        )
        ,first_mutation AS (
          SELECT DISTINCT COALESCE(e.linked_guid, hu.uid) AS merged_guid, e.instructor, e.rsrc_timestamp::date AS event_time
          FROM prod.datavault.hub_user hu
          INNER JOIN prod.datavault.SAT_USER_V2 e ON hu.hub_user_key = e.hub_user_key AND e._LATEST
          LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
          WHERE merged_guid IS NOT NULL
          AND event_time NOT IN ('2018-08-03','2019-08-22')
          AND ui.hub_user_key IS NULL
        )
        ,users AS (
        SELECT *
        FROM all_events_merged
        UNION
        SELECT *
        FROM first_mutation
        )
        SELECT
            d.date_value AS date
            ,COUNT(DISTINCT CASE WHEN instructor THEN u.merged_guid END) AS instructors
            ,COUNT(DISTINCT CASE WHEN NOT instructor OR instructor IS NULL THEN u.merged_guid END) AS students
            ,COUNT(DISTINCT u.merged_guid) AS users
        FROM dates d
        INNER JOIN users u ON u.event_time <= d.date_value
          AND u.event_time > DATEADD(DAY, -365, d.date_value)
        GROUP BY 1
      ;;
      sql_step:
      INSERT INTO LOOKER_SCRATCH.YRU
      SELECT date, users, instructors, students
      FROM looker_scratch.YRU_incremental
      ;;
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.YRU;;

      }
      datagroup_trigger: daily_refresh
    }

    dimension: date {
      hidden: yes
      type: date
      primary_key: yes
    }

    dimension_group: date {
      hidden: yes
      label: "Calendar"
      type:time
      timeframes: [raw,date,month,year]
    }

    dimension: max_date {
      hidden: yes
      type: date
      sql: (SELECT MAX(date) FROM LOOKER_SCRATCH.yru);;
    }

    measure: yru {
      group_label: "Registered Users"
      label: "# Total YRU"
      description: "Users with an event or change to their user profile in the last 365 days, relative to the filtered date (max over period if not reported on a single day)"
      type: number
      sql: MAX(${TABLE}.users) ;;
      value_format_name: decimal_0
    }

    measure: yru_instructors {
      group_label: "Registered Users"
      label: "# YRU Instructors"
      description: "Instructors with an event or change to their user profile in the last 365 days, relative to the filtered date (max over period if not reported on a single day)"
      type: number
      sql: MAX(${TABLE}.instructors) ;;
      value_format_name: decimal_0
    }

    measure: yru_students {
      group_label: "Registered Users"
      label: "# YRU Students"
      description: "Students with an event or change to their user profile in the last 365 days, relative to the filtered date (max over period if not reported on a single day)"
      type: number
      sql: MAX(${TABLE}.students) ;;
      value_format_name: decimal_0
    }
  }
