include: "cohorts.base.view"

  view: cohorts_courseware_dashboard {

    extends: [cohorts_base_number]
    derived_table: {
      sql:  WITH
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
        ,subscription_term_products AS
        (
        SELECT DISTINCT
               user_sso_guid_merged
              ,terms_chron_order_desc
              ,governmentdefinedacademicterm
              ,subscription_state
              ,pp.context_id
          FROM prod.cu_user_analysis_dev.subscription_event_merged s
          LEFT JOIN term_dates_five_most_recent d
            ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
            OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
          LEFT JOIN prod.unlimited.raw_olr_provisioned_product pp
            ON s.user_sso_guid_merged = pp.user_sso_guid
            AND d.start_date < pp.expiration_date
            AND d.end_date > pp.local_time
          WHERE pp.context_id IS NOT NULL
         )
         ,subscription_term_value AS
         (
         SELECT * FROM subscription_term_products
         PIVOT (COUNT (context_id) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
         )
         SELECT
           *
         FROM subscription_term_value
               ;;
    }

    dimension: current {group_label: "# of courseware added to dashboard"}

    dimension: minus_1 {group_label: "# of courseware added to dashboard"}

    dimension: minus_2 {group_label: "# of courseware added to dashboard"}

    dimension: minus_3 {group_label: "# of courseware added to dashboard"}

    dimension: minus_4 {group_label: "# of courseware added to dashboard"}




#   set: detail {
#     fields: [
#       subscription_state,
#       current, minus_1, minus_2, minus_3, minus_4
#     ]
#   }
  }
