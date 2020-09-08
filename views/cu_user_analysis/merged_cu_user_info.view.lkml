include: "cu_user_info.view"
explore: merged_cu_user_info {hidden:yes}

view: merged_cu_user_info {
  extends: [cu_user_info]
#   sql_table_name: ${cu_user_info.SQL_TABLE_NAME} ;;

#   derived_table: {
#     sql:
#       WITH user_info AS (
#       SELECT
#         *
# --         ,ROW_NUMBER() OVER (PARTITION BY merged_guid ORDER BY cu_start_sso DESC) as r
# --       FROM UPLOADS.CU.CU_USER_INFO
#          FROM ${cu_user_info.SQL_TABLE_NAME}
#       )
#       SELECT *
#       FROM user_info
# --      WHERE r = 1
#     ;;
#   }

set: marketing_fields {
  fields: [merged_cu_user_info.email, merged_cu_user_info.first_name,
    merged_cu_user_info.last_name,marketing_opt_out,k12_user,internal_user_flag,entity_flag, region]
}

  dimension: user_sso_guid {
    label: "User SSO GUID"
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: yes
  }

  dimension: guid {
    hidden: yes
  }

  dimension: marketing_opt_out {
    group_label: "User Info - PII"
    type: string
#     case: {
#       when: {label: "Yes" sql: LEFT( ${TABLE}.opt_out, 1) = 'Y';;}
#       when: {label: "No" sql: LEFT(${TABLE}.opt_out, 1) = 'N';;}
#       else: "UNKNOWN"
#     }
  }



}
