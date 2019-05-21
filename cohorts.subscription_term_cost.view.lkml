include: "cohorts_base.view"

view: subscription_term_cost {
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
            FROM prod.cu_user_analysis_dev.subscription_event_merged s
            LEFT JOIN term_dates_five_most_recent d
              ON (s.subscription_end::DATE > d.end_date AND s.subscription_start < d.start_date)
              OR (s.subscription_start::DATE > d.start_date AND s.subscription_start::DATE < d.end_date)
            LEFT JOIN user_entity_chron_desc_course_rank e
              ON s.user_sso_guid = e.user_sso_guid
              AND chron_desc_course_rank = 1
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
            WHERE user_term_sub_rank = 1
            )
            ,previous_five_subscription_term_costs AS
            (
            SELECT
              *
            FROM subscription_term_costs
            PIVOT (SUM (term_subscription_cost) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
            )
            SELECT
              user_sso_guid_merged
              ,governmentdefinedacademicterm
              ,subscription_state
              ,entity_name
              ,SUM(1) AS "1"
              ,SUM(2) AS "2"
              ,SUM(3) AS "3"
              ,SUM(4) AS "4"
              ,SUM(5) AS "5"
            FROM previous_five_subscription_term_costs
            GROUP BY user_sso_guid_merged, governmentdefinedacademicterm, subscription_state, entity_name
       ;;
  }

  set: marketing_fields {
    fields: [subscription_term_cost.institutional_cu_cost_previous_term]
  }


  dimension: term_guid {
    type: string
    sql:  ${TABLE}."USER_SSO_GUID_MERGED" || ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ||  ${TABLE}."ENTITY_NAME" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
    hidden: yes
  }

  dimension: entity_name {
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
    hidden: yes
  }

  dimension: current {group_label: "CU Term Cost ($)" }

  dimension: minus_1 {group_label: "CU Term Cost ($)"}

  dimension: minus_2 {group_label: "CU Term Cost ($)"}

  dimension: minus_3 {group_label: "CU Term Cost ($)"}

  dimension: minus_4 {group_label: "CU Term Cost ($)"}

  measure: institutional_cu_cost_previous_term {
    group_label: "Institutional savings"
    label: "Institutional CU cost - previous term"
    view_label: "Institution"
    type: sum
    sql: ${minus_1} ;;
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
