# view: guid_date_paid_course  {
#   derived_table: {
#     sql:
#     WITH
#           tally AS
#           (
#               SELECT
#                   SEQ8() AS i
#               FROM TABLE(GENERATOR(ROWCOUNT=>10000))
#           )
#           ,paid_courses AS
#           (
#               SELECT
#                   user_sso_guid
#                   ,DATEADD(DAY, t.i, u.course_start_date::DATE) AS active_date
#                   ,CASE WHEN activated THEN 1 ELSE 0 END AS paid_status
#                   ,CASE WHEN (cu_subscription_id IS NOT NULL AND cu_subscription_id <> 'TRIAL') THEN 2 ELSE 1 END AS payment_type
#                   ,HASH(user_sso_guid, active_date) AS pk
#                   ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid, active_date ORDER BY CASE WHEN ACTIVATED THEN 0 ELSE 1 END, u.course_start_date DESC, u.course_end_date DESC) AS r
#               FROM prod.cu_user_analysis.user_courses u
#               INNER JOIN tally t ON i <= DATEDIFF(DAY, u.course_start_date::DATE, LEAST(u.course_end_date::DATE, CURRENT_DATE()))
#               WHERE paid_status = 1
#          )
#          ,active_subs AS (
#             SELECT
#               user_sso_guid
#               ,DATEADD(DAY, t.i, effective_from::DATE) AS active_date
#               ,CASE WHEN subscription_state = 'full_access' THEN 1 ELSE 0 END AS paid_status
#               ,3 AS payment_type
#               ,HASH(user_sso_guid, active_date) AS pk
#               ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid, active_date ORDER BY CASE subscription_state WHEN 'full_access' THEN 0 ELSE 1 END, effective_from DESC, effective_to DESC) AS r
#             FROM ${raw_subscription_event.SQL_TABLE_NAME} e
#             INNER JOIN tally t ON i <= DATEDIFF(DAY, effective_from::DATE, LEAST(effective_to::DATE, CURRENT_DATE()))
#             -- FILTER FOR ONLY FULL ACCESS
#             WHERE paid_status = 1
#           )
#           SELECT
#             user_sso_guid
#             ,active_date
#             ,MAX(paid_status) AS paid_status
#             ,MAX(payment_type) AS payment_type
#           FROM paid_courses
#           WHERE r = 1
#           GROUP BY 1, 2
#           UNION
#           SELECT
#             user_sso_guid
#             ,active_date
#             ,MAX(paid_status) AS paid_status
#             ,MAX(payment_type) AS payment_type
#           FROM active_subs
#           WHERE r = 1 AND user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM paid_courses)
#           GROUP BY 1, 2
#           )
#           ,guid_date_payment_type AS
#           (
#           SELECT
#             user_sso_guid
#             ,active_date
#             ,MAX(paid_status) AS paid_status
#             ,SUM(payment_type) AS payment_type
#           FROM combined
#           GROUP BY 1, 2
#           )
#           SELECT * FROM guid_date_payment_type
#             ;;
#   }
#
#   measure: count {
#     type: count
#     #drill_fields: [detail*]
#   }
#
#   measure: distinct_users {
#     type: count_distinct
#     sql: ${user_sso_guid} ;;
#   }
#
#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#   }
#
#   dimension_group: active_date {
#     type: time
#     timeframes: [year, month, date, raw]
#     sql: ${TABLE}."ACTIVE_DATE" ;;
#   }
#
#   dimension: payment_type {
#     type: number
#     sql: ${TABLE}."PAYMENT_TYPE" ;;
#   }
#
#   dimension: payment_type_name {
#     case: {
#       when: {
#         sql: ${TABLE}."PAYMENT_TYPE" = 1 ;;
#         label: "Stand-alone purchase"
#       }
#       when: {
#         sql:${TABLE}."PAYMENT_TYPE" = 2;;
#         label: "CU Subscription - no courseware"
#       }
#       when: {
#         sql: ${TABLE}."PAYMENT_TYPE" = 3 ;;
#         label: "Courseware and CU Subscription"
#       }
#     }
#
#   }
#
#   dimension: maxpaid_status {
#     type: number
#     sql: ${TABLE}."PAID_STATUS" ;;
#   }
#
# #   set: detail {
# #     fields: [user_sso_guid, active_date, maxpaid_status]
# #   }
# }
