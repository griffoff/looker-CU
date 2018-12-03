# include: "/core/common.lkml"
view: all_events {
  view_label: "Events"
  sql_table_name: cu_user_analysis.ALL_EVENTS ;;

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    label: "User SSO GUID"
    hidden: yes
  }

  dimension:search_outcome{
    group_label: "search"
    sql:  event_data:search_outcome;;
  }


  dimension: event_action {
    group_label: "Event Hierarchy"
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
    label: "Event action"
    description: "A classification of event within the hierachy of events beneath event type and above event name i.e. 'OLR Enrollment'"
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
    primary_key: yes
    label: "Event ID"
    description: "A unique identifier given to each event"
    hidden: yes
  }

  dimension: event_name {
    group_label: "Event Hierarchy"
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
    label: "Event name"
    description: "The lowest level in hierarchy of event classification below event action. Can be asscoaited with describing a user action in plain english i.e. 'Buy Now Button Click'"
  }

  dimension_group: local {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year]
    sql: ${TABLE}."LOCAL_TIME" ;;
    label: "Local Time"
    description: "Components of the events local timestamp"
  }

  dimension: session_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SESSION_ID" ;;
    label: "Session ID"
    description: "A unique identfier given to each session"
    hidden: yes
  }

  dimension: system_category {
    type: string
    sql: ${TABLE}."SYSTEM_CATEGORY" ;;
    label: "System category"
    description: " Categorizes events by system eg: Cengage Unlimited, Registrations"
  }

  measure: count {
    label: "# events"
    type: count
#     drill_fields: [event_day_of_week, count]
    description: "Measure for counting events (drill fields)"
  }

  measure: session_count {
    label: "# sessions"
    type: count_distinct
    sql: ${session_id} ;;
#     drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
    description: "Measure for counting unique sessions (drill fields)"
  }


 }
