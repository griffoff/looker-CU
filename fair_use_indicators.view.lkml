view: fair_use_indicators {
  derived_table: {
    sql:
    WITH multiple_ips AS (
  SELECT
    fair_use_tracking.guid,
    session_start_time,
  max(unique_ips) AS indicator_value,
    1 AS indicator_id
  FROM ${fair_use_tracking.SQL_TABLE_NAME} AS fair_use_tracking
    WHERE (fair_use_tracking.unique_ips > 1)
    GROUP BY 1,2
    ORDER BY 1 DESC),

multiple_devices AS (
  SELECT
    fair_use_tracking.guid,
    session_start_time,
  max(unique_devices) AS indicator_value,
    2 AS indicator_id
  FROM ${fair_use_tracking.SQL_TABLE_NAME} AS fair_use_tracking
    WHERE (fair_use_tracking.unique_devices > 1)
    GROUP BY 1,2
    ORDER BY 1 DESC),

 multiple_prints AS (
    SELECT
      user_sso_guid,
      DATE_TRUNC(day, event_time) AS day,
      COUNT(CASE WHEN event_action = 'Printed' THEN 1 END) AS indicator_value,
    3 AS indicator_id
    FROM unlimited.raw_vitalsource_event
    GROUP BY 1, 2
    HAVING indicator_value > 500
    ORDER BY 2 DESC
 ),

  multiple_downloads AS (
    SELECT
      user_sso_guid,
      DATE_TRUNC(day, event_time) AS day,
      COUNT(CASE WHEN event_action = 'Downloaded' THEN 1 END) AS indicator_value,
      4 AS indicator_id
    FROM unlimited.raw_vitalsource_event
    GROUP BY 1, 2
    HAVING indicator_value > 10
    ORDER BY 2 DESC
 ),


 users_flagged AS (
 SELECT * FROM multiple_ips
 UNION
 SELECT * FROM multiple_devices
 UNION
 SELECT * FROM multiple_prints
 UNION
 SELECT * FROM multiple_downloads
 ),

 all_users AS (
 SELECT
    user_sso_guid,
    DATE_TRUNC(day, event_time)::timestamp_tz AS day
 FROM unlimited.raw_vitalsource_event
 UNION
 SELECT
    user_sso_guid,
    DATE_TRUNC(day, local_time)::timestamp_tz AS day
 FROM unlimited.raw_fair_use_logins
 ),

 users_no_flags AS (
    SELECT
      user_sso_guid,
      day
    FROM all_users
    EXCEPT SELECT guid, session_start_time::date FROM users_flagged
 )

 SELECT * FROM users_flagged
 UNION
 SELECT *, NULL AS indicator_value, 0 AS indicator_id FROM users_no_flags



;;

persist_for: "24 hours"
}

  dimension: guid {}
  dimension_group:  session_start_time {
  label: "Session"
   timeframes: [date, time, time_of_day, week_of_year, month, year]
    type: time
  }
  dimension: indicator_value {}
  dimension: indicator_id {}


  measure:  count {
    type:  count
  }

  measure: user_count {
    type:  count_distinct
    sql: ${guid} ;;
  }

  measure: indicator_count {
    type:  count_distinct
    sql: NULLIF(${indicator_id},0) ;;
  }




#
#   measure: total_users {
#     type:  number
#     sql:  COUNT(DISTINCT ${guid}) OVER () ;;
#   }

 }
