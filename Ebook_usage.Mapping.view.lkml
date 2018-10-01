view: ebook_mapping {
  sql_table_name: uploads.EBOOK_MAP.EBOOK_MAP ;;

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: common_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}."EVENT" ;;
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
