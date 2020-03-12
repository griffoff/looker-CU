explore: ebook_opens {}

view: ebook_opens {
    sql_table_name: prod.unlimited.cu_ebook_usage ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_eisbns {
    type: count_distinct
    sql: ${eisbn} ;;
    drill_fields: [detail*]
  }

  measure: count_uers {
    type: count_distinct
    sql: ${user_sso_guid} ;;
    drill_fields: [detail*]
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: institution_id {
    type: string
    sql: ${TABLE}."INSTITUTION_ID" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: eisbn {
    type: string
    sql: ${TABLE}."EISBN" ;;
  }

  dimension: activity_date {
    type: date
    sql: ${TABLE}."ACTIVITY_DATE" ;;
  }

  dimension: activity_count {
    type: number
    sql: ${TABLE}."ACTIVITY_COUNT" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  set: detail {
    fields: [
      contract_id,
      user_sso_guid,
      institution_id,
      subscription_state,
      eisbn,
      activity_date,
      activity_count,
      source
    ]
  }
}
