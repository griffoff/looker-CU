 connection: "snowflake_ipm"

include: "ipm_browser_event.view.lkml"
include: "ipm_campaign.view.lkml"
include: "ipm_queue_event.view.lkml"
include: "ipm.*.view"
include: "all_events.view"
include: "live_subscription_status.view.lkml"
include: "raw_subscription_event.view.lkml"

# include: "cengage_unlimited.model.lkml"

explore: ipm_campaign {
  label: "IPM Campaign"
#   join: ipm_queue_event {
#     # messages intended for display
#     sql_on: ${ipm_campaign.message_id} = ${ipm_queue_event.message_id} ;;
#     relationship: one_to_many
#   }
  join: ipm_browser_event {
    from: ipm_browser_event_and_outcome
    sql_on: ${ipm_campaign.message_id} = ${ipm_browser_event.message_id}
            AND ${ipm_campaign.campaign_start_raw} <= ${ipm_browser_event.event_raw}
            AND ${ipm_campaign.next_campaign_start_time} > ${ipm_browser_event.event_raw};;
            #and ${ipm_queue_event.user_sso_guid} = ${ipm_browser_event.user_sso_guid};;
    relationship: one_to_many
  }
  sql_always_where: ${campaign_title} NOT ilike '%test%' ;;

}

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

#   join: live_subscription_status {
#     sql_on: ${live_subscription_status.user_sso_guid} = ${ipm_browser_event.user_sso_guid} ;;
#     relationship: many_to_one
#   }
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
