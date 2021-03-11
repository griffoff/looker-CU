include: "//core/common.lkml"
include: "//core/access_grants_file.view"

include: "/views/cu_user_analysis/*.view"

# include: "/views/event_analysis/*.view"
include: "/views/strategy/*.view"

include: "/views/uploads/*.view.lkml"
# include: "/views/cu_ebook/*.view.lkml"
include: "/views/customer_support/*.view.lkml"
include: "/views/fair_use/*.view.lkml"
include: "/views/discounts/*.view.lkml"
# include: "/views/spring_review/*.view.lkml"
include: "/views/sales_order_forecasting/*.view.lkml"
include: "/views/uploads/covid19_trial_shutoff_schedule.view"
include: "/views/uploads/ehp_tweets.view"
include: "/views/uploads/parsed_ehp_tweets.view"
include: "/views/uploads/ehp_cases.view"
include: "/views/uploads/parsed_ehp_cases.view"
include: "/views/uploads/salesforce_support_calls.view"

include: "/datagroups.lkml"

connection: "snowflake_prod"

case_sensitive: no

persist_for: "16 hours"

fiscal_month_offset: 3

######################### Start of PROD Explores #########################################################################

explore: course_sections {
  hidden: no
  from: course_info
  view_name: course_info
  extends: [user_profile, course_info, all_sessions]

  always_filter: {filters: [course_info.is_real_course: "Yes"]}

  view_label: "Course Section Details"

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

}

# MT Mobile Data

