view: user_click_journey {
  sql_table_name: ZPG.USER_CLICK_JOURNEY ;;

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
  }

  dimension: event_number {
    type: number
    sql: ${TABLE}."EVENT_NUMBER" ;;
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

  dimension: five_ {
    type: string
    sql: ${TABLE}."FIVE_" ;;
  }

  dimension: four_ {
    type: string
    sql: ${TABLE}."FOUR_" ;;
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

  dimension: one_ {
    type: string
    sql: ${TABLE}."ONE_" ;;
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

  dimension: three_ {
    type: string
    sql: ${TABLE}."THREE_" ;;
  }

  dimension: two_ {
    type: string
    sql: ${TABLE}."TWO_" ;;
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
    drill_fields: []
  }

  measure: user_count {
    type:  count_distinct
    sql: ${user_sso_guid} ;;
  }
}
