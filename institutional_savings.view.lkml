explore: institutional_savings {}
view: institutional_savings {
  derived_table: {
    sql: Select * from UPLOADS.cu.institution_savings
      ;;
  }
  set: marketing_fields {fields:[student_savings_courseware_ebook_chegg_,average_savings_per_subscriber_who_saved]}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}."ENTITY_NO" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: on_map_entity_list_ {
    type: string
    sql: ${TABLE}."ON_MAP_ENTITY_LIST_" ;;
  }

  dimension: subscribers {
    type: string
    sql: ${TABLE}."SUBSCRIBERS" ;;
  }

  dimension: student_savings_courseware_ebook_chegg_ {
    label: "Institutional Savings"
    description: "Total Savings based on courseware,ebook & chegg calculations done by strategy team. Based off CU subscriptions till Spring 2019 semester. Please Note - This is ONE TIME Feed "
    type: string
    sql: ${TABLE}."STUDENT_SAVINGS_COURSEWARE_EBOOK_CHEGG_" ;;
  }

  dimension: average_savings_per_subscription {
    type: string
    sql: ${TABLE}."AVERAGE_SAVINGS_PER_SUBSCRIPTION" ;;
  }

  dimension: average_savings_per_subscriber_who_saved {
    type: string
    sql: ${TABLE}."AVERAGE_SAVINGS_PER_SUBSCRIBER_WHO_SAVED" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      entity_no,
      institution_nm,
      on_map_entity_list_,
      subscribers,
      student_savings_courseware_ebook_chegg_,
      average_savings_per_subscription,
      average_savings_per_subscriber_who_saved,
      _fivetran_synced_time
    ]
  }
}
