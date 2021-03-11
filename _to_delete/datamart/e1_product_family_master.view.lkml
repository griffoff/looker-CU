# view: e1_product_family_master {
#   derived_table: {
#     sql: Select * from UPLOADS.CU.E1_PRODUCT_FAMILY_MASTER Where _file ilike 'E1 Product Family Master(12-20-18).csv' ;;
#   }
# #   sql_table_name: UPLOADS.CU.E1_PRODUCT_FAMILY_MASTER ;;

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#   }

#   dimension_group: _fivetran_synced {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#   }

#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#   }

#   dimension: course_as_provided_by_prd_team {
#     type: string
#     sql: ${TABLE}."COURSE_AS_PROVIDED_BY_PRD_TEAM" ;;
#   }

#   dimension: course_udc_code {
#     type: string
#     sql: ${TABLE}."COURSE_UDC_CODE" ;;
#   }

#   dimension: discipline {
#     type: string
#     sql: ${TABLE}."DISCIPLINE" ;;
#   }

#   dimension: discipline_description {
#     type: string
#     sql: ${TABLE}."DISCIPLINE_DESCRIPTION" ;;
#   }

#   dimension: family_status {
#     type: string
#     sql: ${TABLE}."FAMILY_STATUS" ;;
#   }

#   dimension: family_status_code {
#     type: string
#     sql: ${TABLE}."FAMILY_STATUS_CODE" ;;
#   }

#   dimension: field_24 {
#     type: string
#     sql: ${TABLE}."FIELD_24" ;;
#   }

#   dimension: general_manager {
#     type: string
#     sql: ${TABLE}."GENERAL_MANAGER" ;;
#   }

#   dimension: general_manager_code {
#     type: string
#     sql: ${TABLE}."GENERAL_MANAGER_CODE" ;;
#   }

#   dimension: latest_edition {
#     type: string
#     sql: ${TABLE}."LATEST_EDITION" ;;
#   }

#   dimension: pf_code {
#     type: string
#     sql: ${TABLE}."PF_CODE" ;;
#   }

#   dimension: pfmt_description {
#     type: string
#     sql: ${TABLE}."PFMT_DESCRIPTION" ;;
#   }

#   dimension: prod_family_description {
#     type: string
#     sql: ${TABLE}."PROD_FAMILY_DESCRIPTION" ;;
#   }

#   dimension: product_director {
#     type: string
#     sql: ${TABLE}."PRODUCT_DIRECTOR" ;;
#   }

#   dimension: product_director_code {
#     type: string
#     sql: ${TABLE}."PRODUCT_DIRECTOR_CODE" ;;
#   }

#   dimension: product_division {
#     type: number
#     sql: ${TABLE}."PRODUCT_DIVISION" ;;
#   }

#   dimension: product_group {
#     type: string
#     sql: ${TABLE}."PRODUCT_GROUP" ;;
#   }

#   dimension: product_group_description {
#     type: string
#     sql: ${TABLE}."PRODUCT_GROUP_DESCRIPTION" ;;
#   }

#   dimension: product_manager {
#     type: string
#     sql: ${TABLE}."PRODUCT_MANAGER" ;;
#   }

#   dimension: product_manager_description {
#     type: string
#     sql: ${TABLE}."PRODUCT_MANAGER_DESCRIPTION" ;;
#   }

#   dimension: subject_major {
#     type: string
#     sql: ${TABLE}."SUBJECT_MAJOR" ;;
#   }

#   dimension: subject_major_description {
#     type: string
#     sql: ${TABLE}."SUBJECT_MAJOR_DESCRIPTION" ;;
#   }

#   dimension: subject_minor {
#     type: string
#     sql: ${TABLE}."SUBJECT_MINOR" ;;
#   }

#   dimension: subject_minor_description {
#     type: string
#     sql: ${TABLE}."SUBJECT_MINOR_DESCRIPTION" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }
# }
