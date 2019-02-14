view: looker_output_test_1000_20190214_final {
  sql_table_name: ZPG.LOOKER_OUTPUT_TEST_1000_20190214_FINAL ;;

  dimension: amount_to_upgrade {
    type: number
    sql: ${TABLE}."AMOUNT_TO_UPGRADE" ;;
    value_format_name: "usd_2"
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

  dimension: cache_dates {
    type: string
    sql: ${TABLE}."CACHE_DATES" ;;
  }

  dimension: cu_isbn {
    type: string
    sql: ${TABLE}."CU_ISBN" ;;
  }

  dimension: cu_term_length {
    type: string
    sql: ${TABLE}."CU_TERM_LENGTH" ;;
  }

  dimension: most_recent_platform_activation {
    type: string
    sql: ${TABLE}."MOST_RECENT_PLATFORM_ACTIVATION" ;;
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

  dimension: price_details {
    type: string
    sql: ${TABLE}."PRICE_DETAILS" ;;
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

#   dimension: user_guid {
#     type: string
#     sql: ${TABLE}."USER_GUID" ;;
#   }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
