connection: "snowflake_prod"

include: "/views/ipm/ipm_browser_event.view.lkml"
include: "/views/ipm/ipm_campaign.view.lkml"
include: "/views/ipm/ipm_queue_event.view.lkml"

include: "/datagroups.lkml"

explore: ipm_campaign {
  label: "IPM Campaign"

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

}
