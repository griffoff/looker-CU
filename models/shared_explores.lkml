include: "//cube/dims.lkml"
include: "//cube/dim_course.view"

include: "/views/cu_user_analysis/*.view"
include: "/views/cu_user_analysis/cohorts/*.view"
include: "/views/event_analysis/*.view"
include: "/views/discounts/*.view"
include: "/views/strategy/*.view"
include: "/views/uploads/*.view"

include: "/testing/*.view"

include: "/views/cu_user_analysis/filter_caches/*.view"

include: "/views/shared/*.view"

explore: user_courses {
  extension: required
  hidden: no

  join: guid_latest_course_activity {
    view_label: "Course / Section Details by User"
    sql_on: ${user_courses.user_sso_guid} = ${guid_latest_course_activity.user_sso_guid}
      and ${user_courses.olr_course_key} = ${guid_latest_course_activity.course_key};;
    relationship: one_to_one
  }

  join: guid_course_used {
    view_label: "Course / Section Details by User"
    sql_on: ${user_courses.user_sso_guid} = ${guid_course_used.user_sso_guid}
      and ${user_courses.olr_course_key} = ${guid_course_used.course_key};;
    relationship: one_to_one
  }
}

explore: all_events {
  extension: required
  hidden: no
  label: "all events prod"

  join: event_groups {
    fields: [event_group]
    sql_on: UPPER(${all_events.event_name}) like UPPER(${event_groups.event_names}) ;;
    relationship: many_to_one
  }

  join: all_events_tags {
    sql:  cross join lateral flatten (${all_events.event_data}) all_events_tags;;
  }

}

explore: all_sessions {
  extension: required
  hidden:  no
  extends: [all_events, dim_course]
  always_filter: {
    filters: [all_sessions.session_start_date: "Last 7 days"]
  }

  join: all_events {
#        from:  all_events_dev
    sql_on: ${all_sessions.session_id} = ${all_events.session_id} ;;
    type: inner
    relationship: one_to_many
  }

  # join: all_events_diff {
  #   sql_table_name: cu_user_analysis.ALL_EVENTS_DIFF{% parameter event_type %} ;;
  #   view_label: "Event Path (preceding and following events)"
  #   sql_on: ${all_events.event_id} = ${all_events_diff.event_id} ;;
  #   relationship: many_to_one
  #   type: inner
  # }

  join: dim_course {
    sql_on: ${all_events.course_key} = REGEXP_REPLACE(${dim_course.olr_course_key},'WA-production-','',1,0,'i') ;;
    relationship: many_to_many
  }

  join: course_section_facts {
    sql_on: ${dim_course.courseid} = ${course_section_facts.courseid} ;;
    relationship: one_to_one
  }

  join: course_section_usage_facts {
    sql_on:  ${dim_course.olr_course_key} = ${course_section_usage_facts.course_key} ;;
    relationship: one_to_one
  }

  join: user_courses {
    view_label: "Course / Section Details by User"
    sql_on: ${all_events.user_sso_guid} = ${user_courses.user_sso_guid}
      and ${all_events.course_key} = REGEXP_REPLACE(${user_courses.olr_course_key},'WA-production-','',1,0,'i')  ;;

    relationship: one_to_many
  }

  join: dim_institution {
    fields: [dim_institution.CU_fields*]
  }

  join: dim_filter {
    sql_on: ${dim_course.coursekey} = ${dim_filter.course_key} ;;
#     fields: [-dim_filter.ALL_FIELDS*]
  }
}

