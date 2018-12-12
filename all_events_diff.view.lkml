view: all_events_diff {
  view_label: "Student Events Categorized"
  sql_table_name: CU_USER_ANALYSIS.ALL_EVENTS_DIFF{% parameter event_type %};;

  parameter: event_type {
    label: "Select type of events to view"
    description: "A paramter for selecting the type of succeding events you want to analyze "
    type: unquoted
    default_value: ""
    allowed_value: {
      label: "Next different event"
      value: ""
    }
    allowed_value: {
      label: "Cengage Unlimited Dashboard"
      value: "_CU"
    }
    allowed_value: {
      label: "Courseware"
      value: "_COURSEWARE"
    }
    allowed_value: {
      label: "Cengage Unlimited Subscriptions"
      value: "_SUBSCRIPTION"
    }
    allowed_value: {
      label: "e-Book usage"
      value: "_EBOOK"
    }
    allowed_value: {
      label: "Dashboard Search"
      value: "_SEARCH"
    }
  }

  #sql_table_name: ZPG.ALL_EVENTS_DIFF ;;

  dimension: event_id {primary_key:yes hidden:yes}

  dimension: first_event_in_session {
    type: yesno
    sql: ${TABLE}.event_no = 1 ;;
  }
  dimension: event_0 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_0" ;;
    label:  "Current event"
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_1" ;;
    label: "Event 1"
    description: "The first succeding event from the current event with a different event name than the current event"
  }

  dimension: event_2 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_2" ;;
    label: "Event 2"
    description: "The second succeding event from the current event with a different event name than event 1"
  }

  dimension: event_3 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_3" ;;
    label: "Event 3"
    description: "The third succeding event from the current event with a different event name than event 2"
  }

  dimension: event_4 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_4" ;;
    label: "Event 4"
    description: "The fourth succeding event from the current event with a different event name than event 3"
  }

  dimension: event_5 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_5" ;;
    label: "Event 5"
    description: "The fifth succeding event from the current event with a different event name than event 4"
  }

}
