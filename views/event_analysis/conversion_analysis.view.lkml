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
    type: unquoted
    allowed_value: {
      label: "Minute(s)"
      value: "minute"
    }
    allowed_value: {
      label: "Hour(s)"
      value: "hour"
    }
    allowed_value: {
      label: "Day(s)"
      value: "day"
    }
    allowed_value: {
      label: "Week(s)"
      value: "week"
    }
    allowed_value: {
      label: "Month(s)"
      value: "month"
    }
    allowed_value: {
      label: "Year(s)"
      value: "year"
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
        , COUNT(*) OVER() as total_user_count
      from ${all_sessions.SQL_TABLE_NAME} s
      INNER JOIN ${all_events.SQL_TABLE_NAME} e USING(session_id)
      WHERE (DATEADD(day, 1, session_start::DATE) >= {% date_start initial_date_range_filter %} OR {% date_start initial_date_range_filter %} IS NULL)
      AND (DATEADD(day, -1, session_start::DATE) < {% date_end initial_date_range_filter %} OR {% date_end initial_date_range_filter %} IS NULL)
      AND {% condition initial_events_filter %} event_name {% endcondition %}
      group by user_sso_guid
      )
    --, conversion as (
      select
        i.user_sso_guid
        , initial_event
        , initial_time_max
        , initial_time_min
        , total_user_count
        , array_agg(event_name) as conversion_event
        , max(event_time) as conversion_time_max
        , min(event_time) as conversion_time_min

        , coalesce(
            greatest(1
              , datediff({{ time_period._parameter_value }},initial_time_min, conversion_time_min)
              )
            ,1) as period_number

        , concat(InitCap('{{ time_period._parameter_value }}'),' ',period_number) as conversion_period
      from initial i
      inner join ${all_events.SQL_TABLE_NAME} e

      on i.user_sso_guid = e.user_sso_guid
          and e.event_time > i.initial_time_min
          and e.event_time <= dateadd({{ time_period._parameter_value }},{{ number_period._parameter_value }}, initial_time_min)

          AND {% condition conversion_events_filter %} event_name {% endcondition %}
      group by 1,2,3,4,5
      union all
      select
        i.user_sso_guid
        , initial_event
        , initial_time_max
        , initial_time_min
        , total_user_count
        , NULL as conversion_event
        , NULL as conversion_time_max
        , NULL as conversion_time_min

        , 0 as period_number

        , 'Total Users' as conversion_period
      from initial i

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
    sql: MAX(${TABLE}.total_user_count);;
    view_label: "** USER EVENT CONVERSION **"
    description: "Total number of users who did one of the initial event(s)"
  }

  measure: conversion_user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
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
    sql: datediff(seconds,${initial_time_min},${conversion_time_min})/24/60/60;;
    view_label: "** USER EVENT CONVERSION **"
    value_format: "d \d\a\y\s h \h\r\s m \m\i\n\s s \s\e\c\s"
#     value_format: "[hh]:mm:ss"
    description: "Average time (in days) between first initital event and first conversion event"
  }

  measure: first_conversion_duration_max {
    type: max
    sql: datediff(seconds,${initial_time_min},${conversion_time_min})/24/60/60;;
    view_label: "** USER EVENT CONVERSION **"
    value_format: "d \d\a\y\s h \h\r\s m \m\i\n\s s \s\e\c\s"
#     value_format: "[hh]:mm:ss"
    description: "Max time (in days) between first initital event and first conversion event"
  }

  measure: first_conversion_duration_min {
    type: min
    sql: datediff(seconds,${initial_time_min},${conversion_time_min})/24/60/60;;
    view_label: "** USER EVENT CONVERSION **"
    value_format: "d \d\a\y\s h \h\r\s m \m\i\n\s s \s\e\c\s"
#     value_format: "[hh]:mm:ss"
    description: "Min time (in days) between first initital event and first conversion event"
  }

}
