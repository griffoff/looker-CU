# explore: new_vs_renewed_cu_user_usage {}

# view: new_vs_renewed_cu_user_usage {
#   derived_table: {
#     sql: SELECT * FROM prod.zpg.new_vs_renewed_cu_usage
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   measure: user_count {
#     type: count_distinct
#     sql: ${user_sso_guid_merged} ;;
#   }

#   measure: average_study_tool_launches {
#     label: "Average # of study tool launches per user"
#     type: average
#     sql: ${study_tool_launches_count} ;;
#   }

#   measure: average_activations_after_20181215 {
#     label: "Average # of number of activations after December 15th, 2018 per user"
#     type: average
#     sql: ${activations_after_20181215} ;;
#   }

#   measure: average_partner_clicks_count {
#     label: "Average # of partner clicks per user"
#     type: average
#     sql: ${partner_clicks_count} ;;
#   }

#   measure: average_searches_count {
#     label: "Average # of searches per user"
#     type: average
#     sql: ${study_tool_launches_count} ;;
#   }

#   dimension: new_vs_renewal_user {
#     type: string
#     sql: ${TABLE}."NEW_VS_RENEWAL_USER" ;;
#   }

#   dimension: user_sso_guid_merged {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
#   }

#   dimension: activations_on_or_prior_20181215 {
#     type: number
#     sql: COALESCE(${TABLE}."ACTIVATIONS_ON_OR_PRIOR_20181215", 0) ;;
#   }

#   dimension: activations_after_20181215 {
#     type: number
#     sql: COALESCE(${TABLE}."ACTIVATIONS_AFTER_20181215", 0) ;;
#   }

#   dimension: partner_clicks_count {
#     type: number
#     sql: COALESCE(${TABLE}."PARTNER_CLICKS_COUNT", 0) ;;

#   }

#   dimension: study_tool_launches_count {
#     type: number
#     sql: COALESCE(${TABLE}."STUDY_TOOL_LAUNCHES_COUNT",0) ;;
#   }

#   dimension: searches_count {
#     type: number
#     sql: COALESCE(${TABLE}."SEARCHES_COUNT",0) ;;
#   }

#   set: detail {
#     fields: [
#       new_vs_renewal_user,
#       user_sso_guid_merged,
#       activations_on_or_prior_20181215,
#       activations_after_20181215,
#       partner_clicks_count,
#       study_tool_launches_count,
#       searches_count
#     ]
#   }
# }
