view: gateway_institution {
  derived_table: {
    sql:
    select school_entity_id as entity_no
      , listagg(distinct lms_type, ', ') within group (order by lms_type) as lms_type
      , listagg(distinct concat(lms_type,' ',lms_version), ', ') within group (order by concat(lms_type,' ',lms_version)) as lms_version
    from ${gateway_lms_course_sections.SQL_TABLE_NAME}
    group by entity_no
    ;;
  }

  set: marketing_fields {fields:[lms_type]}

  dimension: lms_type {
    label: "LMS Type"
     description: "Type of learning management system the institution uses i.e. Canvas, Blackboard, etc."
  }

  dimension: lms_version {
    label: "LMS Version"
    description: "The release version of the LMS software i.e. 1.1"
  }

  dimension: entity_no {
    hidden: yes
  }

  measure: number_lms_types {
    type:  count_distinct
    sql:${lms_type};;
    hidden: yes
  }


#   sql_table_name: UPLOADS.GATEWAY.INSTITUTION ;;
#
#   set: marketing_fields {fields:[lms_type]}
#
#
#   dimension: gw_institution_fk {
#     hidden: yes
#     type: number
#     sql: ${TABLE}."GW_INSTITUTION_FK" ;;
#   }
#
#   dimension: gw_timestamp {
#     hidden: yes
#     type: number
#     sql: ${TABLE}."GW_TIMESTAMP" ;;
#   }
#
#   dimension: integration_type {
#     hidden: yes
#     group_label: "Gateway LMS Details"
#     type: string
#     sql: ${TABLE}."INTEGRATION_TYPE" ;;
#     label: "LMS Integration type"
#     description: "Name of the technical network connection between the LMS and Cengage gateway system"
#   }
#
#   dimension: jde_institution_id {
#     hidden: yes
#     type: number
#     sql: ${TABLE}."JDE_INSTITUTION_ID" ;;
#   }
#
#   dimension: entity_no {
#     hidden: yes
#     type: string
#     primary_key: yes
#     sql: ${jde_institution_id}::string ;;
#   }
#
#   dimension: lms_type {
#     group_label: "Gateway LMS Details"
#     type: string
#     sql: ${TABLE}."LMS_TYPE" ;;
#     label: "LMS type"
#     description: "Type of learning management system the user uses i.e. Canvas, Blackboard, etc."
#   }
#
#   dimension: lms_version {
#     group_label: "Gateway LMS Details"
#     type: number
#     sql: ${TABLE}."LMS_VERSION" ;;
#     label: "LMS version"
#     description: "The release version of the LMS software i.e. 1.1"
#   }
#
#   measure: count {
#     hidden: yes
#     type: count
#     drill_fields: [entity_no, lms_type, lms_version, integration_type]
#     label: "Count"
#   }
}
