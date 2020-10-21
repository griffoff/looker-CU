explore: cas_cafe_activity_sessions {}

view: cas_cafe_activity_sessions {
  sql_table_name: ZANDBOX.DELDERFIELD.SESSION_EVENT_DURATIONS;;

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
          ${event_action} not in ('UNLOAD','ASSESSMENTCOMPLETEDMODALEXIT','CLACOMPLETEDMODALEXIT','CLACOMPLETED','ASSESSMENTCOMPLETED','SUBMITASSIGNMENT','CLACOMPLETEDMODALCLOSE')
        then least(7200,${time_to_next_user_event_seconds})
        else 0
        end ;;
    }

  measure: total_duration  {
    type: sum
    sql: ${duration} / 60 / 60 / 24  ;;
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
