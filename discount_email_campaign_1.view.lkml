explore: discount_email_campaign_1 {}

view: discount_email_campaign_1 {
  sql_table_name: ZPG.DISCOUNT_EMAIL_CAMPAIGN_1 ;;

  dimension: activation_code {
    type: string
    sql: ${TABLE}."ACTIVATION_CODE" ;;
  }

  dimension_group: activation {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ACTIVATION_DATE" ;;
  }

  dimension: amount_to_upgrade {
    type: number
    sql: ${TABLE}."AMOUNT_TO_UPGRADE" ;;
  }

  dimension_group: api_call {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."API_CALL_TIME" ;;
  }

  dimension: calculation_date {
    type: string
    sql: ${TABLE}."CALCULATION_DATE" ;;
  }

  dimension: code_type_list {
    type: string
    sql: ${TABLE}."CODE_TYPE_LIST" ;;
  }

  dimension: cu_subscription {
    type: string
    sql: ${TABLE}."CU_SUBSCRIPTION" ;;
  }

  dimension: discount_total {
    type: number
    sql: ${TABLE}."DISCOUNT_TOTAL" ;;
  }

  dimension: discounted_isbn_list {
    type: string
    sql: ${TABLE}."DISCOUNTED_ISBN_LIST" ;;
  }

  dimension: discounts_list {
    type: string
    sql: ${TABLE}."DISCOUNTS_LIST" ;;
  }

  dimension: most_recent_platform_activation  {
    type: string
    sql: ${TABLE}."MOST_RECENT_PLATFORM_ACTIVATION" ;;
  }

  dimension: number_of_discounts {
    type: string
    sql: ${TABLE}."NUMBER_OF_DISCOUNTS" ;;
  }

  dimension: oldest_activation_code {
    type: string
    sql: ${TABLE}."OLDEST_ACTIVATION_CODE" ;;
  }

  dimension_group: oldest_activation {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."OLDEST_ACTIVATION_DATE" ;;
  }

  dimension_group: subscription_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SUBSCRIPTION_END" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
