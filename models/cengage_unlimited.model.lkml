include: "//core/common.lkml"
include: "//core/access_grants_file.view"

include: "/views/cu_user_analysis/*.view"
# include: "/views/cu_user_analysis/raw_vitalsource_event.view"
# include: "/views/cu_user_analysis/ga_dashboarddata.view"
# include: "/views/cu_user_analysis/cu_product_category.view"
# include: "/views/cu_user_analysis/instiution_star_rating.view"
# include: "/views/cu_user_analysis/ga_dashboarddata_merged_2.view"
# include: "/views/cu_user_analysis/raw_subscription_event_merged_2.view"
# include: "/views/cu_user_analysis/raw_olr_enrollment.view"
# include: "/views/cu_user_analysis/active_users_sam.view"
# include: "/views/cu_user_analysis/guid_date_subscription.view"
# include: "/views/cu_user_analysis/dim_date_to_date.view"
# include: "/views/cu_user_analysis/kpi_user_counts_wide.view"

# include: "/views/cu_user_analysis/Dashboard.*.view"
# include: "/views/cu_user_analysis/ga_mobile_data.view"
# include: "/views/cu_user_analysis/active_users.*.view"
# include: "/views/cu_user_analysis/cu_user_analysis_clustering_information.view"

include: "/views/event_analysis/*.view"
include: "/views/strategy/*.view"
#include: "/views/strategy/courseware_usage_tiers_csms.view.lkml"

include: "/views/cu_user_analysis/cohorts/*.view.lkml"

#include: "/views/uploads/*.view.lkml"
include: "/views/cu_ebook/*.view.lkml"
include: "/views/customer_support/*.view.lkml"
include: "/views/fair_use/*.view.lkml"
include: "/views/discounts/*.view.lkml"
include: "/views/spring_review/*.view.lkml"
include: "/views/sales_order_forecasting/*.view.lkml"
# include: "/views/kpi_dashboards/*.view.lkml"
include: "/views/uploads/covid19_trial_shutoff_schedule.view"
include: "/views/uploads/ehp_tweets.view"
include: "/views/uploads/parsed_ehp_tweets.view"
include: "/views/uploads/ehp_cases.view"
include: "/views/uploads/parsed_ehp_cases.view"


include: "/models/shared_explores.lkml"

connection: "snowflake_prod"

case_sensitive: no

persist_for: "16 hours"

fiscal_month_offset: 3

######################### Start of PROD Explores #########################################################################

# view: current_date {

#   view_label: "** Date Filters **"
#   derived_table: {
#     sql: select date_part(week, current_date()) as current_week_of_year;;
#   }

#   dimension: current_week_of_year {type: number hidden:yes}
# }

explore: instructor_provisioned_products {
  from: raw_olr_provisioned_product
  view_name: raw_olr_provisioned_product
  sql_always_where: ${user_type} = 'instructor' ;;
  label: "instructor Provisioned Products"

  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }

}

explore: raw_olr_provisioned_product {
  extends: [instructor_provisioned_products]
  sql_always_where: ${user_type} = 'student' ;;
  label: "Student Provisioned Products"

  join: live_subscription_status {
    relationship: one_to_one
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${live_subscription_status.user_sso_guid} ;;
  }

  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }

  join: uploads_cu_sidebar_cohort {
    view_label: "CU sidebar cohort"
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${uploads_cu_sidebar_cohort.merged} ;;
    relationship: many_to_one
  }
}