explore: mobiledata {
  hidden: no
  from: ga_mobiledata
  view_name: ga_mobiledata
  label: "MT Mobile GA Data"
  view_label: "MT Mobile GA Data"
  extends: [course_info,user_profile]

  join: course_info {
    sql_on:  ${ga_mobiledata.coursekey} = ${course_info.course_identifier};;
    relationship: many_to_one
  }

  join: user_profile {
    sql_on: ${ga_mobiledata.merged_guid}= ${user_profile.user_sso_guid} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: user_products {
    view_label: "Course Product Details By User"
    sql_on: ${course_info.course_identifier} = ${user_products.course_key}
          and ${user_profile.user_sso_guid} = ${user_products.merged_guid};;
    relationship: one_to_one
  }

}

# **************************************** EHP Data *************************************

explore: ehp_tweets {
  hidden: yes
  label: "EHP Tweets"
  from: ehp_tweets
  join: parsed_ehp_tweets {
    sql_on: ${ehp_tweets._row} = ${parsed_ehp_tweets._row} ;;
    relationship: one_to_many
  }
}

explore: ehp_cases {
  hidden: yes
  label: "EHP Cases"
  from: ehp_cases
  join: parsed_ehp_cases {
    sql_on: ${ehp_cases._row} = ${parsed_ehp_cases._row} ;;
    relationship: one_to_many
  }
}

explore: kpi_user_stats {
  label: "User Count KPIs"
  hidden: no
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

explore: salesforce_support_calls {
  hidden: no
  view_name: salesforce_support_calls
  from: salesforce_support_calls
  extends: [institution_info, user_products]

  join: institution_info {
    sql_on: ${salesforce_support_calls.account_entitynumber_c}::STRING = ${institution_info.institution_id}::STRING ;;
    relationship: many_to_one
  }

  join: user_products {
    view_label: "User Products"
    sql_on: ${user_products.merged_guid} = ${salesforce_support_calls.merged_guid} and ${salesforce_support_calls.created_raw} between coalesce(${user_products._effective_from_raw},to_timestamp(0)) and coalesce(${user_products._effective_to_raw},current_timestamp);;
    relationship: many_to_many
  }

  join: sap_subscriptions {
    view_label: "Subscription"
    sql_on: ${salesforce_support_calls.merged_guid} = ${sap_subscriptions.merged_guid} and ${salesforce_support_calls.created_raw} between ${sap_subscriptions.subscription_start_raw} and coalesce(${sap_subscriptions.cancelled_raw},${sap_subscriptions.subscription_end_raw}) ;;
    relationship: many_to_many
  }

}

# start of ebook_sessions

explore: ebook_sessions {
  from: ebook_sessions
  view_name: ebook_sessions
  extends: [user_profile]

  join: ebook_sessions_weekly {
    sql_on: ${ebook_sessions.merged_guid} = ${ebook_sessions_weekly.merged_guid}
      and ${ebook_sessions.session_start_time_week} = ${ebook_sessions_weekly.session_start_time_week} ;;
    type: inner
    relationship: many_to_one
  }
  join: user_profile {
    sql_on: ${ebook_sessions.merged_guid} = ${user_profile.user_sso_guid} ;;
    relationship: many_to_one
  }
}

# end of ebook_sessions

# start of cas_cafe_student_activity_duration_aggregate_ext

explore: cas_cafe_student_activity_duration_aggregate_ext {
  hidden: yes
  label: "CAS CAFE ACTIVITY DURATION AGGREGATE"
  extends: [cas_cafe_student_activity_duration_aggregate, course_info]
  from: cas_cafe_student_activity_duration_aggregate
  view_name: cas_cafe_student_activity_duration_aggregate

  join: course_info {
    sql_on: ${cas_cafe_student_activity_duration_aggregate.course_key} = ${course_info.course_key} ;;
    relationship: many_to_many
  }

  always_filter: {
    filters:[
      cas_cafe_student_activity_duration_aggregate.group_by_due_date_range: ""
      , cas_cafe_student_activity_duration_aggregate.group_by_activity_name: "No"
      , cas_cafe_student_activity_duration_aggregate.group_by_due_date: "none"
      , cas_cafe_student_activity_duration_aggregate.group_by_group_name: "No"
      , cas_cafe_student_activity_duration_aggregate.group_by_learning_unit_name: "No"
      , cas_cafe_student_activity_duration_aggregate.group_by_learning_path_name: "No"
      , cas_cafe_student_activity_duration_aggregate.only_gradable_activities: "No"
      , cas_cafe_student_activity_duration_aggregate.only_assigned_activities: "No"
      , cas_cafe_student_activity_duration_aggregate.only_attempted_activities: "No"
    ]
  }
}

# end of cas_cafe_student_activity_duration_aggregate_ext

# start of product_analysis

explore: product_analysis {
  hidden: no
  from: user_profile
  extends: [course_info, user_products, all_sessions, user_profile]
  view_name: user_profile
  label: "Event and Session Analysis"

  always_filter: {
    filters: [all_sessions.session_start_date: "Last 7 days"]
  }

  view_label: "User Details"

  join: all_sessions {
    sql_on: ${user_profile.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
    relationship: one_to_many
  }

  join: session_products {
    sql_on: ${all_sessions.session_id} = ${session_products.session_id} ;;
    relationship: one_to_many
    type: inner
  }

  join: all_events {
    view_label: "Events"
    sql_on: ${session_products.session_id} = ${all_events.session_id}
          and coalesce(${session_products.course_key},'') = coalesce(${all_events.course_key},'')
          and coalesce(${session_products.user_products_isbn},'') = coalesce(${all_events.user_products_isbn},'')
          ;;
    relationship: one_to_many
    type: inner
  }

  join: user_products {
    view_label: "Product Details By User"
    sql_on: ${session_products.user_sso_guid} = ${user_products.merged_guid}
      and coalesce(${session_products.user_products_isbn} = ${user_products.isbn13},true)
      and coalesce(${session_products.course_key} = ${user_products.course_key},true)
      and coalesce(nullif(${session_products.user_products_isbn} = ${user_products.isbn13},false),nullif(${session_products.course_key} = ${user_products.course_key},false))
      and ${session_products.session_start_raw} between coalesce(${user_products._effective_from_raw},to_timestamp(0)) and coalesce(${user_products._effective_to_raw},current_timestamp)
      ;;
    relationship: many_to_many
  }

}

# end of product_analysis

# start of user_analysis

explore: user_analysis {
  hidden: no
  extends: [user_profile,user_products]
  from: user_profile
  view_name: user_profile
  view_label: "User Details"

  join: user_products {
    sql_on: ${user_profile.user_sso_guid} = ${user_products.merged_guid} ;;
    relationship: one_to_many
  }
}

# end of user_analysis

# start of fy_2020_support

explore: fy_2020_support {
  label: "FY 2020 Support"
  description: "Temporary explore for FY2020 Support data upload. Will be removed 2021-08-01"
  extends: [product_analysis]

  join: fy_2020_support_mapping_combined {
    sql_on: ${user_profile.user_sso_guid} = ${fy_2020_support_mapping_combined.merged_contact_guid} ;;
    relationship: one_to_many
  }
}

# end of fy_2020_support

# start of subscription_history

explore: subscription_history {
  extends: [user_profile]
  view_name: user_profile

  join: raw_subscription_event_sap {
    view_label: "Subscription History"
    sql_on: ${user_profile.user_sso_guid} = ${raw_subscription_event_sap.merged_guid} ;;
    relationship: one_to_many
    type: inner
  }

  join: user_institution_info {
    from: institution_info
    view_label: "User Institution Details"
    sql_on: ${user_profile.institution_id} = ${user_institution_info.institution_id} ;;
    relationship: many_to_one
  }

  join: live_subscription_status {
    fields: []
  }

}

# end of subscription_history
