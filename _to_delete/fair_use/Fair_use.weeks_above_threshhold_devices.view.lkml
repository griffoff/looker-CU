# view: fair_use_weeks_above_threshhold_devices {
#   derived_table: {
#     sql:
#     WITH
#     state AS (
#     SELECT
#     TO_CHAR(TO_DATE(raw_subscription_event."SUBSCRIPTION_START" ), 'YYYY-MM-DD') AS sub_start_date
#     ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time DESC) AS latest_record
#     ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time ASC) AS earliest_record
#     ,LEAD(subscription_state) over(partition by user_sso_guid order by local_time) as change_in_state
#     ,LEAD(subscription_start) over(partition by user_sso_guid order by local_time) as change_in_start_date
#     ,*
#     FROM Unlimited.Raw_Subscription_event
#     )

#     ,states AS (
#     SELECT
#     s.*
#     ,CASE WHEN s.latest_record = 1 THEN 'yes' ELSE 'no' END AS latest_filter
#     ,CASE WHEN s.earliest_record = 1 THEN 'yes' ELSE 'no' END AS earliest_filter
#     FROM state s
#     LEFT JOIN unlimited.vw_user_blacklist bk
#     ON s.user_sso_guid = bk.user_sso_guid
#     WHERE bk.user_sso_guid IS NULL)

#     ,unique_devices AS (
#     SELECT
#     ga.userssoguid
#     ,DATE_TRUNC(week, TO_DATE(TO_TIMESTAMP(((VISITSTARTTIME*1000) + hits_time )/1000) )) AS week
#     ,COUNT(DISTINCT ga.fullvisitorid) AS unique_devices_count
#     FROM prod.raw_ga.ga_dashboarddata ga
#     JOIN states s
#     ON ga.userssoguid = s.user_sso_guid
#     WHERE s.subscription_state = 'full_access'
#     GROUP BY 1, 2 )

#     SELECT
#         userssoguid
#         ,3 AS threshhold_devices
#         ,COUNT(week) AS weeks_above_threshhold_devices
#     FROM unique_devices
#     WHERE unique_devices_count > threshhold_devices
#     AND userssoguid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users)
#     GROUP BY userssoguid

#     ;;

# }


#   dimension: userssoguid {}
#   dimension: weeks_above_threshhold_devices {}

#   dimension: weeks_above_threshhold_tiers {
#     type:  tier
#     tiers: [ 2, 4, 6, 8, 10]
#     style:  integer
#     sql:  ${weeks_above_threshhold_devices} ;;
#   }


#   measure: user_count {
#     type: count_distinct
#     sql: ${userssoguid} ;;
#     drill_fields: [userssoguid]
#   }





# }
