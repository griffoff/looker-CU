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

  dimension: product_type {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: olr_enrollment_key {
    type: string
    sql: ${TABLE}."OLR_ENROLLMENT_KEY" ;;
    hidden: yes
  }

  dimension: enrollment_date {
    type: date
  }

  measure: enrolled_courses {
    label: "# Users with Enrolled Courses"
    type: count_distinct
    sql: case when ${olr_enrollment_key} is not null then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }

}
