# If necessary, uncomment the line below to include explore_source.

# include: "cengage_unlimited.model.lkml"

# view: logins_last_30_days {
#   derived_table: {
#     explore_source: raw_fair_use_logins {
#       column: user_sso_guid {}
#       column: distinct_days_used {}
#       column: device_count {}
#       filters: {
#         field: raw_fair_use_logins.message_type
#         value: "LoginEvent"
#       }
#       filters: {
#         field: raw_fair_use_logins.platform_environment
#         value: "production"
#       }
#       filters: {
#         field: raw_fair_use_logins.product_platform
#         value: "cares-dashboard"
#       }
#       filters: {
#         field: raw_fair_use_logins.user_environment
#         value: "production"
#       }
#       filters: {
#         field: raw_fair_use_logins._ldts_date
#         value: "30 days"
#       }
#     }
#   }
#   dimension: user_sso_guid {}
#   dimension: distinct_days_used {
#     type: number
#   }
#   dimension: device_count {
#     type: number
#   }
# }
