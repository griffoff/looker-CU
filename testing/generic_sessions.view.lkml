named_value_format: duration_minutes {
  value_format: "[m]:ss \m\i\n\s"
}

explore: sessions  {
  join: session_events {
    sql_on: ${sessions.session_id} = ${session_events.session_id};;
    relationship: one_to_many
    type: inner
  }
}

view: sessions {
  sql_table_name: zandbox.pgriffiths.sessions ;;

  dimension_group: session_start_time  {
    type: time
    timeframes: [date, week, month]
    sql:  CONVERT_TIMEZONE('EST', ${TABLE}.session_start_time) ;;
  }

  dimension: session_id {
    type: number
    primary_key: yes
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}.merged_guid ;;
  }

  dimension: session_no {
    type: number
    value_format_name: decimal_0
  }

  dimension: session_duration {
    type: number
    hidden: yes
    sql: ${TABLE}.session_duration_seconds / 60 / 60 / 24 ;;
  }

  dimension: session_active_time {
    type: number
    hidden: yes
    sql: ${TABLE}.session_active_time_seconds / 60 / 60 / 24 ;;
  }

  dimension: percent_active_time {
    type: number
    hidden: yes
    sql: ${session_active_time} / ${session_duration};;
  }

  measure: session_duration_avg {
    group_label: "Session Duration"
    type: average
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_duration_min {
    group_label: "Session Duration"
    type: min
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_duration_p10 {
    group_label: "Session Duration"
    type: percentile
    percentile: 10
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_duration_p25 {
    group_label: "Session Duration"
    type: percentile
    percentile: 25
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_duration_p50 {
    group_label: "Session Duration"
    type: percentile
    percentile: 50
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_duration_p75 {
    group_label: "Session Duration"
    type: percentile
    percentile: 75
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_duration_p90 {
    group_label: "Session Duration"
    type: percentile
    percentile: 90
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_duration_max {
    group_label: "Session Duration"
    type: max
    sql: ${session_duration} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_avg {
    group_label: "Session Active time"
    type: average
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_min {
    group_label: "Session Active time"
    type: min
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_p10 {
    group_label: "Session Active time"
    type: percentile
    percentile: 10
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_p25 {
    group_label: "Session Active time"
    type: percentile
    percentile: 25
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_p50 {
    group_label: "Session Active time"
    type: percentile
    percentile: 50
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_p75 {
    group_label: "Session Active time"
    type: percentile
    percentile: 75
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_p90 {
    group_label: "Session Active time"
    type: percentile
    percentile: 90
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: session_active_time_max {
    group_label: "Session Active time"
    type: max
    sql: ${session_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_avg {
    group_label: "% Active Time"
    type: average
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_min {
    group_label: "% Active Time"
    type: min
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_p10 {
    group_label: "% Active Time"
    type: percentile
    percentile: 10
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_p25 {
    group_label: "% Active Time"
    type: percentile
    percentile: 25
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_p50 {
    group_label: "% Active Time"
    type: percentile
    percentile: 50
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_p75 {
    group_label: "% Active Time"
    type: percentile
    percentile: 75
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_p90 {
    group_label: "% Active Time"
    type: percentile
    percentile: 90
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: percent_active_time_max {
    group_label: "% Active Time"
    type: max
    sql: ${percent_active_time} ;;
    value_format_name: duration_minutes
  }

  measure: count {
    type: count
    label: "# Sessions"
  }

}

view: session_events {
  sql_table_name: zandbox.pgriffiths.session_events ;;

  label: "Events"

  dimension: event_id {
    type: number
    hidden: yes
    primary_key: yes
  }

  dimension: session_id {
    type: number
    hidden:yes
  }

  dimension_group: event_time {
    type: time
    timeframes: [microsecond, second, minute, hour]
    sql:  CONVERT_TIMEZONE('EST', ${TABLE}.event_time) ;;
  }

  dimension: event_action {
    group_label: "Event Name"
    type: string
  }

  dimension: event_category {
    group_label: "Event Name"
    type: string
  }

  dimension: event_name {
    group_label: "Event Name"
    type: string
  }

  dimension: next_event_1 {
    group_label: "Event Name"
    type: string
  }

  dimension: next_event_2 {
    group_label: "Event Name"
    type: string
  }

  dimension: next_event_3 {
    group_label: "Event Name"
    type: string
  }

  dimension: next_event_4 {
    group_label: "Event Name"
    type: string
  }

  dimension: activity_id {
    type: string
  }
  dimension: course_uri {
    type: string
  }
  dimension: duration {
    type: number
    sql: ${TABLE}.duration / 60 / 60 / 24 ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_avg {
    group_label: "Event Duration"
    type: average
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_min {
    group_label: "Event Duration"
    type: min
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_p10 {
    group_label: "Event Duration"
    type: percentile
    percentile: 10
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_p25 {
    group_label: "Event Duration"
    type: percentile
    percentile: 25
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_p50 {
    group_label: "Event Duration"
    type: percentile
    percentile: 50
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_p75 {
    group_label: "Event Duration"
    type: percentile
    percentile: 75
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_p90 {
    group_label: "Event Duration"
    type: percentile
    percentile: 90
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_duration_max {
    group_label: "Event Duration"
    type: max
    sql: ${duration} ;;
    value_format_name: duration_minutes
  }

  measure: event_count {
    type: count
    label: "# Events"
    value_format_name: decimal_0
    drill_fields: [course_uri, activity_id, event_time_microsecond, event_category, event_action, duration]
  }



}
