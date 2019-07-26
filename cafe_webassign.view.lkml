explore: cafe_webassign {}
view: cafe_webassign {
derived_table: {
  sql: with prim_map AS(
        SELECT *,LEAD(event_time) OVER (PARTITION BY primary_guid ORDER BY event_time ASC) IS NULL AS latest from prod.unlimited.VW_PARTNER_TO_PRIMARY_USER_GUID
      ), mapped_cap as (
        Select cs.*,COALESCE(m.primary_guid, cs.user_sso_guid) AS merged_guid
        ,CONCAT(event_action,CONCAT(' - ',event_category)) as event_name
        from CAP_EVENTING.PROD.WA_CLIENT_ACTIVITY_EVENT cs
        LEFT JOIN prim_map m on cs.user_sso_guid = m.partner_guid
      ) Select
        CASE WHEN event_name ilike 'Load%sidebar' THEN 'Yes' ELSE 'No' END AS is_load_sidebar
        ,Rank() over (partition by user_sso_guid order by event_time) as event_rank
        ,LAG(session_id,1) OVER (PARTITION BY user_sso_guid,session_id ORDER BY event_time) AS lag_session
        ,LEAD(event_name, 1) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id,event_name) AS event_1
        ,LEAD(event_name, 2) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_2
        ,LEAD(event_name, 3) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_3
        ,LEAD(event_name, 4) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_4
        ,LEAD(event_name, 5) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_5
        ,* from  mapped_cap
        ;;
  persist_for: "6 hours"
}


measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: lag_session {
  hidden: yes
}

dimension: event_rank {}

dimension: is_first_session {
  sql: CASE WHEN ${lag_session} IS NULL THEN 'Yes' ELSE 'No' END ;;
}

dimension: merged_guid {
  type: string
#     sql: ${TABLE}."merged_guid" ;;
}

dimension: event_name {
  label: "event_0"
  group_label: "Succeeding five events"
}

dimension: event_1 {
  group_label: "Succeeding five events"
  type: string
}

dimension: event_2 {
  type: string
  group_label: "Succeeding five events"
}

dimension: event_3 {
  type: string
  group_label: "Succeeding five events"
}

dimension: event_4 {
  type: string
  group_label: "Succeeding five events"
}

dimension: event_5 {
  type: string
  group_label: "Succeeding five events"
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
  hidden: yes
}

dimension: message_type {
  type: string
  sql: ${TABLE}."MESSAGE_TYPE" ;;
  hidden: yes
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

dimension: is_load_sidebar {
  label: "Is Load Sidebar Event"
  description: "Make this filtered to 'No' to remove LOAD SIDEBAR events"
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
