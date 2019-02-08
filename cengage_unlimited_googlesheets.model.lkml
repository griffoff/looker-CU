connection: "snowflake_googlesheets"
#Snowflake for accessing looks from google sheets
#Snowflake_prod can't used for this purpose
#This connection dont have a user attribute in the JDBC connection string
include: "all_events.view.lkml"
include: "all_event_actions.view.lkml"
include: "learner_profile.view.lkml"
include: "merged_cu_user_info.view.lkml"
include: "live_subscription_status.view.lkml"


case_sensitive: no


explore: all_events {
  }

explore: all_event_actions {
}




explore: learner_profile2 {
  from: learner_profile
  label: "IPM purchased flag"
  join: merged_cu_user_info {
    view_label: "Learner Profile"
    sql_on:  ${learner_profile2.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
    relationship: one_to_one
  }
  join: live_subscription_status {
    view_label: "Learner Profile - Live Subscription Status"
    sql_on:  ${learner_profile2.user_sso_guid} = ${live_subscription_status.user_sso_guid}  ;;
    relationship: one_to_one

  }
}
