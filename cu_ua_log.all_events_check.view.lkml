

view: all_events_check {
  derived_table: {
    sql:
    SELECT
      *
      ,LAG(run_time_stamp) OVER (PARTITION BY run_id ORDER BY run_time_stamp) AS last_run_time
    FROM prod.cu_user_analysis_dev.all_events_check ;; }


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

  dimension: last_run_time {
    type: date_time
    sql: ${TABLE}."LAST_RUN_TIME" ;;

  }

  dimension_group: time_since_last_run {
    type: duration
    intervals: [day, hour]
    sql_start: ${runtime_time} ;;
    sql_end: ${last_run_time};;
  }

  dimension: events_added_per_hour {
    type: number
    sql: IFF(${unique_events} / ${days_time_since_last_run} ;;
  }

#   measure: time_since_last_run {
#     type: number
#     sql: ${time_since_last_run} ;;
#   }

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

#   measure: most_recent_run_time {
#     type: date_time
#     sql: ${TABLE}."RUN_TIME_STAMP" ;;
#   }



  measure: number_of_runs_since_run_from_start {
    type: number
    sql: MAX(${TABLE}."RUN_ID") - 1 ;;
    label: "Number of incremental runs"
  }

  dimension: most_recent_events {
    type: number
    sql: SUM(unique_events) OVER (PARTITION BY run_id ORDER BY run_time_stamp) ;;
    }
}