explore: course_sections {
  hidden: no
  from: course_info
  view_name: course_info
  extends: [user_profile, course_info, product_institution_info]
  view_label: "Course Section Details"

  # join: current_date {
  #   type:cross
  #   relationship: many_to_one
  # }

  join: user_products {
    view_label: "Course Product Details By User"
    sql_on: ${course_info.course_identifier} = ${user_products.course_key} ;;
    relationship: one_to_many
  }

  join: user_profile {
    view_label: "User Details"
    sql_on: ${user_products.merged_guid} = ${user_profile.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: session_products {
    sql_on: ${session_products.user_sso_guid} = ${user_products.merged_guid}
      and coalesce(${session_products.user_products_isbn} = ${user_products.isbn13},true)
      and coalesce(${session_products.course_key} = ${user_products.course_key},true)
      and coalesce(nullif(${session_products.user_products_isbn} = ${user_products.isbn13},false),nullif(${session_products.course_key} = ${user_products.course_key},false))
      and ${session_products.session_start_raw} between coalesce(${user_products._effective_from_raw},to_timestamp(0)) and coalesce(${user_products._effective_to_raw},current_timestamp)
    ;;
    relationship: many_to_many
  }

  join: all_sessions {
    sql_on: ${all_sessions.session_id} = ${session_products.session_id} ;;
    relationship: many_to_one
  }

  join: all_events {
    sql_on: ${all_events.session_id} = ${all_sessions.session_id};;
    relationship: one_to_many
  }

}


# explore: course_sections {
#   extends: [course_info, institution_info, user_courses, learner_profile_cohorts, all_events]
#   from: current_date
#   view_name: current_date

#   join: course_info {type:cross}

#   label: "Course Sections"

#   join: user_courses {
#     view_label: "Course Section Students"
#     sql_on: ${course_info.course_key} = ${user_courses.olr_course_key} ;;
#     relationship: one_to_many
#   }

#   join: merged_cu_user_info {
#     view_label: "Course Section Students"
#     sql_on:  ${user_courses.user_sso_guid} = ${merged_cu_user_info.user_sso_guid}  ;;
#     relationship: one_to_one
#   }

#   join: learner_profile {
#     sql_on: ${user_courses.user_sso_guid} = ${learner_profile.user_sso_guid} ;;
#     relationship: many_to_one
#   }

#   join: live_subscription_status {
#     sql_on: ${user_courses.user_sso_guid} = ${live_subscription_status.user_sso_guid} ;;
#     relationship: many_to_one
#   }

#   join: raw_olr_provisioned_product {
#     fields: []
#     view_label: "Provisioned Products"
#     sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${live_subscription_status.user_sso_guid};;
#     relationship: many_to_one
#   }

#   join: covid19_trial_shutoff_schedule {
#     sql_on: ${user_courses.entity_id} = ${covid19_trial_shutoff_schedule.entity_no} ;;
#     relationship: many_to_one
#   }

#   join: all_events {
#     sql_on: (${user_courses.user_sso_guid}, REGEXP_REPLACE(${user_courses.olr_course_key},'WA-production-','',1,0,'i')) = (${all_events.user_sso_guid}, ${all_events.course_key}) ;;
#     relationship: one_to_many
#   }

# }


# explore: active_users {
#   hidden: yes
#   from: guid_platform_date_active
# }

# explore: strategy_ecom_sales_orders {
#   label: "Revenue"
#   view_label: "Revenue"
#   join: dim_date {
#     sql_on: ${strategy_ecom_sales_orders.invoice_dt_raw} = ${dim_date.datevalue} ;;
#     relationship: many_to_one
#   }
#   join: dim_product {
#     sql_on: ${strategy_ecom_sales_orders.isbn_13} = ${dim_product.isbn13} ;;
#     relationship: many_to_one
#   }
# }


################################################# End of PROD Explores ###########################################


explore: courseware_usage_tiers_csms {}




explore: products_v {}



######## User Experience Journey End PROD ###################



# explore: customer_support_cases {
#   label: "CU User Analysis Customer Support Cases"
#   description: "One time upload of customer support cases joined with CU user analysis to analyze support cases in the context of CU"
#   extends: [session_analysis]

#   join: customer_support_all {
#     view_label: "Customer Support Cases"
#     sql_on: ${learner_profile.user_sso_guid} = ${customer_support_all.sso_guid}::STRING ;;
#     relationship: one_to_many
#   }
# }





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

# explore: raw_subscription_event {
#   hidden: yes
#   extends: [user_info]
#   label: "Raw Subscription Events"
#   view_name: raw_subscription_event
#   view_label: "Subscription Status"

#   join: raw_olr_provisioned_product {
#     sql_on: ${raw_olr_provisioned_product.merged_guid} = ${raw_subscription_event.merged_guid};;
#     relationship: many_to_one
#   }
#   join: products_v {
#     sql_on: ${raw_olr_provisioned_product.iac_isbn} = ${products_v.isbn13};;
#     relationship: many_to_one
#   }
#   join: dim_date {
#     view_label: "Subscription Start"
#     sql_on: ${raw_subscription_event.subscription_start_date}::date = ${dim_date.datevalue} ;;
#     relationship: many_to_one
#   }
#   join: date_active {
#     view_label: "Subscription at point in time"
#     from: dim_date
#     sql_on: ${date_active.datevalue_raw} between ${raw_subscription_event.subscription_start_raw}::date and ${raw_subscription_event.subscription_end_raw}::date;;
#     relationship: many_to_many
#     type: inner
#   }
#   join: dim_course {
#     sql: cross join lateral flatten(${raw_olr_provisioned_product.context_id}, outer=>True)  courses
#         left join ${dim_course.SQL_TABLE_NAME} dim_course ON courses.value = ${dim_course.context_id} ;;
#     relationship: many_to_one
#   }
# #   join: sub_actv {
# #     sql_on: ${raw_subscription_event.user_sso_guid} = ${sub_actv.user_sso_guid} ;;
# #     relationship: many_to_one
# #   }
# }


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

##### End Dashboard #####




# ##### Ebook Usage #####
#   explore: ebook_usage {
#     label: "Ebook Usage"
#     extends: [raw_subscription_event]
#     join: ebook_usage_actions {
#       sql_on:  ${raw_subscription_event.user_sso_guid} = ${ebook_usage_actions.user_sso_guid} ;;
#       type: left_outer
#       relationship: one_to_many
#     }

#     join: ebook_mapping {
#       type: left_outer
#       sql_on: ${ebook_usage_actions.event_action} = ${ebook_mapping.action}  AND ${ebook_usage_actions.source} = ${ebook_mapping.source} AND ${ebook_usage_actions.event_category} = ${ebook_mapping.event_category};;
#       relationship: many_to_one
#     }
#   }

# explore: ebook_usage_aggregated {}
# ##### End Ebook Usage #####


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
  from: ga_mobiledata
  view_name: ga_mobiledata
  label: "MT Mobile GA Data"
  extends: [course_info]

  join: course_info {
    sql_on:  ${ga_mobiledata.coursekey} = ${course_info.course_key};;
    relationship: many_to_one
  }

  join: learner_profile {
    sql_on: ${ga_mobiledata.userssoguid}= ${learner_profile.user_sso_guid} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: user_courses {
    sql_on: ${course_info.course_key} = ${user_courses.olr_course_key}
          and ${learner_profile.user_sso_guid} = ${user_courses.user_sso_guid};;
    relationship: one_to_one
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

# **************************************** EHP Data *************************************

explore: ehp_tweets {
  label: "EHP Tweets"
  from: ehp_tweets
  join: parsed_ehp_tweets {
    sql_on: ${ehp_tweets._row} = ${parsed_ehp_tweets._row} ;;
    relationship: one_to_many
  }
}

explore: ehp_cases {
  label: "EHP Cases"
  from: ehp_cases
  join: parsed_ehp_cases {
    sql_on: ${ehp_cases._row} = ${parsed_ehp_cases._row} ;;
    relationship: one_to_many
  }
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

# explore: z_kpi_sf_activations {
#   join: dim_date {
#     sql_on: ${z_kpi_sf_activations.actv_dt} = ${dim_date.datevalue} ;;
#     relationship: many_to_one
#   }
# }

# explore: dm_activations {
#   join: dim_date {
#     sql_on: ${dm_activations.actv_dt} = ${dim_date.datevalue} ;;
#     relationship: one_to_one

#   }
# }




#account_creation

#account_creation

# explore: account_creation {
#   label: "Account creation"
#   extends: [session_analysis]
#   join: jia_account_creation {
#     view_label: "account creation F19"
#     sql_on: ${jia_account_creation.user_sso_guid} = ${live_subscription_status.user_sso_guid};;
#     relationship: one_to_one
#   }
#   join: account_link_creation_cohort {
#     view_label: "account link creation cohort"
#     sql_on: ${account_link_creation_cohort.user_sso_guid} = ${live_subscription_status.user_sso_guid};;
#     relationship: one_to_one
#   }
# }


# explore: adoption_usage_analysis {
#   label: "Adoption Usage Analysis"
#   extends: [session_analysis]
#   join: adoption_platform_pivot {
#     view_label: "Adoption Platform Pivot"
#     sql_on:  ${products.prod_family_cd} = ${adoption_platform_pivot.product_family_code} ;;
#     relationship: one_to_one
#   }

#   join: entity_names {
#     view_label: "Entity Names"
#     sql_on: ${dim_institution.entity_no}::string =  ${entity_names.entity_no}::string;;
#     relationship: one_to_one
#   }

#   join: cw_adoption_driver_20191217 {
#     view_label: "Courseware Adoption Driver"
#     sql_on: ${cw_adoption_driver_20191217.adoption_key} = ${entity_names.institution_nm} || '|' ||  ${entity_names.state_cd} || '|' || ${adoption_platform_pivot.course_code_description} ||  '|' ||  ${dim_product.publicationseries}
#     ;;
#     relationship: one_to_many
#   }
# }

view: date_ty_ly {

  parameter: offset {
    view_label: "Filters"
    description: "Offset (days/weeks/months depending on metric) to use when comparing vs prior year, can be positive to move prior year values forwards or negative to shift prior year backwards"
    type: number
    default_value: "0"
  }

  derived_table: {
    sql:
    select
      datevalue
      , datevalue as date
      , date as ty_date
      , null as ly_date
      , DATE_PART(EPOCH, date) as ty_epoch_date
      , null as ly_epoch_date
    from prod.dm_common.dim_date_legacy_cube
    union all
    select
      datevalue
      , DATEADD(day, {% parameter offset %}, dateadd(year, -1, datevalue)) as date
      , null
      , date as ly_date
      , null as ty_epoch_date
      , DATE_PART(EPOCH, date) as ly_epoch_date
    from prod.dm_common.dim_date_legacy_cube
    ;;
  }

  dimension: datevalue {type: date_raw hidden:yes}
  dimension: date {type: date_raw hidden:yes primary_key:yes}
  dimension: ty_date {type:date_raw hidden:yes}
  dimension: ly_date {type:date_raw hidden:yes}

  dimension: ty_epoch_date {type:number hidden:yes}
  dimension: ly_epoch_date {type:number hidden:yes}

}

explore: kpi_user_stats {
  persist_with: daily_refresh
  from: dim_date_to_date
  view_name: dim_date_to_date

  always_filter: {filters:[date_range: "Last 7 days", cumulative_counts: "No", kpi_user_counts.exact_counts: "false"]}

  view_label: "Date"


  join: kpi_user_counts {
    from: kpi_user_counts_wide
    view_label: "User Counts"
    sql_on: ${dim_date_to_date.middle_date_raw} = ${kpi_user_counts.date_raw}
        AND {% condition dim_date_to_date.date_range %} ${kpi_user_counts.date_raw} {% endcondition %}
    ;;
    relationship: many_to_many
  }

  join: yru {
    view_label: "User Counts"
    sql_on: ${dim_date_to_date.middle_date_raw} = ${yru.date_raw};;
    relationship: many_to_one
    type: left_outer
  }

  join: yru_ly {
    from: yru
    view_label: "User Counts - Prior Year"
    sql_on: ${dim_date_to_date.middle_date_ly_raw} = ${yru_ly.date_raw};;
    relationship: many_to_one
    type: left_outer
  }

}
