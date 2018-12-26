connection: "snowflake_ipm"

include: "ipm_browser_event.view.lkml"
include: "ipm_campaign.view.lkml"
include: "ipm_queue_event.view.lkml"


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
}
