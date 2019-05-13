view: subscription_term_products_value {
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
          ,u.isbn
          ,u.net_price
          ,pp.deleted
          ,pp.expiration_date
          ,pp.local_time
          ,pp.date_added
      FROM prod.cu_user_analysis.subscription_events_merged s
      LEFT JOIN term_dates_five_most_recent d
        ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
        OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
      LEFT JOIN prod.unlimited.raw_olr_provisioned_product pp
        ON s.user_sso_guid_merged = pp.user_sso_guid
        AND d.start_date < pp.expiration_date
        AND d.end_date > pp.local_time
      LEFT JOIN prod.cu_user_analysis.user_courses u
        ON s.user_sso_guid_merged = u.user_sso_guid
      WHERE s.subscription_state = 'full_access'
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

    dimension: current {
      group_label: "CU Term Value ($)"
      type: number
      label: "Spring 2019 (Current)"
      sql: COALESCE(${TABLE}."1", 0) ;;
    }

    dimension: minus_1 {
      group_label: "CU Term Value ($)"
      type: number
      label: "Fall 2019"
      sql:  COALESCE(${TABLE}."2", 0) ;;
    }

    dimension: minus_2 {
      group_label: "CU Term Value ($)"
      type: number
      label: "Summer 2018"
      sql: COALESCE(${TABLE}."3", 0) ;;
    }

    dimension: minus_3 {
      group_label: "CU Term Value ($)"
      type: number
      label: "Spring 2018"
      sql:  COALESCE(${TABLE}."4", 0);;
    }

    dimension: minus_4 {
      group_label: "CU Term Value ($)"
      type: number
      label: "Fall 2018"
      sql:  COALESCE(${TABLE}."5", 0) ;;
    }

  set: detail {
    fields: [
      user_sso_guid_merged,
      governmentdefinedacademicterm,
      subscription_state,
      current, minus_1, minus_2, minus_3, minus_4
    ]
  }
}
