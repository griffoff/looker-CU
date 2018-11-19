view: gateway_institution {
  sql_table_name: UPLOADS.GATEWAY.INSTITUTION ;;


  dimension: gw_institution_fk {
    hidden: yes
    type: number
    sql: ${TABLE}."GW_INSTITUTION_FK" ;;
  }

  dimension: gw_timestamp {
    hidden: yes
    type: number
    sql: ${TABLE}."GW_TIMESTAMP" ;;
  }

  dimension: integration_type {
    type: string
    sql: ${TABLE}."INTEGRATION_TYPE" ;;
    label: "Integration type"
    description: "Name of the technical network connection between the LMS and Cengage gateway system"
  }

  dimension: jde_institution_id {
    hidden: yes
    type: number
    sql: ${TABLE}."JDE_INSTITUTION_ID" ;;
  }

  dimension: entity_no {
    hidden: yes
    type: string
    primary_key: yes
    sql: ${jde_institution_id}::string ;;
  }

  dimension: lms_type {
    type: string
    sql: ${TABLE}."LMS_TYPE" ;;
    label: "Learning management system type"
    description: "I.e. Canvas, Blackboard, etc."
  }

  dimension: lms_version {
    type: number
    sql: ${TABLE}."LMS_VERSION" ;;
    label: "Learning management system version"
  }

  measure: count {
    type: count
    drill_fields: [entity_no, lms_type, lms_version, integration_type]
    label: "Count"
  }
}