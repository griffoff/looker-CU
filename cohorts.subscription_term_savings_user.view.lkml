include: "cohorts.base.view"

view: cohorts_subscription_term_savings_user {

  extends: [cohorts_base_number]

  derived_table: {
    sql: WITH
          subscription_terms AS
          (
          SELECT
              user_sso_guid_merged
                ,terms_chron_order_desc
                ,governmentdefinedacademicterm
                ,e.entity_name
                ,DATEDIFF('d', subscription_start, subscription_end) AS subscription_length_days
                ,RANK() OVER (PARTITION BY user_sso_guid_merged, governmentdefinedacademicterm ORDER BY subscription_start DESC) AS user_term_sub_rank
                ,u.net_price
            FROM ${date_latest_5_terms.SQL_TABLE_NAME} d
              ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
              OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)

            LEFT JOIN user_entity_chron_desc_course_rank e
              ON s.user_sso_guid = e.user_sso_guid
              AND chron_desc_course_rank = 1

             LEFT JOIN prod.unlimited.raw_olr_provisioned_product pp
              ON s.user_sso_guid_merged = pp.user_sso_guid
              AND d.start_date < pp.expiration_date
              AND d.end_date > pp.local_time
            LEFT JOIN prod.stg_clts.products u
              ON pp.iac_isbn = u.isbn13


            )
            ,subscription_term_costs AS
            (
            SELECT
                *
                ,CASE
                  WHEN subscription_length_days > 366 THEN 40
                  WHEN subscription_length_days > 121 THEN 60
                  WHEN subscription_length_days > 0 THEN 120
                  ELSE 0 END AS term_subscription_cost
            FROM subscription_terms
            WHERE user_term_sub_rank = 1
            )
            ,previous_five_subscription_term_costs AS
            (
             SELECT
                user_sso_guid_merged
                ,SUM(CASE WHEN terms_chron_order_desc = '1' THEN term_subscription_cost ELSE 0 END) AS "1"
                ,SUM(CASE WHEN terms_chron_order_desc = '2' THEN term_subscription_cost ELSE 0 END) AS "2"
                ,SUM(CASE WHEN terms_chron_order_desc = '3' THEN term_subscription_cost ELSE 0 END) AS "3"
                ,SUM(CASE WHEN terms_chron_order_desc = '4' THEN term_subscription_cost ELSE 0 END) AS "4"
                ,SUM(CASE WHEN terms_chron_order_desc = '5' THEN term_subscription_cost ELSE 0 END) AS "5"
            FROM subscription_term_costs
            GROUP BY 1
            )
            ,previous_five_subscription_term_value AS
            (
            SELECT
                 user_sso_guid_merged
                ,SUM(CASE WHEN terms_chron_order_desc = '1' THEN net_price ELSE 0 END) AS "1"
                ,SUM(CASE WHEN terms_chron_order_desc = '2' THEN net_price ELSE 0 END) AS "2"
                ,SUM(CASE WHEN terms_chron_order_desc = '3' THEN net_price ELSE 0 END) AS "3"
                ,SUM(CASE WHEN terms_chron_order_desc = '4' THEN net_price ELSE 0 END) AS "4"
                ,SUM(CASE WHEN terms_chron_order_desc = '5' THEN net_price ELSE 0 END) AS "5"
            FROM subscription_terms
            GROUP BY 1
            )
            SELECT
              c.user_sso_guid_merged
              ,SUM(v."1") - SUM(c."1") AS "1"
              ,SUM(v."2") - SUM(c."2") AS "2"
              ,SUM(v."3") - SUM(c."3") AS "3"
              ,SUM(v."4") - SUM(c."4") AS "4"
              ,SUM(v."5") - SUM(c."5") AS "5"
            FROM previous_five_subscription_term_costs c
            LEFT JOIN previous_five_subscription_term_value v
                ON c.user_sso_guid_merged = v.user_sso_guid_merged
            GROUP BY c.user_sso_guid_merged
            ;;
  }

  dimension: current {group_label: "CU Term Savings ($)"  hidden: yes}

  dimension: minus_1 {group_label: "CU Term Savings ($)"  hidden: yes }

  dimension: minus_2 {group_label: "CU Term Savings ($)"  hidden: yes }

  dimension: minus_3 {group_label: "CU Term Savings ($)"  hidden: yes }

  dimension: minus_4 {group_label: "CU Term Savings ($)"  hidden: yes}

  dimension: current_tiers {group_label: "CU Term Savings tiers ($)" hidden: yes}

  dimension: minus_1_tiers {group_label: "CU Term Savings tiers ($)" hidden: yes}


}

