# include: "/views/cu_user_analysis/cohorts/*.view"

# include: "/views/shared/tally.view"

# include: "/views/cu_user_analysis/course_info.view"
# include: "/views/cu_user_analysis/user_products.view"
# include: "/views/cu_user_analysis/session_products.view"
# include: "/views/cu_user_analysis/user_profile.view"
# include: "/views/cu_user_analysis/live_subscription_status.view"
# include: "/views/cu_user_analysis/learner_profile.view"
# include: "/views/cu_user_analysis/guid_cohort.view"
# include: "/views/cu_user_analysis/user_courses.view"
# include: "/views/cu_user_analysis/merged_cu_user_info.view"
# include: "/views/cu_user_analysis/raw_olr_provisioned_product.view"
# include: "/views/cu_user_analysis/products_v.view"
# include: "/views/cu_user_analysis/custom_cohort_filter.view"
# include: "/views/cu_user_analysis/user_institution_map.view"
# include: "/views/cu_user_analysis/sat_provisioned_product_v2.view"
# include: "/views/cu_user_analysis/continue_to_partner.view"
# include: "/views/cu_user_analysis/study_pack_material_launch.view"
# include: "/views/cu_user_analysis/study_tool_launch.view"

# include: "/views/uploads/fy_2020_support_mapping_combined.view"
# include: "/views/cu_user_analysis/raw_subscription_event_sap.view"
# include: "/views/cu_user_analysis/ebook_sessions.view"
# include: "/views/cu_user_analysis/cas_cafe_student_activity_duration_aggregate.view"

# include: "/views/discounts/student_discounts_dps.view"
# include: "/views/strategy/institutional_savings.view"


# include: "/views/event_analysis/*.view"
# include: "/views/discounts/*.view"
# include: "/views/strategy/*.view"
# include: "/views/uploads/*.view"

# include: "/testing/*.view"

# include: "/views/shared/*.view"

# start of live_subscription_status

# explore: live_subscription_status {
#   label: "Live Subscription Status"
#   extends: [course_info, user_courses]
#   from: live_subscription_status
#   view_name: live_subscription_status
#   view_label: "Learner Profile"
#   fields: [ALL_FIELDS*, -learner_profile.user_sso_guid]

#   join: merged_cu_user_info {
#     view_label: "Learner Profile"
#     sql_on:  ${live_subscription_status.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
#     relationship: one_to_one
#   }

#   join: learner_profile {
#     view_label: "Learner Profile"
#     sql_on:  ${live_subscription_status.user_sso_guid} = ${learner_profile.user_sso_guid}  ;;
#     relationship: one_to_one
#   }

#   # join: guid_latest_activity {
#   #   view_label: "Learner Profile"
#   #   fields: [guid_latest_activity.active]
#   #   sql_on: ${learner_profile.user_sso_guid} = ${guid_latest_activity.user_sso_guid} ;;
#   #   relationship: one_to_one
#   # }

# #   join: user_institution_map {
# #     fields: []
# #     sql_on: ${live_subscription_status.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
# #     relationship: many_to_one
# #   }

#   join: gateway_institution {
#     view_label: "Institution"
#     sql_on: ${user_courses.entity_id}::STRING = ${gateway_institution.entity_no};;
#     relationship: many_to_one
#   }

#   join: raw_olr_provisioned_product {
#     fields: []
#     view_label: "Provisioned Products"
#     sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${live_subscription_status.user_sso_guid};;
#     relationship: many_to_one
#   }

#   join: products_v {
#     fields: []
#     view_label: "Provisioned Products - Info"
#     sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
#     relationship: many_to_one
#   }

#   join: user_courses {
#     view_label: "Course Section Details by User"
#     sql_on: ${learner_profile.user_sso_guid} = ${user_courses.user_sso_guid} ;;
#     relationship: one_to_many
#   }

# }

# end of live_subscription_status

# start of learner_profile_cohorts

# explore: learner_profile_cohorts {
#   extension: required
#   hidden: no
#   from: learner_profile
#   view_name: learner_profile

