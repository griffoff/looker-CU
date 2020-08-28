connection: "snowflake_prod"

include: "/views/event_analysis/*.view.lkml"
include: "/models/shared_explores.lkml"

explore: conversion_analysis {
  always_filter: {
    filters:[
      initial_events_filter: ""
      , conversion_events_filter: ""
      , initial_date_range_filter: "after 30 days ago"
      , time_period: ""
      , number_period: ""
      ]
    }
}

explore: cohort_analysis {
  label: "Flow analysis"
  extends: [learner_profile]
  from: cohort_selection
  view_name: cohort_selection

  always_filter: {
    filters:[
      cohort_events_filter: ""
      , flow_events_filter: "-UNLOAD UNLOAD"
      , cohort_date_range_filter: "after 21 days ago"
      , time_period: "30"
      , ignore_duplicates: "exclude"
      , before_or_after: "after"
      ]
    }

  join: learner_profile {
    sql_on: ${cohort_selection.user_sso_guid} = ${learner_profile.user_sso_guid} ;;
    relationship: many_to_one
  }
}