view: cohorts_subscription_term_savings_user_old {

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
          ,user_entity_chron_desc_course_rank AS
          (
            SELECT
              RANK() OVER (PARTITION BY user_sso_guid ORDER BY course_start_date DESC) AS chron_desc_course_rank
              ,user_sso_guid
              ,entity_name
            FROM prod.cu_user_analysis_dev.user_courses
          )
          ,subscription_terms AS
          (
          SELECT
              user_sso_guid_merged
                ,terms_chron_order_desc
                ,governmentdefinedacademicterm
                ,subscription_state
                ,e.entity_name
                ,DATEDIFF('d', subscription_start, subscription_end) AS subscription_length_days
                ,RANK() OVER (PARTITION BY user_sso_guid_merged, governmentdefinedacademicterm ORDER BY subscription_start DESC) AS user_term_sub_rank
                ,u.net_price
            FROM prod.cu_user_analysis_dev.subscription_event_merged s
            LEFT JOIN term_dates_five_most_recent d
              ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
              OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
            LEFT JOIN user_entity_chron_desc_course_rank e
              ON s.user_sso_guid = e.user_sso_guid
              AND chron_desc_course_rank = 1
             LEFT JOIN prod.unlimited.raw_olr_provisioned_product pp
              ON s.user_sso_guid_merged = pp.user_sso_guid
              AND d.start_date < pp.expiration_date
              AND d.end_date > pp.local_time
            LEFT JOIN prod.cu_user_analysis_dev.user_courses u
              ON s.user_sso_guid_merged = u.user_sso_guid
            --WHERE subscription_state = 'full_access'
            )
            ,subscription_term_costs AS
            (
            SELECT
                *
                ,CASE
                  WHEN subscription_length_days > 366 THEN 40
                  WHEN subscription_length_days > 121 THEN 60
                  WHEN subscription_length_days > 0 THEN 120
                  ELSE 0 END AS term_subscription_cost
            FROM subscription_terms
            WHERE user_term_sub_rank = 1
            )
            ,previous_five_subscription_term_costs AS
            (
            SELECT
              *
            FROM subscription_term_costs
            PIVOT (SUM(term_subscription_cost) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
            )
            ,previous_five_subscription_term_value AS
            (
            SELECT
              *
            FROM subscription_term_costs
            PIVOT (SUM(net_price) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
            )
            SELECT
              c.user_sso_guid_merged
              ,c.governmentdefinedacademicterm
              ,c.subscription_state
              ,SUM(v."1") - SUM(c."1") AS "1"
              ,SUM(v."2") - SUM(c."2") AS "2"
              ,SUM(v."3") - SUM(c."3") AS "3"
              ,SUM(v."4") - SUM(c."4") AS "4"
              ,SUM(v."5") - SUM(c."5") AS "5"
            FROM previous_five_subscription_term_costs c
            LEFT JOIN previous_five_subscription_term_value v
                ON c.user_sso_guid_merged = v.user_sso_guid_merged
                AND c.governmentdefinedacademicterm = v.governmentdefinedacademicterm
                AND c.subscription_state = v.subscription_state
                AND c.entity_name = v.entity_name
            GROUP BY c.user_sso_guid_merged, c.governmentdefinedacademicterm, c.subscription_state;;
    }

    dimension: current {group_label: "CU Term Savings ($)"}

    dimension: minus_1 {group_label: "CU Term Savings ($)"}

    dimension: minus_2 {group_label: "CU Term Savings ($)"}

    dimension: minus_3 {group_label: "CU Term Savings ($)"}

    dimension: minus_4 {group_label: "CU Term Savings ($)"}

    dimension: current_tiers {group_label: "CU Term Savings ($)" hidden:no}

    dimension: minus_1_tiers {group_label: "CU Term Savings ($)" hidden:no}


  }