#   join: cohorts_platforms_used {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_platforms_used.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: full_access_cohort {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${full_access_cohort.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: full_access_started_cohort {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${full_access_started_cohort.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: TrialAccess_cohorts {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${TrialAccess_cohorts.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: subscription_term_careercenter_clicks {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_careercenter_clicks.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

# #   join: eligible_discount_students_details_20190717 {
# #     view_label: "Learner Profile"
# #     sql_on: ${learner_profile.user_sso_guid} = ${eligible_discount_students_details_20190717.user_sso_guid} ;;
# #     relationship:  one_to_one
# #   }

# #   join: cohorts_base {type: cross relationship: one_to_one}
# #   join: cohorts_base_institution {type: cross relationship: one_to_one}

#   join: cohorts_chegg_clicked {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_chegg_clicked.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_kaplan_clicked {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_kaplan_clicked.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_quizlet_clicked {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_quizlet_clicked.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_evernote_clicked {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_evernote_clicked.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_print_clicked {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_print_clicked.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_courseware_dashboard {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_courseware_dashboard.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_testprep_dashboard {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_testprep_dashboard.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_studyguide_dashboard {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_studyguide_dashboard.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_flashcards_dashboard {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_flashcards_dashboard.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }


#   join: cohorts_user_term_subscriptions_new {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_user_term_subscriptions_new.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

# #   join: cohorts_user_term_subscriptions_new_count {
# #     view_label: "Learner Profile"
# #     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_user_term_subscriptions_new_count.user_sso_guid_merged} ;;
# #     relationship:  one_to_many
# #   }

