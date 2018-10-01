view: ebook_mapping {
  sql_table_name: uploads.EBOOK_MAP.EBOOK_MAP ;;

  dimension: source {
    type: string
    label: "Reader Source Abbreviation"
    description: "Which reader the event came from: MindTap Reader (MTR), MindTap Mobile Reader (MTM), or VitalSource Reader (VS)"
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: common_action {
    type: string
    sql: ${TABLE}."EVENT" ;;
    label: "Reader Action"
    description: "Reader actions as defined in the reader documentation on the wike at: /display/cap/eBook+Reader+Events"
  }

  dimension: action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
    label: "E-Book Reader specific action"
    description: "An action specific to the given e-book reader platform"
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
    description: "A category of e-book actions specific to the given e-book reader platform"
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