explore: live_subscription_status {
  label: "Live Subscription Status"
  extends: [dim_course, user_courses]
  from: live_subscription_status
  view_name: live_subscription_status
  view_label: "Learner Profile"
  fields: [ALL_FIELDS*, -learner_profile.user_sso_guid]

  join: merged_cu_user_info {
    view_label: "Learner Profile"
    sql_on:  ${live_subscription_status.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
    relationship: one_to_one
  }

  join: learner_profile {
    view_label: "Learner Profile"
    sql_on:  ${live_subscription_status.user_sso_guid} = ${learner_profile.user_sso_guid}  ;;
    relationship: one_to_one
  }

  join: guid_latest_activity {
    view_label: "Learner Profile"
    fields: [guid_latest_activity.active]
    sql_on: ${learner_profile.user_sso_guid} = ${guid_latest_activity.user_sso_guid} ;;
    relationship: one_to_one
  }

#   join: user_institution_map {
#     fields: []
#     sql_on: ${live_subscription_status.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
#     relationship: many_to_one
#   }

  join: gateway_institution {
    view_label: "Institution"
    sql_on: ${dim_institution.entity_no}::STRING = ${gateway_institution.entity_no};;
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
    view_label: "Course / Section Details by User"
    sql_on: ${learner_profile.user_sso_guid} = ${user_courses.user_sso_guid} ;;
    relationship: one_to_many
  }

  join: dim_course {
    sql_on: ${user_courses.olr_course_key = ${dim_course.coursekey} ;;
    relationship: many_to_many
  }

  join: course_section_facts {
    sql_on: ${dim_course.courseid} = ${course_section_facts.courseid} ;;
    relationship: one_to_one
  }

  join: dim_date {
    view_label: "Subscription Start Date"
    sql_on: ${live_subscription_status.subscription_start_date} =  ${dim_date.datevalue} ;;
    relationship: one_to_one
  }
}

explore: learner_profile_cohorts {
  extension: required
  hidden: no
  from: learner_profile
  view_name: learner_profile

  always_filter: {filters:[merged_cu_user_info.real_user_flag: "Yes"]}

  join: cohorts_platforms_used {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_platforms_used.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: full_access_cohort {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${full_access_cohort.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: full_access_started_cohort {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${full_access_started_cohort.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: TrialAccess_cohorts {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${TrialAccess_cohorts.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: subscription_term_careercenter_clicks {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_careercenter_clicks.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

#   join: eligible_discount_students_details_20190717 {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${eligible_discount_students_details_20190717.user_sso_guid} ;;
#     relationship:  one_to_one
#   }

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


  join: cohorts_user_term_subscriptions_new {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_user_term_subscriptions_new.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

#   join: cohorts_user_term_subscriptions_new_count {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_user_term_subscriptions_new_count.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

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

  join: cohorts_subscription_term_cost_user {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_subscription_term_cost_user.user_sso_guid_merged} ;;
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
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_logins.user_sso_guid_merged} ;;
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

  join: cohorts_full_access_new {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_full_access_new.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_full_access_ended {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_full_access_ended.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_full_access_50{
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_full_access_50.user_sso_guid} ;;
    relationship:  one_to_many
  }

  join: cohorts_extended {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_extended.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: continue_to_partner {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${continue_to_partner.user_sso_guid} ;;
    relationship: one_to_one
  }

  join: study_pack_material_launch {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${study_pack_material_launch.user_sso_guid} ;;
    relationship: one_to_one
  }

  join: study_tool_launch {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${study_tool_launch.user_sso_guid} ;;
    relationship: one_to_one
  }

  join: cohorts_paid_access_cu {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_paid_access_cu.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_paid_access_non_cu {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_paid_access_non_cu.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: cohorts_mobile_usage {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${cohorts_mobile_usage.user_sso_guid_merged} ;;
    relationship:  one_to_many
  }

  join: uploads_cu_sidebar_cohort {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid}=${uploads_cu_sidebar_cohort.merged} ;;
    relationship: many_to_one
  }

  join: guid_cohort {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${guid_cohort.guid} ;;
    relationship: many_to_one
    type: inner
  }

}

explore: learner_profile {
  extends: [learner_profile_cohorts, dim_course, user_courses]
  view_name: learner_profile
  from: learner_profile
  label: "Learner Profile"

  join: merged_cu_user_info {
    view_label: "Learner Profile"
    sql_on:  ${learner_profile.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
    relationship: one_to_one
  }
  join: live_subscription_status {
    view_label: "Learner Profile - Live Subscription Status"
    sql_on:  ${learner_profile.user_sso_guid} = ${live_subscription_status.merged_guid}  ;;
    relationship: one_to_one
  }

  join: guid_latest_activity {
    view_label: "Learner Profile"
    fields: [guid_latest_activity.active, guid_latest_activity.active_desc]
    sql_on: ${learner_profile.user_sso_guid} = ${guid_latest_activity.user_sso_guid} ;;
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
    view_label: "Provisioned Products"
    sql_on: ${live_subscription_status.user_sso_guid} = ${raw_olr_provisioned_product.merged_guid} ;;
    relationship: many_to_many
  }

  join: sat_provisioned_product_v2 {
    fields: [sat_provisioned_product_v2.net_price,sat_provisioned_product_v2.total_user_product_value,sat_provisioned_product_v2.average_total_product_value_per_user,sat_provisioned_product_v2.provisioned_products_per_user]
    view_label: "Provisioned Products"
    sql_on: ${sat_provisioned_product_v2.merged_guid} = ${learner_profile.user_sso_guid} ;;
    relationship: one_to_many
  }

  join: products_v {
    fields: []
    view_label: "Provisioned Products - Info"
    sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
    relationship: many_to_one
  }

  join: user_courses {
    view_label: "Course / Section Details by User"
    sql_on: ${learner_profile.user_sso_guid} = ${user_courses.user_sso_guid} ;;
    relationship: one_to_many
  }

#   join: all_events_user_course_day {
#     view_label: "Course / Section Details by User"
#     sql_on: ${user_courses.user_sso_guid} = ${all_events_user_course_day.user_sso_guid}
#       and ${user_courses.olr_course_key} = ${all_events_user_course_day.olr_course_key};;
#   }

  join: dim_course {
    sql_on: ${user_courses.olr_course_key} = ${dim_course.coursekey} ;;
    relationship: many_to_many
  }

  join: course_section_facts {
    sql_on: ${dim_course.courseid} = ${course_section_facts.courseid} ;;
    relationship: one_to_one
  }

  join: course_section_usage_facts {
    sql_on:  ${dim_course.olr_course_key} = ${course_section_usage_facts.course_key} ;;
    relationship: one_to_one
  }

  join: student_discounts_dps {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${student_discounts_dps.user_sso_guid} ;;
    relationship: one_to_one
  }

  join: institutional_savings {
    view_label: "Institution"
    sql_on: ${dim_institution.entity_no}::STRING = ${institutional_savings.entity_no}::STRING ;;
    relationship: many_to_one
  }

}



explore: session_analysis {
  label: "CU User Analysis Prod"
  extends: [learner_profile, all_sessions]
  from: learner_profile
  view_name: learner_profile
  #fields: [-]

  join: event_cohort_selector {
    sql_on: ${learner_profile.user_sso_guid} = ${event_cohort_selector.user_sso_guid} ;;
    relationship: one_to_one
  }

  join: all_sessions {
    #sql: LEFT JOIN ${all_sessions.SQL_TABLE_NAME} all_sessions SAMPLE({% parameter all_sessions.session_sampling %}) ON ${learner_profile.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
    sql_on: ${learner_profile.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
    relationship: one_to_many
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

  join: products_v {
    fields: [products_v.print_digital_config_cd, products_v.print_digital_config_de]
    view_label: "Product"
    sql_on: ${dim_product.isbn13} = ${products_v.isbn13} ;;
    relationship: one_to_one
  }

  # join: above_the_course_usage_buckets {
  #   view_label: "Above the course usage buckets"
  #   sql_on:  ${learner_profile.user_sso_guid} = ${above_the_course_usage_buckets.user_sso_guid} ;;
  #   relationship:  one_to_many
  # }

  join: strategy_cui_pricing {
    view_label: "Institution"
    sql_on:  ${dim_institution.entity_no} = ${strategy_cui_pricing.entity_id} ;;
    relationship:  one_to_many

  }


}


explore: ebook_sessions {
  join: ebook_sessions_weekly {
    sql_on: ${ebook_sessions.merged_guid} = ${ebook_sessions_weekly.merged_guid}
      and ${ebook_sessions.session_start_time_week} = ${ebook_sessions_weekly.session_start_time_week} ;;
    type: inner
    relationship: many_to_one
  }
  join: cu_user_info {
    sql_on: ${ebook_sessions.merged_guid} = ${cu_user_info.merged_guid} ;;
    relationship: many_to_one
  }
}

explore: cas_cafe_activity_sessions_ext {
  label: "CAS CAFE SESSIONS"
  hidden: no
  extends: [cas_cafe_activity_sessions, dim_course]
  from: cas_cafe_activity_sessions
  view_name: cas_cafe_activity_sessions

  join: dim_course {
    sql_on: ${cas_cafe_activity_sessions.course_key} = ${dim_course.olr_course_key} ;;
    relationship: many_to_many
  }
}
