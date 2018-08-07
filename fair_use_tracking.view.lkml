view: fair_use_tracking {
  derived_table: {
    sql:
WITH logins AS (
    SELECT DISTINCT *,
    30 AS threshold_mins
    FROM unlimited.raw_fair_use_logins
//    WHERE user_sso_guid = '87e8176e75d1ecf2:177c5c08:1613f8bd2cb:1b61'
)

,previous_login AS (
      -- Sets new field 'ip_change' to 1 if a user changes IP addresses
     SELECT
       l._hash,
       l.user_sso_guid as guid,
       l.cmp_session_id,
       l.ip_address,
       l.local_time AS session_start_time,
       LAG(array_construct(l.ip_address, l.local_time), 1) OVER (PARTITION BY l.user_sso_guid ORDER BY l.local_time) AS lag_login,
       DATEDIFF(minute, lag_login[1], l.local_time) AS login_delta_mins,
       CASE WHEN lag_login[0] <> l.ip_address AND login_delta_mins < threshold_mins THEN 1
       ELSE NULL END AS ip_change
     FROM logins l
  )

  ,previous_logins_aggregate AS
  (
  SELECT
    l._hash,
    COUNT(DISTINCT pl.ip_address) AS unique_ips
  FROM logins l
  JOIN  logins pl
        ON l.user_sso_guid = pl.user_sso_guid
        AND  DATEDIFF(minute, pl.local_time, l.local_time) BETWEEN 0 and l.threshold_mins
  GROUP BY 1
  )

  SELECT
    pl.*,
    pla.unique_ips
  FROM previous_login pl
  JOIN previous_logins_aggregate pla
    ON pl._hash = pla._hash ;;

persist_for: "24 hours"
}

dimension:  _hash {
  primary_key: yes
}
  dimension:  guid {}
  dimension:  cmp_session_id {  }
  dimension:  ip_address {}
  dimension_group:  session_start_time {
     timeframes: [date, time, time_of_day, month, year]
     type: time
  }
  dimension:  lag_login {}
  dimension:  ip_change {}
  dimension:  unique_ips {}

  dimension: unique_ip_bucket {
    type:  tier
    tiers: [1, 2, 3, 4, 5]
    style:  relational
    sql:  ${unique_ips} ;;
  }

  measure: count {
    type: count
  }

  measure: count_users {
    type:  count_distinct
    sql: ${guid} ;;
  }




}
