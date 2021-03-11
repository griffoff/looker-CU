# include: "cohorts.base.view"

# view: cohorts_base_institution {
#   extends: [cohorts_base_number]

#   set: marketing_fields {
#     fields: [params*, cohort_term_fields*, institutional_previous_term] #institutional_previous_term
#   }

#   view_label: "Institution"

#   dimension: term_entity {
#     type: string
#     sql:  ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ||  ${TABLE}."ENTITY_NO" ;;
#     hidden: yes
#   }

#   dimension: primary_key {
#     sql: ${term_entity} ;;
#   }

#   dimension: entity_name {
#     type: string
#     sql: ${TABLE}."ENTITY_NAME" ;;
#     hidden: yes
#   }

#   measure: institutional_previous_term {
#     group_label: "Institutional savings"
#     type: sum
#     sql: ${minus_1} ;;
#     hidden: yes
#     value_format_name: usd_0
#   }

# }
