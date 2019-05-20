include: "cohorts_base.view"

view: TrialAccess_cohorts {
  extends: [cohorts_base]
  derived_table: {
    sql:
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
      FROM prod.cu_user_analysis.subscription_events_merged s
      LEFT JOIN term_dates_five_most_recent d
        ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
        OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
      WHERE subscription_state = 'trial_access'
      )
      SELECT
          *
      FROM subscription_terms
      PIVOT (COUNT (subscription_state) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
       ;;
  }


  dimension: primary_key {
    type: string
    primary_key: yes
    sql: ${user_sso_guid_merged} || ${current} || ${minus_1} || ${minus_2} || ${minus_3} || ${minus_4} ;;
    hidden: yes
  }

  dimension: current {
    group_label: "Trial Access"
    sql: CASE WHEN ${TABLE}."1" > 0 THEN 1 END;;
  }

  dimension: minus_1 {
    group_label: "Trial Access"
    sql:  CASE WHEN ${TABLE}."2" > 0 THEN 1 END ;;
  }

  dimension: minus_2 {
    group_label: "Trial Access"
    sql:  CASE WHEN ${TABLE}."3" > 0 THEN 1 END ;;
  }

  dimension: minus_3 {
    group_label: "Trial Access"
    sql:  CASE WHEN ${TABLE}."4" > 0 THEN 1 END ;;
  }

  dimension: minus_4 {
    group_label: "Trial Access"
    sql:  CASE WHEN ${TABLE}."5" > 0 THEN 1 END ;;
  }


  set: detail {
    fields: [user_sso_guid_merged, current, minus_1, minus_2, minus_3, minus_4]
  }
}
