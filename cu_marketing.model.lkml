include: "*.view.lkml"
include: "//core/common.lkml"
include: "//cube/dims.lkml"
# include: "//cube/dim_course.view"
include: "//core/access_grants_file.view"


case_sensitive: no

explore: marketing_analysis {
  label: "Marketing CU User Analysis"
  description: "Marketing explore for user segmentation, IPM/email campaign analysis and ad-hoc marketing analysis"
  extends: [session_analysis]

  fields: [learner_profile.marketing_fields* ,all_events.marketing_fields*,live_subscription_status.marketing_fields*,
    merged_cu_user_info.marketing_fields*,
    dim_institution.marketing_fields*,
    dim_product.marketing_fields*,
    dim_productplatform.productplatform,
    dim_course.marketing_fields*,
    instiution_star_rating.marketing_fields*,
    courseinstructor.instructoremail,
    olr_courses.instructor_name, olr_courses.instructor_guid
    ]

  join: instiution_star_rating {
    view_label: "Institution"
    sql_on: ${dim_institution.entity_no}::STRING = ${instiution_star_rating.entity_}::STRING ;;
    relationship: many_to_one
  }
}
