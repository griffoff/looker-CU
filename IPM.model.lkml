connection: "snowflake_ipm"

include: "ipm_browser_event.view.lkml"
include: "ipm_campaign.view.lkml"
include: "ipm_queue_event.view.lkml"


explore: ipm_browser_event {
  label: "IPM User Events"
  description: "Contains client-side events
  that are captured when a message is presented to a user,
  and when a user interacts with the message"
}
