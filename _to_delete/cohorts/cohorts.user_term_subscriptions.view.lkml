# view: cohorts_user_term_subscriptions {
#   derived_table: {

#     persist_for: "60 minutes"

#     sql:
#       WITH cancelled AS (
#         SELECT
#           user_sso_guid_merged
#           , contract_id
#           , local_time
#           , subscription_state
#         FROM prod.cu_user_analysis.subscription_event_merged
#         WHERE subscription_state = 'cancelled'
#         )
#       , subscriptions as (
#         SELECT
#           s.user_sso_guid_merged
#           ,COALESCE(c.subscription_state, s.subscription_state) AS subscription_state
#           ,s.subscription_start
#           ,s.subscription_end
#           ,s.local_time
#         FROM prod.cu_user_analysis.subscription_event_merged s
#         LEFT JOIN cancelled c ON s.user_sso_guid_merged = c.user_sso_guid_merged AND s.contract_id = c.contract_id AND c.local_time > s.local_time AND s.subscription_state = 'full_access'
#         )
#         SELECT
#               s.user_sso_guid_merged
#               ,d.terms_chron_order_desc
#               ,d.governmentdefinedacademicterm
#               ,d.start_date
#               ,d.end_date
#               ,s.subscription_state
#               ,s.subscription_start
#               ,s.subscription_end
#               ,s.local_time
#         FROM ${date_latest_5_terms.SQL_TABLE_NAME} d
#         INNER JOIN subscriptions s
#             ON (
#                 -- starts this term before the last week of the term
#                 s.subscription_start::DATE BETWEEN d.start_date AND DATEADD(day, -8, d.end_date)
#                 OR
#                 -- ends this term after the first week of the term
#                 s.subscription_end::DATE BETWEEN DATEADD(day, 8, d.start_date) and d.end_date
#                 OR
#                 --started before this term and ends after this term
#                 (
#                   s.subscription_start::DATE < d.start_date
#                   AND s.subscription_end::DATE > d.end_date
#                 )
#               )
#       --WHERE user_sso_guid_merged IN ('033b20b27ca503d5:20c4c7b6:15f6f339f0c:-5f8b', '033b20b27ca503d5:20c4c7b6:15e2fad1470:5223', 'efa047457a23f24d:-260a5249:1655840aed1:-1568')
#       ;;
#   }

#   dimension: user_sso_guid_merged {}
#   dimension: term_chron_order_desc {}
#   dimension: governmentdefinedacademicterm {}
#   dimension: subscription_state {}

# }

# view: cohorts_user_term_subscriptions_old {
#   derived_table: {
#     persist_for: "60 minutes"

#     sql:
#         SELECT
#               s.user_sso_guid_merged
#               ,d.terms_chron_order_desc
#               ,d.governmentdefinedacademicterm
#               ,d.start_date
#               ,d.end_date
#               ,s.subscription_state
#               ,s.subscription_start
#               ,s.subscription_end
#         FROM ${date_latest_5_terms.SQL_TABLE_NAME} d
#         INNER JOIN prod.cu_user_analysis.subscription_event_merged s
#             ON (
#                 s.subscription_start::DATE BETWEEN d.start_date AND DATEADD(day, -8, d.end_date) -- starts before the last week of the term
#                 OR s.subscription_end::DATE BETWEEN DATEADD(day, 8, d.start_date) AND d.end_date -- ends after the first week of the term
#               )
#       --WHERE user_sso_guid_merged IN ('033b20b27ca503d5:20c4c7b6:15f6f339f0c:-5f8b', '033b20b27ca503d5:20c4c7b6:15e2fad1470:5223', 'efa047457a23f24d:-260a5249:1655840aed1:-1568')
#       ;;
#   }

#   dimension: user_sso_guid_merged {}
#   dimension: term_chron_order_desc {}
#   dimension: governmentdefinedacademicterm {}
#   dimension: subscription_state {}

# }
