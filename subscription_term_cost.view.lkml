view: subscription_term_cost {
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
          ,subscription_terms AS
          (
          SELECT
              user_sso_guid_merged
                ,terms_chron_order_desc
                ,governmentdefinedacademicterm
                ,subscription_state
                ,DATEDIFF('d', subscription_start, subscription_end) AS subscription_length_days
            FROM prod.cu_user_analysis.subscription_events_merged s
            LEFT JOIN term_dates_five_most_recent d
              ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
              OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
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
            FROM subscription_terms
            )
            SELECT
              *
            FROM subscription_term_costs
            PIVOT (SUM (term_subscription_cost) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  }

  dimension: governmentdefinedacademicterm {
    type: string
    sql: ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: subscription_length_days {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_LENGTH_DAYS" ;;
  }

   dimension: current {
    group_label: "CU Term Cost ($)"
    type: number
    label: "Spring 2019 (Current)"
    sql: COALESCE(${TABLE}."1", 0) ;;
  }

  dimension: minus_1 {
    group_label: "CU Term Cost ($)"
    type: number
    label: "Fall 2019"
    sql:  COALESCE(${TABLE}."2", 0) ;;
  }

  dimension: minus_2 {
    group_label: "CU Term Cost ($)"
    type: number
    label: "Summer 2018"
    sql: COALESCE(${TABLE}."3", 0) ;;
  }

  dimension: minus_3 {
    group_label: "CU Term Cost ($)"
    type: number
    label: "Spring 2018"
    sql:  COALESCE(${TABLE}."4", 0);;
  }

  dimension: minus_4 {
    group_label: "CU Term Cost ($)"
    type: number
    label: "Fall 2018"
    sql:  COALESCE(${TABLE}."5", 0) ;;
  }

  set: detail {
    fields: [
      user_sso_guid_merged,
      governmentdefinedacademicterm,
      subscription_state,
      subscription_length_days,
     current, minus_1, minus_2, minus_3, minus_4
    ]
  }
}
