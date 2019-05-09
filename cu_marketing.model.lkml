connection: "snowflake_prod"

include: "*.view.lkml"


explore: marketing_analysis {
  label: "Marketing CU User Analysis"
  description: "Marketing explore for user segmentation, IPM/email campaign analysis and ad-hoc marketing analysis"
  extends: [session_analysis]
  fields: [learner_profile.user_sso_guid, learner_profile.subscription_start_date, learner_profile.subscription_end_date, learner_profile.products_added_tier,
    all_events.event_subscription_state, all_events.product_platform, all_events.event_name, all_events.local_date, all_events.local_time, all_events.local_week,
    live_subscription_status.student_count,
    dim_institution.entity_no, dim_institution.country, dim_institution.institutionname, dim_institution.city, dim_institution.region, dim_institution.source,
    dim_product.coursearea, dim_product.discipline, dim_product.iac_isbn, dim_product.isbn13, dim_product.authors, dim_product.course, dim_product.titleshort, dim_product.productfamily, dim_product.count,
    dim_productplatform.productplatform,
    dim_course.coursename, dim_course.enddatekey, dim_course.startdatekey, dim_course.coursekey,
    courseinstructor.instructoremail,
    olr_courses.instructor_name, olr_courses.instructor_guid
    ]
}
