explore: locker_funnel {}

view: locker_funnel {
  derived_table: {
    sql: SELECT * FROM prod.zpg.locker_funnel
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: sum {
    type: sum
    sql: ${student_count} ;;
    drill_fields: [detail*]
  }

  dimension: funnel_category {
    type: string
    sql: ${TABLE}."FUNNEL_CATEGORY" ;;
  }

  dimension: student_count {
    type: number
    sql: ${TABLE}."STUDENT_COUNT" ;;
  }

  set: detail {
    fields: [funnel_category, student_count]
  }
}
