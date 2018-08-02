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

  dimension: ip {
    type:  string
    sql:  ${TABLE}."IP_ADDRESS" ;;
  }


  measure: user_count_distinct {
    type: count_distinct
    sql:  ${user_sso_guid} ;;
  }

  measure: ip_count_distinct {
    type:  count_distinct
    sql:  ${ip} ;;
  }

measure: count {
  type:  count
}

}

# Per day how many IP address is each user using
# Top ten users with highest number of IP address per day, per week, per month
