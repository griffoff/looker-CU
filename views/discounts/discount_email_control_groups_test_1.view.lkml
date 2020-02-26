view: discount_email_control_groups_test_1 {
  derived_table: {
    sql: SELECT * FROM uploads.CU.upgrades_guids_upload_1000test_send_ko
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

  dimension: discount_info_test_1000_user_sso_guid {
    type: string
    sql: ${TABLE}."DISCOUNT_INFO_TEST_1000_USER_SSO_GUID" ;;
  }

  dimension: discount_info_test_1000_amount_to_upgrade {
    type: number
    sql: ${TABLE}."DISCOUNT_INFO_TEST_1000_AMOUNT_TO_UPGRADE" ;;
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
      discount_info_test_1000_user_sso_guid,
      discount_info_test_1000_amount_to_upgrade,
      rand,
      trial_run_group,
      test_send_group,
      full_send_group,
      ipm_test_group,
      ipm_full_group
    ]
  }
}
