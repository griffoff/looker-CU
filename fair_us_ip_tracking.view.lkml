view: fair_us_ip_tracking {
  derived_table: {
    sql:
        WITH
        ip_change AS
            (
              -- Sets new field 'ip_change' to 1 if a user changes IP addresses
             SELECT
             user_sso_guid as guid,
             --cmp_session_id as session_id,
             TO_CHAR(raw_fair_use_logins."LOCAL_TIME" , 'YYYY-MM-DD HH24:MI:SS') AS session_start_time,
             LAG(session_start_time, 1) OVER (PARTITION BY guid ORDER BY session_start_time) AS lag_start_time,
             DATEDIFF(minute,lag_start_time, session_start_time) AS session_time_delta,
             ip_address as ip,
             LAG(ip_address, 1) OVER (PARTITION BY guid ORDER BY session_start_time) AS lag_ip,
             device,
             CASE WHEN lag_ip <> ip_address then 1
             ELSE NULL END AS ip_change
             FROM unlimited.raw_fair_use_logins
             ),

        ip_change_under_30 AS
            (
              -- Sets new field flag to 1 if a user has changed IP address within the last 30 minutes
              SELECT
              *,
              CASE WHEN session_time_delta < 30 AND ip_change = 1 THEN 1
              ELSE NULL END AS ip_change_under_30_mins
              FROM ip_change
            ),

        ip_change_2x_under_30 as
            (
             -- Sets new filed ip_change_2x_under_30_mins to 1 if a user has
             -- changed IP address in two sessions that started less than 30 minutes apart
            SELECT
            *,
            LAG(ip_change_under_30_mins) OVER (PARTITION BY guid ORDER BY session_start_time) AS user_previously_switched_ip,
            CASE WHEN ip_change = 1 AND user_previously_switched_ip = 1 AND session_time_delta < 30 THEN 1
            ELSE NULL END AS ip_change_2x_under_30_mins
            FROM ip_change_under_30
            ),

        ip_change_3x_under_30 as
            (
            -- Sets a new field ip_change_3x_under_30_mins to 1 if a user has chaned IP address
            -- 3 times in three sessions that started less than 30 minutes apart
            SELECT
            *,
             LAG(ip_change_2x_under_30_mins, 2) OVER (PARTITION BY guid ORDER BY session_start_time) AS user_previously_switched_ip_2x_under_30,
            CASE WHEN ip_change = 1 AND user_previously_switched_ip_2x_under_30 = 1 AND session_time_delta < 30 THEN 1
            ELSE NULL END AS ip_change_3x_under_30_mins
            FROM ip_change_2x_under_30
            )

        SELECT
        /*
        SUM(ip_change_3x_under_30_mins) AS num_3x_under_30,
        SUM(ip_change_2x_under_30_mins) AS num_2x_under_30,
        SUM(ip_change_under_30_mins) AS num_1x_under_30,
        (num_3x_under_30 / count(*)) * 100 AS perc_3x_under_30,
        (num_2x_under_30 / count(*)) * 100 AS perc_2x_under_30,
        (num_1x_under_30 / count(*)) * 100 AS perc_1x_under_30
        */
        *
        FROM ip_change_3x_under_30 ;;
        }

        dimension: guid {
          type: string
        }
        dimension: session_start_time {}
        dimension: lag_start_time {}
        dimension: session_time_delta {}
        dimension: ip {}
        dimension: lag_ip {}
        dimension: device {}
        dimension: ip_change {}
        dimension: ip_change_under_30_mins {}
        dimension: user_previously_switched_ip {}
        dimension: ip_change_2x_under_30_mins {}
        dimension: user_previously_switched_ip_2x_under_30 {}
        dimension: ip_change_3x_under_30_mins {}


        measure: num_3x_under_30 {
        type:  sum
        sql:  ${ip_change_3x_under_30_mins} ;;
        }

        measure: num_2x_under_30 {
          type:  sum
          sql:  ${ip_change_2x_under_30_mins} ;;
        }

        measure: num_1x_under_30 {
          type:  sum
          sql:  ${ip_change_under_30_mins} ;;
        }

        measure: perc_3x_under_30 {
          type:  number
          sql: (SUM(${ip_change_3x_under_30_mins}) / count(*)) * 100;;
        }

        measure: perc_2x_under_30 {
          type:  number
          sql: (SUM(${ip_change_2x_under_30_mins}) / count(*)) * 100;;
        }

        measure: perc_1x_under_30 {
          type:  number
          sql: (SUM(${ip_change_under_30_mins}) / count(*)) * 100;;
        }



}
