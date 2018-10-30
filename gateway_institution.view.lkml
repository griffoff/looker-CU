view: gateway_institution {
  sql_table_name: UPLOADS.GATEWAY.INSTITUTION ;;


  dimension: gw_institution_fk {
    type: number
    sql: ${TABLE}."GW_INSTITUTION_FK" ;;
  }

  dimension: gw_timestamp {
    type: number
    sql: ${TABLE}."GW_TIMESTAMP" ;;
  }

  dimension: integration_type {
    type: string
    sql: ${TABLE}."INTEGRATION_TYPE" ;;
  }

  dimension: jde_institution_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."JDE_INSTITUTION_ID" ;;
  }

  dimension: lms_type {
    type: string
    sql: ${TABLE}."LMS_TYPE" ;;
  }

  dimension: lms_version {
    type: number
    sql: ${TABLE}."LMS_VERSION" ;;
  }

  measure: count {
    type: count
    drill_fields: [jde_institution_id]
  }
}
