explore: user_event_conversion {}
view: user_event_conversion {

  filter: initial_events_filter {
    view_label: "** USER EVENT CONVERSION **"
    label: "Choose 1st (initial) event"
    description: "Select the starting event(s) that you want to analyze conversion for"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: conversion_events_filter {
    view_label: "** USER EVENT CONVERSION **"
    label: "Choose 2nd (conversion) event"
    description: "Select the conversion event(s) that you want to analyze following the initial event"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: initial_date_range_filter {
    view_label: "** USER EVENT CONVERSION **"
    label: "Choose a initial event date range"
    description: "Select a date range for the initial event to occur within"
    type: date
    datatype: date
  }

  parameter: time_period {
    view_label: "** USER EVENT CONVERSION **"
    label: "Include conversions within (n) days after the initial event"
    description: "How long after the initial event do you want to look for conversions. Leave blank for all conversions up to current date."
    type: number
  }


  derived_table: {
    sql:
    with initial as (
      select distinct
        user_sso_guid
        , array_agg(event_name) as initial_event
        , max(event_time) as initial_time_max
        , min(event_time) as initial_time_min
      from ${all_events.SQL_TABLE_NAME} e
      WHERE (DATEADD(day, 1, event_time::DATE) >= {% date_start initial_date_range_filter %} OR {% date_start initial_date_range_filter %} IS NULL)
      AND (DATEADD(day, -1, event_time::DATE) < {% date_end initial_date_range_filter %} OR {% date_end initial_date_range_filter %} IS NULL)
      AND {% condition initial_events_filter %} event_name {% endcondition %}
      group by user_sso_guid
      )
    --, conversion as (
      select
        i.user_sso_guid
        , initial_event
        , initial_time_max
        , initial_time_min
        , array_agg(event_name) as conversion_event
        , max(event_time) as conversion_time_max
        , min(event_time) as conversion_time_min
      from initial i
      left join ${all_events.SQL_TABLE_NAME} e

      on i.user_sso_guid = e.user_sso_guid
        and e.event_time between i.initial_time_max and coalesce(dateadd(d, {{ time_period._parameter_value }}, i.initial_time_max), current_date())
        AND {% condition conversion_events_filter %} event_name {% endcondition %}
      group by 1,2,3,4

      ;;
  }

  dimension: user_sso_guid {view_label: "** USER EVENT CONVERSION **"}
  dimension: initial_event {view_label: "** USER EVENT CONVERSION **"}
  dimension: initial_time_max {view_label: "** USER EVENT CONVERSION **" type:date}
  dimension: initial_time_min {view_label: "** USER EVENT CONVERSION **" type:date}
  dimension: conversion_event {view_label: "** USER EVENT CONVERSION **"}
  dimension: conversion_time_max {view_label: "** USER EVENT CONVERSION **" type:date}
  dimension: conversion_time_min {view_label: "** USER EVENT CONVERSION **" type:date}

  dimension: user_converted {
    view_label: "** USER EVENT CONVERSION **"
    sql: case when ${conversion_time_max} is not null then true else false end ;;
    type: yesno
    }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
    view_label: "** USER EVENT CONVERSION **"
  }

  measure: conversion_user_count {
    type: count_distinct
    sql: case when ${conversion_time_max} is not null then ${user_sso_guid} end ;;
    view_label: "** USER EVENT CONVERSION **"
  }

  measure: conversion_rate {
    type: number
    sql: ${conversion_user_count} / nullif(${user_count},0) ;;
    view_label: "** USER EVENT CONVERSION **"
    value_format_name: percent_2
  }

}
