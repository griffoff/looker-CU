include: "user_courses.view"
include: "//core/common.lkml"
view: user_courses_dev {
  extends: [user_courses]
  view_label: "User Courses Dev"
  sql_table_name: ZPG.user_courses ;;

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

  dimension: olr_activation_key {
    type: string
    sql: ${TABLE}."OLR_ACTIVATION_KEY" ;;
  }

  dimension: olr_course_key {
    type: string
    sql: ${TABLE}."OLR_COURSE_KEY" ;;
  }

  dimension: session_count {
    type: string
    sql: ${TABLE}."SESSION_COUNT" ;;
  }

  dimension: course_start_date {
    type: date
  }

  dimension: course_end_date {
    type: date
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