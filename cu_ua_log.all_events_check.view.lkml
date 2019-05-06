

view: all_events_check {
  sql_table_name: dev.CU_UA_04.ALL_EVENTS_CHECK ;;

  dimension: event_name {
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
  }

  dimension_group: event_week {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EVENT_WEEK" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension_group: run {
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
    convert_tz: no
    datatype: datetime
    sql: ${TABLE}."RUN_TIME_STAMP" ;;
  }

  dimension_group: runtime {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year]
    sql: ${TABLE}."RUN_TIME" ;;
    group_label: "Event Time"
    label: "Event"
    description: "Components of the events local timestamp"
  }

  dimension: run_id {
    type: number
    sql: ${TABLE}."RUN_ID" ;;
  }

  dimension: unique_events {
    type: number
    sql: ${TABLE}."UNIQUE_EVENTS" ;;
  }

  dimension: unique_users {
    type: number
    sql: ${TABLE}."UNIQUE_USERS" ;;
  }

  measure: count {
    type: count
    drill_fields: [event_name]
  }

  measure: unique_users_total {
    type: sum
    sql:  unique_users ;;
  }

  measure: unique_events_total {
    type: sum
    sql:  unique_events ;;
  }

  measure: most_recent_run_time {
    type: date_time
    sql: MAX(${TABLE}."RUN_TIME_STAMP") ;;
  }

  measure: number_of_runs_since_run_from_start {
    type: number
    sql: MAX(${TABLE}."RUN_ID") - 1 ;;
    label: "Number of incremental runs"
  }
}
