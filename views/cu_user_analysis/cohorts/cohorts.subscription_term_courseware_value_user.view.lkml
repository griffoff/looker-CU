include: "cohorts.base.view"

view: subscription_term_courseware_value_users {

  extends: [cohorts_base_number]
    derived_table: {
      sql:  WITH
          subscription_term_products AS
          (
          SELECT
                u.user_sso_guid
                ,d.terms_chron_order_desc
                ,d.governmentdefinedacademicterm
                ,u.entity_name
                ,u.isbn
                ,u.net_price
            FROM prod.cu_user_analysis.user_courses u
            LEFT JOIN ${date_latest_5_terms.SQL_TABLE_NAME} d
              ON u.course_start_date::DATE >= d.start_date AND u.course_start_date <= d.end_date
           )
           SELECT
              user_sso_guid AS user_sso_guid_merged
              ,SUM(CASE WHEN terms_chron_order_desc = 1 THEN net_price ELSE 0 END) AS "1"
              ,SUM(CASE WHEN terms_chron_order_desc = 2 THEN net_price ELSE 0 END) AS "2"
              ,SUM(CASE WHEN terms_chron_order_desc = 3 THEN net_price ELSE 0 END) AS "3"
              ,SUM(CASE WHEN terms_chron_order_desc = 4 THEN net_price ELSE 0 END) AS "4"
              ,SUM(CASE WHEN terms_chron_order_desc = 5 THEN net_price ELSE 0 END) AS "5"
            FROM subscription_term_products
            GROUP BY 1
            /*
           ,subscription_term_value AS
           (
           SELECT * FROM subscription_term_products
           PIVOT (SUM (net_price) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
           )
           SELECT
              user_sso_guid_merged
              ,governmentdefinedacademicterm
              ,subscription_state
              ,SUM(1) AS "1"
              ,SUM(2) AS "2"
              ,SUM(3) AS "3"
              ,SUM(4) AS "4"
              ,SUM(5) AS "5"
           FROM subscription_term_value
           GROUP BY user_sso_guid_merged, governmentdefinedacademicterm, subscription_state
          */
            ;;
    }



  dimension: current {group_label: "CU Term Value User ($)"
    value_format_name: "usd" description: "Total net price of courseware used between subscription start and end date (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_1 {group_label: "CU Term Value User ($)"
    value_format_name: "usd" description: "Total net price of courseware used between subscription start and end date (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_2 {group_label: "CU Term Value User ($)"
    value_format_name: "usd" description: "Total net price of courseware used between subscription start and end date (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_3 {group_label: "CU Term Value User ($)"
    value_format_name: "usd" description: "Total net price of courseware used between subscription start and end date (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}

  dimension: minus_4 {group_label: "CU Term Value User ($)"
    value_format_name: "usd" description: "Total net price of courseware used between subscription start and end date (Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"}



#   set: detail {
#     fields: [
#       subscription_state,
#       current, minus_1, minus_2, minus_3, minus_4
#     ]
#   }
}




view: subscription_term_courseware_value_users_old {

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
          SELECT
              user_sso_guid_merged
                ,terms_chron_order_desc
                ,governmentdefinedacademicterm
                ,subscription_state
                ,DATEDIFF('d', subscription_start, subscription_end) AS subscription_length_days
                ,u.entity_name
                ,u.isbn
                ,u.net_price
                ,pp.deleted
                ,pp.expiration_date
                ,pp.local_time
                ,pp.date_added
            FROM prod.cu_user_analysis.subscription_merged_new s
            LEFT JOIN term_dates_five_most_recent d
              ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
              OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
            LEFT JOIN olr.prod.provisioned_product pp
              ON s.user_sso_guid_merged = pp.user_sso_guid
              AND d.start_date < pp.expiration_date
              AND d.end_date > pp.local_time
              AND pp.context_id IS NOT NULL
            LEFT JOIN prod.cu_user_analysis.user_courses u
              ON s.user_sso_guid_merged = u.user_sso_guid
           )
           ,subscription_term_value AS
           (
           SELECT * FROM subscription_term_products
           PIVOT (SUM (net_price) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
           )
           SELECT
              user_sso_guid_merged
              ,governmentdefinedacademicterm
              ,subscription_state
              ,SUM(1) AS "1"
              ,SUM(2) AS "2"
              ,SUM(3) AS "3"
              ,SUM(4) AS "4"
              ,SUM(5) AS "5"
           FROM subscription_term_value
           GROUP BY user_sso_guid_merged, governmentdefinedacademicterm, subscription_state
             ;;
  }


  dimension: current {group_label: "CU Term Value User ($)"}

  dimension: minus_1 {group_label: "CU Term Value User ($)"}

  dimension: minus_2 {group_label: "CU Term Value User ($)"}

  dimension: minus_3 {group_label: "CU Term Value User ($)"}

  dimension: minus_4 {group_label: "CU Term Value User ($)"}



#   set: detail {
#     fields: [
#       subscription_state,
#       current, minus_1, minus_2, minus_3, minus_4
#     ]
#   }
}