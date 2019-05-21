 include: "cohorts_base.view"

  view: cohorts_studyguide_dashboard {

    set: marketing_fields {
      fields: [cohorts_studyguide_dashboard.current, cohorts_studyguide_dashboard.minus_1, cohorts_studyguide_dashboard.minus_2, cohorts_studyguide_dashboard.minus_3, cohorts_studyguide_dashboard.minus_4
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
        ,subscription_term_products AS
        (
        SELECT DISTINCT
               user_sso_guid_merged
              ,terms_chron_order_desc
              ,governmentdefinedacademicterm
              ,subscription_state
              ,CASE WHEN iac.pp_product_type = 'STGU' THEN 1 END AS studyguide_count
          FROM prod.cu_user_analysis_dev.subscription_event_merged s
          LEFT JOIN term_dates_five_most_recent d
            ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
            OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
          LEFT JOIN prod.unlimited.raw_olr_provisioned_product pp
            ON s.user_sso_guid_merged = pp.user_sso_guid
            AND d.start_date < pp.expiration_date
            AND d.end_date > pp.local_time
          LEFT JOIN prod.unlimited.raw_olr_extended_iac iac
            ON iac.pp_pid = pp.product_id
            AND pp.user_type LIKE 'student'
          WHERE s.subscription_state = 'full_access'
         )
         ,subscription_term_value AS
         (
         SELECT * FROM subscription_term_products
         PIVOT (SUM (studyguide_count) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
         )
         SELECT
           *
         FROM subscription_term_value
       ;;
    }


    dimension: current {group_label: "Studyguide added to dashboard"}

    dimension: minus_1 {group_label: "Studyguide added to dashboard"}

    dimension: minus_2 {group_label: "Studyguide added to dashboard"}

    dimension: minus_3 {group_label: "Studyguide added to dashboard"}

    dimension: minus_4 {group_label: "Studyguide added to dashboard"}

  }
