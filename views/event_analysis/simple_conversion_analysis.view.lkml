include: "./conversion_analysis.view"

explore: simple_conversion_analysis {hidden: yes
  always_filter:{
    filters:[
      initial_date_range_filter: "30 days"
      ,simple_conversion_analysis.initial_events_filter:"Homepage Submit Search"
      ,simple_conversion_analysis.conversion_events_filter:"Search Item Nav To Title"
      ,simple_conversion_analysis.time_period: "30"
      ]}
}

view: simple_conversion_analysis {
  extends: [conversion_filters_base]

  parameter: time_period {

    label: "Include events (n) minutes before/after the initial behavior"
    description: "How long after the initial behavior (within the same session) do you want to look for subsequent actions"
    type: number
  }

  derived_table: {
    sql:
    WITH events
      AS (
          SELECT {% condition initial_events_filter %} event_name {% endcondition %}       AS is_first_event
               ,{% condition conversion_events_filter %} event_name {% endcondition %}     AS is_target_event
               , LAG(is_first_event) OVER (PARTITION BY user_sso_guid ORDER BY event_time) AS prev_is_first_event
               , LAG(e.event_time) OVER (PARTITION BY user_sso_guid ORDER BY e.event_time) AS prev_event_time
               , *
          FROM ${all_events.SQL_TABLE_NAME} e
          WHERE (session_id >= DATE_PART(epoch, {% date_start initial_date_range_filter %}::TIMESTAMP) OR {% date_start initial_date_range_filter %} IS NULL)
        AND (session_id <= DATE_PART(epoch, {% date_end initial_date_range_filter %}::TIMESTAMP) OR {% date_end initial_date_range_filter %} IS NULL)
        AND (
          {% condition initial_events_filter %} event_name {% endcondition %}
          OR
          {% condition conversion_events_filter %} event_name {% endcondition %}
          )
      )
     , sessions AS (
      SELECT user_sso_guid
           , event_id
           , event_name
           , event_time
           , is_first_event
           , is_target_event
           , LEAD(events.event_time)
                  OVER (PARTITION BY events.user_sso_guid ORDER BY events.event_time) AS target_event_time
      FROM events
      WHERE prev_is_first_event IS NULL
         OR prev_is_first_event = is_target_event
      )
      SELECT s.user_sso_guid
           , ROW_NUMBER() OVER (PARTITION BY s.user_sso_guid ORDER BY s.event_time) AS user_session_no
           , s.event_time                                                           AS start_event
           , s.target_event_time                                                    AS target_event
           , MAX(e.event_time)                                                      AS last_event
           , ARRAY_AGG(OBJECT_CONSTRUCT(
                               'event', e.event_name
                           , 'time', e.event_time
                           , 'interval_ms', DATEDIFF(MILLISECONDS, e.prev_event_time, e.event_time)
                           )) WITHIN GROUP (ORDER BY e.event_time)                  AS event_times
           , SUM(e.is_first_event::INT)                                             AS cycles
           , SUM(e.is_target_event::INT)                                            AS target_hit
      FROM sessions s
           LEFT JOIN events e ON s.user_sso_guid = e.user_sso_guid
          AND e.event_time >= s.event_time
          AND (e.event_time <= s.target_event_time OR s.target_event_time IS NULL)
          AND DATEDIFF(minute, s.event_time, e.event_time) <= {{ time_period._parameter_value }}
      WHERE s.is_first_event
      AND (
        target_event IS NULL
        OR DATEDIFF(minute, start_event, target_event) <= {{ time_period._parameter_value }}
        )
      GROUP BY s.user_sso_guid, s.event_time, s.target_event_time
    ;;
  }

  dimension: user_sso_guid {}
  dimension: user_session_no {type:number}
  dimension: cycles {label:"Attempts" type:number}
  dimension: target_hit {type: yesno}
  dimension_group: start_event {type:time}
  dimension_group: target_event {type:time}
  dimension_group: last_event {type:time}
  dimension_group: to_convert {
    type:duration
    sql_start: ${start_event_raw};;
    sql_end: ${target_event_raw} ;;
    }
  dimension_group: attempting {
    type:duration
    sql_start: ${start_event_raw};;
    sql_end: ${last_event_raw} ;;
  }
  measure: conversion_time_average_mins {
    type: average
    sql: ${minutes_to_convert} ;;
    value_format_name: decimal_2
  }
  measure: attempt_time_average_mins {
    type: average
    sql: ${minutes_attempting} ;;
    value_format_name: decimal_2
  }
  measure: conversion_time_average_seconds {
    type: average
    sql: ${seconds_to_convert} ;;
    value_format_name: decimal_1
  }
  measure: count {
    type: count
  }
  measure: success_count {
    type: sum
    sql:  ${target_hit};;
  }
  measure: success_rate {
    type: number
    sql: ${success_count} / ${count} ;;
    value_format_name: percent_1
  }

}
