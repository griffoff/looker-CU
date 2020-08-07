# include: "cengage_unlimited.model.lkml"

explore: guid_platform_date_active {
  hidden: yes
}

view: guid_platform_date_active {
  derived_table: {
    create_process: {
      sql_step:
      CREATE TABLE IF NOT EXISTS looker_scratch.guid_platform_date_active
      (
        date DATE
        ,user_sso_guid STRING
        ,productplatform STRING
        ,instructor BOOLEAN
        ,event_count INT
        ,event_duration_total NUMERIC(12, 4)
        ,latest BOOLEAN
        ,latest_by_platform BOOLEAN
      )
      ;;
      sql_step:
      INSERT INTO looker_scratch.guid_platform_date_active
      SELECT
        date
        ,g.user_sso_guid
        ,productplatform
        ,instructor AS role
        ,SUM(event_count)
        ,SUM(event_duration_total)
        ,MAX(g.latest)
        ,MAX(latest_by_platform)
      FROM ${guid_course_date_active.SQL_TABLE_NAME} AS g
      LEFT JOIN ${merged_cu_user_info.SQL_TABLE_NAME} AS m
        ON g.user_sso_guid = m.user_sso_guid
      WHERE date > (SELECT COALESCE(MAX(date), '2018-08-01'::DATE) FROM looker_scratch.guid_platform_date_active)
      GROUP BY 1, 2, 3, 4
      /*
      SELECT
          all_events.local_time::DATE
          ,all_events.user_sso_guid
          ,dim_productplatform.productplatform
          ,COUNT(*) AS event_count
          ,SUM(all_events.event_data:event_duration / 3600 / 24) AS event_duration_total
          ,ROW_NUMBER() OVER (PARTITION BY all_events.user_sso_guid ORDER BY local_time::DATE DESC) = 1 AS latest
          ,ROW_NUMBER() OVER (PARTITION BY all_events.user_sso_guid, dim_productplatform.productplatform ORDER BY all_events.local_time::DATE DESC) = 1 AS latest_by_platform
      FROM ${all_events.SQL_TABLE_NAME} all_events
      LEFT JOIN ${all_sessions.SQL_TABLE_NAME}  AS all_sessions ON all_events.session_id = all_sessions.session_id
      LEFT JOIN ${dim_course.SQL_TABLE_NAME} AS dim_course ON (all_sessions."COURSE_KEYS")[0] = dim_course.coursekey
      LEFT JOIN ${dim_productplatform.SQL_TABLE_NAME}  AS dim_productplatform ON dim_course.PRODUCTPLATFORMID = dim_productplatform.PRODUCTPLATFORMID
      WHERE all_events.local_time::DATE > (SELECT COALESCE(MAX(date), '2018-08-01') FROM looker_scratch.guid_platform_date_active)
      AND all_events.local_time::DATE < CURRENT_DATE()
      GROUP BY 1, 2, 3;
      */
      ;;
      sql_step:
        CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
        CLONE looker_scratch.guid_platform_date_active
      ;;
    }
    datagroup_trigger: daily_refresh
  }

  dimension: instructor {
    type:  yesno
    label: "Instructor"
    hidden: no
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    hidden: yes
  }
  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  dimension: latest {
    type: yesno
  }
  dimension: latest_by_platform {
    type: yesno
  }
  dimension: productplatform {
    label: "Product Platform"
    description: "MindTap, Aplia, CNOW, etc."
  }
  dimension: date {
    label: "Event Date"
    description: "Components of the events local timestamp"
    type: date
  }
  dimension: event_count {
    label: "Events # Events"
    description: "Measure for counting events (drill fields)"
    type: number
  }
  dimension: event_duration_total {
    label: "Events Total Time Active"
    value_format: "hh:mm:ss"
    type: number
  }
  measure: average_time_spent_per_student_per_day {
    type: average
    sql: ${event_duration_total} ;;
    value_format: "hh:mm:ss"
  }
  measure: event_count_measure {
    type:  sum
    sql:  ${event_count} ;;

  }
}
