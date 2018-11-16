include: "/core/common.lkml"
view: all_events {
  view_label: "User Events"
  sql_table_name: ZPG.ALL_EVENTS ;;

  dimension: iac_isbn {
    sql: ${event_data}:iac_isbn ;;
  }

  dimension: event_duration {
    type:  number
    sql: event_data:event_duration  / (60 * 60 * 24) ;;
    value_format_name: duration_hms
    label: "Event duration"
    description: "An event's duration calculated for events such as reading, viewing, and app usage, but not given to individual click events"
  }

  dimension: first_event_in_session {
    sql: ${TABLE}.event_no = 1 ;;
    type: yesno
    label: "First event in session"
    description: "TRUE if the event is the first in a session and FALSE otherwise"
  }

  dimension: event_0 {
    type: string
    sql: ${TABLE}."EVENT_0" ;;
    group_label: "Proceding five events"
    label: "Current event"
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."EVENT_1" ;;
    group_label: "Proceding five events"
    label: "Event 1"
    description: "The event one prior to the current event"
  }

  dimension: event_2 {
    type: string
    sql: ${TABLE}."EVENT_2" ;;
    group_label: "Proceding five events"
    label: "Event 2"
    description: "The event two prior to the current event"
  }

  dimension: event_3 {
    type: string
    sql: ${TABLE}."EVENT_3" ;;
    group_label: "Proceding five events"
    label: "Event 3"
    description: "The event three prior to the current event"
  }

  dimension: event_4 {
    type: string
    sql: ${TABLE}."EVENT_4" ;;
    group_label: "Proceding five events"
    label: "Event 4"
    description: "The event four prior to the current event"
  }

  dimension: event_5 {
    type: string
    sql: ${TABLE}."EVENT_5" ;;
    group_label: "Proceding five events"
    label: "Event 5"
    description: "The event five prior to the current event"
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
    label: "Event action"
    description: "A classification of event within the hierachy of events beneath event type and above event name i.e. 'OLR Enrollment'"
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
    label: "Event data"
    description: "Data associated with a given event in a json format containing information like page number, URL, coursekeys, device information, etc."
  }

#   dimension: has_coursekey {
#     type: yesno
#     sql: ${event_data}:course_key is not null ;;
#   }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
    primary_key: yes
    label: "Event ID"
    description: "A unique identifier given to each event"
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
    label: "Event name"
    description: "The lowest level in hierarchy of event classification below event action. Can be asscoaited with describing a user action in plain english i.e. 'Buy Now Button Click'"
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
      day_of_week,
      hour_of_day
    ]
    sql: ${TABLE}."EVENT_TIME" ;;
    label: "Event timestamp UTC"
    description: "Components of the events timestamp stored in TZ format"
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
    label: "Event type"
    description: "The highest level in the hierarchy of event classicfication above event action"
  }

  dimension: load_metadata {
    type: string
    sql: ${TABLE}."LOAD_METADATA" ;;
    label: "Load metadata"
    description: "Data related to the underlying table refresh (_HASH, LDTS, _RSRC)"
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
    label: "Local Time"
    description: "Components of the events local timestamp"
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
    label: "Platform environment"
    description: "Development platofrm i.e. production, staging, development, etc."
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
    label: "Product platform"
    description: "I.e. VitalSource, CU DASHBOARD, MT4, MT3, SubscriptionService, cares-dashboard, olr"
  }

  dimension: session_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SESSION_ID" ;;
    label: "Session ID"
    description: "A unique identfier given to each session"
  }

  dimension: system_category {
    type: string
    sql: ${TABLE}."SYSTEM_CATEGORY" ;;
    label: "System category"
    description: ""
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
    label: "User environment"
    description: "Development platofrm i.e. production, staging, development, etc."
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    label: "User SSO GUID"
  }

  measure: count {
    label: "# events"
    type: count
    drill_fields: [event_day_of_week, count]
    description: "Measure for counting events (drill fields)"
  }

  measure: session_count {
    label: "# sessions"
    type: count_distinct
    sql: ${session_id} ;;
    drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
    description: "Measure for counting unique sessions (drill fields)"
  }

  measure: user_count {
    label: "# people"
    type: count_distinct
    sql: ${user_sso_guid} ;;
    drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
    description: "Measure for counting unique users (drill fields)"
  }

  measure: example_event_data {
    type: string
    sql: any_value(${event_data}) ;;
    label: "Example event data"
    description: "Randomly selects some event data from the event data json as an example of the type of data tracked with the given event type"
  }

  measure: latest_event_time {
    type: date_time
    sql: max(${event_raw}) ;;
    label: "Latest event time"
    description: "Latest event time for the currently querried subset of population (i.e. filterable)"
  }

  measure: first_event_time {
    type: date_time
    sql:min(${event_raw}) ;;
    label: "First event time"
    description: "First event time for the currently querried subset of population (i.e. filterable)"
  }

  measure: days_total {
    type: number
    sql: CEIL(datediff(hour, ${first_event_time}, ${latest_event_time})/24, 0) ;;
    label: "Total number of days"
    description: "Total number of days between the first event time and latest event time over the currently querried subset of population (i.e. filterable)"
  }

  measure: days_active {
    type: count_distinct
    sql: ${event_date} ;;
    label: "Days active"
    description: "Count of the unique dates"
  }

  measure: days_active_per_week {
    sql: LEAST(${days_active}, ${days_total}) / GREATEST(nullif((${days_total}/7), 0), 1) ;;
    label: "Days active per week"
    description: "Average days active per week"
  }

  measure: days_since_last_login {
    type: number
    sql: datediff(hour, ${latest_event_time}, current_timestamp()) / 24 ;;
    label: "Days since last login"
    description: "Calculated as number of days since last login"
  }

  measure: events_per_session {
    sql: ${count} / nullif(${session_count}, 0) ;;
    label: "Events per session"
    description: "Calculated as the number of events per session"
  }

  measure: recency {
    sql: -ROUND(${days_since_last_login}, 0)  ;;
    label: "Recency"
    description: "Calculated as the number of days since the last login"
  }
  measure: frequency {
    sql: ROUND(${days_active_per_week}, 1) ;;
    label: "Frequency"
    description: "Calculated as the average number of days active per week"
  }
  measure: intensity {
    sql: ROUND(${events_per_session}, 1) ;;
    label: "Intensity"
    description: "Calculated as the average number of events per session"
  }

  measure: sum_of_event_duration{
    type: sum
    sql: event_data:event_duration  / (60 * 60 * 24) ;;
    value_format_name: duration_dhm
    label: "Sum of event durations"
    description: "Calcualted as the sum of event durations grouped by selected dimensions"
  }

  measure: course_ware_duration {
    type: sum
    sql: CASE WHEN event_data:course_key IS NOT NULL THEN event_data:event_duration / (60 * 60 * 24) END   ;;
    value_format_name: duration_dhm
  }

  measure: non_courseware_duration {
    type: sum
    sql: CASE WHEN event_data:course_key IS NULL THEN event_data:event_duration / (60 * 60 * 24) END  ;;
    value_format_name: duration_dhm
  }

}
