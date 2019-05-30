include: "user_courses.view"
include: "//core/common.lkml"

view: user_courses_dev {
  extends: [user_courses]
  view_label: "User Courses Dev"
  sql_table_name: dev.cu_user_analysis_dev.user_courses ;;

  set: marketing_fields {
    fields: [user_courses_dev.net_price_enrolled, user_courses_dev.amount_to_upgrade_tiers,ala_cart_purchase]
  }

  dimension: instructor_guid {
    type: string
    sql: ${TABLE}."instructor_guid" ;;
  }

  dimension: net_price_enrolled {
    view_label: "Learner Profile"
    label: "$ value of enrolled courses"
    type: number
    sql: ${TABLE}."NET_PRICE_ENROLLED" ;;
  }


  dimension: amount_to_upgrade_tiers {
    view_label: "Learner Profile"
    type: string
    sql: CASE
            WHEN ${net_price_enrolled} = 0 THEN '$0.00'
            WHEN ${net_price_enrolled} < 10 THEN '$0.01-$9.99'
            WHEN ${net_price_enrolled} < 20 THEN '$10.00-$19.99'
            WHEN ${net_price_enrolled} < 30 THEN '$20.00-$29.99'
            WHEN ${net_price_enrolled} < 40 THEN '$30.00-$39.99'
            WHEN ${net_price_enrolled} < 50 THEN '$40.00-$49.99'
            ELSE 'over $50.00'
            END
            ;;
  }

  dimension: activation_code {
    type: string
    sql: ${TABLE}."ACTIVATION_CODE" ;;
  }

  dimension_group: first_session_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."FIRST_SESSION_START" ;;
  }

  dimension_group: latest_session_start {
    type: duration
    intervals: [day, week, month]
    sql_start: ${TABLE}."LATEST_SESSION_START" ;;
    sql_end: CURRENT_DATE() ;;
  }

  dimension: session_count {
    type: string
    sql: ${TABLE}."SESSION_COUNT" ;;
  }


  dimension: activation_date {
    type: date
    # intervals: [day, week, month]
  }

  dimension: isbn {
    type: string
  }

  dimension: date_added {
    type: date
  }

  dimension: net_price_on_dashboard {
    type: number
  }


  measure: count {
    type: count
    drill_fields: []
  }



  dimension: cui_flag {
    type: string
    sql: ${TABLE}.cui_flag;;
    hidden: no
    label: "CUI Flag"
    description: "Flag to identify Cengage Unlimited Institutional Subscription"
  }

  dimension: cu_contract_id {
    type: string
    sql: ${TABLE}.cu_contract_id;;
    label: "CU Contract ID"
    description: "Unique contract ID for Cengage Unlimited Subscription"

    hidden: no
  }

  dimension: cu_flag {
    type: yesno
    sql: ${cu_contract_id} IS NOT NULL OR cui_flag = 'Y' ;;
  }




  measure: ala_cart_purchase {
    label: "a la cart purchase count"
    type: count_distinct
    sql: CASE WHEN ${cu_flag} = 'Yes' THEN ${cu_contract_id} END;;
  }



  measure: activated_courses {
    label: "# Users with Activated Courses"
    type: count_distinct
    sql: case when ${olr_activation_key} is not null then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }

  measure: found_courses {
    label: "# Users with Matched OLR Course Key"
    type: count_distinct
    sql: case when ${olr_course_key} is not null then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }

  measure: captured_course_keys {
    label: "# Users with Captured Course Keys"
    type: count_distinct
    sql: case when ${captured_key} is not null then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }


}
