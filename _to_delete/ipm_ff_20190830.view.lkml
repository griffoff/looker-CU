# view: ipm_ff_20190830 {
#   derived_table: {
#     sql: SELECT * FROM uploads.cu.ipm_campaign_free_20190829
#       ;;
#   }

#   set: marketing_fields {
#     fields: [ipm_ff_20190830.user_sso_guid]
#   }



#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#   }

#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#   }

#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#   }

#   dimension_group: _fivetran_synced {
#     type: time
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#   }

#   set: detail {
#     fields: [_file, _line, user_sso_guid, _fivetran_synced_time]
#   }
# }
