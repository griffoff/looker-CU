view: all_events_backup {
  sql_table_name: ZPG.ALL_EVENTS_BACKUP ;;

  dimension: event_0 {
    type: string
    sql: ${TABLE}."EVENT_0" ;;
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."EVENT_1" ;;
  }

  dimension: event_1_courseware {
    type: string
    sql: ${TABLE}."EVENT_1_COURSEWARE" ;;
  }

  dimension: event_1_cu {
    type: string
    sql: ${TABLE}."EVENT_1_CU" ;;
  }

  dimension: event_2 {
    type: string
    sql: ${TABLE}."EVENT_2" ;;
  }

  dimension: event_3 {
    type: string
    sql: ${TABLE}."EVENT_3" ;;
  }

  dimension: event_4 {
    type: string
    sql: ${TABLE}."EVENT_4" ;;
  }

  dimension: event_5 {
    type: string
    sql: ${TABLE}."EVENT_5" ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
  }

  dimension: event_name_courseware {
    type: string
    sql: ${TABLE}."EVENT_NAME_COURSEWARE" ;;
  }

  dimension: event_name_cu {
    type: string
    sql: ${TABLE}."EVENT_NAME_CU" ;;
  }

  dimension: event_no {
    type: number
    sql: ${TABLE}."EVENT_NO" ;;
  }

  dimension_group: event {
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
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
  }

  dimension: exclude_event {
    type: yesno
    sql: ${TABLE}."EXCLUDE_EVENT" ;;
  }

  dimension: load_metadata {
    type: string
    sql: ${TABLE}."LOAD_METADATA" ;;
  }

  dimension_group: local {
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
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: system_category {
    type: string
    sql: ${TABLE}."SYSTEM_CATEGORY" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: [event_name]
  }
}
