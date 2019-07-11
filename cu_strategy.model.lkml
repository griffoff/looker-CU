include: "*.view.lkml"
include: "//core/common.lkml"
include: "//cube/dims.lkml"
include: "//cube/dim_course.view"
include: "//core/access_grants_file.view"


case_sensitive: no

explore: strategy_analysis {
  label: "CU User Analysis Strategy"
  description: "Strategy explore for executing repeatable business strategy
  analysis i.e. take-rate, revenue canibalization and student savings"
  extends: [session_analysis]

  fields: [
    learner_profile.marketing_fields*
    ,all_events.marketing_fields*
    ,live_subscription_status.marketing_fields*
    ,merged_cu_user_info.marketing_fields*
    ,dim_institution.marketing_fields*
    ,dim_product.marketing_fields*
    ,dim_productplatform.productplatform
    ,dim_course.marketing_fields*
    ,instiution_star_rating.marketing_fields*
    ,course_section_facts.total_noofactivations
    ,courseinstructor.marketing_fields*
    ,dim_start_date.marketing_fields*
    ,olr_courses.instructor_name
    ,subscription_term_products_value.marketing_fields*
    ,subscription_term_cost.marketing_fields*
    ,user_courses.marketing_fields*
#     ,user_courses_dev.marketing_fields*
    ,FullAccess_cohort.marketing_fields*
    ,subscription_term_careercenter_clicks.marketing_fields*
    ,cohorts_chegg_clicked.marketing_fields*
    ,cohorts_courseware_dashboard.marketing_fields*
    ,cohorts_evernote_clicked.marketing_fields*
    ,cohorts_flashcards_dashboard.marketing_fields*
    ,cohorts_kaplan_clicked.marketing_fields*
    ,cohorts_print_clicked.marketing_fields*
    ,cohorts_quizlet_clicked.marketing_fields*
    ,cohorts_studyguide_dashboard.marketing_fields*
    ,subscription_term_cost.marketing_fields*
    ,subscription_term_products_value.marketing_fields*
    ,subscription_term_savings.marketing_fields*
    ,cohorts_testprep_dashboard.marketing_fields*
    ,TrialAccess_cohorts.marketing_fields*
    ,csat_survey.marketing_fields*
    ,cohorts_subscription_term_savings_user.marketing_fields*
    ,subscription_term_courseware_value_users.marketing_fields*
    ,gateway_institution.marketing_fields*
    ,cohorts_term_courses.marketing_fields*
    ,cohorts_time_in_platform.marketing_fields*
    ,cohorts_number_of_logins.marketing_fields*
    ,cohorts_number_of_ebooks_added_dash.marketing_fields*
    ,cohorts_number_of_courseware_added_to_dash.marketing_fields*
    ,magellan_instructor_setup_status*
    ,magellan_ipeds_details*
    ,cu_enterprise_licenses*
    ,strategy_spring_review_queries.strategy_fields*
  ]

  join: instiution_star_rating {
    view_label: "Institution"
    sql_on: ${dim_institution.entity_no}::STRING = ${instiution_star_rating.entity_}::STRING ;;
    relationship: many_to_one
  }

  join: csat_survey {
    view_label: "CSAT Survey"
    sql_on: ${csat_survey.mapped_guid} = ${all_events.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: magellan_instructor_setup_status {
    view_label: "Magellan Instructor Status"
    sql_on: ${courseinstructor.instructor_guid} = ${magellan_instructor_setup_status.user_guid} ;;
    relationship: many_to_one
  }

  join: magellan_ipeds_details {
    view_label: "IPEDS Details"
    sql_on: ${dim_institution.entity_no}::STRING = ${magellan_ipeds_details.entity_no}::STRING ;;
    relationship: one_to_one
  }

  join: cu_enterprise_licenses {
    view_label: "CUI Info"
    sql_on: ${dim_course.olr_course_key} = ${cu_enterprise_licenses.course_context_id} ;;
    relationship: many_to_one
  }

  join: strategy_spring_review_queries {
    view_label: "Strategy Spring Review"
    sql_on: ${learner_profile.user_sso_guid} = ${strategy_spring_review_queries.merged_guid} ;;
    relationship: one_to_many
  }


}
