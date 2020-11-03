include: "//cube/dim_date.view"

explore: cas_cafe_activity_sessions {
  join: duration_percentiles {
    sql_on:  ;;
  }

  aggregate_table: user_activity_duration {
    query: {
      dimensions: [cas_cafe_activity_sessions.merged_guid,cas_cafe_activity_sessions.activity_id,cas_cafe_activity_sessions.user_activity_duration]
      measures: [cas_cafe_activity_sessions.total_duration]
    }
    materialization: {
      sql_trigger_value: select current_date ;;
    }
  }

  aggregate_table: user_week_duration {
    query: {
      dimensions: [cas_cafe_activity_sessions.merged_guid,cas_cafe_activity_sessions.due_date_week]
      measures: [cas_cafe_activity_sessions.total_duration]
    }
    materialization: {
      sql_trigger_value: select current_date ;;
    }
  }

}

view: cas_cafe_activity_sessions {
  # sql_table_name: ZANDBOX.DELDERFIELD.SESSION_EVENT_DURATIONS;;

  derived_table: {
    sql:
      select
        *
        , sum(duration) over(partition by merged_guid, activity_id) as user_activity_duration
      from ZANDBOX.DELDERFIELD.SESSION_EVENT_DURATIONS
    ;;
    persist_for: "8 hours"
  }

  dimension: pk {
    sql: hash(EVENT_TIME,MERGED_GUID,EVENT_ACTION,EVENT_CATEGORY,ACTIVITY_ID) ;;
    primary_key: yes
    hidden: yes
  }

  dimension_group: event_time {
    label: "Event"
    type:time
    timeframes: [raw,date,week,month,year,time]
    hidden: no
  }

  dimension: event_action {}
  dimension: event_category {}
  dimension: merged_guid {}

  dimension: session_partition {hidden: yes}
  dimension: active_time_partition {hidden: yes}
  dimension: attempt_id {hidden: yes}

  dimension: activity_id {type: string}

  dimension: course_uri {hidden: yes}
  dimension: cla_page_number {hidden: yes}
  dimension: number_of_pages {hidden: yes}

  dimension: is_gradable {type: yesno}

  dimension_group: due_date {
    label: "Due"
    type:time
    timeframes: [raw,date,week,month,year]
  }

  dimension: course_key {}

  dimension: ref_id {hidden: yes}
  dimension: prev_event_time {hidden: yes}
  dimension: next_event_time {hidden: yes}
  dimension: next_event_time_user {hidden: yes}
  dimension: time_from_prev_event_seconds {hidden: yes}
  dimension: time_to_next_session_event_seconds {hidden: yes}
  dimension: time_to_next_user_event_seconds {hidden: yes}

  dimension: duration {
    type: number
    sql: case when
          upper(${event_action}) not in ('UNLOAD','ASSESSMENTCOMPLETEDMODALEXIT','CLACOMPLETEDMODALEXIT','CLACOMPLETED','ASSESSMENTCOMPLETED','SUBMITASSIGNMENT','CLACOMPLETEDMODALCLOSE')
        then least(7200,${time_to_next_session_event_seconds})
        else 0
        end ;;
    }

    dimension: user_activity_duration {

    }

  # dimension_group: from_course_start {
  #   type: duration
  #   sql_start: ${dim_start_date.datevalue_raw} ;;
  #   sql_end: ${event_time_raw} ;;
  #   intervals: [day,week,month]
  # }

  measure: total_duration  {
    type: sum
    sql: ${duration} / 60 / 60 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: number_users {
    type: count_distinct
    sql: ${merged_guid};;
    label: "# Users"
  }

  measure: average_duration  {
    type: sum
    sql: sum(${duration} / 60 / 60 / 24) / nullif(count(distinct ${merged_guid}),0)  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: duration_p10 {
    group_label: "Duration"
    type: percentile
    percentile: 10
    sql: ${duration} / 60 / 60 / 24 ;;
    value_format_name: duration_minutes
  }

  measure: duration_p25 {
    group_label: "Duration"
    type: percentile
    percentile: 25
    sql: ${duration}/ 60 / 60 / 24 ;;
    value_format_name: duration_minutes
  }

  measure: duration_p50 {
    group_label: "Duration"
    type: percentile
    percentile: 50
    sql: ${duration} / 60 / 60 / 24;;
    value_format_name: duration_minutes
  }

  measure: duration_p75 {
    group_label: "Duration"
    type: percentile
    percentile: 75
    sql: ${duration} / 60 / 60 / 24;;
    value_format_name: duration_minutes
  }

  measure: duration_p90 {
    group_label: "Duration"
    type: percentile
    percentile: 90
    sql: ${duration} / 60 / 60 / 24;;
    value_format_name: duration_minutes
  }

  measure: count {
    type: count
  }
  }

  view: duration_percentiles {
     extends: [cas_cafe_activity_sessions]

    # dimension: pk {
    #   primary_key: yes
    #   sql: hash(  ;;
    # }

    measure: number_users {
      type: count_distinct
      sql: ${cas_cafe_activity_sessions.merged_guid};;
      label: "# Users"
      view_label: "Aggregates"
    }

    measure: average_duration  {
      type: average
      sql: ${cas_cafe_activity_sessions.user_activity_duration}/ 60 / 60 / 24  ;;
      value_format: "[m]:ss \m\i\n\s"
      view_label: "Aggregates"
    }

    measure: duration_p10 {
      group_label: "Duration"
      type: number
      sql: PERCENTILE_CONT( 0.1 ) WITHIN GROUP (ORDER BY ${cas_cafe_activity_sessions.user_activity_duration})/ 60 / 60 / 24 ;;
      value_format_name: duration_minutes
      view_label: "Aggregates"
    }

    # measure: duration_p25 {
    #   group_label: "Duration"
    #   type: percentile
    #   percentile: 25
    #   sql: ${cas_cafe_activity_sessions.total_duration}/ 60 / 60 / 24 ;;
    #   value_format_name: duration_minutes
    #   view_label: "Aggregates"
    # }

    # measure: duration_p50 {
    #   group_label: "Duration"
    #   type: percentile
    #   percentile: 50
    #   sql: ${cas_cafe_activity_sessions.total_duration} / 60 / 60 / 24;;
    #   value_format_name: duration_minutes
    #   view_label: "Aggregates"
    # }

    # measure: duration_p75 {
    #   group_label: "Duration"
    #   type: percentile
    #   percentile: 75
    #   sql: ${cas_cafe_activity_sessions.total_duration} / 60 / 60 / 24;;
    #   value_format_name: duration_minutes
    #   view_label: "Aggregates"
    # }

    # measure: duration_p90 {
    #   group_label: "Duration"
    #   type: percentile
    #   percentile: 90
    #   sql: ${cas_cafe_activity_sessions.total_duration} / 60 / 60 / 24;;
    #   value_format_name: duration_minutes
    #   view_label: "Aggregates"
    # }
  }
