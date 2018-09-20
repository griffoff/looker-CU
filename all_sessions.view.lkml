view: all_sessions {
  sql_table_name: ZPG.ALL_SESSIONS ;;

  dimension: course_keys {
    type: string
    sql: ${TABLE}."COURSE_KEYS" ;;
  }

  dimension: first_event {
    type: string
    sql: ${TABLE}."FIRST_EVENT" ;;
  }

  dimension: ips {
    type: string
    sql: ${TABLE}."IPS" ;;
  }

  dimension: last_event {
    type: string
    sql: ${TABLE}."LAST_EVENT" ;;
  }

  dimension: logins {
    type: number
    sql: ${TABLE}."LOGINS" ;;
  }

  dimension: other_events {
    type: number
    sql: ${TABLE}."OTHER_EVENTS" ;;
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
    sql: ${TABLE}."SESSION_END" ;;
  }

  dimension: session_gap_hours {
    type: number
    sql: ${TABLE}."SESSION_GAP_HOURS" ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: session_length_mins {
    type: number
    sql: ${TABLE}."SESSION_LENGTH_MINS" ;;
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
    sql: ${TABLE}."SESSION_START" ;;
  }

  dimension: unique_event_types {
    type: number
    sql: ${TABLE}."UNIQUE_EVENT_TYPES" ;;
  }

  dimension: unique_events {
    type: string
    sql: ${TABLE}."UNIQUE_EVENTS" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
