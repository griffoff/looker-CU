view: all_event_actions {
  sql_table_name: zpg.ALL_EVENT_ACTIONS ;;

  dimension_group: earliest_event {
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
    sql: ${TABLE}."EARLIEST_EVENT_TIME" ;;
  }

  dimension: event_action_count {
    label: "# Unique Event Actions"
    type: number
    sql: ${TABLE}."EVENT_ACTION_COUNT" ;;
  }

  dimension: event_label_count {
    label: "# Unique Event Labels"
    type: number
    sql: ${TABLE}."EVENT_LABEL_COUNT" ;;
  }

  dimension: event_type_parsed {
    label: "Event Type"
    type: string
    sql: ${TABLE}."EVENT_TYPE_PARSED" ;;
  }

  dimension: event_action_parsed {
    label: "Event Action"
    type: string
    sql: ${TABLE}."EVENT_ACTION_PARSED" ;;
  }

  dimension: event_type {
    label: "Raw Original Event Type"
    hidden: yes
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
  }

  dimension: event_action {
    label: "Raw Original Event Action"
    hidden: yes
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event_action_ranking {
    description: "Event Action Ranking by # of Events"
    type: number
    sql: ${TABLE}."EVENT_ACTION_RANKING" ;;
  }

  measure: event_count {
    label: "# Events"
    type: sum
    sql: ${TABLE}."EVENT_COUNT" ;;
  }

  dimension: example_event_data {
    type: string
    sql: ${TABLE}."EXAMPLE_EVENT_DATA" ;;
  }

  dimension_group: latest_event {
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
    sql: ${TABLE}."LATEST_EVENT_TIME" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
