include: "all_events.view"

view: all_events_dev {
  sql_table_name: zpg.all_events ;;
 extends: [all_events]


  dimension: event_duration {
    type:  number
    sql: event_data:event_duration  / (60 * 60 * 24) ;;
    value_format_name: duration_hms
    label: "Event duration"
    description: "An event's duration calculated for events such as reading, viewing, and app usage, but not given to individual click events"
  }

    dimension: time_to_next_event {
    type:  number
    sql: event_data:time_until_next_event  / (60 * 60 * 24) ;;
    value_format_name: duration_hms
    label: "Event duration (time to next event)"
    description: "An event's duration calculated for all event types as the time until the next event is fired"
  }

  }
