include: "cohorts.base.view"

view: TrialAccess_cohorts {


  extends: [cohorts_base_binary]
  derived_table: {
    sql:
    /*
     WITH
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
    ,subscription_terms AS
    (
    SELECT
        user_sso_guid_merged
          ,terms_chron_order_desc
          ,governmentdefinedacademicterm
          ,subscription_state
      FROM prod.cu_user_analysis.subscription_event_merged s
      LEFT JOIN term_dates_five_most_recent d
        ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
        OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
      WHERE subscription_state = 'trial_access'
      )
      SELECT
          *
      FROM subscription_terms
      PIVOT (COUNT (subscription_state) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
      */

      WITH
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
--          SELECT * FROM term_dates_five_most_recent;
          ,subscription_term_career_center_clicks AS
          (
          SELECT
              user_sso_guid
                ,terms_chron_order_desc
                ,governmentdefinedacademicterm
                ,CASE WHEN event_name = 'One month Free Chegg Clicked' THEN 1 END AS clicked_career_center
            FROM prod.cu_user_analysis.all_events e
            LEFT JOIN term_dates_five_most_recent d
                ON e.event_time > d.start_date
                AND  e.event_time  < d.end_date
           )
           ,subscription_term_career_center_clicks_agg AS
           (
           SELECT * FROM subscription_term_career_center_clicks
           PIVOT (SUM (clicked_career_center) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
           )
           SELECT * FROM subscription_term_career_center_clicks_agg


       ;;
  }

  dimension: current { group_label: "Trial Access" }

  dimension: minus_1 { group_label: "Trial Access" }

  dimension: minus_2 { group_label: "Trial Access" }

  dimension: minus_3 { group_label: "Trial Access" }

  dimension: minus_4 { group_label: "Trial Access" }

}
