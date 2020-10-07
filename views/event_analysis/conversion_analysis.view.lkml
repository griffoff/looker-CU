view: conversion_analysis {

  view_label: "** USER EVENT CONVERSION **"

  filter: initial_events_filter {
    label: "Choose 1st (initial) event"
    description: "Select the starting event(s) that you want to analyze conversion for"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: conversion_events_filter {
    label: "Choose 2nd (conversion) event"
    description: "Select the conversion event(s) that you want to analyze following the initial event"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: initial_date_range_filter {
    label: "Choose date range"
    description: "Select a date range within which the events will occur. Conversions/Retention outside of this date range will not be counted."
    type: date
    datatype: date
  }

  parameter: analysis_type {
    type: unquoted
    default_value: ""
    description: "First time conversion looks ONLY for the first time a user has performed the second action after the first.
    All conversions looks for EVERY time a user has performed the first AND THEN the second action.
    Retention looks for EVERY time a user has performed the second action after the first."
    allowed_value: {
      label: "First time conversions"
      value: ""
    }
    allowed_value: {
      label: "All conversions"
      value: "all_conversons"
    }
    allowed_value: {
      label: "Retention"
      value: "retention"
    }
  }

  parameter: time_period {
    label: "Conversion period"
    description: "Time frames for bucketing results"
    type: number
    allowed_value: {
      label: "Minute(s)"
      value: "0.01"
    }
    allowed_value: {
      label: "Hour(s)"
      value: "0.1"
    }
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
    label: "Number of periods to show"
    description: "Leave blank for all periods up to current date."
    type: number
  }

  parameter: show_total {
    label: "Show a 'Total' period"
    type: unquoted
    default_value: "hide"
    allowed_value: {
      label: "Show total period"
      value: "show"
    }
    allowed_value: {
      label: "Only show conversion periods"
      value: "hide"
    }
  }


  derived_table: {
    sql:
    WITH all_relevant_events_base AS (
      SELECT distinct
          user_sso_guid
          , event_time
          , event_name
          , CASE WHEN {% condition initial_events_filter %} event_name {% endcondition %}
              THEN 'initial'
              ELSE 'conversion'
              END AS event_type
        FROM ${all_sessions.SQL_TABLE_NAME} s
        INNER JOIN ${all_events.SQL_TABLE_NAME} e USING(session_id)
        WHERE (DATEADD(day, 1, session_start::DATE) >= {% date_start initial_date_range_filter %} OR {% date_start initial_date_range_filter %} IS NULL)
        AND (DATEADD(day, -1, session_start::DATE) < {% date_end initial_date_range_filter %} OR {% date_end initial_date_range_filter %} IS NULL)
        AND (
          {% condition initial_events_filter %} event_name {% endcondition %}
          OR
          {% condition conversion_events_filter %} event_name {% endcondition %}
        )
    )
    ,all_relevant_events AS (
      SELECT
        *
        , COALESCE(LAG(event_type) OVER (PARTITION BY user_sso_guid ORDER BY event_time), '') = event_type AS same_type_as_previous
      FROM all_relevant_events_base
    )
    ,simplify_events AS (
      SELECT
        *
        ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY event_time)   AS sequence_number
        {% if analysis_type._parameter_value == 'retention' %}
        ,MIN(event_time) OVER(PARTITION BY user_sso_guid ORDER BY event_time)
        {% else %}
        ,LAG(event_time) OVER(PARTITION BY user_sso_guid ORDER BY event_time)
        {% endif %}
        AS reference_event_time
      FROM all_relevant_events
      {% if analysis_type._parameter_value == 'retention' %}
      -- if retention keep the first "initial event" and all subsequent conversion events
      WHERE (NOT same_type_as_previous OR event_type = 'conversion')
      {% else  %}
      -- if conversion analysis remove repeated events of the same type
      WHERE NOT same_type_as_previous
      {% endif %}
    )
    ,adjust_first_event AS (
      --if the first event is a conversion event we want to ignore it
      SELECT user_sso_guid, CASE WHEN event_type = 'conversion' THEN -1 ELSE 0 END as modifier
      FROM simplify_events
      WHERE sequence_number = 1
    )
    ,final_events AS (
      SELECT *
      FROM simplify_events
      INNER JOIN adjust_first_event USING(user_sso_guid)
      WHERE sequence_number + modifier > 0
      {% if analysis_type._parameter_value == '' %}
      AND sequence_number + modifier <= 2
      {% endif %}
    )
    {% if show_total._parameter_value == 'show' %}
    SELECT DISTINCT
      user_sso_guid
      ,(SELECT COUNT(DISTINCT user_sso_guid) FROM final_events) AS total_user_count
      ,-1 as period_number
      ,'Total Users' as period_label
      ,NULL as initial_time_min
      ,NULL as initial_time_max
      ,NULL as conversion_time_min
      ,NULL as conversion_time_max
      ,NULL AS conversion_event
      ,NULL AS conversion_event_count
    FROM simplify_events
    UNION ALL
    {% endif %}
    SELECT
      user_sso_guid
      ,(SELECT COUNT(DISTINCT user_sso_guid) FROM final_events) AS total_user_count
      ,COALESCE(GREATEST(1, DATEDIFF(
          {% if time_period._parameter_value == '0.01' %}
            minute
          {% elsif time_period._parameter_value == '0.1' %}
            hour
          {% elsif time_period._parameter_value == '1' %}
            day
          {% elsif time_period._parameter_value == '7' %}
            week
          {% elsif time_period._parameter_value == '30' %}
            month
          {% elsif time_period._parameter_value == '365' %}
            year
          {% endif %}
          ,reference_event_time
          ,event_time
        )), 1) as period_number
      , CONCAT(DECODE({{ time_period._parameter_value }}, 0.01, 'Minute', 0.1, 'Hour', 1, 'Day', 7, 'Week', 30, 'Month', 365, 'Year')
                  ,' ',period_number) AS period_label
      , MIN(reference_event_time) AS initial_time_min
      , MAX(reference_event_time) AS initial_time_max
      , MIN(event_time) as conversion_time_min
      , MAX(event_time) as conversion_time_max
      , CASE WHEN COUNT(DISTINCT event_name) > 10
          THEN ARRAY_CONSTRUCT('Too many events to list...')
          ELSE ARRAY_AGG(DISTINCT event_name)
        END AS conversion_event
      , COUNT(*) AS conversion_event_count
    FROM final_events
    WHERE event_type = 'conversion'
    {% if number_period._parameter_value != '' %}
    AND period_number <= {{ number_period._parameter_value }}
    {% endif %}
    GROUP BY 1, 2, 3, 4

      ;;
  }

  dimension: user_sso_guid {
    view_label: "** USER EVENT CONVERSION **"
    hidden: no
    description: "User sso guid in potential conversion population"
    }

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
    sql: ${TABLE}.period_label ;;
    }


  dimension: user_converted {
    view_label: "** USER EVENT CONVERSION **"
    sql: ${conversion_time_max} IS NOT NULL ;;
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
    label: "# Converted Users"
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
