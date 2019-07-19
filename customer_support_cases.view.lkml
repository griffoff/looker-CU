view: customer_support_cases {
  derived_table: {
    sql: SELECT u.*
                ,s.polarity
                ,s.subjectivity
         FROM uploads.cu.customer_support_cases20190707 u left join dev.zsp.sentiment s on u.case_number = s.case_number
      ;;
  }

  measure: count {
    label: "Case count"
    type: count
    drill_fields: [customer_support_case_fields*]
  }


  measure: unique_count {
    label: "Unique Case count"
    description: "Distinct count of case id field"
    type: count_distinct
    sql:  ${case_id};;
    drill_fields: [customer_support_case_fields*]
  }

  measure: duration {
    label: "Case Duration"
    description: "Days case took to close"
    type: average
    sql: ${days_case_duration} ;;
  }

  dimension: polarity {
    type: number
    sql: ${TABLE}."POLARITY" ;;
  }

  dimension: subjectivity {
    type: number
    sql: ${TABLE}."SUBJECTIVITY" ;;
  }


  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: case_number {
    type: number
    sql: ${TABLE}."CASE_NUMBER" ;;
    primary_key: yes
  }



#   dimension_group: date_time_opened {
#     type: time
#     timeframes: [raw, time,  date, week, month, quarter, year]
#     sql: ${TABLE}."DATE_TIME_OPENED"
#     group_label: "Opened Time"
#   }

  dimension: date_time_closed {
    type: string
    sql: ${TABLE}."DATE_TIME_CLOSED" ;;
  }

  dimension: age_hours_ {
    type: string
    sql: ${TABLE}."AGE_HOURS_" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: primary_issue {
    type: string
    sql: ${TABLE}."PRIMARY_ISSUE" ;;
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}."ISSUE_TYPE" ;;
  }

  dimension: root_cause {
    type: string
    sql: ${TABLE}."ROOT_CAUSE" ;;
  }

  dimension: platform_service {
    type: string
    sql: ${TABLE}."PLATFORM_SERVICE" ;;
  }

  dimension: ir_code {
    type: string
    sql: ${TABLE}."IR_CODE" ;;
  }

  dimension: case_origin {
    type: string
    sql: ${TABLE}."CASE_ORIGIN" ;;
  }



  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: contact_type {
    type: string
    sql: ${TABLE}."CONTACT_TYPE" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_email {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL" ;;
  }

  dimension: web_name {
    type: string
    sql: ${TABLE}."WEB_NAME" ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}."PRIORITY" ;;
  }

  dimension: cengage_unlimited_subscriber {
    type: string
    sql: ${TABLE}."CENGAGE_UNLIMITED_SUBSCRIBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: auto_close {
    type: string
    sql: ${TABLE}."AUTO_CLOSE" ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}."ISBN" ;;
  }

  dimension: core_isbn {
    type: string
    sql: ${TABLE}."CORE_ISBN" ;;
  }

  dimension: sso_isbn_13 {
    type: string
    sql: ${TABLE}."SSO_ISBN_13" ;;
  }

  dimension: case_timer {
    type: string
    sql: ${TABLE}."CASE_TIMER" ;;
  }

  dimension: total_wait_external {
    type: string
    sql: ${TABLE}."TOTAL_WAIT_EXTERNAL" ;;
  }

  dimension: total_wait_external_hrs_ {
    type: string
    sql: ${TABLE}."TOTAL_WAIT_EXTERNAL_HRS_" ;;
  }

  dimension: total_wait_internal {
    type: string
    sql: ${TABLE}."TOTAL_WAIT_INTERNAL" ;;
  }

  dimension: total_wait_internal_hrs_ {
    type: string
    sql: ${TABLE}."TOTAL_WAIT_INTERNAL_HRS_" ;;
  }

  dimension: case_timer_ownership {
    type: string
    sql: ${TABLE}."CASE_TIMER_OWNERSHIP" ;;
  }

  dimension: jira_escalated {
    type: string
    sql: ${TABLE}."JIRA_ESCALATED" ;;
  }

  dimension: jira_ticket_id {
    type: string
    sql: ${TABLE}."JIRA_TICKET_ID" ;;
  }

  dimension: case_owner {
    type: string
    sql: ${TABLE}."CASE_OWNER" ;;
  }

  dimension: case_owner_alias {
    type: string
    sql: ${TABLE}."CASE_OWNER_ALIAS" ;;
  }

  dimension: case_owner_role {
    type: string
    sql: ${TABLE}."CASE_OWNER_ROLE" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: created_alias {
    type: string
    sql: ${TABLE}."CREATED_ALIAS" ;;
  }

  dimension: case_last_modified_by {
    type: string
    sql: ${TABLE}."CASE_LAST_MODIFIED_BY" ;;
  }

  dimension: case_last_modified_alias {
    type: string
    sql: ${TABLE}."CASE_LAST_MODIFIED_ALIAS" ;;
  }

  dimension: subject {
    type: string
    sql: ${TABLE}."SUBJECT" ;;
  }

  dimension: parent_case_number {
    type: string
    sql: ${TABLE}."PARENT_CASE_NUMBER" ;;
  }

  dimension: parent_case_id {
    type: string
    sql: ${TABLE}."PARENT_CASE_ID" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: case_record_type {
    type: string
    sql: ${TABLE}."CASE_RECORD_TYPE" ;;
  }

  dimension: case_reason {
    type: string
    sql: ${TABLE}."CASE_REASON" ;;
  }

  dimension_group: opened_date {
    type: time
    label: "Opened Date"
    timeframes: [raw,  date, week, month, quarter, year]
    sql: TRY_TO_DATE(COALESCE(opened_date,NULL)) ;;
  }

  #   dimension_group: date_time_opened {
#     type: time
#     timeframes: [raw, time,  date, week, month, quarter, year]
#     sql: ${TABLE}."DATE_TIME_OPENED"
#     group_label: "Opened Time"
#   }


  dimension: case_date_time_last_modified {
    type: string
    sql: ${TABLE}."CASE_DATE_TIME_LAST_MODIFIED" ;;
  }

  dimension: case_last_modified_date {
    type: string
    sql: ${TABLE}."CASE_LAST_MODIFIED_DATE" ;;
  }


  dimension_group: closed_date {
    type: time
    label: "Closed Date"
    timeframes: [raw,  date, week, month, quarter, year]
    sql: TRY_TO_DATE(COALESCE(closed_date,NULL)) ;;
  }


  dimension_group: case_duration {
    type: duration
    label: "Case Duration"
    sql_start:  TRY_TO_DATE(COALESCE(opened_date,NULL));;  # often this is a single database column
    sql_end: TRY_TO_DATE(COALESCE(closed_date,NULL)) ;;  # often this is a single database column
    intervals: [day, week, month] # valid intervals described below
  }


  dimension: open {
    type: string
    sql: ${TABLE}."OPEN" ;;
  }

  dimension: closed {
    type: string
    sql: ${TABLE}."CLOSED" ;;
  }

  dimension: escalated {
    type: string
    sql: ${TABLE}."ESCALATED" ;;
  }

  dimension: case_currency {
    type: string
    sql: ${TABLE}."CASE_CURRENCY" ;;
  }

  dimension: case_id {
    type: string
    sql: ${TABLE}."CASE_ID" ;;
  }

  dimension: web_company {
    type: string
    sql: ${TABLE}."WEB_COMPANY" ;;
  }

  dimension: web_email {
    type: string
    sql: ${TABLE}."WEB_EMAIL" ;;
  }

  dimension: web_phone {
    type: string
    sql: ${TABLE}."WEB_PHONE" ;;
  }

  dimension: contact_record_type {
    type: string
    sql: ${TABLE}."CONTACT_RECORD_TYPE" ;;
  }

  dimension: contact_account_name {
    type: string
    sql: ${TABLE}."CONTACT_ACCOUNT_NAME" ;;
  }

  dimension: contact_account_id {
    type: string
    sql: ${TABLE}."CONTACT_ACCOUNT_ID" ;;
  }

  dimension: job_title {
    type: string
    sql: ${TABLE}."JOB_TITLE" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: last_activity {
    type: string
    sql: ${TABLE}."LAST_ACTIVITY" ;;
  }

  dimension: contact_currency {
    type: string
    sql: ${TABLE}."CONTACT_CURRENCY" ;;
  }

  dimension: contact_last_modified_date {
    type: string
    sql: ${TABLE}."CONTACT_LAST_MODIFIED_DATE" ;;
  }

  dimension: contact_created_date {
    type: string
    sql: ${TABLE}."CONTACT_CREATED_DATE" ;;
  }

  dimension: last_stay_in_touch_request_date {
    type: string
    sql: ${TABLE}."LAST_STAY_IN_TOUCH_REQUEST_DATE" ;;
  }

  dimension: last_stay_in_touch_save_date {
    type: string
    sql: ${TABLE}."LAST_STAY_IN_TOUCH_SAVE_DATE" ;;
  }

  dimension: account_owner {
    type: string
    sql: ${TABLE}."ACCOUNT_OWNER" ;;
  }

  dimension: account_owner_alias {
    type: string
    sql: ${TABLE}."ACCOUNT_OWNER_ALIAS" ;;
  }

  dimension: account_record_type {
    type: string
    sql: ${TABLE}."ACCOUNT_RECORD_TYPE" ;;
  }

  dimension: industry {
    type: string
    sql: ${TABLE}."INDUSTRY" ;;
  }

  dimension: employees {
    type: string
    sql: ${TABLE}."EMPLOYEES" ;;
  }

  dimension: account_id {
    type: string
    sql: ${TABLE}."ACCOUNT_ID" ;;
  }

  dimension: contact_id {
    type: string
    sql: ${TABLE}."CONTACT_ID" ;;
  }

  dimension: acct_mag_id {
    type: string
    sql: ${TABLE}."ACCT_MAG_ID" ;;
  }

  dimension: alert_shown {
    type: string
    sql: ${TABLE}."ALERT_SHOWN" ;;
  }

  dimension: alert_tracking {
    type: string
    sql: ${TABLE}."ALERT_TRACKING" ;;
  }

  dimension: answers {
    type: string
    sql: ${TABLE}."ANSWERS" ;;
  }

  dimension: assign_using_active_assignment_rule {
    type: string
    sql: ${TABLE}."ASSIGN_USING_ACTIVE_ASSIGNMENT_RULE" ;;
  }

  dimension: bybass_validation {
    type: string
    sql: ${TABLE}."BYBASS_VALIDATION" ;;
  }

  dimension: callback_number {
    type: string
    sql: ${TABLE}."CALLBACK_NUMBER" ;;
  }

  dimension: case_created_by_external_admin_ {
    type: string
    sql: ${TABLE}."CASE_CREATED_BY_EXTERNAL_ADMIN_" ;;
  }

  dimension: case_owner_dupe {
    type: string
    sql: ${TABLE}."CASE_OWNER_DUPE" ;;
  }

  dimension: case_owner_dupe_name {
    type: string
    sql: ${TABLE}."CASE_OWNER_DUPE_NAME" ;;
  }

  dimension: case_power_of_one {
    type: string
    sql: ${TABLE}."CASE_POWER_OF_ONE" ;;
  }

  dimension: cengage_org {
    type: string
    sql: ${TABLE}."CENGAGE_ORG" ;;
  }

  dimension: cengage_unlimited_trial {
    type: string
    sql: ${TABLE}."CENGAGE_UNLIMITED_TRIAL" ;;
  }

  dimension: component {
    type: string
    sql: ${TABLE}."COMPONENT" ;;
  }

  dimension: contact_or_loggless_email {
    type: string
    sql: ${TABLE}."CONTACT_OR_LOGGLESS_EMAIL" ;;
  }

  dimension: content_editor {
    type: string
    sql: ${TABLE}."CONTENT_EDITOR" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }

  dimension: creation_timer {
    type: string
    sql: ${TABLE}."CREATION_TIMER" ;;
  }

  dimension: deactivated_owner {
    type: string
    sql: ${TABLE}."DEACTIVATED_OWNER" ;;
  }

  dimension: do_not_contact_flag {
    type: string
    sql: ${TABLE}."DO_NOT_CONTACT_FLAG" ;;
  }

  dimension: external_participant_emails {
    type: string
    sql: ${TABLE}."EXTERNAL_PARTICIPANT_EMAILS" ;;
  }

  dimension: internal_participant_emails {
    type: string
    sql: ${TABLE}."INTERNAL_PARTICIPANT_EMAILS" ;;
  }

  dimension: isbn_name {
    type: string
    sql: ${TABLE}."ISBN_NAME" ;;
  }

  dimension: is_name {
    type: string
    sql: ${TABLE}."IS_NAME" ;;
  }

  dimension: is_vip {
    type: string
    sql: ${TABLE}."IS_VIP" ;;
  }

  dimension: jira_customer {
    type: string
    sql: ${TABLE}."JIRA_CUSTOMER" ;;
  }

  dimension: jira_description {
    type: string
    sql: ${TABLE}."JIRA_DESCRIPTION" ;;
  }

  dimension: jira_institution {
    type: string
    sql: ${TABLE}."JIRA_INSTITUTION" ;;
  }

  dimension: jira_issue_link {
    type: string
    sql: ${TABLE}."JIRA_ISSUE_LINK" ;;
  }

  dimension: jira_priority {
    type: string
    sql: ${TABLE}."JIRA_PRIORITY" ;;
  }

  dimension: jira_summary {
    type: string
    sql: ${TABLE}."JIRA_SUMMARY" ;;
  }

  dimension: jira_ticket_status {
    type: string
    sql: ${TABLE}."JIRA_TICKET_STATUS" ;;
  }

  dimension: last_num_hours {
    type: string
    sql: ${TABLE}."LAST_NUM_HOURS" ;;
  }

  dimension: last_modified_timer {
    type: string
    sql: ${TABLE}."LAST_MODIFIED_TIMER" ;;
  }

  dimension: last_timer_change {
    type: string
    sql: ${TABLE}."LAST_TIMER_CHANGE" ;;
  }

  dimension: lms_subcategory {
    type: string
    sql: ${TABLE}."LMS_SUBCATEGORY" ;;
  }

  dimension: logless {
    type: string
    sql: ${TABLE}."LOGLESS" ;;
  }

  dimension: magellan_id {
    type: string
    sql: ${TABLE}."MAGELLAN_ID" ;;
  }

  dimension: mind_app_subcategory {
    type: string
    sql: ${TABLE}."MIND_APP_SUBCATEGORY" ;;
  }

  dimension: mobile_os_subcategory {
    type: string
    sql: ${TABLE}."MOBILE_OS_SUBCATEGORY" ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}."PRODUCT" ;;
  }

  dimension: product_group {
    type: string
    sql: ${TABLE}."PRODUCT_GROUP" ;;
  }

  dimension: product_manager {
    type: string
    sql: ${TABLE}."PRODUCT_MANAGER" ;;
  }

  dimension: stage {
    type: string
    sql: ${TABLE}."STAGE" ;;
  }

  dimension: project {
    type: string
    sql: ${TABLE}."PROJECT" ;;
  }

  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }

  dimension: subject_major {
    type: string
    sql: ${TABLE}."SUBJECT_MAJOR" ;;
  }

  dimension: subject_minor {
    type: string
    sql: ${TABLE}."SUBJECT_MINOR" ;;
  }

  dimension: submitter_email {
    type: string
    sql: ${TABLE}."SUBMITTER_EMAIL" ;;
  }

  dimension: tell_us_a_little_about_yourself {
    type: string
    sql: ${TABLE}."TELL_US_A_LITTLE_ABOUT_YOURSELF" ;;
  }

  dimension: vip_level {
    type: string
    sql: ${TABLE}."VIP_LEVEL" ;;
  }

  dimension: alert_shown_2 {
    type: string
    sql: ${TABLE}."ALERT_SHOWN_2" ;;
  }

  dimension: alert_tracking_3 {
    type: string
    sql: ${TABLE}."ALERT_TRACKING_3" ;;
  }

  dimension: person_uid {
    type: string
    sql: ${TABLE}."PERSON_UID" ;;
  }

  dimension: sso_guid {
    type: string
    sql: ${TABLE}."SSO_GUID" ;;
  }

  dimension: mailing_state_province {
    type: string
    sql: ${TABLE}."MAILING_STATE_PROVINCE" ;;
  }

  dimension: billing_state_province {
    type: string
    sql: ${TABLE}."BILLING_STATE_PROVINCE" ;;
  }

  dimension: shipping_state_province {
    type: string
    sql: ${TABLE}."SHIPPING_STATE_PROVINCE" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: customer_support_case_fields {
    fields: [
      count,
      _file,
      _line,
      case_number,
      unique_count,
      polarity,
      subjectivity,
#       date_time_opened,
      date_time_closed,
      age_hours_,
      status,
      primary_issue,
      issue_type,
      root_cause,
      platform_service,
      ir_code,
      case_origin,
      account_type,
      contact_type,
      account_name,
      contact_name,
      contact_email,
      web_name,
      priority,
      cengage_unlimited_subscriber,
      description,
      auto_close,
      isbn,
      core_isbn,
      sso_isbn_13,
      case_timer,
      total_wait_external,
      total_wait_external_hrs_,
      total_wait_internal,
      total_wait_internal_hrs_,
      case_timer_ownership,
      jira_escalated,
      jira_ticket_id,
      case_owner,
      case_owner_alias,
      case_owner_role,
      created_by,
      created_alias,
      case_last_modified_by,
      case_last_modified_alias,
      subject,
      parent_case_number,
      parent_case_id,
      type,
      case_record_type,
      case_reason,
      opened_date_raw,
      opened_date_date,
      opened_date_month,
      opened_date_week,
      case_date_time_last_modified,
      case_last_modified_date,
      closed_date_raw,
      closed_date_date,
      closed_date_week,
      closed_date_month,
      days_case_duration,
      weeks_case_duration,
      months_case_duration,
      open,
      closed,
      escalated,
      case_currency,
      case_id,
      web_company,
      web_email,
      web_phone,
      contact_record_type,
      contact_account_name,
      contact_account_id,
      job_title,
      department,
      last_activity,
      contact_currency,
      contact_last_modified_date,
      contact_created_date,
      last_stay_in_touch_request_date,
      last_stay_in_touch_save_date,
      account_owner,
      account_owner_alias,
      account_record_type,
      industry,
      employees,
      account_id,
      contact_id,
      acct_mag_id,
      alert_shown,
      alert_tracking,
      answers,
      assign_using_active_assignment_rule,
      bybass_validation,
      callback_number,
      case_created_by_external_admin_,
      case_owner_dupe,
      case_owner_dupe_name,
      case_power_of_one,
      cengage_org,
      cengage_unlimited_trial,
      component,
      contact_or_loggless_email,
      content_editor,
      course_key,
      course_name,
      creation_timer,
      deactivated_owner,
      do_not_contact_flag,
      external_participant_emails,
      internal_participant_emails,
      isbn_name,
      is_name,
      is_vip,
      jira_customer,
      jira_description,
      jira_institution,
      jira_issue_link,
      jira_priority,
      jira_summary,
      jira_ticket_status,
      last_num_hours,
      last_modified_timer,
      last_timer_change,
      lms_subcategory,
      logless,
      magellan_id,
      mind_app_subcategory,
      mobile_os_subcategory,
      product,
      product_group,
      product_manager,
      stage,
      project,
      sub_category,
      subject_major,
      subject_minor,
      submitter_email,
      tell_us_a_little_about_yourself,
      vip_level,
      alert_shown_2,
      alert_tracking_3,
      person_uid,
      sso_guid,
      mailing_state_province,
      billing_state_province,
      shipping_state_province,
      _fivetran_synced_time,
      duration
    ]
  }
}
