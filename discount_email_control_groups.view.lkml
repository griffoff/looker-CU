view: discount_email_control_groups {
  derived_table: {
    sql: SELECT * FROM uploads.cu.upgrades_guids_upload_ko ;;
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

  dimension: discount_email_campaign_1_user_sso_guid {
    type: string
    sql: ${TABLE}."DISCOUNT_EMAIL_CAMPAIGN_1_USER_SSO_GUID" ;;
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

  set: detail {
    fields: [
      _file,
      _line,
      discount_email_campaign_1_user_sso_guid,
      rand,
      trial_run_group,
      test_send_group,
      full_send_group
    ]
  }
}
