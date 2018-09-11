view: instiution_star_rating {
  sql_table_name: CU.INSTIUTION_STAR_RATING ;;

  dimension: entity_ {
    type: number
    sql: ${TABLE}."ENTITY_" ;;
  }

  dimension: institution {
    type: string
    sql: ${TABLE}."INSTITUTION" ;;
  }

  dimension: star_rating_2_nd_pass {
    type: number
    sql: ${TABLE}."STAR_RATING_2_ND_PASS" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
