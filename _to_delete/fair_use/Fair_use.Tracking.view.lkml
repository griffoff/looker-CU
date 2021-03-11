# #  Tracks IP and Device changes per user per 30 minute threshold
# view: fair_use_tracking {
#   derived_table: {
#     sql:
#     WITH logins AS (
#     SELECT DISTINCT _hash, user_sso_guid, cmp_session_id, ip_address, local_time, device,
#     30 AS threshold_mins
#     FROM unlimited.raw_fair_use_logins
# )

# ,previous_login AS (
#       -- Sets new field 'ip_change' to 1 if a user changes IP addresses
#     SELECT
#       l._hash,
#       l.user_sso_guid as guid,
#       l.cmp_session_id as session_id,
#       l.ip_address,
#       l.local_time AS session_start_time,
#       l.device,
#       LAG(array_construct(l.ip_address, l.device, l.local_time), 1) OVER (PARTITION BY l.user_sso_guid ORDER BY l.local_time) AS lag_login,
#       DATEDIFF(minute, lag_login[2], l.local_time) AS login_delta_mins,
#       CASE WHEN lag_login[0] <> l.ip_address AND login_delta_mins < threshold_mins THEN 1 END AS ip_change,
#       CASE WHEN lag_login[1] <> l.device AND login_delta_mins < threshold_mins THEN 1 END AS device_change
#     FROM logins l
#   )

#   ,previous_logins_aggregate AS
#   (
#   SELECT
#     l._hash,
#     COUNT(DISTINCT pl.ip_address) AS unique_ips,
#     COUNT(DISTINCT pl.device) AS unique_devices
#   FROM logins l
#   JOIN  logins pl
#         ON l.user_sso_guid = pl.user_sso_guid
#         AND  DATEDIFF(minute, pl.local_time, l.local_time) BETWEEN 0 and l.threshold_mins
#   GROUP BY 1
#   )

#   SELECT
#     pl.*,
#     pla.unique_ips,
#     pla.unique_devices
#   FROM previous_login pl
#   JOIN previous_logins_aggregate pla
#     ON pl._hash = pla._hash;;

#       persist_for: "24 hours"
#     }

#     dimension:  _hash {
#       primary_key: yes
#     }
#     dimension:  guid {}
#     dimension:  cmp_session_id {  }
#     dimension:  ip_address {}
#     dimension: device {}

#     dimension_group:  session_start_time {
#       timeframes: [date, time, time_of_day, month, year]
#       type: time
#     }
#     dimension:  lag_login {}
#     dimension:  ip_change {}
#     dimension:  device_change {}
#     dimension:  unique_ips {
#       type:  number
#     }
#     dimension:  unique_devices {}

#     dimension: unique_ip_bucket {
#       type:  tier
#       tiers: [ 2, 3, 4, 5]
#       style:  integer
#       sql:  ${unique_ips} ;;
#     }

#     dimension: unique_device_bucket {
#       type:  tier
#       tiers: [ 2, 3, 4, 5]
#       style:  integer
#       sql:  ${unique_devices} ;;
#     }


#     measure: count {
#       type: count
#     }

#     measure: count_users {
#       type:  count_distinct
#       sql: ${guid} ;;
#     }




#   }
