view: conversion_analysis {

  view_label: "** USER EVENT CONVERSION **"

  filter: initial_events_filter {
    label: "Choose 1st (initial) event"
    description: "Select the starting event(s) that represent the beginning of the workflow  or the retention baseline"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: conversion_events_filter {
    label: "Choose 2nd (conversion) event"
    description: "Select the conversion event(s) that represent the conversion or retention behavior"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: initial_date_range_filter {
    label: "Choose date range to use as the boundary for all events included in the analysis"
    description: "Select a date range within which the events will occur. Conversions/Retention outside of this date range will not be counted."
    type: date
    datatype: date
  }

  parameter: analysis_type {
    label: "Choose the type of analysis"
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
    create_process: {
      # sql_step: use warehouse heavyduty ;;
      sql_step: use schema looker_scratch ;;
      sql_step:
        create or replace temporary table initial_events AS (
        SELECT DISTINCT
            user_sso_guid
            ,DATE_TRUNC(
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
            ,event_time) AS event_time
            ,'initial' as event_type
        FROM ${all_events.SQL_TABLE_NAME} e
        --WHERE (TO_TIMESTAMP(session_id::INT) >= {% date_start initial_date_range_filter %} OR {% date_start initial_date_range_filter %} IS NULL)
        --AND (TO_TIMESTAMP(session_id::INT) <= {% date_end initial_date_range_filter %} OR {% date_end initial_date_range_filter %} IS NULL)
        WHERE (session_id >= DATE_PART(epoch, {% date_start initial_date_range_filter %}::TIMESTAMP) OR {% date_start initial_date_range_filter %} IS NULL)
        AND (session_id <= DATE_PART(epoch, {% date_end initial_date_range_filter %}::TIMESTAMP) OR {% date_end initial_date_range_filter %} IS NULL)
        AND {% condition initial_events_filter %} event_name {% endcondition %}
        )
        ;;

      sql_step:
        create or replace temporary table conversion_events AS (
        SELECT DISTINCT
          user_sso_guid
          ,DATE_TRUNC(
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
            ,event_time) AS event_time
          ,'conversion' as event_type
        FROM ${all_events.SQL_TABLE_NAME} e
        --WHERE (TO_TIMESTAMP(session_id::INT) >= {% date_start initial_date_range_filter %} OR {% date_start initial_date_range_filter %} IS NULL)
        --AND (TO_TIMESTAMP(session_id::INT) <= {% date_end initial_date_range_filter %} OR {% date_end initial_date_range_filter %} IS NULL)
        WHERE (session_id >= DATE_PART(epoch, {% date_start initial_date_range_filter %}::TIMESTAMP) OR {% date_start initial_date_range_filter %} IS NULL)
        AND (session_id <= DATE_PART(epoch, {% date_end initial_date_range_filter %}::TIMESTAMP) OR {% date_end initial_date_range_filter %} IS NULL)
        AND {% condition conversion_events_filter %} event_name {% endcondition %}
        AND user_sso_guid IN (SELECT DISTINCT user_sso_guid FROM initial_events)
        )
        ;;

      sql_step:
        create or replace temporary table all_relevant_events AS (
        SELECT
          user_sso_guid
          , event_time
          , event_type
          , COALESCE(LAG(event_type) OVER (PARTITION BY user_sso_guid ORDER BY event_time, event_type desc), '') = event_type AS same_type_as_previous
        FROM (
          SELECT *
          FROM initial_events
          UNION ALL
          SELECT *
          FROM conversion_events
          ORDER BY user_sso_guid, event_time, event_type desc
          )

        )
        ;;
      sql_step:
        create or replace temporary table simplify_events AS (
        SELECT
          *
          {% if analysis_type._parameter_value == 'retention' %}
          ,MIN(event_time) OVER(PARTITION BY user_sso_guid)
          {% else %}
          ,LAG(event_time) OVER(PARTITION BY user_sso_guid ORDER BY event_time, event_type desc)
          {% endif %}
          AS reference_event_time
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
          ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY event_time, event_type desc)   AS sequence_number
        FROM all_relevant_events
        {% if analysis_type._parameter_value == 'retention' %}
        -- if retention keep the first "initial event" and all subsequent conversion events
        WHERE (NOT same_type_as_previous OR event_type = 'conversion')
        {% else  %}
        -- if conversion analysis remove repeated events of the same type
        WHERE NOT same_type_as_previous
        {% endif %}

        )
        ;;
      sql_step:
      create or replace temporary table user_info AS (
        --if the first event is a conversion event we want to ignore it
        SELECT
            user_sso_guid
            ,MIN(CASE WHEN event_type = 'conversion' AND sequence_number = 1 THEN -1 ELSE 0 END) as modifier
            ,COUNT(DISTINCT CASE WHEN event_type = 'conversion' THEN period_number END) as period_count
        FROM simplify_events
        GROUP BY user_sso_guid
        )
        ;;
      sql_step:
        /* if the first event is a conversion event, exclude it */
        create or replace temporary table final_events AS (
        SELECT *
        FROM simplify_events
        INNER JOIN user_info USING(user_sso_guid)
        WHERE sequence_number + modifier > 0
        {% if analysis_type._parameter_value == '' %}
        AND sequence_number + modifier <= 2
        {% endif %}
        )
        ;;
      sql_step:
        create or replace transient table ${SQL_TABLE_NAME} AS
        {% if show_total._parameter_value == 'show' %}
        SELECT DISTINCT
          user_sso_guid
          ,NULL AS conversion_periods_count
          ,(SELECT COUNT(DISTINCT user_sso_guid) FROM final_events) AS total_user_count
          ,(SELECT COUNT(DISTINCT user_sso_guid) FROM final_events WHERE event_type = 'conversion' ) AS total_converted_user_count
          ,-1 as period_number
          ,'Total Users' as period_label
          ,NULL AS initial_time_min
          ,NULL AS initial_time_max
          ,NULL AS conversion_time_min
          ,NULL AS conversion_time_max
          ,NULL AS conversion_event_count
        FROM user_info
        UNION ALL
        {% endif %}
        SELECT
          user_sso_guid
          ,period_count AS conversion_periods_count
          ,(SELECT COUNT(DISTINCT user_sso_guid) FROM final_events) AS total_user_count
          ,(SELECT COUNT(DISTINCT user_sso_guid) FROM final_events WHERE event_type = 'conversion' ) AS total_converted_user_count
          , period_number
          , CONCAT(DECODE({{ time_period._parameter_value }}, 0.01, 'Minute', 0.1, 'Hour', 1, 'Day', 7, 'Week', 30, 'Month', 365, 'Year')
                      ,' ',period_number) AS period_label
          , MIN(reference_event_time) AS initial_time_min
          , MAX(reference_event_time) AS initial_time_max
          , MIN(event_time) AS conversion_time_min
          , MAX(event_time) AS conversion_time_max
          , COUNT(*) AS conversion_event_count
        FROM final_events
        WHERE event_type = 'conversion'
        AND (
          period_number <= {{ number_period._parameter_value }}
          OR {{ number_period._parameter_value }} IS NULL
          )
        GROUP BY user_sso_guid, period_count, period_number, period_label
        ;;
      # sql_step: alter warehouse heavyduty suspend ;;
      # sql_step: use warehouse looker ;;
    }

    persist_for: "1 second"
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

  dimension: conversion_periods_count {
    label: "# Periods of activity"
    description: "Number of periods in which a user had one or more conversion events"
    type: tier
    tiers: [1, 2, 5, 10]
    style: relational
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
    description: "Total number of users who did at least one of the initial event(s)"
  }

  measure: total_converted_user_count {
    type: number
    sql: MAX(${TABLE}.total_converted_user_count);;
    view_label: "** USER EVENT CONVERSION **"
    description: "Total number of users who did at least one of the initial events and at least one of the conversion event(s)"
  }

  measure: conversion_user_count {
    label: "# Converted Users"
    #required_fields: [conversion_period]
    type: count_distinct
    sql: ${user_sso_guid} ;;
    view_label: "** USER EVENT CONVERSION **"
    description: "Number of users who converted (did one of the initial event(s) followed by one of the conversion event(s))"
  }

  dimension: conversion_event_duration {
    label: "Total minutes spent on conversion events"
    type: tier
    style: relational
    tiers: [5, 10, 15, 50, 60, 120]
    sql: ${TABLE}.conversion_event_duration / 60 ;;
    value_format: "0 \m\i\n\s"
    view_label: "** USER EVENT CONVERSION **"
  }

  measure: conversion_rate {
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${period_number} >= 0 THEN ${user_sso_guid} END) / nullif(${total_user_count},0);;
    view_label: "** USER EVENT CONVERSION **"
    value_format_name: percent_2
    description: "Ratio of number of users who converted over number that did one of the initial event(s).  NOTE: this does not work if you add other dimensions to the result"
  }

  measure: first_conversion_duration_average {
    type: number
    sql: AVG(datediff(seconds,${initial_time_min},${conversion_time_min}))/24/60/60;;
    view_label: "** USER EVENT CONVERSION **"
    value_format: "d \d\a\y\s h \h\r\s m \m\i\n\s s \s\e\c\s"
#     value_format: "[hh]:mm:ss"
    description: "Average time (in days) between first initital event and first conversion event"
  }

  measure: first_conversion_duration_max {
    type: number
    sql: MAX(datediff(seconds,${initial_time_min},${conversion_time_min}))/24/60/60;;
    view_label: "** USER EVENT CONVERSION **"
    value_format: "d \d\a\y\s h \h\r\s m \m\i\n\s s \s\e\c\s"
#     value_format: "[hh]:mm:ss"
    description: "Max time (in days) between first initital event and first conversion event"
  }

  measure: first_conversion_duration_min {
    type: number
    sql: MIN(datediff(seconds,${initial_time_min},${conversion_time_min}))/24/60/60;;
    view_label: "** USER EVENT CONVERSION **"
    value_format: "d \d\a\y\s h \h\r\s m \m\i\n\s s \s\e\c\s"
#     value_format: "[hh]:mm:ss"
    description: "Min time (in days) between first initital event and first conversion event"
  }

}
