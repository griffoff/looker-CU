view: all_sessions {
  view_label: "User Sessions"

  sql_table_name: ZPG.ALL_SESSIONS ;;

  dimension: course_keys {
    type: string
  }

  dimension: first_event {
    type: string
  }

  dimension: first_session {
    type: yesno
  }

  dimension: session_no {
    type: number
  }

  dimension: ips {
    type: string
  }

  dimension: last_event {
    type: string
  }

  dimension: logins {
    type: number
  }

  dimension: other_events {
    type: number
  }

  dimension_group: session_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
  }

  dimension: session_gap_hours {
    type: number
  }

  dimension: session_id {
    type: number
  }

  dimension: session_length_mins {
    type: number
  }

  dimension: session_length {
    type: number
    sql: ${session_length_mins} / 60 / 24 ;;
    value_format_name: duration_hms
  }

  dimension_group: session_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
  }

  dimension: unique_event_types {
    type: number
  }

  dimension: unique_events {
    type: string
  }

  dimension: user_sso_guid {
    type: string
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
