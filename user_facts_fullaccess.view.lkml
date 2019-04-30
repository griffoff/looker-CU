explore: user_facts_fullaccess {}

view: user_facts_fullaccess {
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
    ,subscription_terms AS
    (
    SELECT
        user_sso_guid_merged
          ,governmentdefinedacademicterm
          ,subscription_state
      FROM prod.cu_user_analysis.subscription_events_merged s
      LEFT JOIN term_dates d
        ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
        OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
      WHERE subscription_state = 'full_access'
      )
      SELECT
          *
      FROM subscription_terms
      PIVOT (COUNT (subscription_state) FOR governmentdefinedacademicterm IN ('Fall 2019', 'Spring 2019', 'Summer 2019', 'Fall 2020'))
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: ${user_sso_guid_merged} || ${fall_2019} || ${spring_2019} || ${summer_2019} || ${fall_2020} ;;
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  }

  dimension: fall_2019 {
    group_label: "Cohort Analysis"
    type: number
    label: "Fall 2019"
    sql: CASE WHEN ${TABLE}."'Fall 2019'" > 0 THEN 1 END;;
  }

  dimension: spring_2019 {
    group_label: "Cohort Analysis"
    type: number
    label: "Spring 2019"
    sql:  CASE WHEN ${TABLE}."'Spring 2019'" > 0 THEN 1 END ;;
  }

  dimension: summer_2019 {
    group_label: "Cohort Analysis"
    type: number
    label: "Summer 2019"
    sql:  CASE WHEN ${TABLE}."'Summer 2019'" > 0 THEN 1 END ;;
  }

  dimension: fall_2020 {
    group_label: "Cohort Analysis"
    type: number
    label: "Fall 2020"
    sql:  CASE WHEN ${TABLE}."'Fall 2020'" > 0 THEN 1 END ;;
  }

  dimension: fall19_spring19_renewal {
    group_label: "Cohort Analysis"
    type: number
    label: "Fall 2019 renew for Spring 2019"
    sql:  CASE WHEN ${TABLE}."'Fall 2019'" > 0 AND ${TABLE}."'Spring 2019'" > 0 THEN 1 END ;;
  }

  set: detail {
    fields: [user_sso_guid_merged, fall_2019, spring_2019, summer_2019, fall_2020]
  }
}
