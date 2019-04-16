view: client_activity_event_prod {
  sql_table_name: Select * from CAP_EVENTING.PROD.CLIENT_ACTIVITY_EVENT;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: event_duration {
    type: number
    sql: ${TABLE}."EVENT_DURATION" ;;
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: product_environment {
    type: string
    sql: ${TABLE}."PRODUCT_ENVIRONMENT" ;;
  }

  dimension: user_platform {
    type: string
    sql: ${TABLE}."USER_PLATFORM" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: host_platform {
    type: string
    sql: ${TABLE}."HOST_PLATFORM" ;;
  }

  dimension: host_environment {
    type: string
    sql: ${TABLE}."HOST_ENVIRONMENT" ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: event_id {
    type: string
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: event_uri {
    type: string
    sql: ${TABLE}."EVENT_URI" ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }

  set: detail {
    fields: [
      _ldts_time,
      _rsrc,
      message_format_version,
      message_type,
      event_time_time,
      event_duration,
      event_category,
      event_action,
      product_platform,
      product_environment,
      user_platform,
      user_environment,
      host_platform,
      host_environment,
      session_id,
      event_id,
      user_sso_guid,
      event_uri,
      tags
    ]
  }
}
