# view: active_users_sam {
#   sql_table_name: UPLOADS.ZAS.ACTIVE_USERS_SAM ;;

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#   }

#   dimension: _line {
#     type: string
#     sql: ${TABLE}."_LINE" ;;
#   }

#   dimension: custudent_status {
#     type: string
#     sql: ${TABLE}."CUSTUDENT_STATUS" ;;
#   }

#   dimension: institution {
#     type: string
#     sql: ${TABLE}."INSTITUTION" ;;
#   }

#   dimension: institution_id {
#     type: string
#     sql: ${TABLE}."INSTITUTION_ID" ;;
#   }

#   dimension: section {
#     type: string
#     sql: ${TABLE}."SECTION" ;;
#   }

#   dimension: section_id {
#     type: string
#     sql: ${TABLE}."SECTION_ID" ;;
#   }

#   dimension: user_guid {
#     type: string
#     sql: ${TABLE}."USER_GUID" ;;
#   }

#   dimension: user_name {
#     type: string
#     sql: ${TABLE}."USER_NAME" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [user_name]
#   }

#   measure: count_distinct {
#     label: "# users (distinct)"
#     sql: ${user_guid} ;;
#     type: count_distinct
#     drill_fields: [user_name]
#   }
# }
