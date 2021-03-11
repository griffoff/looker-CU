# explore: cu_ebook_usage {}

# view: cu_ebook_usage {
#   sql_table_name: UNLIMITED.CU_EBOOK_USAGE ;;

#   dimension: pk {
#     sql: hash(${source}, ${user_sso_guid}, ${activity_raw}, ${institution_id}, ${eisbn}) ;;
#     primary_key: yes
#     hidden: yes
#   }

#   dimension: activity_count {
#     type: string
#     sql: ${TABLE}."ACTIVITY_COUNT" ;;
#   }

#   dimension_group: activity {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."ACTIVITY_DATE" ;;
#   }

#   dimension: contract_id {
#     type: string
#     sql: ${TABLE}."CONTRACT_ID" ;;
#   }

#   dimension: eisbn {
#     type: string
#     sql: ${TABLE}."EISBN" ;;
#   }

#   dimension: institution_id {
#     type: string
#     sql: ${TABLE}."INSTITUTION_ID" ;;
#   }

#   dimension: source {
#     type: string
#     sql: ${TABLE}."SOURCE" ;;
#   }

#   dimension: subscription_state {
#     type: string
#     sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
#   }

#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }

#   measure: user_count {
#     type: count_distinct
#     sql: ${user_sso_guid} ;;
#   }

#   measure: contract_count {
#     type: count_distinct
#     sql: ${contract_id} ;;
#   }
# }
