view: discount_email_control_groups {
  derived_table: {
    sql: SELECT * FROM uploads.cu.upgrades_guids_upload_full_send_02212019_ko
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: students_email_campaign_criteria_user_guid {
    type: string
    sql: ${TABLE}."STUDENTS_EMAIL_CAMPAIGN_CRITERIA_USER_GUID" ;;
  }

  dimension: rand {
    type: number
    sql: ${TABLE}."RAND" ;;
  }

  dimension: trial_run_group {
    type: string
    sql: ${TABLE}."TRIAL_RUN_GROUP" ;;
  }

  dimension: test_send_group {
    type: string
    sql: ${TABLE}."TEST_SEND_GROUP" ;;
  }

  dimension: full_send_group {
    type: string
    sql: ${TABLE}."FULL_SEND_GROUP" ;;
  }

  dimension: ipm_test_group {
    type: string
    sql: ${TABLE}."IPM_TEST_GROUP" ;;
  }

  dimension: ipm_full_group {
    type: string
    sql: ${TABLE}."IPM_FULL_GROUP" ;;
  }

  set: detail {
    fields: [
      _file,
      _line,
      students_email_campaign_criteria_user_guid,
      rand,
      trial_run_group,
      test_send_group,
      full_send_group,
      ipm_test_group,
      ipm_full_group
    ]
  }
}
