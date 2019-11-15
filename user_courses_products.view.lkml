

view: user_courses_products {
  derived_table: {
    sql:
      SELECT
          u.*
          ,dp.discipline AS discipline
      FROM cu_user_analysis.user_courses u
      LEFT JOIN ${dim_course.SQL_TABLE_NAME} AS dc ON u.olr_course_key = dc.olr_course_key
      LEFT JOIN ${dim_product.SQL_TABLE_NAME}  AS dp ON dp.isbn13 = u.isbn
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}."DISCIPLINE" ;;
  }

  dimension: ucp_pk {
    type: string
    sql: COALESCE(${TABLE}."USER_SSO_GUID", ${TABLE}."INSTRUCTOR_GUID") || ${TABLE}."OLR_COURSE_KEY";;
    primary_key: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: instructor_guid {
    type: string
    sql: ${TABLE}."INSTRUCTOR_GUID" ;;
  }

  dimension: is_new_customer {
    type: number
    sql: ${TABLE}."IS_NEW_CUSTOMER" ;;
  }

  dimension: is_returning_customer {
    type: number
    sql: ${TABLE}."IS_RETURNING_CUSTOMER" ;;
  }

  dimension: captured_key {
    type: string
    sql: ${TABLE}."CAPTURED_KEY" ;;
  }

  dimension: olr_course_key {
    type: string
    sql: ${TABLE}."OLR_COURSE_KEY" ;;
  }

  dimension: olr_enrollment_key {
    type: string
    sql: ${TABLE}."OLR_ENROLLMENT_KEY" ;;
  }

  dimension: olr_activation_key {
    type: string
    sql: ${TABLE}."OLR_ACTIVATION_KEY" ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}."ISBN" ;;
  }

  dimension: activation_code {
    type: string
    sql: ${TABLE}."ACTIVATION_CODE" ;;
  }

  dimension: activation_date {
    type: date
    sql: ${TABLE}."ACTIVATION_DATE" ;;
  }

  dimension_group: course_start_date {
    type: time
    sql: ${TABLE}."COURSE_START_DATE" ;;
  }

  dimension_group: course_end_date {
    type: time
    sql: ${TABLE}."COURSE_END_DATE" ;;
  }

  dimension_group: date_added {
    type: time
    sql: ${TABLE}."DATE_ADDED" ;;
  }

  dimension_group: enrollment_date {
    type: time
    sql: ${TABLE}."ENROLLMENT_DATE" ;;
  }

  dimension: net_price {
    type: string
    sql: ${TABLE}."NET_PRICE" ;;
  }

  dimension: net_price_enrolled {
    type: number
    sql: ${TABLE}."NET_PRICE_ENROLLED" ;;
  }

  dimension: net_price_activated {
    type: number
    sql: ${TABLE}."NET_PRICE_ACTIVATED" ;;
  }

  dimension: net_price_on_dashboard {
    type: number
    sql: ${TABLE}."NET_PRICE_ON_DASHBOARD" ;;
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: entity_name {
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
  }

  dimension: cui_flag {
    type: string
    sql: ${TABLE}."CUI_FLAG" ;;
  }

  dimension: cu_contract_id {
    type: string
    sql: ${TABLE}."CU_CONTRACT_ID" ;;
  }

  dimension: on_dashboard_courseware {
    type: string
    sql: ${TABLE}."ON_DASHBOARD_COURSEWARE" ;;
  }

  dimension: on_dashboard_isbn_only {
    type: string
    sql: ${TABLE}."ON_DASHBOARD_ISBN_ONLY" ;;
  }

  dimension: enrolled {
    type: string
    sql: ${TABLE}."ENROLLED" ;;
  }

  dimension: activated {
    type: string
    sql: ${TABLE}."ACTIVATED" ;;
  }

  dimension: course_used_flag {
    type: string
    sql: ${TABLE}."COURSE_USED_FLAG" ;;
  }

  dimension_group: first_session_start {
    type: time
    sql: ${TABLE}."FIRST_SESSION_START" ;;
  }

  dimension_group: latest_session_start {
    type: time
    sql: ${TABLE}."LATEST_SESSION_START" ;;
  }

  dimension: session_count {
    type: number
    sql: ${TABLE}."SESSION_COUNT" ;;
  }

  dimension: grace_period_flag {
    type: string
    sql: ${TABLE}."GRACE_PERIOD_FLAG" ;;
  }

  set: detail {
    fields: [
      discipline,
      user_sso_guid,
      instructor_guid,
      is_new_customer,
      is_returning_customer,
      captured_key,
      olr_course_key,
      olr_enrollment_key,
      olr_activation_key,
      isbn,
      activation_code,
      activation_date,
      course_start_date_time,
      course_end_date_time,
      date_added_time,
      enrollment_date_time,
      net_price,
      net_price_enrolled,
      net_price_activated,
      net_price_on_dashboard,
      product_type,
      entity_name,
      cui_flag,
      cu_contract_id,
      on_dashboard_courseware,
      on_dashboard_isbn_only,
      enrolled,
      activated,
      course_used_flag,
      first_session_start_time,
      latest_session_start_time,
      session_count,
      grace_period_flag
    ]
  }
}
