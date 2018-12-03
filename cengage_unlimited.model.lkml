connection: "snowflake_prod"
include: "*.view.lkml"         # include all views in this project
include: "/core/common.lkml"
include: "/cube/dims.lkml"
include: "/cube/dim_course.view"
include: "/cube/ga_mobiledata.view"


case_sensitive: no

######################### Start of PROD Explores #########################################################################3

######## User Experience Journey Start ###################
explore: all_events {}

explore: all_events_prod {
  label: "all events prod"
  join: all_events_diff_prod {
    view_label: "Event Category Analysis"
    sql_on: ${all_events_prod.event_id} = ${all_events_diff_prod.event_id} ;;
    relationship: many_to_one
    type: inner
  }

  join: student_subscription_status_prod {
    sql_on: ${all_events_prod.user_sso_guid} = ${student_subscription_status_prod.user_sso_guid} ;;
    relationship: many_to_one
  }
  join: event_groups {
    view_label: "User Events"
    fields: [event_group]
    sql_on: UPPER(${all_events_prod.event_name}) like UPPER(${event_groups.event_names}) ;;
    relationship: many_to_one
  }
}


explore: session_analysis_prod {
  label: "CU User Analysis Prod"
  extends: [all_events_prod, dim_course]
  from: all_sessions_prod
  view_name: all_sessions_prod

  join: dim_course {
    sql_on: ${all_sessions_prod.course_keys}[0] = ${dim_course.coursekey} ;;
    relationship: many_to_many
  }

  join: user_institution_map {
    fields: []
    sql_on: ${all_sessions_prod.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: gateway_institution {
    sql_on: ${user_institution_map.entity_no} = ${gateway_institution.entity_no} ;;
    relationship: many_to_one
  }

  join: learner_profile_prod {
    sql_on: ${all_sessions_prod.user_sso_guid} = ${learner_profile_prod.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: all_events_prod {
    sql_on: ${all_sessions_prod.session_id} = ${all_events_prod.session_id} ;;
    relationship: one_to_many
  }

  join: sessions_analysis_week {
    sql_on: ${all_sessions_prod.user_sso_guid} = ${sessions_analysis_week.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: products_v {
    sql_on: ${all_events_prod.iac_isbn} = ${products_v.isbn13} ;;
    relationship: many_to_one
  }
}


explore: event_analysis {
  extends: [all_events]
  from: all_events
  view_name: all_events

  join: learner_profile_prod {
    sql_on: ${all_events.user_sso_guid} = ${learner_profile_prod.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: all_sessions_prod {
    sql_on: ${all_events.session_id} = ${all_sessions_prod.session_id} ;;
    relationship: many_to_one
  }

  join: all_weeks_cu_value {
    sql_on: ${all_sessions_prod.user_sso_guid} = ${all_weeks_cu_value.user_sso_guid} ;;
    relationship: many_to_many
  }

  join: all_weeks_cu_value_sankey {
    sql_on: ${all_sessions_prod.user_sso_guid} = ${all_weeks_cu_value_sankey.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: all_sessions_cu_value {
    sql_on: ${all_sessions_prod.session_id} = ${all_sessions_cu_value.session_id} ;;
    relationship: one_to_one
  }

  join: ip_locations {
    sql_on: ${all_sessions_prod.ips} = ${ip_locations.ip_address} ;;
    relationship: one_to_one
  }
}

################################################# End of PROD Explores ###########################################

################################################ Start of DEV Explores #############################################
access_grant: can_view_CU_dev_data {
  user_attribute: access_grant_team
  allowed_values: [ "yes" ]
}

###### new explore testing#########
explore: all_events_dev {
  label: "testing Dev"
  required_access_grants: [can_view_CU_dev_data]

join: all_events_diff_dev {
  view_label: "Event Category Analysis"
  sql_on: ${all_events_dev.event_id} = ${all_events_diff_dev.event_id} ;;
  relationship: many_to_one
  type: inner
}

join: student_subscription_status_dev {
  sql_on: ${all_events_dev.user_sso_guid} = ${student_subscription_status_dev.user_sso_guid} ;;
  relationship: many_to_one
}
join: event_groups {
  view_label: "User Events"
  fields: [event_group]
  sql_on: UPPER(${all_events_dev.event_name}) like UPPER(${event_groups.event_names}) ;;
  relationship: many_to_one
}

}

explore: session_analysis_dev {
  label: "CU User Analysis Dev"
  from: all_sessions_dev
  extends: [all_events_dev,dim_course]
  # view_name: all_sessions_dev

  join: dim_course {
    sql_on: ${all_sessions_dev.course_keys}[0] = ${dim_course.coursekey} ;;
    relationship: many_to_many
  }

  join: user_institution_map {
    fields: []
    sql_on: ${all_sessions_dev.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: gateway_institution {
    sql_on: ${user_institution_map.entity_no} = ${gateway_institution.entity_no} ;;
    relationship: many_to_one
  }

  join: learner_profile_dev {
    sql_on: ${all_sessions_dev.user_sso_guid} = ${learner_profile_dev.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: all_events_dev {
    sql_on: ${all_sessions_dev.session_id} = ${all_events_dev.session_id} ;;
    relationship: one_to_many
  }

  join: sessions_analysis_week {
    sql_on: ${all_sessions_dev.user_sso_guid} = ${sessions_analysis_week.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: products_v {
    sql_on: ${all_events_dev.iac_isbn} = ${products_v.isbn13} ;;
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
  view_name: raw_subscription_event
  view_label: "Raw Subscription Event"
  join: raw_olr_provisioned_product {
    sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid};;
    relationship: many_to_one
  }
  join: products_v {
    sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
    relationship: many_to_one
  }
  join: sub_actv {
    sql_on: ${raw_subscription_event.user_sso_guid} = ${sub_actv.user_sso_guid} ;;
    relationship: many_to_one
  }
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

  join: cu_user_info {
    sql_on:  ${ga_dashboarddata.userssoguid} = ${cu_user_info.guid}  ;;
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
}


explore: dashboard_use_over_time_bucketed {
  label: "Dashboard Use Over Time Binned"
  join: raw_subscription_event {
    sql_on: ${raw_subscription_event.user_sso_guid} = ${dashboard_use_over_time_bucketed.user_sso_guid} ;;
    relationship: one_to_many
    type: left_outer
  }
  join: cu_user_info {
    sql_on:  ${dashboard_use_over_time_bucketed.user_sso_guid} = ${cu_user_info.guid}  ;;
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

##### End Ebook Usage #####


#### Raw enrollment for Prod research #####
explore: raw_olr_enrollment {
  label: "Product Research (AJ survey)"
  join: aj_survey {
    type: inner
    relationship: many_to_one
    sql_on: ${raw_olr_enrollment.user_sso_guid} = ${aj_survey.ga_dashboarddata_userssoguid} ;;
  }
  join: raw_olr_provisioned_product {
    type: left_outer
    relationship: many_to_many
    sql_on: ${raw_olr_enrollment.user_sso_guid} = ${raw_olr_provisioned_product.user_sso_guid} AND ${raw_olr_enrollment.course_key} = ${raw_olr_provisioned_product.context_id} ;;
  }
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

  join: raw_subscription_event {
    sql_on: ${ga_mobiledata.userssoguid}= ${raw_subscription_event.user_sso_guid} ;;
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
