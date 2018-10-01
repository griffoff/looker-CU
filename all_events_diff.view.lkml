view: all_events_diff {
  view_label: "User Events Categorized"
  sql_table_name: ZPG.ALL_EVENTS_DIFF{% parameter event_type %};;

  parameter: event_type {
    label: "Select type of events to view"
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
  }

  #sql_table_name: ZPG.ALL_EVENTS_DIFF ;;

  dimension: event_id {primary_key:yes hidden:yes}

  dimension: first_event {
    label: "First event in a session"
    type: yesno
  }

  dimension: last_event {
    type: yesno
    hidden: yes
  }

  dimension: event_0 {
    type: string
    label: "First Event"
    sql: ${TABLE}."DIFF_EVENT_0" ;;
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_1" ;;
  }

  dimension: event_2 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_2" ;;
  }

  dimension: event_3 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_3" ;;
  }

  dimension: event_4 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_4" ;;
  }

  dimension: event_5 {
    type: string
    sql: ${TABLE}."DIFF_EVENT_5" ;;
  }

}
