# # explore: jia_account_creation {}


#   view: jia_account_creation {
#     derived_table: {
#       sql: WITH account_creation_user_dates
#         AS
#         (
#         SELECT
#           user_sso_guid
#           ,MAX(event_time::date) AS most_recent_account_creation_date
#         FROM prod.cu_user_analysis.all_events
#         WHERE event_name ILIKE '%account creation%' AND event_time > '2019-11-01'
#         GROUP BY user_sso_guid
#         LIMIT 200
#         )
#         SELECT
#           ac_users.user_sso_guid
#           ,event_name
#           ,most_recent_account_creation_date
#           ,DATEDIFF('d', most_recent_account_creation_date, event_time) AS day_since_ac
#         FROM account_creation_user_dates ac_users
#         LEFT JOIN prod.cu_user_analysis.all_events events
#           ON events.user_sso_guid = ac_users.user_sso_guid
#           AND events.event_time > ac_users.most_recent_account_creation_date
#   ;;
#     }

#     measure: count {
#       type: count
#       drill_fields: [detail*]
#     }

#     dimension: user_sso_guid {
#       type: string
#       sql: ${TABLE}."USER_SSO_GUID" ;;
#     }

#     dimension: event_name {
#       type: string
#       sql: ${TABLE}."EVENT_NAME" ;;
#     }

#     dimension: most_recent_account_creation_date {
#       type: date
#       sql: ${TABLE}."MOST_RECENT_ACCOUNT_CREATION_DATE" ;;
#     }

#     dimension: day_since_ac {
#       type: number
#       sql: ${TABLE}."DAY_SINCE_AC" ;;
#     }

#     set: detail {
#       fields: [user_sso_guid, event_name, most_recent_account_creation_date, day_since_ac]
#     }
#   }
