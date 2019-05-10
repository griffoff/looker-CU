connection: "snowflake_prod"

include: "*.view.lkml"
include: "//core/common.lkml"
include: "//cube/dims.lkml"
include: "//cube/dim_course.view"
include: "//cube/ga_mobiledata.view"
include: "//core/access_grants_file.view"


case_sensitive: no

explore: marketing_analysis {
  label: "Marketing CU User Analysis"
  description: "Marketing explore for user segmentation, IPM/email campaign analysis and ad-hoc marketing analysis"
  extends: [session_analysis]
  fields: [learner_profile.user_sso_guid, learner_profile.subscription_start_date, learner_profile.subscription_end_date, learner_profile.products_added_count, learner_profile.products_added_tier,
    all_events.event_subscription_state, all_events.product_platform, all_events.event_name, all_events.local_date, all_events.local_time, all_events.local_week,
    live_subscription_status.student_count, live_subscription_status.subscription_status, live_subscription_status.days_time_left_in_current_status,
    merged_cu_user_info.email, merged_cu_user_info.first_name, merged_cu_user_info.last_name,
    dim_institution.entity_no, dim_institution.country, dim_institution.institutionname, dim_institution.city, dim_institution.region, dim_institution.source,
    dim_product.coursearea, dim_product.discipline, dim_product.iac_isbn, dim_product.isbn13, dim_product.authors, dim_product.course, dim_product.titleshort, dim_product.productfamily, dim_product.count,
    dim_productplatform.productplatform,
    dim_course.coursename, dim_course.enddatekey, dim_course.startdatekey, dim_course.coursekey,
    courseinstructor.instructoremail,
    olr_courses.instructor_name, olr_courses.instructor_guid
    ]
}
