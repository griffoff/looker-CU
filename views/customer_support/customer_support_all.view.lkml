view: customer_support_all {
  derived_table: {
    sql: WITH
      new AS (
      SELECT
          case_origin
          ,cengage_unlimited_subscriber::string
          ,cengage_unlimited_trial::string
          ,closed_date::string
          ,closed::string
          ,course_key::string
          ,course_name
          ,core_isbn::string
          ,department
          ,escalated::string
          ,isbn
          ,isbn_name
          ,issue_type
          ,jira_escalated::string
          ,lms_subcategory
          ,opened_date::string
          ,primary_issue
          ,platform_service
          ,product
          ,root_cause
          ,sso_guid
      FROM uploads.support.escals_201961_2019918_current
      )
      ,old AS
      (
      SELECT
          case_origin
          ,cengage_unlimited_subscriber
          ,cengage_unlimited_trial::string
          ,closed_date::string
          ,closed::string
          ,course_key
          ,course_name
          ,core_isbn
          ,department
          ,escalated
          ,isbn
          ,isbn_name
          ,issue_type
          ,jira_escalated
          ,lms_subcategory
          ,opened_date::string
          ,primary_issue
          ,platform_service
          ,product
          ,root_cause
          ,sso_guid
      FROM uploads.cu.customer_support_cases20190707
      )
      SELECT * FROM new UNION SELECT * FROM old
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: case_origin {
    type: string
    sql: ${TABLE}."CASE_ORIGIN" ;;
  }

  dimension: cengage_unlimited_subscriberstring {
    type: string
    sql: ${TABLE}."CENGAGE_UNLIMITED_SUBSCRIBER::STRING" ;;
  }

  dimension: cengage_unlimited_trialstring {
    type: string
    sql: ${TABLE}."CENGAGE_UNLIMITED_TRIAL::STRING" ;;
  }

  dimension: closed_datestring {
    type: string
    sql: ${TABLE}."CLOSED_DATE::STRING" ;;
  }

  dimension: closedstring {
    type: string
    sql: ${TABLE}."CLOSED::STRING" ;;
  }

  dimension: course_keystring {
    type: string
    sql: ${TABLE}."COURSE_KEY::STRING" ;;
  }

  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }

  dimension: core_isbnstring {
    type: string
    sql: ${TABLE}."CORE_ISBN::STRING" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: escalatedstring {
    type: string
    sql: ${TABLE}."ESCALATED::STRING" ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}."ISBN" ;;
  }

  dimension: isbn_name {
    type: string
    sql: ${TABLE}."ISBN_NAME" ;;
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}."ISSUE_TYPE" ;;
  }

  dimension: jira_escalatedstring {
    type: string
    sql: ${TABLE}."JIRA_ESCALATED::STRING" ;;
  }

  dimension: lms_subcategory {
    type: string
    sql: ${TABLE}."LMS_SUBCATEGORY" ;;
  }

  dimension: opened_datestring {
    type: string
    sql: ${TABLE}."OPENED_DATE::STRING" ;;
  }

  dimension: primary_issue {
    type: string
    sql: ${TABLE}."PRIMARY_ISSUE" ;;
  }

  dimension: platform_service {
    type: string
    sql: ${TABLE}."PLATFORM_SERVICE" ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}."PRODUCT" ;;
  }

  dimension: root_cause {
    type: string
    sql: ${TABLE}."ROOT_CAUSE" ;;
  }

  dimension: sso_guid {
    type: string
    sql: ${TABLE}."SSO_GUID" ;;
  }

  set: detail {
    fields: [
      case_origin,
      cengage_unlimited_subscriberstring,
      cengage_unlimited_trialstring,
      closed_datestring,
      closedstring,
      course_keystring,
      course_name,
      core_isbnstring,
      department,
      escalatedstring,
      isbn,
      isbn_name,
      issue_type,
      jira_escalatedstring,
      lms_subcategory,
      opened_datestring,
      primary_issue,
      platform_service,
      product,
      root_cause,
      sso_guid
    ]
  }
}
