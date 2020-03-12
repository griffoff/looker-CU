explore:  darien_demo{}

view: darien_demo {
  derived_table: {
    sql: select * from prod.cu_user_analysis.all_events limit 10
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
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

  dimension: original_user_sso_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_USER_SSO_GUID" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: load_metadata {
    type: string
    sql: ${TABLE}."LOAD_METADATA" ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
  }

  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
  }

  dimension: system_category {
    type: string
    sql: ${TABLE}."SYSTEM_CATEGORY" ;;
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
  }

  dimension: event_name_cu {
    type: string
    sql: ${TABLE}."EVENT_NAME_CU" ;;
  }

  dimension: event_name_courseware {
    type: string
    sql: ${TABLE}."EVENT_NAME_COURSEWARE" ;;
  }

  dimension: event_0 {
    type: string
    sql: ${TABLE}."EVENT_0" ;;
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."EVENT_1" ;;
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

  dimension: event_1_cu {
    type: string
    sql: ${TABLE}."EVENT_1_CU" ;;
  }

  dimension: event_1_courseware {
    type: string
    sql: ${TABLE}."EVENT_1_COURSEWARE" ;;
  }

  dimension: event_0_p {
    type: string
    sql: ${TABLE}."EVENT_0P" ;;
  }

  dimension: event_1_p {
    type: string
    sql: ${TABLE}."EVENT_1P" ;;
  }

  dimension: event_2_p {
    type: string
    sql: ${TABLE}."EVENT_2P" ;;
  }

  dimension: event_3_p {
    type: string
    sql: ${TABLE}."EVENT_3P" ;;
  }

  dimension: event_4_p {
    type: string
    sql: ${TABLE}."EVENT_4P" ;;
  }

  dimension: event_5_p {
    type: string
    sql: ${TABLE}."EVENT_5P" ;;
  }

  dimension: event_1_cu_p {
    type: string
    sql: ${TABLE}."EVENT_1_CU_P" ;;
  }

  dimension: event_1_courseware_p {
    type: string
    sql: ${TABLE}."EVENT_1_COURSEWARE_P" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: event_no {
    type: number
    sql: ${TABLE}."EVENT_NO" ;;
  }

  dimension: first_event_in_session {
    type: string
    sql: ${TABLE}."FIRST_EVENT_IN_SESSION" ;;
  }

  dimension: last_event_in_session {
    type: string
    sql: ${TABLE}."LAST_EVENT_IN_SESSION" ;;
  }

  dimension: collapsible {
    type: string
    sql: ${TABLE}."COLLAPSIBLE" ;;
  }

  dimension: duration_code {
    type: string
    sql: ${TABLE}."DURATION_CODE" ;;
  }

  dimension: new_events {
    type: number
    sql: ${TABLE}."NEW_EVENTS" ;;
  }

  dimension: most_recent_five_events {
    type: number
    sql: ${TABLE}."MOST_RECENT_FIVE_EVENTS" ;;
  }

  dimension: rebuild_session {
    type: number
    sql: ${TABLE}."REBUILD_SESSION" ;;
  }

  set: detail {
    fields: [
      event_id,
      platform_environment,
      product_platform,
      user_environment,
      original_user_sso_guid,
      user_sso_guid,
      load_metadata,
      event_action,
      event_time_time,
      event_type,
      local_time_time,
      event_data,
      system_category,
      event_name,
      event_name_cu,
      event_name_courseware,
      event_0,
      event_1,
      event_2,
      event_3,
      event_4,
      event_5,
      event_1_cu,
      event_1_courseware,
      event_0_p,
      event_1_p,
      event_2_p,
      event_3_p,
      event_4_p,
      event_5_p,
      event_1_cu_p,
      event_1_courseware_p,
      subscription_state,
      session_id,
      event_no,
      first_event_in_session,
      last_event_in_session,
      collapsible,
      duration_code,
      new_events,
      most_recent_five_events,
      rebuild_session
    ]
  }
}
