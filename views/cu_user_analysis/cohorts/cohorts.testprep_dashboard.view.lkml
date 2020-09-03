include: "cohorts.base.view"

view: cohorts_testprep_dashboard {

  extends: [cohorts_base_number]

  derived_table: {
    sql: WITH
        subscription_term_products AS
        (
        SELECT DISTINCT
               user_sso_guid_merged
              ,terms_chron_order_desc
              ,governmentdefinedacademicterm
              ,subscription_state
              ,CASE WHEN pp_name ILIKE '%test%prep%' THEN 1 END AS testprep_count
          FROM prod.cu_user_analysis.subscription_merged_new s
          LEFT JOIN ${date_latest_5_terms.SQL_TABLE_NAME} d
            ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
            OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
          LEFT JOIN olr.prod.provisioned_product pp
            ON s.user_sso_guid_merged = pp.user_sso_guid
            AND d.start_date < pp.expiration_date
            AND d.end_date > pp.local_time
          LEFT JOIN prod.unlimited.raw_olr_extended_iac iac
            ON iac.pp_pid = pp.product_id
            AND pp.user_type LIKE 'student'
         )
         SELECT
            user_sso_guid_merged
            ,SUM(CASE WHEN terms_chron_order_desc = 1 THEN testprep_count ELSE 0 END) AS "1"
            ,SUM(CASE WHEN terms_chron_order_desc = 2 THEN testprep_count ELSE 0 END) AS "2"
            ,SUM(CASE WHEN terms_chron_order_desc = 3 THEN testprep_count ELSE 0 END) AS "3"
            ,SUM(CASE WHEN terms_chron_order_desc = 4 THEN testprep_count ELSE 0 END) AS "4"
            ,SUM(CASE WHEN terms_chron_order_desc = 5 THEN testprep_count ELSE 0 END) AS "5"
         FROM subscription_term_products s
         GROUP BY 1
      /*
         ,subscription_term_value AS
         (
         SELECT * FROM subscription_term_products
         PIVOT (SUM (testprep_count) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
         )
         SELECT
           *
         FROM subscription_term_value
        */
       ;;
  }


  dimension: current {group_label: "Test-prep added to dashboard" description:"Number of test prep items added to dashboard for term (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_1 {group_label: "Test-prep added to dashboard" description:"Number of test prep items added to dashboard for term (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_2 {group_label: "Test-prep added to dashboard" description:"Number of test prep items added to dashboard for term (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_3 {group_label: "Test-prep added to dashboard" description:"Number of test prep items added to dashboard for term (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_4 {group_label: "Test-prep added to dashboard" description:"Number of test prep items added to dashboard for term (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

}



view: cohorts_testprep_dashboard_old {

    extends: [cohorts_base_number]

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
              ,CASE WHEN pp_name ILIKE '%test%prep%' THEN 1 END AS testprep_count
          FROM prod.cu_user_analysis.subscription_merged_new s
          LEFT JOIN term_dates_five_most_recent d
            ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
            OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
          LEFT JOIN olr.prod.provisioned_product pp
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
         PIVOT (SUM (testprep_count) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
         )
         SELECT
           *
         FROM subscription_term_value
       ;;
    }


    dimension: current {group_label: "Test-prep added to dashboard"}

    dimension: minus_1 {group_label: "Test-prep added to dashboard"}

    dimension: minus_2 {group_label: "Test-prep added to dashboard"}

    dimension: minus_3 {group_label: "Test-prep added to dashboard"}

    dimension: minus_4 {group_label: "Test-prep added to dashboard"}

  }