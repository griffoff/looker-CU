view: client_activity_event_prod {
#   sql_table_name: CAP_EVENTING.PROD.CLIENT_ACTIVITY_EVENT;;
derived_table: {
  sql: with prim_map AS(
        SELECT *,LEAD(event_time) OVER (PARTITION BY primary_guid ORDER BY event_time ASC) IS NULL AS latest from prod.unlimited.VW_PARTNER_TO_PRIMARY_USER_GUID
      )
        Select cs.*,COALESCE(m.primary_guid, cs.user_sso_guid) AS merged_guid from CAP_EVENTING.PROD.CLIENT_ACTIVITY_EVENT cs
        LEFT JOIN prim_map m on cs.user_sso_guid = m.partner_guid
        ;;
}


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: merged_guid {
    type: string
#     sql: ${TABLE}."merged_guid" ;;
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
    hidden: yes
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden: yes
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

  dimension: load_sidebar {
    label: "Remove Load Sidebar Events"
    sql: CASE WHEN ${event_action} like 'LOAD' and ${event_category} like 'SIDEBAR'
              THEN 'Yes' ELSE 'No'END;;
    type: string
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
    hidden: yes
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
