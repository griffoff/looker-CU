view: ebook_mapping {
  sql_table_name: uploads.EBOOK_USAGE.EBOOK_MAPPING ;;

  dimension: action {
    type: string
    sql: ${TABLE}."ACTION" ;;
  }

  dimension: common_action {
    type: string
    sql: COALESCE(${TABLE}."MAP", ${ebook_usage_actions.event_action}) ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
