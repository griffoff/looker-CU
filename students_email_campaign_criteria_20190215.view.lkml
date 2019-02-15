view: students_email_campaign_criteria {
  sql_table_name: ZPG.STUDENTS_EMAIL_CAMPAIGN_CRITERIA_20190215 ;;

  dimension: activated_26_30_total {
    type: string
    sql: ${TABLE}."ACTIVATED_26_30_TOTAL" ;;
  }

  dimension: activated_past_25_total {
    type: string
    sql: ${TABLE}."ACTIVATED_PAST_25_TOTAL" ;;
  }

  dimension: ala_cart_activations {
    type: string
    sql: ${TABLE}."ALA_CART_ACTIVATIONS" ;;
  }

  dimension_group: earliest_activation {
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
    sql: ${TABLE}."EARLIEST_ACTIVATION_DATE" ;;
  }

  dimension: elic_or_slua_activations {
    type: string
    sql: ${TABLE}."ELIC_OR_SLUA_ACTIVATIONS" ;;
  }

  dimension: most_recent_platform_activation {
    type: string
    sql: ${TABLE}."MOST_RECENT_PLATFORM_ACTIVATION" ;;
  }

  dimension: number_activation_dates {
    type: string
    sql: ${TABLE}."NUMBER_ACTIVATION_DATES" ;;
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

  dimension: shadow_guid {
    type: string
    sql: ${TABLE}."SHADOW_GUID" ;;
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

  dimension_group: subscription_start {
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
    sql: ${TABLE}."SUBSCRIPTION_START" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: user_guid {
    type: string
    sql: ${TABLE}."USER_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
