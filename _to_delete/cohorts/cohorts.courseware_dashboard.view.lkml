# include: "cohorts.base.view"

#   view: cohorts_courseware_dashboard {

#     extends: [cohorts_base_number]
#     derived_table: {

#       sql:
#         WITH subscription_term_products AS
#         (
#         SELECT DISTINCT
#               user_sso_guid_merged
#               ,terms_chron_order_desc
#               ,governmentdefinedacademicterm
#               ,subscription_state
#               ,pp.context_id
#           FROM prod.cu_user_analysis.subscription_merged_new s
# --           LEFT JOIN term_dates_five_most_recent
#             LEFT JOIN ${date_latest_5_terms.SQL_TABLE_NAME} d
#             ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
#             OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
#           LEFT JOIN olr.prod.provisioned_product pp
#             ON s.user_sso_guid_merged = pp.user_sso_guid
#             AND d.start_date < pp.expiration_date
#             AND d.end_date > pp.local_time
#           WHERE pp.context_id IS NOT NULL
#         )
#         /*
#         ,subscription_term_value AS
#         (
#         SELECT * FROM subscription_term_products
#         PIVOT (COUNT (context_id) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
#         )
#         SELECT
#           *
#         FROM subscription_term_value
#           */

#           SELECT user_sso_guid_merged
#           , SUM(CASE WHEN terms_chron_order_desc = 1 THEN 1 END) AS "1"
#           , SUM(CASE WHEN terms_chron_order_desc = 2 THEN 1 END) AS "2"
#           , SUM(CASE WHEN terms_chron_order_desc = 3 THEN 1 END) AS "3"
#           , SUM(CASE WHEN terms_chron_order_desc = 4 THEN 1 END) AS "4"
#           , SUM(CASE WHEN terms_chron_order_desc = 5 THEN 1 END) AS "5"
#       FROM subscription_term_products
#       GROUP BY 1
#               ;;


#     }

#     dimension: current {
#       group_label: "# of courseware added to dashboard"
#       description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"
#       type: string
#       sql: CASE WHEN COALESCE(${TABLE}."1", 0) >= 7 THEN '7+' ELSE COALESCE(${TABLE}."1", 0)::string END  ;;
#       }

#     dimension: minus_1 {group_label: "# of courseware added to dashboard"
#       description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"
#       type: string
#       sql: CASE WHEN COALESCE(${TABLE}."2", 0) >= 7 THEN '7+' ELSE COALESCE(${TABLE}."2", 0)::string END  ;;}

#     dimension: minus_2 {group_label: "# of courseware added to dashboard"
#       description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"
#       type: string
#       sql: CASE WHEN COALESCE(${TABLE}."3", 0) >= 7 THEN '7+' ELSE COALESCE(${TABLE}."3", 0)::string END  ;;}

#     dimension: minus_3 {group_label: "# of courseware added to dashboard"
#       description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"
#       type: string
#       sql: CASE WHEN COALESCE(${TABLE}."4", 0) >= 7 THEN '7+' ELSE COALESCE(${TABLE}."4", 0)::string END  ;;}

#     dimension: minus_4 {group_label: "# of courseware added to dashboard"
#       description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"
#       type: string
#       sql: CASE WHEN COALESCE(${TABLE}."5", 0) >= 7 THEN '7+' ELSE COALESCE(${TABLE}."5", 0)::string END  ;;}




# #   set: detail {
# #     fields: [
# #       subscription_state,
# #       current, minus_1, minus_2, minus_3, minus_4
# #     ]
# #   }
#   }
