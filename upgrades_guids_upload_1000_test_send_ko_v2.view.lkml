view: discount_email_campaign_control_groups {
  sql_table_name: uploads.CU.UPGRADES_GUIDS_UPLOAD_1000TEST_SEND_KO_V2 ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension: _line {
    type: string
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: full_send_group {
    type: string
    sql: ${TABLE}."FULL_SEND_GROUP" ;;
  }

  dimension: ipm_full_group {
    type: string
    sql: ${TABLE}."IPM_FULL_GROUP" ;;
  }

  dimension: ipm_test_group {
    type: string
    sql: ${TABLE}."IPM_TEST_GROUP" ;;
  }

  dimension: looker_1000_test_primary_20190215_user_guid {
    type: string
    sql: ${TABLE}."LOOKER_1000_TEST_PRIMARY_20190215_USER_GUID" ;;
  }

  dimension: rand {
    type: string
    sql: ${TABLE}."RAND" ;;
  }

  dimension: test_send_group {
    type: string
    sql: ${TABLE}."TEST_SEND_GROUP" ;;
  }

  dimension: trial_run_group {
    type: string
    sql: ${TABLE}."TRIAL_RUN_GROUP" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
