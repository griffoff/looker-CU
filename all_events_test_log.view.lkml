explore: all_events_test_log {}

view: all_events_test_log {
  sql_table_name: ZPG.ALL_EVENTS_TEST_LOG ;;

  dimension: build_step {
    type: string
    sql: ${TABLE}."BUILD_STEP" ;;
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

  dimension_group: run {
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
    sql: ${TABLE}."RUN_TIME" ;;
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
