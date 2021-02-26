include: "/models/shared_explores.lkml"

include: "/views/cu_user_analysis/cu_enterprise_licenses.view"
include: "/views/cu_user_analysis/instiution_star_rating.view"
include: "/views/cu_user_analysis/csat_survey.view"

include: "/views/magellan/*.view"
include: "/views/discounts/*.view"
include: "/views/strategy/account_sharers.view"
include: "/views/strategy/late_activators.view"
include: "/views/ipm/ipm_guids_impressions_past_7_days.view"

connection: "snowflake_prod"

case_sensitive: no

explore: account_sharers {
  label: "Account Sharing"
  join: cu_user_info {
    sql_on: ${account_sharers.merged_guid} = ${cu_user_info.user_sso_guid}  ;;
    relationship: many_to_one
  }
}

explore: late_activators_removals {
  from: late_activators_removals
  view_name: late_activators
  label: "Late Activations - daily removals"
  join: cu_user_info {
    sql_on: ${late_activators.user_sso_guid} = ${cu_user_info.user_sso_guid}  ;;
    relationship: many_to_one
  }
  join: live_subscription_status {
    sql_on: ${cu_user_info.user_sso_guid} = ${live_subscription_status.merged_guid} ;;
    relationship: one_to_one
  }
}

explore: late_activators_retroactive {
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

# explore: magellan_instructor_setup_status {

#   extends: [user_courses]

#   join: dim_institution {
#     sql_on: ${magellan_instructor_setup_status.entity_no}::STRING = ${dim_institution.entity_no}::STRING ;;
#     relationship: many_to_one
#   }

#   join: courseinstructor {
#     sql_on: ${magellan_instructor_setup_status.user_guid} = ${courseinstructor.instructor_guid};;
#     relationship: many_to_many
#   }

#   join: dim_course {
#     sql_on: ${dim_institution.institutionid} = ${dim_course.institutionid}
#             AND ${dim_course.coursekey} = ${courseinstructor.coursekey};;
#     relationship: one_to_many
#   }

#   join: dim_start_date {
#     sql_on: ${dim_course.startdatekey} = ${dim_start_date.datekey} ;;
#     relationship: many_to_one
#   }

#   join: dim_product {
#     sql_on: ${dim_course.productid} = ${dim_product.productid} ;;
#     relationship: many_to_one
#   }

#   join: user_courses {
#     sql_on: ${dim_course.olr_course_key} = ${user_courses.olr_course_key} ;;
#     relationship: one_to_many
#   }


#   join: course_section_facts {
#     sql_on: ${dim_course.courseid} = ${course_section_facts.courseid} ;;
#     relationship: one_to_one
#   }

# }

explore: marketing_analysis {
  hidden: yes
  label: "CU User Analysis Marketing"
  description: "Marketing explore for user segmentation, IPM/email campaign analysis and ad-hoc marketing analysis"
  extends: [session_analysis]

# This method only works if everyone has a mapping (i.e. there is no override to see all)
#   access_filter: {
#     field: magellan_lc_mapping.email
#     user_attribute: saml_user_id
#   }
#  Use this code to filter results for individuals
  sql_always_where:
          UPPER(${magellan_entity_user_mapping.email}) = UPPER('{{ _user_attributes['saml_user_id'] }}')
          OR UPPER(${magellan_entity_user_mapping.email}) = UPPER('{{ _user_attributes['email'] }}')
          OR '{{ _user_attributes['view_all_institutions'] }}' = 'yes'
          ;;

  join: magellan_entity_user_mapping {
    sql_on: ${institution_info.institution_id}::STRING = ${magellan_entity_user_mapping.entity_no}::STRING ;;
    relationship: one_to_many
  }

  join: instiution_star_rating {
    view_label: "Institution"
    sql_on: ${institution_info.institution_id}::STRING = ${instiution_star_rating.entity_}::STRING ;;
    relationship: many_to_one
  }

  join: institutional_savings {
    view_label: "Institution"
    sql_on: ${institution_info.institution_id}::STRING = ${institutional_savings.entity_no}::STRING ;;
    relationship: many_to_one
  }

  join: csat_survey {
    view_label: "CSAT Survey"
    sql_on: ${csat_survey.mapped_guid} = ${all_events.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: magellan_ipeds_details {
    view_label: "IPEDS Details"
    sql_on: ${institution_info.institution_id}::STRING = ${magellan_ipeds_details.entity_no}::STRING ;;
    relationship: one_to_one
  }

  join: cu_enterprise_licenses {
    view_label: "CUI Info"
    sql_on: ${course_info.course_key} = ${cu_enterprise_licenses.course_context_id} ;;
    relationship: many_to_one
  }

  join: student_discounts_dps {
    view_label: "Learner Profile"
    sql_on: ${learner_profile.user_sso_guid} = ${student_discounts_dps.user_sso_guid} ;;
    relationship: one_to_one
  }

  # join: magellan_instructor_setup_status {
  #   view_label: "Magellan Instructor Status"
  #   sql_on: ${courseinstructor.instructor_guid} = ${magellan_instructor_setup_status.user_guid} ;;
  #   relationship: many_to_one
  # }

  # join: ipm_260_email_list {
  #   view_label: " IPM 260 email list"
  #   sql_on: ${courseinstructor.instructoremail} = ${ipm_260_email_list.email} ;;
  #   relationship: many_to_one
  # }

  join: ipm_guids_impressions_past_7_days {
    view_label: "IPM Impressions past 7 days guid list"
    sql_on: ${learner_profile.user_sso_guid} = ${ipm_guids_impressions_past_7_days.user_sso_guid} ;;
    relationship: one_to_one
  }

#   join: ipm_ff_20190830 {
#     sql_on: ${learner_profile.user_sso_guid} = ${ipm_ff_20190830.user_sso_guid} ;;
#     relationship: one_to_one
#   }

}

explore: marketing_learner_profile {
  extends: [learner_profile]
  hidden: yes

}
