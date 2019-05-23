include: "cohorts.base.view"

view: cohorts_chegg_clicked {

  set: marketing_fields {
    fields: [cohorts_chegg_clicked.current, cohorts_chegg_clicked.minus_1, cohorts_chegg_clicked.minus_2, cohorts_chegg_clicked.minus_3, cohorts_chegg_clicked.minus_4
    ]
  }

  extends: [cohorts_base]

  derived_table: {
    sql: WITH
          term_dates AS
          (
            SELECT
              governmentdefinedacademicterm
              ,1 AS groupbyhack
              ,MAX(datevalue) AS end_date
              ,MIN(datevalue) AS start_date
            FROM prod.dw_ga.dim_date
            WHERE governmentdefinedacademicterm IS NOT NULL
            GROUP BY 1
            ORDER BY 2 DESC
          )
          ,term_dates_five_most_recent AS
          (
              SELECT
                RANK() OVER (ORDER BY start_date DESC) AS terms_chron_order_desc
                ,*
              FROM term_dates
              WHERE start_date < CURRENT_DATE()
              ORDER BY terms_chron_order_desc
              LIMIT 5
          )
          ,subscription_term_career_center_clicks AS
          (
          SELECT
              user_sso_guid_merged
                ,terms_chron_order_desc
                ,governmentdefinedacademicterm
                ,s.subscription_state
                ,CASE WHEN event_name = 'One month Free Chegg Clicked' THEN 1 END AS clicked_career_center
            FROM prod.cu_user_analysis_dev.subscription_event_merged s
            LEFT JOIN term_dates_five_most_recent d
              ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
              OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
            LEFT JOIN prod.cu_user_analysis.all_events e
              ON s.user_sso_guid_merged = e.user_sso_guid
              AND d.start_date < e.event_time
              AND d.end_date > e.event_time
            LEFT JOIN prod.cu_user_analysis_dev.user_courses u
              ON s.user_sso_guid_merged = u.user_sso_guid
            WHERE s.subscription_state = 'full_access'
           )
           ,subscription_term_career_center_clicks_agg AS
           (
           SELECT * FROM subscription_term_career_center_clicks
           PIVOT (SUM (clicked_career_center) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
           )
           SELECT * FROM subscription_term_career_center_clicks_agg
       ;;
  }


  dimension: current {group_label: "Partners: Chegg clicked"}

  dimension: minus_1 {group_label: "Partners: Chegg clicked"}

  dimension: minus_2 {group_label: "Partners: Chegg clicked"}

  dimension: minus_3 {group_label: "Partners: Chegg clicked"}

  dimension: minus_4 {group_label: "Partners: Chegg clicked"}



  }
