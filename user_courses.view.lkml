view: user_courses {
  view_label: "User Courses"
  sql_table_name: CU_USER_ANALYSIS.USER_COURSES ;;

  dimension: captured_key {
    type: string
    sql: ${TABLE}."CAPTURED_KEY" ;;
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: pk {
    sql: HASH(${user_sso_guid}, ${captured_key}) ;;
    primary_key: yes
    hidden: yes
  }

  dimension: olr_activation_key {
    type: string
    sql: ${TABLE}."OLR_ACTIVATION_KEY" ;;
  }

  dimension: olr_course_key {
    type: string
    sql: ${TABLE}."OLR_COURSE_KEY" ;;
  }

  dimension: course_start_date {
    type: date
  }

  dimension: course_end_date {
    type: date
  }

  dimension: product_type {
    type: string
    description: "can be filtered on to differentiate between MT,WA,SAM,etc."
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: olr_enrollment_key {
    type: string
    sql: ${TABLE}."OLR_ENROLLMENT_KEY" ;;
    hidden: yes
  }

  dimension: enrollment_date {
    label: "Date on which user enrolled into a course"
    type: date
  }

  measure: enrolled_courses {
    label: "# Users with Enrolled Courses"
    description: "Number of users with an enrolled course"
    type: count_distinct
    sql: case when ${olr_enrollment_key} is not null then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }

}
