explore: student_discounts_dps {}

view: student_discounts_dps {
  derived_table: {
    sql: SELECT user_sso_guid, SUM(discount) AS discount, LISTAGG(isbn) AS isbn FROM prod.cu_user_analysis.student_discounts GROUP BY 1
      ;;
#   persist_for: "6 hours"
  sql_trigger_value: Select * from prod.cu_user_analysis.student_discounts   ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    primary_key: yes
  }

  dimension_group: api_call_time {
    type: time
    sql: ${TABLE}."API_CALL_TIME" ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}."ISBN" ;;
  }

  dimension: code_type {
    type: string
    sql: ${TABLE}."CODE_TYPE" ;;
  }

#   dimension: discount {
#     type: string
#     sql: COALESCE(${TABLE}."DISCOUNT", 0) ;;
#   }

  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
  }

  dimension: price_details {
    type: string
    sql: ${TABLE}."PRICE_DETAILS" ;;
  }

  dimension: discount {
    group_label: "Discount info"
    type: number
    sql: ${TABLE}.discount ;;
  }

  dimension: amount_to_upgrade {
    group_label: "Discount info"
    type: number
    sql: CASE WHEN (120 - COALESCE(${TABLE}."DISCOUNT", 0)) < 0 THEN 0 ELSE (120 - COALESCE(${TABLE}."DISCOUNT", 0)) END ;;
  }



  dimension: amount_to_upgrade_string {
    group_label: "Discount info"
    type: string
    sql: CASE
            WHEN ${amount_to_upgrade} = 0 THEN 'for free'
            WHEN ${amount_to_upgrade} > 50 THEN ' '
            ELSE CONCAT('for only $', ${amount_to_upgrade}::string) END;;
   }


#
#   dimension: amount_to_upgrade_tiers {
#     type: string
#     sql: CASE
#             WHEN ${amount_to_upgrade} = 0 THEN '0'
#             WHEN ${amount_to_upgrade} < 10 THEN '$0.01-$9.99'
#             WHEN ${amount_to_upgrade} < 20 THEN '$10.00-$19.99'
#             WHEN ${amount_to_upgrade} < 30 THEN '$20.00-$29.99'
#             WHEN ${amount_to_upgrade} < 40 THEN '$30.00-$39.99'
#             WHEN ${amount_to_upgrade} < 50 THEN '$40.00-$49.99'
#             ELSE 'over $50.00'
#             END
#             ;;
#   }

  set: marketing_fields {fields: [amount_to_upgrade_string, amount_to_upgrade, discount]}


  set: detail {
    fields: [
      user_sso_guid,
      api_call_time_time,
      isbn,
      code_type,
      discount,
      index,
      price_details
    ]
  }


}
