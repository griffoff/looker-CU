# include: "cohorts.base.view"

# view: full_access_started_cohort {
#   extends: [cohorts_base_binary]

#   derived_table: {
#     sql:
#       SELECT user_sso_guid_merged
#           , MAX(CASE WHEN terms_chron_order_desc = 1 THEN 1 END) AS "1"
#           , MAX(CASE WHEN terms_chron_order_desc = 2 THEN 1 END) AS "2"
#           , MAX(CASE WHEN terms_chron_order_desc = 3 THEN 1 END) AS "3"
#           , MAX(CASE WHEN terms_chron_order_desc = 4 THEN 1 END) AS "4"
#           , MAX(CASE WHEN terms_chron_order_desc = 5 THEN 1 END) AS "5"
#       FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME} s
#       WHERE s.subscription_state = 'full_access' and s.subscription_start between s.start_date and s.end_date
#       GROUP BY 1
#       /*
#       ,subscription_terms_pivoted AS
#       (
#         SELECT
#             *
#         FROM subscription_terms
#         PIVOT (COUNT (subscription_state) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
#       )
#       SELECT
#         user_sso_guid_merged
#         ,SUM(CASE WHEN "1" > 0 THEN 1 ELSE 0 END) AS "1"
#         ,SUM(CASE WHEN "2" > 0 THEN 1 ELSE 0 END) AS "2"
#         ,SUM(CASE WHEN "3" > 0 THEN 1 ELSE 0 END) AS "3"
#         ,SUM(CASE WHEN "4" > 0 THEN 1 ELSE 0 END) AS "4"
#         ,SUM(CASE WHEN "5" > 0 THEN 1 ELSE 0 END) AS "5"
#       FROM subscription_terms_pivoted
#       GROUP BY 1
#       */

#       ;;
#   }

#   dimension: current { group_label: "Full Access Started" description: "Student with full access CU subscription started this semester (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

#   dimension: minus_1 { group_label: "Full Access Started" description: "Student with full access CU subscription started this semester (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

#   dimension: minus_2 { group_label: "Full Access Started" description: "Student with full access CU subscription started this semester (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

#   dimension: minus_3 { group_label: "Full Access Started" description: "Student with full access CU subscription started this semester (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

#   dimension: minus_4 { group_label: "Full Access Started" description: "Student with full access CU subscription started this semester (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

# }