#   join: cohorts_subscription_term_savings_user {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_subscription_term_savings_user.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: subscription_term_courseware_value_users {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_courseware_value_users.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_subscription_term_cost_user {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_subscription_term_cost_user.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_term_courses {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_term_courses.user_sso_guid} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_time_in_platform {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_time_in_platform.user_sso_guid} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_number_of_logins {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_logins.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_number_of_ebooks_added_dash {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_ebooks_added_dash.user_sso_guid} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_number_of_courseware_added_to_dash{
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_number_of_courseware_added_to_dash.user_sso_guid} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_full_access_new {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_full_access_new.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_full_access_ended {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_full_access_ended.user_sso_guid} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_full_access_50{
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_full_access_50.user_sso_guid} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_extended {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_extended.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: continue_to_partner {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${continue_to_partner.user_sso_guid} ;;
#     relationship: one_to_one
#   }

#   join: study_pack_material_launch {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${study_pack_material_launch.user_sso_guid} ;;
#     relationship: one_to_one
#   }

#   join: study_tool_launch {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${study_tool_launch.user_sso_guid} ;;
#     relationship: one_to_one
#   }

#   join: cohorts_paid_access_cu {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_paid_access_cu.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_paid_access_non_cu {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_paid_access_non_cu.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: cohorts_mobile_usage {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${cohorts_mobile_usage.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: uploads_cu_sidebar_cohort {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid}=${uploads_cu_sidebar_cohort.merged} ;;
#     relationship: many_to_one
#   }

#   join: guid_cohort {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${guid_cohort.guid} ;;
#     relationship: many_to_one
#     type: inner
#   }

# }

# end of learner_profile_cohorts

# start of learner_profile

# explore: learner_profile {
#   extends: [learner_profile_cohorts, user_courses]
#   view_name: learner_profile
#   from: learner_profile
#   label: "Learner Profile"

#   join: merged_cu_user_info {
#     view_label: "Learner Profile"
#     sql_on:  ${learner_profile.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
#     relationship: one_to_one
#   }

#   join: institution_info {
#     view_label: "Learner Profile"
#     sql_on: ${merged_cu_user_info.entity_id} = ${institution_info.institution_id} ;;
#     relationship: many_to_one
#   }

#   join: live_subscription_status {
#     view_label: "Learner Profile - Live Subscription Status"
#     sql_on:  ${learner_profile.user_sso_guid} = ${live_subscription_status.merged_guid}  ;;
#     relationship: one_to_one
#   }

#   join: custom_cohort_filter {
#     view_label: "** Custom User Cohort Filter **"
#     sql_on: ${learner_profile.user_sso_guid} = ${custom_cohort_filter.user_sso_guid} ;;
#     # type: left_outer
#     relationship: one_to_many
#   }

#   # join: guid_latest_activity {
#   #   view_label: "Learner Profile"
#   #   fields: [guid_latest_activity.active, guid_latest_activity.active_desc]
#   #   sql_on: ${learner_profile.user_sso_guid} = ${guid_latest_activity.user_sso_guid} ;;
#   #   relationship: one_to_one
#   # }

#   join: user_institution_map {
#     fields: []
#     sql_on: ${live_subscription_status.user_sso_guid} = ${user_institution_map.user_sso_guid} ;;
#     relationship: many_to_one
#   }
#   join: gateway_institution {
#     view_label: "Learner Profile"
#     sql_on: coalesce(${merged_cu_user_info.entity_id}::string, ${user_institution_map.entity_no}) = ${gateway_institution.entity_no};;
#     relationship: many_to_one
#   }

#   join: raw_olr_provisioned_product {
#     view_label: "Provisioned Products"
#     sql_on: ${live_subscription_status.user_sso_guid} = ${raw_olr_provisioned_product.merged_guid} ;;
#     relationship: many_to_many
#   }

#   join: sat_provisioned_product_v2 {
#     fields: [sat_provisioned_product_v2.net_price,sat_provisioned_product_v2.total_user_product_value,sat_provisioned_product_v2.average_total_product_value_per_user,sat_provisioned_product_v2.provisioned_products_per_user]
#     view_label: "Provisioned Products"
#     sql_on: ${sat_provisioned_product_v2.merged_guid} = ${learner_profile.user_sso_guid} ;;
#     relationship: one_to_many
#   }

#   join: products_v {
#     fields: []
#     view_label: "Provisioned Products - Info"
#     sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
#     relationship: many_to_one
#   }

#   join: user_courses {
#     view_label: "Course Section Details by User"
#     sql_on: ${learner_profile.user_sso_guid} = ${user_courses.user_sso_guid} ;;
#     relationship: one_to_many
#   }

#   join: custom_course_key_cohort_filter {
#     view_label: "** Custom Course Key Cohort Filter **"
#     sql_on: ${user_courses.olr_course_key} = ${custom_course_key_cohort_filter.course_key} ;;
#     # type: left_outer
#     relationship: many_to_many
#   }

#   join: student_discounts_dps {
#     view_label: "Learner Profile"
#     sql_on: ${learner_profile.user_sso_guid} = ${student_discounts_dps.user_sso_guid} ;;
#     relationship: one_to_one
#   }

#   join: institutional_savings {
#     view_label: "Institution"
#     sql_on: ${user_courses.entity_id}::STRING = ${institutional_savings.entity_no}::STRING ;;
#     relationship: many_to_one
#   }

# }

# end of learner_profile


# start of session analysis

# explore: session_analysis {
#   hidden: yes
#   label: "CU User Analysis Prod"
#   extends: [learner_profile, all_sessions]
#   from: learner_profile
#   view_name: learner_profile
#   #fields: [-]

#   join: all_sessions {
#     #sql: LEFT JOIN ${all_sessions.SQL_TABLE_NAME} all_sessions SAMPLE({% parameter all_sessions.session_sampling %}) ON ${learner_profile.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
#     sql_on: ${learner_profile.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
#     relationship: one_to_many
#   }

#   join: subscription_term_cost {
#     view_label: "Institution"
#     sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_cost.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: subscription_term_products_value {
#     view_label: "Institution"
#     sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_products_value.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

#   join: subscription_term_savings {
#     view_label: "Institution"
#     sql_on: ${learner_profile.user_sso_guid} = ${subscription_term_savings.user_sso_guid_merged} ;;
#     relationship:  one_to_many
#   }

# }

# end session analysis
