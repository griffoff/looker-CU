include: "//core/common.lkml"
include: "//cube/ga_mobiledata.view"
include: "//core/access_grants_file.view"

include: "/views/cu_user_analysis/*.view.lkml"
include: "/views/cu_user_analysis/cohorts/*.view.lkml"
include: "/views/strategy/*.view.lkml"
include: "/views/uploads/*.view.lkml"
include: "/views/cu_ebook/*.view.lkml"
include: "/views/customer_support/*.view.lkml"
include: "/views/fair_use/*.view.lkml"
include: "/views/discounts/*.view.lkml"
include: "/views/spring_review/*.view.lkml"
include: "/views/sales_order_forecasting/*.view.lkml"
include: "/views/kpi_dashboards/*.view.lkml"
include: "/views/uploads/covid19_trial_shutoff_schedule.view"

include: "/models/shared_explores.lkml"

connection: "snowflake_prod"

case_sensitive: no

######################### Start of PROD Explores #########################################################################

view: current_date {

  view_label: "** Date Filters **"
  derived_table: {
    sql: select date_part(week, current_date()) as current_week_of_year;;
  }

  dimension: current_week_of_year {type: number hidden:yes}
}

explore: course_sections {
  extends: [dim_course]
  from: dim_course
  view_name: dim_course

  label: "Course Sections"

  join: user_courses {
    view_label: "Course / Section Students"
    sql_on: ${dim_course.olr_course_key} = ${user_courses.olr_course_key} ;;
    relationship: one_to_many
  }

  join: merged_cu_user_info {
    view_label: "Course / Section Students"
    sql_on:  ${user_courses.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
    relationship: one_to_one
  }

  join: live_subscription_status {
    sql_on: ${user_courses.user_sso_guid} = ${live_subscription_status.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: current_date {
    sql_on:  1=1 ;;
    relationship: one_to_one
  }

  join: covid19_trial_shutoff_schedule {
    sql_on: ${user_courses.entity_id} = ${covid19_trial_shutoff_schedule.entity_no} ;;
    relationship: many_to_one
  }


}


explore: active_users {
  hidden: yes
  from: guid_platform_date_active

}

explore: active_users_stats  {
  from: dim_date

  join: active_users_platforms {
    relationship: many_to_many
    type: cross
  }

  join: daily_coursesection_instructors {
    sql_on: ${active_users_stats.datevalue} = ${daily_coursesection_instructors.date} ;;
    relationship: one_to_many
  }

  join: daily_paid_users {
    sql_on: ${active_users_stats.datevalue} = ${daily_paid_users.date} ;;
    relationship: one_to_many
  }

  join: dau {
    sql_on: ${active_users_stats.datevalue} = ${dau.date}
        AND ${active_users_platforms.product_platform} = ${dau.product_platform};;
    relationship: one_to_one
    type: inner
  }

  join: dau_old {
    sql_on: ${active_users_stats.datevalue} = ${dau_old.date}
      AND ${active_users_platforms.product_platform} = ${dau_old.product_platform};;
    relationship: one_to_one
    type: inner
  }

  join: dau_ly {
    view_label: "User Activity Counts - Prior Year"
    from: dau
    sql_on: DATEADD(day, {{ ${active_users_platforms.offset._parameter_value }}, ${active_users_stats.datevalue}) = DATEADD(year, 1, ${dau_ly.date})
      AND ${active_users_platforms.product_platform} = ${dau_ly.product_platform};;
    relationship: one_to_one
    type: left_outer
  }

  join: wau {
    sql_on: ${active_users_stats.datevalue} = ${wau.date}
        AND ${active_users_platforms.product_platform} = ${wau.product_platform};;
    relationship: one_to_one
    type: inner
  }

  join: wau_ly {
    view_label: "User Activity Counts - Prior Year"
    from: wau
    sql_on: DATEADD(week, {{ ${active_users_platforms.offset._parameter_value }}, ${active_users_stats.datevalue})  = DATEADD(year, 1, ${wau_ly.date})
      AND ${active_users_platforms.product_platform} = ${wau_ly.product_platform};;
    relationship: one_to_one
    type: left_outer
  }

  join: mau {
    sql_on: ${active_users_stats.datevalue} = ${mau.date}
        AND ${active_users_platforms.product_platform} = ${mau.product_platform};;
    relationship: one_to_one
    type: inner
  }

  join: mau_ly {
    view_label: "User Activity Counts - Prior Year"
    from: mau
    sql_on: DATEADD(month, {{ ${active_users_platforms.offset._parameter_value }}, ${active_users_stats.datevalue})  = DATEADD(year, 1, ${mau_ly.date})
      AND ${active_users_platforms.product_platform} = ${mau_ly.product_platform};;
    relationship: one_to_one
    type: left_outer
  }
  join: dru {
    sql_on: ${active_users_stats.datevalue} = ${dru.date};;
    relationship: one_to_one
    type: inner
  }
  join: wru {
    sql_on: ${active_users_stats.datevalue} = ${wru.date};;
    relationship: one_to_one
    type: inner
  }
  join: mru {
    sql_on: ${active_users_stats.datevalue} = ${mru.date};;
    relationship: one_to_one
    type: inner
  }
  join: yru {
    sql_on: ${active_users_stats.datevalue} = ${yru.date};;
    relationship: one_to_one
    type: inner
  }
}

explore: strategy_ecom_sales_orders {
  label: "Revenue"
  view_label: "Revenue"
  join: dim_date {
    sql_on: ${strategy_ecom_sales_orders.invoice_dt_raw} = ${dim_date.datevalue} ;;
    relationship: many_to_one
  }
  join: dim_product {
    sql_on: ${strategy_ecom_sales_orders.isbn_13} = ${dim_product.isbn13} ;;
    relationship: many_to_one
  }
}



explore: cu_ebook_usage {}




################################################# End of PROD Explores ###########################################


explore: courseware_usage_tiers_csms {}




explore: products_v {}



######## User Experience Journey End PROD ###################



explore: customer_support_cases {
  label: "CU User Analysis Customer Support Cases"
  description: "One time upload of customer support cases joined with CU user analysis to analyze support cases in the context of CU"
  extends: [session_analysis]

  join: customer_support_all {
    view_label: "Customer Support Cases"
    sql_on: ${learner_profile.user_sso_guid} = ${customer_support_all.sso_guid}::STRING ;;
    relationship: one_to_many
  }
  fields: [
    learner_profile.marketing_fields*
    ,all_events.marketing_fields*
    ,live_subscription_status.marketing_fields*
    ,merged_cu_user_info.marketing_fields*
    ,dim_institution.marketing_fields*
    ,dim_product.marketing_fields*
    ,dim_productplatform.productplatform
    ,dim_course.marketing_fields*
#     ,instiution_star_rating.marketing_fields*
    ,course_section_facts.total_noofactivations
    ,courseinstructor.marketing_fields*
    ,dim_start_date.marketing_fields*
    ,olr_courses.instructor_name
#     ,subscription_term_products_value.marketing_fields*
#     ,subscription_term_cost.marketing_fields*
    ,user_courses.marketing_fields*
    ,customer_support_all.detail*]
}





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
  label: "Raw Subscription Events"
  view_name: raw_subscription_event
  view_label: "Subscription Status"
  join: raw_olr_provisioned_product {
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${raw_subscription_event.merged_guid};;
    relationship: many_to_one
  }
  join: products_v {
    sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
    relationship: many_to_one
  }
  join: dim_date {
    sql_on: ${raw_subscription_event.subscription_start_date}::date = ${dim_date.datevalue} ;;
    relationship: many_to_one
  }
#   join: sub_actv {
#     sql_on: ${raw_subscription_event.user_sso_guid} = ${sub_actv.user_sso_guid} ;;
#     relationship: many_to_one
#   }
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

  join: cu_product_category {
    view_label: "Product Category (PRoc)"
    sql_on: ${cu_product_category.isbn_13} = ${raw_olr_provisioned_product.iac_isbn} ;;
    relationship: many_to_one
  }

  join: cu_user_info {
    sql_on:  ${ga_dashboarddata.userssoguid} = ${cu_user_info.merged_guid}  ;;
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

  join: products_v {
    sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
    relationship: many_to_one
  }
}

explore: ga_dashboarddata_merged_2 {
  label: "CU Dashboard mapped"
  join: raw_subscription_event_merged_2 {
    sql_on: ${ga_dashboarddata_merged_2.mapped_guid} = ${raw_subscription_event_merged_2.mapped_guid} ;;
    type: full_outer
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
    sql_on:  ${dashboard_use_over_time_bucketed.user_sso_guid} = ${cu_user_info.merged_guid}  ;;
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

explore: ebook_usage_aggregated {}
##### End Ebook Usage #####


#### Raw enrollment for Prod research #####
explore: raw_olr_enrollment {
  label: "Raw Enrollments"
#   join: raw_olr_provisioned_product {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${raw_olr_enrollment.user_sso_guid} = ${raw_olr_provisioned_product.user_sso_guid} AND ${raw_olr_enrollment.course_key} = ${raw_olr_provisioned_product.context_id} ;;
#   }
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

  join: learner_profile {
    sql_on: ${ga_mobiledata.userssoguid}= ${learner_profile.user_sso_guid} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: live_subscription_status {
    view_label: "Learner Profile"
    sql_on: ${ga_mobiledata.userssoguid}= ${live_subscription_status.user_sso_guid} ;;
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
explore: active_users_sam {
  join: raw_subscription_event {
    type: inner
    relationship: one_to_one
    sql_on: ${active_users_sam.user_guid}=${raw_subscription_event.user_sso_guid} ;;
  }
}



############################ Discount email campaign ##################################

# explore: looker_output_test_1000_20190214_final {}
# explore: email_discount_campaign {
#   label: "Email Discount Campaign"
#   view_label: "Live subscription status"
#   from: live_subscription_status
#
#   join: students_email_campaign_criteria {
#     relationship: one_to_one
#     sql_on: ${email_discount_campaign.user_sso_guid} = ${students_email_campaign_criteria.user_guid} ;;
#   }
#   join: discount_info {
#     relationship: one_to_one
#     sql_on: ${email_discount_campaign.user_sso_guid} = ${discount_info.user_sso_guid} ;;
#   }
#   join: merged_cu_user_info {
#     relationship: one_to_one
#     sql_on: ${email_discount_campaign.user_sso_guid} = ${merged_cu_user_info.user_sso_guid} ;;
#   }
#   # join: upgrade_campaign_user_info_latest_20192021 {
#   #   relationship: one_to_one
#   #   sql_on: ${email_discount_campaign.user_sso_guid} = ${upgrade_campaign_user_info_latest_20192021.guid} ;;
#   # }
#    join: discount_email_control_groups {
#     relationship:  one_to_one
#     sql_on: ${email_discount_campaign.user_sso_guid} =  ${discount_email_control_groups.students_email_campaign_criteria_user_guid};;
#   }
# }
# explore: discount_info {}
# #explore: discount_email_campaign_control_groups {}
#
# explore: students_email_campaign_criteria {
#   join: discount_info {
#     sql_on: ${students_email_campaign_criteria.user_guid} = ${discount_info.user_sso_guid}  ;;
#     relationship: one_to_one
#   }
# }



# --------------------------- Spring Review ----------------------------------

explore: renewed_vs_not_renewed_cu_user_usage_fall_2019 {
}



# ------ Sales order explore -------------------------------------


explore: sales_orders_forecasting {
  label: "Sales Order Forecasting"

join: activations_sales_order_forecasting {
  sql_on: ${sales_orders_forecasting.adoption_key} = ${activations_sales_order_forecasting.adoption_key}
          AND ${sales_orders_forecasting.fiscalyearvalue} = ${activations_sales_order_forecasting.fiscalyear};;
  relationship: many_to_many
}

join: ebook_consumed_salesorder_forecasting {
  sql_on: ${sales_orders_forecasting.adoption_key} = ${ebook_consumed_salesorder_forecasting.adoption_key}
          AND ${sales_orders_forecasting.fiscalyearvalue} = ${ebook_consumed_salesorder_forecasting.fiscalyear};;
  relationship: many_to_many
}

join: ia_adoptions_salesorder_forecasting {
  sql_on:  ${sales_orders_forecasting.adoption_key} = ${ia_adoptions_salesorder_forecasting.adoption_key}
            AND ${sales_orders_forecasting.fiscalyearvalue} = ${ia_adoptions_salesorder_forecasting.fiscalyear};;
  relationship: many_to_one
}

join: cui_adoptions_salesorders {
  sql_on: ${sales_orders_forecasting.institution_nm} = ${cui_adoptions_salesorders.institution_name}
          AND ${sales_orders_forecasting.fiscalyearvalue} = ${cui_adoptions_salesorders.fiscalyear};;
  relationship: many_to_many
}

}

explore: sales_order_adoption_base {}



# **************************************** KPI Dashboard *************************************

explore: z_kpi_sf_activations {
  join: dim_date {
    sql_on: ${z_kpi_sf_activations.actv_dt} = ${dim_date.datevalue} ;;
    relationship: many_to_one
  }
}

explore: dm_activations {
  join: dim_date {
    sql_on: ${dm_activations.actv_dt} = ${dim_date.datevalue} ;;
    relationship: one_to_one

  }
}




#account_creation

#account_creation

explore: account_creation {
  label: "Account creation"
  extends: [session_analysis]
  join: jia_account_creation {
    view_label: "account creation F19"
    sql_on: ${jia_account_creation.user_sso_guid} = ${live_subscription_status.user_sso_guid};;
    relationship: one_to_one
  }
  join: account_link_creation_cohort {
    view_label: "account link creation cohort"
    sql_on: ${account_link_creation_cohort.user_sso_guid} = ${live_subscription_status.user_sso_guid};;
    relationship: one_to_one
  }
}


explore: adoption_usage_analysis {
  label: "Adoption Usage Analysis"
  extends: [session_analysis]
  join: adoption_platform_pivot {
    view_label: "Adoption Platform Pivot"
    sql_on:  ${products.prod_family_cd} = ${adoption_platform_pivot.product_family_code} ;;
    relationship: one_to_one
  }

  join: entity_names {
    view_label: "Entity Names"
    sql_on: ${dim_institution.entity_no}::string =  ${entity_names.entity_no}::string;;
    relationship: one_to_one
  }

  join: cw_adoption_driver_20191217 {
    view_label: "Courseware Adoption Driver"
    sql_on: ${cw_adoption_driver_20191217.adoption_key} = ${entity_names.institution_nm} || '|' ||  ${entity_names.state_cd} || '|' || ${adoption_platform_pivot.course_code_description} ||  '|' ||  ${dim_product.publicationseries}
    ;;
    relationship: one_to_many
  }
  }
