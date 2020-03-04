connection: "snowflake_prod"

include: "/models/shared_explores.lkml"
include: "/views/magellan/*.view"
include: "/views/spring_review/*.view"
include: "/views/strategy/*.view"
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
