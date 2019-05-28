include: "*.view.lkml"
include: "//core/common.lkml"
include: "//cube/dims.lkml"
include: "//cube/dim_course.view"
include: "//core/access_grants_file.view"


case_sensitive: no

explore: marketing_analysis {
  label: "Marketing CU User Analysis"
  description: "Marketing explore for user segmentation, IPM/email campaign analysis and ad-hoc marketing analysis"
  extends: [session_analysis_dev]

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
    ,courseinstructor.instructoremail
    ,dim_start_date.marketing_fields*
    ,olr_courses.instructor_name
    ,olr_courses.instructor_guid
    ,subscription_term_products_value.marketing_fields*
    ,subscription_term_cost.marketing_fields*
    ,user_courses.marketing_fields*
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
}
