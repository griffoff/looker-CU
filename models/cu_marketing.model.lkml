# include: "/views/strategy/account_sharers.view"
include: "/views/strategy/late_activators.view"
include: "/views/cu_user_analysis/user_profile.view"
include: "/views/cu_user_analysis/course_info.view"
include: "/views/cu_user_analysis/live_subscription_status.view"
include: "/datagroups.lkml"

connection: "snowflake_prod"

case_sensitive: no

# removed 2020-03-10
#
# explore: account_sharers {
#   label: "Account Sharing"
#   join: cu_user_info {
#     sql_on: ${account_sharers.merged_guid} = ${cu_user_info.user_sso_guid}  ;;
#     relationship: many_to_one
#   }
# }

explore: late_activators_removals {
  hidden: yes
  from: late_activators_removals
  view_name: late_activators
  label: "Late Activations - daily removals"

  fields: [ALL_FIELDS*,-cu_user_info.cu_target_segment]

  join: cu_user_info {
    view_label: "User Information"
    from: user_profile
    sql_on: ${late_activators.user_sso_guid} = ${cu_user_info.user_sso_guid}  ;;
    relationship: many_to_one
  }

  join: live_subscription_status {
    sql_on: ${cu_user_info.user_sso_guid} = ${live_subscription_status.merged_guid} ;;
    relationship: one_to_one
  }
}

explore: late_activators_retroactive {
  hidden: yes
  extends: [late_activators_removals]
  from: late_activators_full_retroactive_email_list
  view_name: late_activators

  label: "Late Activations - Retroactive removals emails"
}

explore: late_activators {
  extends: [course_info, late_activators_removals]
  view_name: late_activators
  from: late_activators_messages
  label: "Late Activations - daily removals emails"

  join: course_info {
    sql_on: ${late_activators.course_key} = ${course_info.course_key} ;;
    relationship: many_to_one
  }
}
