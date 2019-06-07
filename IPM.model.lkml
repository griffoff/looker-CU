 connection: "snowflake_ipm"

include: "ipm_browser_event.view.lkml"
include: "ipm_campaign.view.lkml"
include: "ipm_queue_event.view.lkml"
include: "live_subscription_status.view.lkml"
# include: "cengage_unlimited.model.lkml"

explore: ipm_browser_event {
  label: "IPM User Events"
  description: "Contains client-side events
  that are captured when a message is presented to a user,
  and when a user interacts with the message"
  join: ipm_campaign {
    relationship: many_to_one
    type: left_outer
    sql_on: ${ipm_browser_event.message_id} = ${ipm_campaign.message_id} ;;
  }
  join: ipm_queue_event {
    relationship: many_to_one
    type: left_outer
    sql_on: ${ipm_browser_event.message_id}=${ipm_browser_event.message_id} ;;
  }
  join: live_subscription_status {
    sql_on: ${live_subscription_status.user_sso_guid} = ${ipm_browser_event.user_sso_guid} ;;
    relationship: many_to_one
  }
}

#
# explore: session_analysis_ipm {
#   label: "CU User Analysis Prod IPM"
#   extends: [live_subscription_status, all_sessions]
#   from: live_subscription_status
#
#   join: all_sessions {
#     sql_on: ${live_subscription_status.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
#     relationship: one_to_many
#   }
# }
