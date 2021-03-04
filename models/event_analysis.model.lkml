include: "/views/event_analysis/*.view.lkml"
include: "/models/cengage_unlimited.model"

connection: "snowflake_prod"

explore: conversion_analysis {
  extends: [user_profile, user_products]
  from:  conversion_analysis
  view_name:  conversion_analysis

  label: "Conversion/Retention Analysis"
  always_filter: {
    filters:[
      initial_events_filter: ""
      , conversion_events_filter: ""
      , initial_date_range_filter: "after 30 days ago"
      , analysis_type: ""
      , time_period: "1"
      , number_period: "5"
      , show_total: "show"
      ]
    }

  join: user_profile {
    sql_on: ${conversion_analysis.user_sso_guid} = ${user_profile.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: user_products {
    sql_on: ${user_profile.user_sso_guid} = ${user_products.merged_guid} ;;
    relationship: one_to_many
  }
}

explore: flow_analysis {
  label: "Flow Analysis"
  extends: [user_profile, user_products]
  from: cohort_selection
  view_name: cohort_selection

  always_filter: {
    filters:[
      cohort_events_filter: ""
      , flow_events_filter: "-Unload"
      , cohort_date_range_filter: "after 21 days ago"
      , time_period: "30"
      , bucket_other_events: "exclude"
      , ignore_duplicates: "exclude"
      , before_or_after: "after"
      , cohort_selection.sample_size: "50"
      ]
    }

  join: user_profile {
    sql_on: ${cohort_selection.user_sso_guid} = ${user_profile.user_sso_guid} ;;
    relationship: many_to_one
  }

  join: user_products {
    sql_on: ${user_profile.user_sso_guid} = ${user_products.merged_guid} ;;
    relationship: one_to_many
  }
}
