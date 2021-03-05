connection: "snowflake_prod"
connection: "snowflake_uploads"

#include: "cengage_unlimited.model.lkml"
include: "fivetran_trueup.view.lkml"
# ##explore: ipm_browser_event {
# ##  label: "IPM User Events"
# ##  description: "Contains client-side events
#   that are captured when a message is presented to a user,
#   and when a user interacts with the message"
#   join: ipm_campaign {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${ipm_browser_event.message_id} = ${ipm_campaign.message_id} ;;
#   }
#   join: ipm_queue_event {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${ipm_browser_event.message_id}=${ipm_browser_event.message_id} ;;
#   }
# }
explore: fivetran_trueup {}

# explore: session_analysis_ipm {
#   label: "CU User Analysis Prod IPM"
#   extends: [live_subscription_status, all_sessions]
#   from: live_subscription_status

#   join: all_sessions {
#     sql_on: ${live_subscription_status.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
#     relationship: one_to_many
#   }
# }
