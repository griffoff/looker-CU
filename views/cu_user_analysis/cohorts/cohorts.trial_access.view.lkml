include: "cohorts.base.view"

view: TrialAccess_cohorts {
  extends: [cohorts_base_binary]

  derived_table: {
    sql:
      SELECT user_sso_guid_merged
          , MAX(CASE WHEN terms_chron_order_desc = 1 THEN 1 END) AS "1"
          , MAX(CASE WHEN terms_chron_order_desc = 2 THEN 1 END) AS "2"
          , MAX(CASE WHEN terms_chron_order_desc = 3 THEN 1 END) AS "3"
          , MAX(CASE WHEN terms_chron_order_desc = 4 THEN 1 END) AS "4"
          , MAX(CASE WHEN terms_chron_order_desc = 5 THEN 1 END) AS "5"
       FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME} s
       WHERE s.subscription_state = 'trial_access'
       GROUP BY 1
      /*
      ,subscription_terms_pivoted AS
      (
        SELECT
            *
        FROM subscription_terms
        PIVOT (COUNT (subscription_state) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
      )
      SELECT
        user_sso_guid_merged
        ,SUM(CASE WHEN "1" > 0 THEN 1 ELSE 0 END) AS "1"
        ,SUM(CASE WHEN "2" > 0 THEN 1 ELSE 0 END) AS "2"
        ,SUM(CASE WHEN "3" > 0 THEN 1 ELSE 0 END) AS "3"
        ,SUM(CASE WHEN "4" > 0 THEN 1 ELSE 0 END) AS "4"
        ,SUM(CASE WHEN "5" > 0 THEN 1 ELSE 0 END) AS "5"
      FROM subscription_terms_pivoted
      GROUP BY 1
      */

      ;;
  }

# view: TrialAccess_cohorts_old {
#
#
#   extends: [cohorts_base_binary]
#   derived_table: {
#     sql:
#     /*
#      WITH
#     term_dates AS
#     (
#       SELECT
#         governmentdefinedacademicterm
#         ,1 AS groupbyhack
#         ,MAX(datevalue) AS end_date
#         ,MIN(datevalue) AS start_date
#       FROM prod.dw_ga.dim_date
#       WHERE governmentdefinedacademicterm IS NOT NULL
#       GROUP BY 1
#       ORDER BY 2 DESC
#     )
#     ,term_dates_five_most_recent AS
#     (
#         SELECT
#           RANK() OVER (ORDER BY start_date DESC) AS terms_chron_order_desc
#           ,*
#         FROM term_dates
#         WHERE start_date < CURRENT_DATE()
#         ORDER BY terms_chron_order_desc
#         LIMIT 5
#     )
#     ,subscription_terms AS
#     (
#     SELECT
#         user_sso_guid_merged
#           ,terms_chron_order_desc
#           ,governmentdefinedacademicterm
#           ,subscription_state
#       FROM prod.cu_user_analysis.subscription_event_merged s
#       LEFT JOIN term_dates_five_most_recent d
#         ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
#         OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
#       WHERE subscription_state = 'trial_access'
#       )
#       SELECT
#           *
#       FROM subscription_terms
#       PIVOT (COUNT (subscription_state) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
#       */
#
#       WITH
#           term_dates AS
#           (
#             SELECT
#               governmentdefinedacademicterm
#               ,1 AS groupbyhack
#               ,MAX(datevalue) AS end_date
#               ,MIN(datevalue) AS start_date
#             FROM prod.dw_ga.dim_date
#             WHERE governmentdefinedacademicterm IS NOT NULL
#             GROUP BY 1
#             ORDER BY 2 DESC
#           )
#           ,term_dates_five_most_recent AS
#           (
#               SELECT
#                 RANK() OVER (ORDER BY start_date DESC) AS terms_chron_order_desc
#                 ,*
#               FROM term_dates
#               WHERE start_date < CURRENT_DATE()
#               ORDER BY terms_chron_order_desc
#               LIMIT 5
#           )
# --          SELECT * FROM term_dates_five_most_recent;
#           ,subscription_term_trial_access AS
#           (
#           SELECT
#               user_sso_guid as user_sso_guid_merged
#                 ,terms_chron_order_desc
#                 ,governmentdefinedacademicterm
#                 ,CASE WHEN event_name ilike '%trial access%' THEN 1 END AS trial_access_event
#             FROM prod.cu_user_analysis.all_events e
#             LEFT JOIN term_dates_five_most_recent d
#                 ON e.event_time > d.start_date
#                 AND  e.event_time  < d.end_date
#            )
#            ,subscription_term_trial_access_agg AS
#            (
#            SELECT * FROM subscription_term_trial_access
#            PIVOT (SUM (trial_access_event) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
#            )
#            SELECT * FROM subscription_term_trial_access_agg
#
#
#        ;;
#   }

  dimension: current { group_label: "Trial Access" description:"User had trial access during term Y/N (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_1 { group_label: "Trial Access" description:"User had trial access during term Y/N (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_2 { group_label: "Trial Access" description:"User had trial access during term Y/N (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_3 { group_label: "Trial Access" description:"User had trial access during term Y/N (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_4 { group_label: "Trial Access" description:"User had trial access during term Y/N (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

}
