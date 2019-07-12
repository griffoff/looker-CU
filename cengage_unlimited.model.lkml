connection: "snowflake_prod"
include: "*.view.lkml"         # include all views in this project
include: "//core/common.lkml"
include: "//cube/dims.lkml"
include: "//cube/dim_course.view"
include: "//cube/ga_mobiledata.view"
include: "//core/access_grants_file.view"


 case_sensitive: no

######################### Start of PROD Explores #########################################################################3

######## User Experience Journey Start ###################

explore: learner_profile {
  extension: required
  join: merged_cu_user_info {
    view_label: "Learner Profile"
    sql_on:  ${learner_profile.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
    relationship: one_to_one
  }
  join: live_subscription_status {
    view_label: "Learner Profile - Live Subscription Status"
    sql_on:  ${learner_profile.user_sso_guid} = ${live_subscription_status.user_sso_guid}  ;;
    relationship: one_to_one

  }
}

explore: live_subscription_status {
  #extension: required
  from: live_subscription_status
  view_name: live_subscription_status
  view_label: "Learner Profile"
  fields: [ALL_FIELDS*, -learner_profile.user_sso_guid]

  join: merged_cu_user_info {
    required_access_grants: [can_view_CU_pii_data]
    view_label: "Learner Profile"
    sql_on:  ${live_subscription_status.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
    relationship: one_to_one
  }
  join: learner_profile {
    view_label: "Learner Profile"
    sql_on:  ${live_subscription_status.user_sso_guid} = ${learner_profile.user_sso_guid}  ;;
    relationship: one_to_one
  }
  join: user_institution_map {
    fields: []
    sql_on: ${live_subscription_status.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
    relationship: many_to_one
  }
  join: gateway_institution {
    view_label: "Learner Profile"
    sql_on: coalesce(${merged_cu_user_info.entity_id}::string, ${user_institution_map.entity_no}) = ${gateway_institution.entity_no};;
    relationship: many_to_one
  }

  join: raw_olr_provisioned_product {
    fields: []
    view_label: "Provisioned Products"
    sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${live_subscription_status.user_sso_guid};;
    relationship: many_to_one
  }

  join: products_v {
    fields: []
    view_label: "Provisioned Products - Info"
    sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
    relationship: many_to_one
  }

  join: user_courses {
    sql_on: ${learner_profile.user_sso_guid} = ${user_courses.user_sso_guid} ;;
    relationship: one_to_many
  }

  join: dim_date {
    view_label: "Learner Profile"
    sql_on: ${live_subscription_status.subscription_start_date} =  ${dim_date.datevalue} ;;
    relationship: one_to_one
  }
}

explore: all_events {
  extension: required
  label: "all events prod"

  join: event_groups {
    fields: [event_group]
    sql_on: UPPER(${all_events.event_name}) like UPPER(${event_groups.event_names}) ;;
    relationship: many_to_one
  }
}

explore: all_sessions {
  extension: required
  extends: [all_events, dim_course]

  join: all_events {
    sql_on: ${all_sessions.session_id} = ${all_events.session_id} ;;
    relationship: one_to_many
  }

  join: dim_course {
    sql_on: ${all_sessions.course_keys}[0] = ${dim_course.coursekey} ;;
    relationship: many_to_many
  }

}

explore: session_analysis {
  label: "CU User Analysis Prod"
  extends: [live_subscription_status, all_sessions]
  from: live_subscription_status

  join: all_sessions {
    sql_on: ${live_subscription_status.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
    relationship: one_to_many
  }

  join: uploads_cu_sidebar_cohort {
    sql_on: ${live_subscription_status.user_sso_guid}=${uploads_cu_sidebar_cohort.merged} ;;
    relationship: many_to_one
  }

  join: guid_cohort {
    sql_on: ${live_subscription_status.user_sso_guid} = ${guid_cohort.guid} ;;
    relationship: many_to_one
    type: inner
  }

  join: FullAccess_cohort {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${FullAccess_cohort.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: TrialAccess_cohorts {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${TrialAccess_cohorts.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_cost {
    view_label: "Institution"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_cost.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }
  join: subscription_term_products_value {
    view_label: "Institution"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_products_value.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_savings {
    view_label: "Institution"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_savings.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_careercenter_clicks {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_careercenter_clicks.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

#   join: cohorts_base {type: cross relationship: one_to_one}
#   join: cohorts_base_institution {type: cross relationship: one_to_one}

  join: cohorts_chegg_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_chegg_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_kaplan_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_kaplan_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_quizlet_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_quizlet_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_evernote_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_evernote_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_print_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_print_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_courseware_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_courseware_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_testprep_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_testprep_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_studyguide_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_studyguide_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_flashcards_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_flashcards_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_subscription_term_savings_user {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_subscription_term_savings_user.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_courseware_value_users {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_courseware_value_users.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_term_courses {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_term_courses.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_time_in_platform {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_time_in_platform.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_number_of_logins {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_logins.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_number_of_ebooks_added_dash {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_ebooks_added_dash.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_number_of_courseware_added_to_dash{
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_courseware_added_to_dash.user_sso_guid} ;;
    relationship:  one_to_many
  }

}

explore: session_analysis_old {
  hidden: yes
  label: "CU User Analysis Prod - Old"
  extends: [all_sessions]
  from: all_sessions
  view_name: all_sessions

  join: dim_course {
    sql_on: ${all_sessions.course_keys}[0] = ${dim_course.coursekey} ;;
    relationship: many_to_many
  }

join: user_institution_map {
  fields: []
  sql_on: ${all_sessions.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
  relationship: many_to_one
}

join: gateway_institution {
  view_label: "Learner Profile"
  sql_on: ${user_institution_map.entity_no} = ${gateway_institution.entity_no} ;;
  relationship: many_to_one
}

  join: learner_profile {
    sql_on: ${all_sessions.user_sso_guid} = ${learner_profile.user_sso_guid} ;;
    relationship: many_to_one
  }


#   join: sessions_analysis_week {
#     sql_on: ${all_sessions.user_sso_guid} = ${sessions_analysis_week.user_sso_guid} ;;
#     relationship: many_to_one
#   }
#
#   join: products_v {
#     sql_on: ${all_events.iac_isbn} = ${products_v.isbn13} ;;
#     relationship: many_to_one
#   }
}


explore: event_analysis {
  label: "Event Analysis"
  extends: [all_events_dev, learner_profile]
  from: all_events
  view_name: all_events

  join: learner_profile {
  from: learner_profile_dev
    sql_on: ${all_events.user_sso_guid} = ${learner_profile.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: ipm_campaign {
    sql_on: ${ipm_campaign.message_id} = ${all_events.campaign_msg_id};;
    relationship: one_to_many
  }

  join: all_sessions {
    from: all_sessions_dev
    sql_on: ${all_events.session_id} = ${all_sessions.session_id} ;;
    relationship: many_to_one
  }

  join: all_weeks_cu_value {
    sql_on: ${all_sessions.user_sso_guid} = ${all_weeks_cu_value.user_sso_guid} ;;
    relationship: many_to_many
  }

  join: all_weeks_cu_value_sankey {
    sql_on: ${all_sessions.user_sso_guid} = ${all_weeks_cu_value_sankey.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: all_sessions_cu_value {
    sql_on: ${all_sessions.session_id} = ${all_sessions_cu_value.session_id} ;;
    relationship: one_to_one
  }

  join: ip_locations {
    sql_on: ${all_sessions.ips} = ${ip_locations.ip_address} ;;
    relationship: one_to_one
  }
}

################################################# End of PROD Explores ###########################################

################################################ Start of DEV Explores #############################################

###### new explore testing#########
explore: all_events_dev {
  label: "testing Dev"
  required_access_grants: [can_view_CU_dev_data]
  view_name: all_events
  extends: [all_events]
  from: all_events_dev

#   join: all_events_diff {
#     from:  all_events_diff_dev
#   }

  join: all_events_diff {
    from: all_events_diff_dev
    view_label: "Event Category Analysis"
    sql_on: ${all_events.event_id} = ${all_events_diff.event_id} ;;
    relationship: many_to_one
    type: inner
  }

#   join: student_subscription_status {
#     from: student_subscription_status_dev
#   }

  join: student_subscription_status {
    from: student_subscription_status_dev
    sql_on: ${all_events.user_sso_guid} = ${student_subscription_status.user_sso_guid} ;;
    relationship: many_to_one
  }
}


explore: session_analysis_dev {
  label: "CU User Analysis Dev"
  from: live_subscription_status
#   extends: [session_analysis, all_events_dev, dim_course, learner_profile]
  required_access_grants: [can_view_CU_dev_data]
  extends: [session_analysis]
  view_name: live_subscription_status

  join: all_sessions {
    from: all_sessions_dev
#     sql_on: a = b ;;
  }
  join: learner_profile {
    from: learner_profile_dev
  }

  join: guid_cohort {
    view_label: "Learner Cohort Analysis"
  }

  join: FullAccess_cohort {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${FullAccess_cohort.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_platforms_used {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_platforms_used.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: TrialAccess_cohorts {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${TrialAccess_cohorts.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_cost {
    view_label: "Institution"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_cost.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_products_value {
    view_label: "Institution"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_products_value.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_savings {
    view_label: "Institution"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_savings.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_careercenter_clicks {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_careercenter_clicks.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

#   join: cohorts_base {type: cross relationship: one_to_one}
#   join: cohorts_base_institution {type: cross relationship: one_to_one}

  join: cohorts_chegg_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_chegg_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_kaplan_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_kaplan_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_quizlet_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_quizlet_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_evernote_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_evernote_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_print_clicked {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_print_clicked.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_courseware_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_courseware_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_testprep_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_testprep_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_studyguide_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_studyguide_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_flashcards_dashboard {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_flashcards_dashboard.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_subscription_term_savings_user {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_subscription_term_savings_user.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_courseware_value_users {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_courseware_value_users.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_term_courses {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_term_courses.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_time_in_platform {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_time_in_platform.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_number_of_logins {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_logins.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_number_of_ebooks_added_dash {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_ebooks_added_dash.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_number_of_courseware_added_to_dash{
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_courseware_added_to_dash.user_sso_guid} ;;
    relationship:  one_to_many
  }


  join: all_events {
    from: all_events_dev
  }

  join: user_courses {
    from: user_courses_dev
  }

   join: dim_course {
     sql_on: ${all_sessions.course_keys}[0] = ${dim_course.olr_course_key} ;;
     relationship: many_to_many
   }

   join: sessions_analysis_week {
     sql_on: ${all_sessions.user_sso_guid} = ${sessions_analysis_week.user_sso_guid} ;;
     relationship: many_to_one
   }

    join: products_v {
      view_label: "Product Added to Dashboard - info"
      sql_on: ${all_events.iac_isbn} = ${products_v.isbn13} ;;
      relationship: many_to_one
    }

   join: cu_ebook_rollup {
     sql_on:  ${learner_profile.user_sso_guid} = ${cu_ebook_rollup.mapped_guid} ;;
    relationship:  one_to_one
    }



#   join: sessions_analysis_week {
#     sql_on: ${all_sessions_dev.user_sso_guid} = ${sessions_analysis_week.user_sso_guid} ;;
#     relationship: many_to_one
#   }

}

explore: courseware_activations_per_user {}



explore: products_v {}





explore: activations_courses_products {
  label: "CU Take Rate Analysis - Strategy"
  view_label: "Course info"

join: raw_subscription_event {
  view_label: "Subscription info"
  sql_on: ${activations_courses_products.user_id} = ${raw_subscription_event.merged_guid};;
  relationship: many_to_one
}


}
################################################## End of DEV Explores #######################################################

# explore: all_events2 {
#   from:  all_events
#   sql_table_name: cu_user_analysis.all_events ;;
#   label: "test3"
#
#   join: all_sessions {
#     sql_on: ${all_events2.session_id} = ${all_sessions.session_id} ;;
#     relationship: many_to_one
#     sql_table_name: cu_user_analysis.all_sessions ;;
#   }
#
#   required_access_grants: [can_view_CU_prod_data]
#   fields: [all_events2.user_sso_guid, all_events2.event_name, all_sessions.country, all_sessions.course_keys]
#
# }

######## User Experience Journey End ###################


######## User Experience Journey Start PROD ###################

# explore: all_events_dev {
#   extends: [all_events]
#   label: "All Events Devlopment"
#   from: all_events_dev
#   view_name: all_events
#   required_access_grants: [can_view_CU_dev_data]
#
# explore: all_events_prod {
#   from: all_events_prod
#   sql_table_name: cu_user_analysis.all_events ;;
#   join: all_events_diff {
#     sql_table_name: cu_user_analysis.ALL_EVENTS_DIFF{% parameter event_type %} ;;
#     view_label: "Event Category Analysis PROD"
#     sql_on: ${all_events_prod.event_id} = ${all_events_diff.event_id} ;;
#     relationship: many_to_one
#     type: inner
#   }

#   join: student_subscription_status {
#     sql_on: ${all_events_prod.user_sso_guid} = ${student_subscription_status.user_sso_guid} ;;
#     relationship: many_to_one
#     sql_table_name: cu_user_analysis.student_subscription_status ;;
#   }
#   join: event_groups {
#     view_label: "User Events PROD"
#     fields: [event_group]
#     sql_on: UPPER(${all_events_prod.event_name}) like UPPER(${event_groups.event_names}) ;;
#     relationship: many_to_one
#   }
#   required_access_grants: [can_view_CU_prod_data]
#
# }


# explore: session_analysis_prod {
#   label: "CU User Analysis PROD"
#   extends: [all_events, dim_course]
#   from: all_sessions
#   sql_table_name: cu_user_analysis.all_sessions ;;
#   view_name: all_sessions
#
#   join: dim_course {
#     sql_on: ${all_sessions.course_keys}[0] = ${dim_course.coursekey} ;;
#     relationship: many_to_many
#   }
#
#   join: user_institution_map {
#     fields: []
#     sql_on: ${all_sessions.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
#     relationship: many_to_one
#   }
#
#   join: gateway_institution {
#     sql_on: ${user_institution_map.entity_no} = ${gateway_institution.entity_no} ;;
#     relationship: many_to_one
#   }
#
#   join: learner_profile_2 {
#     sql_on: ${all_sessions.user_sso_guid} = ${learner_profile_2.user_sso_guid} ;;
#     relationship: many_to_one
#     sql_table_name: cu_user_analysis.learner_profile ;;
#   }
#
#   join: all_events {
#     sql_on: ${all_sessions.session_id} = ${all_events.session_id} ;;
#     relationship: one_to_many
#     sql_table_name: cu_user_analysis.all_events ;;
#   }
#
#   join: sessions_analysis_week {
#     sql_on: ${all_sessions.user_sso_guid} = ${sessions_analysis_week.user_sso_guid} ;;
#     relationship: many_to_one
#     sql_table_name: cu_user_analysis.session_analysis_week ;;
#   }
#
#   join: products_v {
#     sql_on: ${all_events.iac_isbn} = ${products_v.isbn13} ;;
#     relationship: many_to_one
#   }
#
#   required_access_grants: [can_view_CU_prod_data]
# }






######## User Experience Journey End PROD ###################



explore: customer_support_cases {
  label: "CU User Analysis Customer Support Cases"
  description: "One time upload of customer support cases joined with CU user analysis to analyze support cases in the context of CU"
  extends: [session_analysis]

  join: customer_support_cases {
    view_label: "Customer Support Cases"
    sql_on: ${learner_profile.user_sso_guid} = ${customer_support_cases.sso_guid}::STRING ;;
    relationship: one_to_many
  }
  fields: [
    learner_profile.marketing_fields*
    ,all_events.marketing_fields*
    ,live_subscription_status.marketing_fields*
    ,merged_cu_user_info.marketing_fields*
    ,dim_institution.marketing_fields*
    ,dim_product.marketing_fields*
    ,dim_productplatform.productplatform
    ,dim_course.marketing_fields*
#     ,instiution_star_rating.marketing_fields*
    ,course_section_facts.total_noofactivations
    ,courseinstructor.marketing_fields*
    ,dim_start_date.marketing_fields*
    ,olr_courses.instructor_name
#     ,subscription_term_products_value.marketing_fields*
#     ,subscription_term_cost.marketing_fields*
    ,user_courses.marketing_fields*
    ,customer_support_cases.customer_support_case_fields*]
}





##### Raw Snowflake Tables #####
explore: provisioned_product {
  label: "VitalSource events"
  from: raw_olr_provisioned_product
  join: raw_subscription_event {
    sql_on: ${provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid} ;;
    relationship: many_to_one
  }

  join:  raw_vitalsource_event {
    sql_on: ${provisioned_product.user_sso_guid} = ${raw_vitalsource_event.user_sso_guid} ;;
    relationship: many_to_many
  }
}

explore: raw_subscription_event {
  label: "Raw Subscription Events"
  view_name: raw_subscription_event
  view_label: "Subscription Status"
  join: raw_olr_provisioned_product {
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${raw_subscription_event.merged_guid};;
    relationship: many_to_one
  }
  join: products_v {
    sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
    relationship: many_to_one
  }
  join: dim_date {
    sql_on: ${raw_subscription_event.subscription_start_date}::date = ${dim_date.datevalue} ;;
    relationship: many_to_one
  }
#   join: sub_actv {
#     sql_on: ${raw_subscription_event.user_sso_guid} = ${sub_actv.user_sso_guid} ;;
#     relationship: many_to_one
#   }
}


##### END  Raw Snowflake Tables #####



##### Dashboard #####
explore: ga_dashboarddata {
  label: "CU Dashboard"
  join: raw_subscription_event {
    sql_on: ${ga_dashboarddata.userssoguid} = ${raw_subscription_event.user_sso_guid} ;;
    type: full_outer
    relationship: many_to_one
  }
  join: raw_olr_provisioned_product {
    sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid};;
    relationship: many_to_one
  }

  join: cu_product_category {
    view_label: "Product Category (PRoc)"
    sql_on: ${cu_product_category.isbn_13} = ${raw_olr_provisioned_product.iac_isbn} ;;
    relationship: many_to_one
  }

  join: cu_user_info {
    sql_on:  ${ga_dashboarddata.userssoguid} = ${cu_user_info.merged_guid}  ;;
    relationship: many_to_one
  }

  join: instiution_star_rating {
    sql_on: ${cu_user_info.entity_id} = ${instiution_star_rating.entity_} ;;
    relationship: many_to_one
  }
  join: dashboard_use_over_time {
    sql_on: ${ga_dashboarddata.userssoguid} = ${dashboard_use_over_time.user_sso_guid} ;;
    relationship: many_to_one
  }
  join: dashboard_use_over_time_bucketed {
    sql_on: ${ga_dashboarddata.userssoguid} = ${dashboard_use_over_time_bucketed.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: products_v {
    sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
    relationship: many_to_one
  }
}

explore: ga_dashboarddata_merged_2 {
  label: "CU Dashboard mapped"
  join: raw_subscription_event_merged_2 {
    sql_on: ${ga_dashboarddata_merged_2.mapped_guid} = ${raw_subscription_event_merged_2.mapped_guid} ;;
    type: full_outer
    relationship: many_to_one
  }
  }

explore: dashboard_use_over_time_bucketed {
  label: "Dashboard Use Over Time Binned"
  join: raw_subscription_event {
    sql_on: ${raw_subscription_event.user_sso_guid} = ${dashboard_use_over_time_bucketed.user_sso_guid} ;;
    relationship: one_to_many
    type: left_outer
  }
  join: cu_user_info {
    sql_on:  ${dashboard_use_over_time_bucketed.user_sso_guid} = ${cu_user_info.merged_guid}  ;;
    relationship: many_to_one
  }
}

explore: dashboardbuckets {
  label: "CU Dashboard Actions Bucketed"
  join: ga_dashboarddata {
    sql_on: ${ga_dashboarddata.userssoguid}=${dashboardbuckets.userssoguid} ;;
    relationship: many_to_many
    type: left_outer
  }
}

explore: CU_Sandbox {
  label: "CU Sandbox"
  extends: [ebook_usage]
  join: ga_dashboarddata {
    sql_on: ${raw_subscription_event.user_sso_guid} = ${ga_dashboarddata.userssoguid} ;;
    relationship: one_to_many
 }
}

##### End Dashboard #####




##### Ebook Usage #####
  explore: ebook_usage {
    label: "Ebook Usage"
    extends: [raw_subscription_event]
    join: ebook_usage_actions {
      sql_on:  ${raw_subscription_event.user_sso_guid} = ${ebook_usage_actions.user_sso_guid} ;;
      type: left_outer
      relationship: one_to_many
    }

     join: ebook_mapping {
       type: left_outer
       sql_on: ${ebook_usage_actions.event_action} = ${ebook_mapping.action}  AND ${ebook_usage_actions.source} = ${ebook_mapping.source} AND ${ebook_usage_actions.event_category} = ${ebook_mapping.event_category};;
       relationship: many_to_one
     }
  }

explore: ebook_usage_aggregated {}
##### End Ebook Usage #####


#### Raw enrollment for Prod research #####
explore: raw_olr_enrollment {
  label: "Raw Enrollments"
#   join: raw_olr_provisioned_product {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${raw_olr_enrollment.user_sso_guid} = ${raw_olr_provisioned_product.user_sso_guid} AND ${raw_olr_enrollment.course_key} = ${raw_olr_provisioned_product.context_id} ;;
#   }
}

# MT Mobile Data

explore: mobiledata {
  from: dim_course
  view_name: dim_course
  label: "MT Mobile GA Data"
  extends: [dim_course]

  join: ga_mobiledata {
    sql_on: ${dim_course.coursekey} = ${ga_mobiledata.coursekey};;
    relationship: many_to_one
  }

  join: learner_profile {
    sql_on: ${ga_mobiledata.userssoguid}= ${learner_profile.user_sso_guid} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: live_subscription_status {
    view_label: "Learner Profile"
    sql_on: ${ga_mobiledata.userssoguid}= ${live_subscription_status.user_sso_guid} ;;
    type: left_outer
    relationship: many_to_one
  }


  join: raw_olr_provisioned_product {
    sql_on: ${ga_mobiledata.userssoguid}= ${raw_olr_provisioned_product.user_sso_guid} ;;
    type: left_outer
    relationship: many_to_one
  }

# join: cu_user_info {
#   sql_on: ${ga_mobiledata.userssoguid} = ${cu_user_info.guid} ;;
#   relationship: many_to_one
# }

}

################ MApped guids ###########################

# explore: vw_subscription_event_mapped_guids {}
explore: active_users_sam {
  join: raw_subscription_event {
    type: inner
    relationship: one_to_one
    sql_on: ${active_users_sam.user_guid}=${raw_subscription_event.user_sso_guid} ;;
  }
}

explore: client_activity_event {
  label: "CU Sidebar Events DEV"

  join: live_subscription_status {
    relationship: one_to_one
    sql_on: ${client_activity_event.merged_guid} = ${live_subscription_status.user_sso_guid} ;;
  }

  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${client_activity_event.merged_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }

  join: uploads_cu_sidebar_cohort {
    view_label: "CU sidebar cohort"
    sql_on: ${client_activity_event.merged_guid} = ${uploads_cu_sidebar_cohort.merged} ;;
    relationship: many_to_one
  }
}

explore: client_activity_event_prod {
  view_label: "CU side bar events"
  label: "CU Sidebar Events Prod"

  join: live_subscription_status {
    relationship: one_to_one
    sql_on: ${client_activity_event_prod.merged_guid} = ${live_subscription_status.user_sso_guid} ;;
  }

  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${client_activity_event_prod.merged_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }

  join: uploads_cu_sidebar_cohort {
    view_label: "CU sidebar cohort"
  sql_on: ${client_activity_event_prod.merged_guid} = ${uploads_cu_sidebar_cohort.merged} ;;
  relationship: many_to_one
  }
}


############################ Discount email campaign ##################################

# explore: looker_output_test_1000_20190214_final {}
explore: email_discount_campaign {
  label: "Email Discount Campaign"
  view_label: "Live subscription status"
  from: live_subscription_status

  join: students_email_campaign_criteria {
    relationship: one_to_one
    sql_on: ${email_discount_campaign.user_sso_guid} = ${students_email_campaign_criteria.user_guid} ;;
  }
  join: discount_info {
    relationship: one_to_one
    sql_on: ${email_discount_campaign.user_sso_guid} = ${discount_info.user_sso_guid} ;;
  }
  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${email_discount_campaign.user_sso_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }
  # join: upgrade_campaign_user_info_latest_20192021 {
  #   relationship: one_to_one
  #   sql_on: ${email_discount_campaign.user_sso_guid} = ${upgrade_campaign_user_info_latest_20192021.guid} ;;
  # }
   join: discount_email_control_groups {
    relationship:  one_to_one
    sql_on: ${email_discount_campaign.user_sso_guid} =  ${discount_email_control_groups.students_email_campaign_criteria_user_guid};;
  }
}
explore: discount_info {}
explore: discount_email_campaign_control_groups {}

explore: students_email_campaign_criteria {
  join: discount_info {
    sql_on: ${students_email_campaign_criteria.user_guid} = ${discount_info.user_sso_guid}  ;;
    relationship: one_to_one
  }
}

explore: looker_output_test_1000_20190214_final {
  view_label: "Discount info (test 1000)"
  label: "Discount email campaign"
  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${looker_output_test_1000_20190214_final.user_sso_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }
  join: discount_email_control_groups_test_2 {
    relationship: one_to_one
    sql_on: ${looker_output_test_1000_20190214_final.user_sso_guid} = ${discount_email_control_groups_test_2.discount_info_test_1000_user_sso_guid};;
  }
}


explore: looker_1000_test_primary_20190215 {
  label: "Discount email campaign (test 1000)"
  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${looker_1000_test_primary_20190215.user_sso_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }

  join: discount_email_campaign_control_groups {
    relationship: one_to_one
    sql_on: ${looker_1000_test_primary_20190215.user_sso_guid} = ${discount_email_campaign_control_groups.looker_1000_test_primary_20190215_user_guid};;
  }
}

explore: student_activities_20190226 {
  extends: [dim_course]

  join: dim_course {
    sql_on: ${student_activities_20190226.course_key} = ${dim_course.olr_course_key} ;;
    relationship: one_to_one
  }
}

# ----IPM ----

explore: ipm_conversion {

}

# --------------------------- Spring Review ----------------------------------

explore: renewed_vs_not_renewed_cu_user_usage_fall_2019 {
}

#-----------sso -------------------
explore: sso_logins {
  from: credentials_used

  join: iam_user_mutation {
    relationship:one_to_many
    sql_on: ${iam_user_mutation.user_sso_guid} = ${sso_logins.user_sso_guid} ;;
  }
}

# ------ Sales order explore -------------------------------------

explore: dm_sales_orders {

  join: dm_territories {
    sql_on: ${dm_sales_orders.territory_skey}=${dm_territories.territory_skey} ;;
    relationship: many_to_one
  }

  join: dm_products {
    sql_on: ${dm_sales_orders.product_skey_bu} = ${dm_products.product_skey} ;;
    relationship: many_to_one
  }

  join: dim_date {
    sql_on: ${dm_sales_orders.invoice_dt_date} = ${dim_date.datekey};;
    relationship: many_to_one
  }

  join: dm_customers {
    sql_on: ${dm_sales_orders.cust_no_ship} = ${dm_customers.cust_no} ;;
    relationship:many_to_one
  }

  join: dm_entities {
    sql_on: ${dm_entities.entity_no} = ${dm_customers.entity_no};;
    relationship: one_to_many
  }

  join: activations_olr {
    sql_on: ${dm_entities.entity_no} = ${activations_olr.entity_no}
    and ${dm_products.product_skey} = ${activations_olr.product_skey};;
    relationship: many_to_many
  }

}
