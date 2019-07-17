explore:  eligible_discount_students_details_20190717 {}

view: eligible_discount_students_details_20190717 {
  derived_table: {
    sql: SELECT * FROM dev.discount_email_campaign_fall2020.eligible_discount_students_details
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    primary_key: yes
    hidden: yes
  }

  dimension_group: api_call_time {
    group_label: "Discount Info"
    label: "Last updated"
    type: time
   timeframes: [date]
    sql: ${TABLE}."API_CALL_TIME" ;;
    hidden: no
  }

  dimension: isbn {
    group_label: "Discount Info"
    label: "ISBN producing discount"
    type: string
    sql: ${TABLE}."ISBN" ;;
  }

  dimension: code_type {
    group_label: "Discount Info"
    type: string
    sql: ${TABLE}."CODE_TYPE" ;;
  }

  dimension: discount {
    group_label: "Discount Info"
    type: number
    sql: COALESCE( ${TABLE}."DISCOUNT", 0)::float ;;
    value_format_name: usd
  }

  dimension: amount_to_upgrade {
    group_label: "Discount Info"
    label: "Upgrade amount"
    description: "Amount to upgrade to one term Cengage Unlimited subscription"
    type: number
    sql:  CASE WHEN ((120 - ${discount}) < 0) THEN 0 ELSE (120 - ${discount}) END;;
    value_format_name: usd
  }

  dimension: amount_to_upgrade_string {
    group_label: "Discount Info"
    label: "Upgrade amount string"
    description: "Amount to upgrade to one term Cengage Unlimited subscription"
    type: string
    sql: CASE WHEN ${amount_to_upgrade} <= 0 THEN "Free upgrade!" ELSE ${amount_to_upgrade}::STRING ;;
    hidden: yes
  }

  dimension: has_discount {
    group_label: "Discount Info"
    label: "Has a discount "
    type: yesno
    sql:  ${amount_to_upgrade} < 120;;
    value_format_name: usd
  }



  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
  }

  dimension: price_details {
    type: string
    sql: ${TABLE}."PRICE_DETAILS" ;;
  }

  set: detail {
    fields: [
      user_sso_guid,
      api_call_time_date,
      isbn,
      code_type,
      discount,
      index,
      price_details
    ]
  }
}
