view: ebook_mapping {
  sql_table_name: EBOOK_USAGE.EBOOK_MAPPING ;;

  dimension: action {
    type: string
    sql: ${TABLE}."ACTION" ;;
  }

  dimension: map {
    type: string
    sql: ${TABLE}."MAP" ;;
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
