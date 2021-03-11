# include: "cohorts.base.view"

# view: cohorts_user_term_subscriptions_new {
#   extends: [cohorts_base_binary]
#   derived_table: {
#     sql:
#       WITH
#         new_course_flag AS
#         (
#         SELECT
#           *
#           ,CASE WHEN local_time::date <> subscription_start::date AND subscription_state = 'full_access' THEN 1 END AS new_subscription_flag
#         FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME}
#         )
#         SELECT
#           user_sso_guid_merged
#           ,MAX(CASE WHEN terms_chron_order_desc = 1 THEN new_subscription_flag END) AS "1"
#           ,MAX(CASE WHEN terms_chron_order_desc = 2 THEN new_subscription_flag END) AS "2"
#           ,MAX(CASE WHEN terms_chron_order_desc = 3 THEN new_subscription_flag END) AS "3"
#           ,MAX(CASE WHEN terms_chron_order_desc = 4 THEN new_subscription_flag END) AS "4"
#           ,MAX(CASE WHEN terms_chron_order_desc = 5 THEN new_subscription_flag END) AS "5"
#       FROM new_course_flag
#       GROUP BY 1
#       ;;
#   }

#   dimension: user_sso_guid_merged {}
#   dimension: current {group_label: "New subscriptions" hidden: no description: "Subscription started this semester i.e. not renewed (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}
#   dimension: minus_1 {group_label: "New subscriptions" hidden: no description: "Subscription started this semester i.e. not renewed (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}
#   dimension: minus_2 {group_label: "New subscriptions" hidden: no description: "Subscription started this semester i.e. not renewed (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}
#   dimension: minus_3 {group_label: "New subscriptions" hidden: no description: "Subscription started this semester i.e. not renewed (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}
#   dimension: minus_4 {group_label: "New subscriptions" hidden: no description: "Subscription started this semester i.e. not renewed (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}


# #   dimension: new_subscription_flag {
# #     type: yesno
# #     sql: new_subscription_flag = 'Yes' ;;
# #     label: "New subscrition"
# #     description: "Yesno field designated if this was a new (non-renewed) subscription"
# #     hidden: no
# #   }
# #
# }
