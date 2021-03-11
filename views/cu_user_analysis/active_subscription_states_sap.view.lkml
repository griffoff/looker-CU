# explore: active_subscription_states_sap {}

# view: active_subscription_states_sap {
#     derived_table: {
#       sql:
#           WITH active_subs AS (
#             SELECT
#               user_sso_guid
#               ,DATEADD(DAY, t.i, effective_from::DATE) AS active_date
#               ,DATEDIFF(month, subscription_start, subscription_end) as subscription_length
#               ,subscription_state
#               ,HASH(user_sso_guid, active_date) AS pk
#               ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid, active_date ORDER BY CASE subscription_status WHEN 'Full Access' THEN 0 ELSE 1 END, effective_from DESC, effective_to DESC) AS r
#             FROM ${raw_subscription_event_sap.SQL_TABLE_NAME} e
#             INNER JOIN ${tally.SQL_TABLE_NAME} t ON i <= DATEDIFF(DAY, effective_from::DATE, LEAST(effective_to::DATE, CURRENT_DATE()))
#           )
#           SELECT *
#           FROM active_subs
#           WHERE r = 1
#           ;;

#         persist_for: "3 hours"
#       }

#       dimension: pk {primary_key:yes hidden:yes}

#       dimension: user_sso_guid {

#       }

#       dimension_group: active_date {
#         type: time
#         label: ""
#         timeframes: [date, week, month, month_name, year, fiscal_year, fiscal_quarter, fiscal_quarter_of_year, fiscal_month_num]
#       }

#       dimension: subscription_length {
#         type: tier
#         tiers: [3, 4, 11, 13, 23, 25]
#         style: integer
#       }
#       dimension: subscription_state {}

#       measure: subscribers {
#         type: count_distinct
#         sql: ${user_sso_guid} ;;
#       }
#     }
