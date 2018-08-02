view: raw_fair_use_logins_distinct_w {
  derived_table: {
    sql: SELECT
      TRUNC(LOCAL_TIME, 'MONTH') AS month_,
      TRUNC(LOCAL_TIME, 'WEEK') AS week,
      TRUNC(LOCAL_TIME, 'DAY') AS day,
      COUNT(DISTINCT user_sso_guid) AS daily_sessions
      FROM unlimited.raw_fair_use_logins
      GROUP BY 1, 2, 3 ;;
  }

  dimension: month {
    type:  date_month
    sql: ${TABLE}.month_ ;;
  }

  measure:  count {
    type: count_distinct
    sql:  ${TABLE}.daily_sessions ;;
  }
}
