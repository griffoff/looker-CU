explore: term_platform_states {}

view: term_platform_states {
  derived_table: {
    sql: SELECT * FROM dev.zkc.platform_semesters
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: governmentdefinedacademicterm {
    type: string
    sql: ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ;;
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: subscriber_status {
    type: string
    sql: ${TABLE}."SUBSCRIBER_STATUS" ;;
  }

  dimension: unique_users {
    type: number
    sql: ${TABLE}."UNIQUE_USERS" ;;
  }

  set: detail {
    fields: [governmentdefinedacademicterm, product_type, subscriber_status, unique_users]
  }
}
