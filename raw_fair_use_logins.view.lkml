view: raw_fair_use_logins {
  sql_table_name: UNLIMITED.RAW_FAIR_USE_LOGINS ;;

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
  }

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
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: cmp_session_id {
    type: string
    sql: ${TABLE}."CMP_SESSION_ID" ;;
  }

  dimension: device {
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  dimension: ga_session_id {
    type: string
    sql: ${TABLE}."GA_SESSION_ID" ;;
  }

  dimension: ip_address {
    type: string
    sql: ${TABLE}."IP_ADDRESS" ;;
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

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
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

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: distinct_users {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  measure: device_count {
    type: count_distinct
    sql:   ${TABLE}."DEVICE";;
  }
}
