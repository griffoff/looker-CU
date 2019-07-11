include: "cohorts.base.view"

view: subscription_term_careercenter_clicks {
  extends: [cohorts_base_events]

  parameter: events_to_include {
    default_value: "Clicked on Career Center"
  }

  dimension: current {group_label: "Career center clicks"}

  dimension: minus_1 {group_label: "Career center clicks"}

  dimension: minus_2 {group_label: "Career center clicks"}

  dimension: minus_3 {group_label: "Career center clicks"}

  dimension: minus_4 {group_label: "Career center clicks"}

}


view: subscription_term_careercenter_clicks_old {

  extends: [cohorts_base_number]
  derived_table: {
#     sql: WITH
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
#           ,subscription_term_career_center_clicks AS
#           (
#           SELECT
#               user_sso_guid_merged
#                 ,terms_chron_order_desc
#                 ,governmentdefinedacademicterm
#                 ,s.subscription_state
#                 ,CASE WHEN event_name = 'Clicked on Career Center' THEN 1 END AS clicked_career_center
#             FROM prod.cu_user_analysis_dev.subscription_event_merged s
#             LEFT JOIN term_dates_five_most_recent d
#               ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
#               OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
#             LEFT JOIN prod.cu_user_analysis.all_events e
#               ON s.user_sso_guid_merged = e.user_sso_guid
#               AND d.start_date < e.event_time
#               AND d.end_date > e.event_time
#             LEFT JOIN prod.cu_user_analysis_dev.user_courses u
#               ON s.user_sso_guid_merged = u.user_sso_guid
#             WHERE s.subscription_state = 'full_access'
#            )
#            ,subscription_term_career_center_clicks_agg AS
#            (
#            SELECT * FROM subscription_term_career_center_clicks
#            PIVOT (SUM (clicked_career_center) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
#            )
#            SELECT * FROM subscription_term_career_center_clicks_agg
#        ;;

      sql:
        SELECT
          user_sso_guid_merged
          ,MAX(CASE WHEN terms_chron_order_desc = 1 THEN 1 END) AS "1"
          ,MAX(CASE WHEN terms_chron_order_desc = 2 THEN 1 END) AS "2"
          ,MAX(CASE WHEN terms_chron_order_desc = 3 THEN 1 END) AS "3"
          ,MAX(CASE WHEN terms_chron_order_desc = 4 THEN 1 END) AS "4"
          ,MAX(CASE WHEN terms_chron_order_desc = 5 THEN 1 END) AS "5"
       FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME} s
       INNER JOIN ${all_events.SQL_TABLE_NAME} e
              ON s.user_sso_guid_merged = e.user_sso_guid
              AND s.start_date < e.event_time
              AND s.end_date > e.event_time
              AND e.event_name = 'Clicked on Career Center'
            /*
            --Is this necessary?
            INNER JOIN ${user_courses.SQL_TABLE_NAME} u
              ON s.user_sso_guid_merged = u.user_sso_guid
            */
       WHERE s.subscription_state = 'full_access'
       GROUP BY 1
      ;;
  }

 dimension: current {group_label: "Career center clicks"}

 dimension: minus_1 {group_label: "Career center clicks"}

 dimension: minus_2 {group_label: "Career center clicks"}

 dimension: minus_3 {group_label: "Career center clicks"}

 dimension: minus_4 {group_label: "Career center clicks"}

}
