include: "cohorts.base.view"

view: FullAccess_cohort {
  extends: [cohorts_base_binary]

  derived_table: {
    sql:
     /* WITH
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
      FROM term_dates_five_most_recent d
      LEFT JOIN prod.cu_user_analysis.subscription_event_merged s
        --ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
        --OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
        ON DATEADD('d', -30, s.subscription_start::DATE) <= d.start_date
        AND s.subscription_end::DATE >= DATEADD('d', -30, d.end_date)
      WHERE subscription_state = 'full_access'
      )
      SELECT
          *
      FROM subscription_terms
      PIVOT (COUNT (subscription_state) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5)) */


       WITH
    term_dates AS
    (
      SELECT
        governmentdefinedacademicterm
        ,1 AS groupbyhack
        ,MIN(datevalue) AS start_date
        ,MAX(datevalue) AS end_date
      FROM prod.dw_ga.dim_date
      WHERE governmentdefinedacademicterm IS NOT NULL
      GROUP BY 1
      ORDER BY 4 DESC
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
           ON s.subscription_start::DATE >= d.start_date AND s.subscription_start <= d.end_date
         --ON DATEADD('d', -30, s.subscription_start::DATE) <= d.start_date
         --AND s.subscription_end::DATE >= DATEADD('d', -30, d.end_date)
      WHERE subscription_state = 'full_access'
      --AND user_sso_guid_merged IN ('033b20b27ca503d5:20c4c7b6:15f6f339f0c:-5f8b', '033b20b27ca503d5:20c4c7b6:15e2fad1470:5223', 'efa047457a23f24d:-260a5249:1655840aed1:-1568')
      )
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
      ;;
  }

  dimension: current { group_label: "Full Access" }

  dimension: minus_1 { group_label: "Full Access" }

  dimension: minus_2 { group_label: "Full Access" }

  dimension: minus_3 { group_label: "Full Access" }

  dimension: minus_4 { group_label: "Full Access" }

}
