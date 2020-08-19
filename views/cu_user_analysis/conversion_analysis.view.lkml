explore: conversion_analysis {}
view: conversion_analysis {

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
    label: "Choose initial event date range"
    description: "Select a date range for the initial event to occur within"
    type: date
    datatype: date
  }

  parameter: time_period {
    view_label: "** USER EVENT CONVERSION **"
    label: "Conversion period"
     description: "Analyze conversion occuring in this time period. Leave blank for all conversions up to current date."
    type: number
    allowed_value: {
      label: "Day(s)"
      value: "1"
    }
    allowed_value: {
      label: "Week(s)"
      value: "7"
    }
    allowed_value: {
      label: "Month(s)"
      value: "30"
    }
    allowed_value: {
      label: "Year(s)"
      value: "365"
    }
  }

  parameter: number_period {
    view_label: "** USER EVENT CONVERSION **"
    label: "Number of periods after initial event to look for conversions"
     description: "Leave blank for all periods up to current date."
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

        , coalesce(greatest(1, ceil(datediff(d,initial_time_max, conversion_time_min)/{{ time_period._parameter_value }})),1) as period_number

        , case
            when {{ time_period._parameter_value }} = 365 then 'Year'
            when {{ time_period._parameter_value }} = 30 then 'Month'
            when {{ time_period._parameter_value }} = 7 then 'Week'
            when {{ time_period._parameter_value }} = 1 then 'Day'
          end as time_period_label

        , concat(time_period_label,' ',period_number) as conversion_period

      from initial i
      left join ${all_events.SQL_TABLE_NAME} e

      on i.user_sso_guid = e.user_sso_guid
        and e.event_time between i.initial_time_max

        and coalesce(dateadd(d, {{ time_period._parameter_value }} * {{ number_period._parameter_value }}, i.initial_time_max), current_date())

        AND {% condition conversion_events_filter %} event_name {% endcondition %}
      group by 1,2,3,4

      ;;
  }

  dimension: user_sso_guid {view_label: "** USER EVENT CONVERSION **" hidden:yes}
  dimension: initial_event {view_label: "** USER EVENT CONVERSION **" hidden:yes}
  dimension: initial_time_max {view_label: "** USER EVENT CONVERSION **" type:date hidden:yes}
  dimension: initial_time_min {view_label: "** USER EVENT CONVERSION **" type:date hidden:yes}
  dimension: conversion_event {view_label: "** USER EVENT CONVERSION **" hidden:yes}
  dimension: conversion_time_max {view_label: "** USER EVENT CONVERSION **" type:date hidden:yes}
  dimension: conversion_time_min {view_label: "** USER EVENT CONVERSION **" type:date hidden:yes}

  dimension: period_number {view_label: "** USER EVENT CONVERSION **" type: number hidden:yes}

  dimension: conversion_period {
    label: "Conversion Period (output)"
    view_label: "** USER EVENT CONVERSION **"
    order_by_field: period_number
    description: "Conversion occurred during this period after the initial event"
    }


  dimension: user_converted {
    view_label: "** USER EVENT CONVERSION **"
    sql: case when ${conversion_time_max} is not null then true else false end ;;
    type: yesno
    description: "User converted according the specified filter parameters"
    }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
    view_label: "** USER EVENT CONVERSION **"
    hidden:yes
  }

  measure: total_user_count {
    type: number
    sql: sum(${user_count}) over();;
    view_label: "** USER EVENT CONVERSION **"
    description: "Total number of users who did one of the initial event(s)"
  }

  measure: conversion_user_count {
    type: count_distinct
    sql: case when ${conversion_time_max} is not null then ${user_sso_guid} end ;;
    view_label: "** USER EVENT CONVERSION **"
    description: "Number of users who converted (did one of the initial event(s) followed by one of the conversion event(s))"
  }


  measure: conversion_rate {
    type: number
    sql: ${conversion_user_count} / nullif(${total_user_count},0) ;;
    view_label: "** USER EVENT CONVERSION **"
    value_format_name: percent_2
    description: "Ratio of number of users who converted over number that did one of the initial event(s)"
  }


  measure: first_conversion_duration_average {
    type: average
    sql: datediff(h,${initial_time_min},${conversion_time_min});;
    view_label: "** USER EVENT CONVERSION **"
#     value_format: "[hh]:mm:ss"
    description: "Average time between first initital event and first conversion event"
  }

  measure: first_conversion_duration_max {
    type: max
    sql: datediff(h,${initial_time_min},${conversion_time_min});;
    view_label: "** USER EVENT CONVERSION **"
#     value_format: "[hh]:mm:ss"
    description: "Max time between first initital event and first conversion event"
  }

  measure: first_conversion_duration_min {
    type: min
    sql: datediff(h,${initial_time_min},${conversion_time_min});;
    view_label: "** USER EVENT CONVERSION **"
#     value_format: "[hh]:mm:ss"
    description: "Min time between first initital event and first conversion event"
  }

}
