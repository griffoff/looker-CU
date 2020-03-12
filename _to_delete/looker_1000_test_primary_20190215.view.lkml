view: looker_1000_test_primary_20190215 {
  sql_table_name: ZPG.LOOKER_1000_TEST_PRIMARY_20190215 ;;

  dimension: amount_to_upgrade {
    type: number
    sql: ${TABLE}."AMOUNT_TO_UPGRADE" ;;
    value_format_name: "usd"
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

  dimension: user_guid {
    type: string
    sql: ${TABLE}."USER_GUID" ;;
  }

  dimension: user_sso_guid {
    type: string
    hidden: yes
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: amount_to_upgrade_string {
    type: string
    sql: CASE
            WHEN amount_to_upgrade = 0 THEN 'for free'
            ELSE CONCAT('for only $', ${amount_to_upgrade}::decimal(4,2)) END;;
  }

  dimension: amount_to_upgrade_tiers {
    type: string
    sql: CASE
            WHEN ${amount_to_upgrade} = 0 THEN '0'
            WHEN ${amount_to_upgrade} < 10 THEN '$0.01-$9.99'
            WHEN ${amount_to_upgrade} < 20 THEN '$10.00-$19.99'
            WHEN ${amount_to_upgrade} < 30 THEN '$20.00-$29.99'
            WHEN ${amount_to_upgrade} < 40 THEN '$30.00-$39.99'
            WHEN ${amount_to_upgrade} < 50 THEN '$40.00-$49.99'
            ELSE 'Huah'
            END
            ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
