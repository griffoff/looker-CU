# include: "cohorts.base.view"

# view: cohorts_platforms_used {
#   extends: [cohorts_base_string]

#   derived_table: {
#     sql:
#       SELECT
#           user_sso_guid_merged
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 1 THEN product_platform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 1 THEN product_platform END) AS "1"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 2 THEN product_platform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 2 THEN product_platform END) AS "2"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 3 THEN product_platform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 3 THEN product_platform END) AS "3"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 4 THEN product_platform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 4 THEN product_platform END) AS "4"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 5 THEN product_platform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 5 THEN product_platform END) AS "5"
#       FROM (
#         SELECT DISTINCT terms_chron_order_desc, user_sso_guid_merged, all_events.user_products_isbn AS isbn
#         FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME} s
#         INNER JOIN ${all_sessions.SQL_TABLE_NAME}  AS all_sessions ON s.user_sso_guid_merged = (all_sessions."USER_SSO_GUID")
#                               AND all_sessions.session_start BETWEEN s.subscription_start AND s.subscription_end
#         INNER JOIN ${all_events.SQL_TABLE_NAME} AS all_events USING(session_id)
#         ) k
#       INNER JOIN ${product_info.SQL_TABLE_NAME} products ON k.isbn = products.isbn13
#       GROUP BY 1
#       ;;

#   }

#   dimension: current { group_label: "Platforms Accessed" description:"List of platforms used (MindTap, WA, etc.) in an array (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

#   dimension: minus_1 { group_label: "Platforms Accessed" description:"List of platforms used (MindTap, WA, etc.) in an array (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)" }

#   dimension: minus_2 { group_label: "Platforms Accessed" description:"List of platforms used (MindTap, WA, etc.) in an array (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)" }

#   dimension: minus_3 { group_label: "Platforms Accessed" description:"List of platforms used (MindTap, WA, etc.) in an array (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)" }

#   dimension: minus_4 { group_label: "Platforms Accessed" description:"List of platforms used (MindTap, WA, etc.) in an array (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)" }

# }
