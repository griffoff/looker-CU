connection: "snowflake_prod"

include: "/views/event_analysis/*.view.lkml"
include: "/models/shared_explores.lkml"

explore: conversion_analysis {
  extends: [learner_profile]
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

  join: learner_profile {
    sql_on: ${conversion_analysis.user_sso_guid} = ${learner_profile.user_sso_guid} ;;
    relationship: many_to_one
  }
}

explore: cohort_analysis {
  label: "Flow Analysis"
  extends: [learner_profile]
  from: cohort_selection
  view_name: cohort_selection

  always_filter: {
    filters:[
      cohort_events_filter: ""
      , flow_events_filter: "-UNLOAD UNLOAD"
      , cohort_date_range_filter: "after 21 days ago"
      , time_period: "30"
      , bucket_other_events: "exclude"
      , ignore_duplicates: "exclude"
      , before_or_after: "after"
      ]
    }

  join: learner_profile {
    sql_on: ${cohort_selection.user_sso_guid} = ${learner_profile.user_sso_guid} ;;
    relationship: many_to_one
  }
}
