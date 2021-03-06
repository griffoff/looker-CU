explore: cu_user_analysis_build_log_summary {}

view: cu_user_analysis_build_log_summary {
  sql_table_name: ZPG.CU_USER_ANALYSIS_BUILD_LOG_SUMMARY ;;

  dimension: build_step {
    type: string
    sql: ${TABLE}."BUILD_STEP" ;;
  }

  dimension_group: date_day {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_DAY" ;;
  }

  dimension: event_action_non_null {
    type: string
    sql: ${TABLE}."EVENT_ACTION_NON_NULL" ;;
  }

  dimension: event_action_unique {
    type: string
    sql: ${TABLE}."EVENT_ACTION_UNIQUE" ;;
  }

  dimension: event_data_unique {
    type: string
    sql: ${TABLE}."EVENT_DATA_UNIQUE" ;;
  }

  dimension: event_id_guid {
    type: string
    sql: ${TABLE}."EVENT_ID_GUID" ;;
  }

  dimension: event_id_non_null {
    type: string
    sql: ${TABLE}."EVENT_ID_NON_NULL" ;;
  }

  dimension: event_id_unique {
    type: string
    sql: ${TABLE}."EVENT_ID_UNIQUE" ;;
  }

  dimension: event_type_non_null {
    type: string
    sql: ${TABLE}."EVENT_TYPE_NON_NULL" ;;
  }

  dimension: event_type_unique {
    type: string
    sql: ${TABLE}."EVENT_TYPE_UNIQUE" ;;
  }

  dimension: last_data_load {
    type: string
    sql: ${TABLE}."LAST_DATA_LOAD" ;;
  }

  dimension: run_time {
    type: string
    sql: ${TABLE}."RUN_TIME" ;;
  }

  dimension: total_records {
    type: string
    sql: ${TABLE}."TOTAL_RECORDS" ;;
  }

  dimension: user_sso_guid_non_null {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_NON_NULL" ;;
  }

  dimension: user_sso_guid_unique {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_UNIQUE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
