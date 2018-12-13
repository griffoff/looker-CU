view: ipm_browser_event {
  sql_table_name: PROD.IPM_BROWSER_EVENT ;;

  dimension_group: _ldts {
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
    sql: ${TABLE}."_LDTS" ;;
    hidden: yes
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden: yes
  }

  dimension: click_id {
    type: string
    sql: ${TABLE}."CLICK_ID" ;;
  }

  dimension: click_title {
    type: string
    sql: ${TABLE}."CLICK_TITLE" ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
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

  dimension: message_format_version {
    type: string
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_id {
    type: string
    sql: ${TABLE}."MESSAGE_ID" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_platform {
    type: string
    sql: ${TABLE}."USER_PLATFORM" ;;
  }

  dimension: user_platform_environment {
    type: string
    sql: ${TABLE}."USER_PLATFORM_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
