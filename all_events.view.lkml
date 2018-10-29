view: all_events {
  view_label: "User Events"
  sql_table_name: ZPG.ALL_EVENTS_LOOKER ;;

  dimension: first_event_in_session {
    sql: ${TABLE}.event_no = 1 ;;
    type: yesno
  }

  dimension: event_0 {
    type: string
    sql: ${TABLE}."EVENT_0" ;;
    group_label: "Proceding five events"
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."EVENT_1" ;;
    group_label: "Proceding five events"
  }

  dimension: event_2 {
    type: string
    sql: ${TABLE}."EVENT_2" ;;
    group_label: "Proceding five events"
  }

  dimension: event_3 {
    type: string
    sql: ${TABLE}."EVENT_3" ;;
    group_label: "Proceding five events"
  }

  dimension: event_4 {
    type: string
    sql: ${TABLE}."EVENT_4" ;;
    group_label: "Proceding five events"
  }

  dimension: event_5 {
    type: string
    sql: ${TABLE}."EVENT_5" ;;
    group_label: "Proceding five events"
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
  }

#   dimension: has_coursekey {
#     type: yesno
#     sql: ${event_data}:course_key is not null ;;
#   }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
    primary_key: yes
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
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
      year,
      day_of_week
    ]
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
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
    value_format_name: id
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
    label: "# events"
    type: count
    drill_fields: [event_day_of_week, count]
  }

  measure: session_count {
    label: "# sessions"
    type: count_distinct
    sql: ${session_id} ;;
    drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
  }

  measure: user_count {
    label: "# people"
    type: count_distinct
    sql: ${user_sso_guid} ;;
    drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
  }

  measure: example_event_data {
    type: string
    sql: any_value(${event_data}) ;;
  }

  measure: latest_event_time {
    type: date_time
    sql: max(${event_raw}) ;;
  }

  measure: first_event_time {
    type: date_time
    sql:min(${event_raw}) ;;
  }

  measure: days_total {
    type: number
    sql: CEIL(datediff(hour, ${first_event_time}, ${latest_event_time})/24, 0) ;;
  }

  measure: days_active {
    type: count_distinct
    sql: ${event_date} ;;
  }

  measure: days_active_per_week {
    sql: LEAST(${days_active}, ${days_total}) / GREATEST(nullif((${days_total}/7), 0), 1) ;;
  }

  measure: days_since_last_login {
    type: number
    sql: datediff(hour, ${latest_event_time}, current_timestamp()) / 24 ;;
  }

  measure: events_per_session {
    sql: ${count} / nullif(${session_count}, 0) ;;
  }

  measure: recency {
    sql: -ROUND(${days_since_last_login}, 0)  ;;
  }
  measure: frequency {
    sql: ROUND(${days_active_per_week}, 1) ;;
  }
  measure: intensity {
    sql: ROUND(${events_per_session}, 1) ;;
  }

}
