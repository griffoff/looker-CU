view: cu_user_info {
  sql_table_name: UPLOADS.CU.CU_USER_INFO ;;

  dimension_group: cu_end_sso {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CU_END_SSO" ;;
    hidden: yes
  }

  dimension_group: cu_start_sso {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CU_START_SSO" ;;
    hidden: yes
  }

  dimension: cu_state_sso {
    type: string
    sql: ${TABLE}."CU_STATE_SSO" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: entity_id {
    type: number
    sql: ${TABLE}."ENTITY_ID" ;;
  }

  dimension: entity_name {
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: guid {
    type: string
    sql: ${TABLE}."GUID" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: no_contact_user {
    type: string
    sql: ${TABLE}."NO_CONTACT_USER" ;;
  }

  dimension: opt_out {
    type: string
    sql: ${TABLE}."OPT_OUT" ;;
  }

  dimension: provided_paid {
    type: string
    sql: ${TABLE}."PROVIDED_PAID" ;;
  }

  dimension: provided_status {
    type: string
    sql: ${TABLE}."PROVIDED_STATUS" ;;
  }

  dimension: user_region {
    type: string
    sql: ${TABLE}."USER_REGION" ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name, entity_name]
  }
}
