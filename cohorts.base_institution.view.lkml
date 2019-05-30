include: "cohorts.base.view"

view: cohorts_base_institution {
  extends: [cohorts_base_number]

  set: marketing_fields {
    fields: [params*, cohort_term_fields*] #institutional_previous_term
  }

  view_label: "Institution"

  dimension: term_guid {
    type: string
    sql:  ${TABLE}."USER_SSO_GUID_MERGED" || ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ||  ${TABLE}."ENTITY_NAME" ;;
    hidden: yes
  }

  dimension: primary_key {sql: ${term_guid} ;;}

  dimension: entity_name {
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
    hidden: yes
  }

#   measure: institutional_previous_term {
#     group_label: "Institutional savings"
#     type: sum
#     sql: ${minus_1} ;;
#     hidden: no
#   }

}
