explore: gateway_institution {hidden:yes}
view: gateway_institution {
  derived_table: {
    sql:
    with i as (
      select
        hi.institution_id as entity_no
        ,CASE WHEN sig.hub_institutiongateway_key IS NOT NULL THEN 'Gateway' WHEN wpa.school_id IS NOT NULL THEN 'Webassign' ELSE 'N/A' END as source
        ,COALESCE(sig.lms_type, wpa.kind) as lms_type_base
        ,UPPER(DECODE(lms_type_base, 'BB', 'Blackboard', lms_type_base)) as lms_type
        , 'v' || NULLIF(sig.lms_version, '') AS lms_version
        ,ROW_NUMBER() OVER (PARTITION BY hi.institution_id ORDER BY COALESCE(sig.created_at, wpa.created_at) DESC) = 1 as latest
      from prod.datavault.hub_institution hi
      left join prod.datavault.link_institutiongateway_institution ligi on hi.hub_institution_key = ligi.hub_institution_key
      left join prod.datavault.sat_institution_gateway sig on ligi.hub_institutiongateway_key = sig.hub_institutiongateway_key and sig._latest
      left join webassign.wa_app_v4net.schools ws ON hi.institution_id = ws.cl_entity_number
      left join webassign.wa_app_v4net.partner_applications wpa on ws.id = wpa.school_id
    )
    SELECT *
    FROM i
    WHERE latest
    AND lms_type IS NOT NULL
    ;;

    persist_for: "24 hours"
  }

  set: marketing_fields {fields:[lms_type]}

  dimension: lms_type {
    group_label: "LMS Integration"
    label: "LMS Type"
    description: "Type of learning management system the institution uses i.e. Canvas, Blackboard, etc."
    sql: COALESCE(${TABLE}.lms_type, 'NOT LMS INTEGRATED') ;;
  }

  dimension: lms_version {
    group_label: "LMS Integration"
    label: "LMS Version"
    description: "The release version of the LMS software i.e. 1.1"
  }

  dimension: is_lms_integrated {
    group_label: "LMS Integration"
    description: "Institution uses LMS integration"
    label: "LMS Integrated"
    type: yesno
    sql: ${lms_type}!='NOT LMS INTEGRATED' ;;
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
