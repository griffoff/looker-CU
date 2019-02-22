view: discount_info {
  derived_table: {
    sql: SELECT
      di.user_sso_guid
      ,di.api_call_time
       ,value:isbn AS cu_isbn
      ,CASE WHEN d.value:price < 0 THEN 0 ELSE d.value:price END AS amount_to_upgrade
      ,d.value:productType AS cu_term_length
      ,d.value:cacheDate AS cache_dates
      ,di.price_details
  FROM prod.zpg.discount_info di
  FULL JOIN LATERAL FLATTEN(price_details:"prices", outer => True) d
  WHERE value:productType = 'CU-4month'
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension_group: api_call_time {
    type: time
    sql: ${TABLE}."API_CALL_TIME" ;;
  }

  dimension: cu_isbn {
    type: string
    sql: ${TABLE}."CU_ISBN" ;;
  }

  dimension: amount_to_upgrade {
    type: string
    sql: ${TABLE}."AMOUNT_TO_UPGRADE"::float ;;
  }

  dimension: cu_term_length {
    type: string
    sql: ${TABLE}."CU_TERM_LENGTH" ;;
  }

  dimension: cache_dates {
    type: string
    sql: ${TABLE}."CACHE_DATES" ;;
  }

  dimension: price_details {
    type: string
    sql: ${TABLE}."PRICE_DETAILS" ;;
  }


  dimension: amount_to_upgrade_string {
    type: string
    sql: CASE
            WHEN amount_to_upgrade = 0 THEN 'for free'
            ELSE CONCAT('for only $', ${amount_to_upgrade}) END;;
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
            ELSE 'over $50.00'
            END
            ;;
  }

  set: detail {
    fields: [
      user_sso_guid,
      api_call_time_time,
      cu_isbn,
      amount_to_upgrade,
      cu_term_length,
      cache_dates,
      price_details
    ]
  }
}
