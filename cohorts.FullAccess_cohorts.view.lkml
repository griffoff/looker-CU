explore: FullAccess_cohort {}

view: FullAccess_cohort {
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
          ,governmentdefinedacademicterm
          ,subscription_state
      FROM prod.cu_user_analysis.subscription_events_merged s
      LEFT JOIN term_dates_five_most_recent d
        ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
        OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
      WHERE subscription_state = 'full_access'
      )
      SELECT
          *
      FROM subscription_terms
      PIVOT (COUNT (subscription_state) FOR governmentdefinedacademicterm IN ('Spring 2019', 'Fall 2019', 'Summer 2018', 'Spring 2018', 'Fall 2018'))
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: ${user_sso_guid_merged} || ${fall_2019} || ${spring_2019} || ${summer_2018} || ${spring_2019} || ${fall_2018} ;;
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  }

    dimension: fall_2019 {
      group_label: "Full Access"
      type: number
      label: "Fall 2019"
      sql: CASE WHEN ${TABLE}."'Fall 2019'" > 0 THEN 1 END;;
    }

    dimension: spring_2019 {
      group_label: "Full Access"
      type: number
      label: "Spring 2019"
      sql:  CASE WHEN ${TABLE}."'Spring 2019'" > 0 THEN 1 END ;;
    }

    dimension: summer_2018 {
      group_label: "Full Access"
      type: number
      label: "Summer 2018"
      sql:  CASE WHEN ${TABLE}."'Summer 2018'" > 0 THEN 1 END ;;
    }

    dimension: spring_2018 {
      group_label: "Full Access"
      type: number
      label: "Spring 2018"
      sql:  CASE WHEN ${TABLE}."'Spring 2020'" > 0 THEN 1 END ;;
    }

    dimension: fall_2018 {
      group_label: "Full Access"
      type: number
      label: "Fall 2018"
      sql:  CASE WHEN ${TABLE}."'Fall 2018'" > 0 THEN 1 END ;;
    }


  set: detail {
    fields: [user_sso_guid_merged, fall_2019, spring_2019, summer_2018, spring_2018, fall_2018]
  }
}
