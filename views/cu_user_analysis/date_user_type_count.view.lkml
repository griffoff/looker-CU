explore: date_user_type_count {}
view: date_user_type_count {
  derived_table: {
    create_process: {
      sql_step:
      CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.date_user_type_count
      (
      date DATE
      ,user_type STRING
      ,user_count INT
      )
      ;;

      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.date_user_type_count_incremental
        AS
          WITH dates AS (
            SELECT d.datevalue
            FROM ${dim_date.SQL_TABLE_NAME} d
            WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.date_user_type_count)
            AND d.datevalue < CURRENT_DATE()
          )
          SELECT date, 'Registered Student Users' AS user_type, students AS user_count
          FROM ${yru.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          UNION ALL
          SELECT date, 'Registered Instructor Users' AS user_type, instructors AS user_count
          FROM ${yru.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          UNION ALL
          SELECT date, 'Digital Student Users' AS user_type, COUNT(DISTINCT userbase_digital_user_guid) AS user_count
          FROM ${kpi_user_counts.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          GROUP BY date
          UNION ALL
          SELECT date, 'Instructors with Active Digital Course' AS user_type, COUNT(DISTINCT all_instructors_active_course_guid) AS user_count
          FROM ${kpi_user_counts.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          GROUP BY date
          UNION ALL
          SELECT date, 'Paid Digital Student Users' AS user_type, COUNT(DISTINCT userbase_paid_user_guid) AS user_count
          FROM ${kpi_user_counts.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          GROUP BY date
          UNION ALL
          SELECT date, 'Paid Courseware Student Users' AS user_type, COUNT(DISTINCT userbase_paid_courseware_guid) AS user_count
          FROM ${kpi_user_counts.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          GROUP BY date
          UNION ALL
          SELECT date, 'Paid eBook Only Student Users' AS user_type, COUNT(DISTINCT userbase_paid_ebook_only_guid) AS user_count
          FROM ${kpi_user_counts.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          GROUP BY date
          UNION ALL
          SELECT date, 'Full Access CU Users, no provisions' AS user_type, COUNT(DISTINCT userbase_full_access_cu_only_guid) AS user_count
          FROM ${kpi_user_counts.SQL_TABLE_NAME} t
          INNER JOIN dates d on d.datevalue = t.date
          GROUP BY date
      ;;

      sql_step:
        INSERT INTO LOOKER_SCRATCH.date_user_type_count
        SELECT date, user_type, user_count
        FROM looker_scratch.date_user_type_count_incremental
      ;;

      sql_step:
        CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
        CLONE LOOKER_SCRATCH.date_user_type_count
      ;;
    }
    datagroup_trigger: daily_refresh
}




    dimension: date {
      hidden:  yes
      type: date}

    dimension: max_date {
      hidden: yes
      type: date
#       sql: (SELECT MAX(dateadd(d,-1,date)) FROM ${date_user_type_count.SQL_TABLE_NAME});;
      sql: (SELECT MAX(date) FROM ${date_user_type_count.SQL_TABLE_NAME});;
    }

    dimension: user_type {
      group_label: "Visualization Dimensions"
      description: "For visualization only. Use with Date & User Count to show table breakdown for Current Student and Instructor Users"
      type:string
      hidden: no
      }

    dimension: user_count {
      group_label: "Visualization Dimensions"
      description: "For visualization only. Use with Date & User Type to show table breakdown for Current Student and Instructor Users"
      type:number
      hidden: no
      }

      measure: average_user_count {
        group_label: "Visualization Dimensions"
        type: average
        sql: ${user_count};;
        value_format_name: decimal_0

      }

 }
