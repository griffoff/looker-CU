view: fair_use_device_tracking {
  derived_table: {
  sql:
      WITH
device_change AS
    (
      -- Sets new field 'ip_change' to 1 if a user changes IP addresses
     SELECT
     user_sso_guid as guid,
     --cmp_session_id as session_id,
     TO_CHAR(raw_fair_use_logins."LOCAL_TIME" , 'YYYY-MM-DD HH24:MI:SS') AS session_start_time,
     LAG(session_start_time, 1) OVER (PARTITION BY guid ORDER BY session_start_time) AS lag_start_time,
     DATEDIFF(minute,lag_start_time, session_start_time) AS session_time_delta,
     device,
     LAG(device, 1) OVER (PARTITION BY guid ORDER BY session_start_time) AS lag_device,
     CASE WHEN lag_device <> device then 1
     ELSE NULL END AS device_change
     FROM unlimited.raw_fair_use_logins
     ),

     device_change_under_30 AS
    (
      -- Sets new field flag to 1 if a user has changed IP address within the last 30 minutes
      SELECT
      *,
      CASE WHEN session_time_delta < 30 AND device_change = 1 THEN 1
      ELSE NULL END AS device_change_under_30_mins
      FROM device_change
    ),

device_change_2x_under_30 as
    (
     -- Sets new filed ip_change_2x_under_30_mins to 1 if a user has
     -- changed IP address in two sessions that started less than 30 minutes apart
    SELECT
    *,
    LAG(device_change_under_30_mins) OVER (PARTITION BY guid ORDER BY session_start_time) AS user_previously_switched_device,
    CASE WHEN device_change = 1 AND user_previously_switched_device = 1 AND session_time_delta < 30 THEN 1
    ELSE NULL END AS device_change_2x_under_30_mins
    FROM device_change_under_30
    ),

device_change_3x_under_30 as
    (
    -- Sets a new field ip_change_3x_under_30_mins to 1 if a user has chaned IP address
    -- 3 times in three sessions that started less than 30 minutes apart
    SELECT
    *,
     LAG(device_change_2x_under_30_mins, 2) OVER (PARTITION BY guid ORDER BY session_start_time) AS user_previously_switched_device_2x_under_30,
    CASE WHEN device_change = 1 AND user_previously_switched_device_2x_under_30 = 1 AND session_time_delta < 30 THEN 1
    ELSE NULL END AS device_change_3x_under_30_mins
    FROM device_change_2x_under_30
    )

     SELECT
     CASE
      WHEN device_change_3x_under_30_mins = 1 THEN 3
      WHEN device_change_2x_under_30_mins = 1 THEN 2
      WHEN device_change_under_30_mins = 1 THEN 1
      ELSE 0 END AS num_device_changes_
      FROM device_change_3x_under_30;;
}
       dimension: guid {
          type: string
        }
        dimension: session_start_time {}
        dimension: lag_start_time {}
        dimension: session_time_delta {}
        dimension: device {}
        dimension: lag_device {}
        dimension: device_change {}
        dimension: device_change_under_30_mins {}
        dimension: user_previously_switched_ip {}
        dimension: device_change_2x_under_30_mins {}
        dimension: user_previously_switched_device_2x_under_30 {}
        dimension: device_change_3x_under_30_mins {}
        dimension: num_device_changes_ {}


        measure: num_3x_under_30 {
        type:  sum
        sql:  ${device_change_3x_under_30_mins} ;;
        }

        measure: num_2x_under_30 {
          type:  sum
          sql:  ${device_change_2x_under_30_mins} ;;
        }

        measure: num_1x_under_30 {
          type:  sum
          sql:  ${device_change_under_30_mins} ;;
        }

        measure: perc_3x_under_30 {
          type:  number
          sql: (SUM(${device_change_3x_under_30_mins}) / count(*)) * 100;;
        }

        measure: perc_2x_under_30 {
          type:  number
          sql: (SUM(${device_change_2x_under_30_mins}) / count(*)) * 100;;
        }

        measure: perc_1x_under_30 {
          type:  number
          sql: (SUM(${device_change_under_30_mins}) / count(*)) * 100;;
        }

        measure: count_device_change {
          type:  count
        }
}
