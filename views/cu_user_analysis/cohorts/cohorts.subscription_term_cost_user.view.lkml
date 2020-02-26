include: "cohorts.base.view"

view: cohorts_subscription_term_cost_user {

    extends: [cohorts_base_number]

    derived_table: {
      sql:
      WITH
        subscription_term_lengths AS
        (
          SELECT
             *
            ,DATEDIFF('d', subscription_start, subscription_end) AS subscription_length_days
        FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME}
        WHERE subscription_state = 'full_access'
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
        FROM subscription_term_lengths
      )
      SELECT user_sso_guid_merged
          ,MAX(CASE WHEN terms_chron_order_desc = 1 THEN term_subscription_cost END) AS "1"
          ,MAX(CASE WHEN terms_chron_order_desc = 2 THEN term_subscription_cost END) AS "2"
          ,MAX(CASE WHEN terms_chron_order_desc = 3 THEN term_subscription_cost END) AS "3"
          ,MAX(CASE WHEN terms_chron_order_desc = 4 THEN term_subscription_cost END) AS "4"
          ,MAX(CASE WHEN terms_chron_order_desc = 5 THEN term_subscription_cost END) AS "5"
       FROM subscription_term_costs s
       GROUP BY 1
      /*CU Term Cost ($)
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

    dimension: current { group_label: "CU Term Cost ($)" value_format_name: "usd" }

    dimension: minus_1 { group_label: "CU Term Cost ($)" value_format_name: "usd"}

    dimension: minus_2 { group_label: "CU Term Cost ($)" value_format_name: "usd"}

    dimension: minus_3 { group_label: "CU Term Cost ($)" value_format_name: "usd"}

    dimension: minus_4 { group_label: "CU Term Cost ($)" value_format_name: "usd"}

  }
