
view: credentials_used {
  sql_table_name: IAM.PROD.CREDENTIALS_USED;;

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

  dimension: is_under_18 {
    type: yesno
    sql: ${TABLE}."IS_UNDER_18" ;;
  }

  dimension: message_format_version {
    type: string
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: success {
    type: yesno
    sql: ${TABLE}."SUCCESS" ;;
  }

  dimension: use_type {
    type: string
    sql: ${TABLE}."USE_TYPE" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: user_count {
    label: "# User Logins"
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
