view: raw_fair_use_logins_distinct {
  sql_table_name: UNLIMITED.RAW_FAIR_USE_LOGINS ;;

  dimension_group: local {
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
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql:  ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count_distinct {
    type: count_distinct
    sql:  ${user_sso_guid} ;;
  }

}
