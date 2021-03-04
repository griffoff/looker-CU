view: learner_profile_check {
  sql_table_name: cu_user_analysis_dev.learner_profile_check ;;

  dimension: age_in_days {
    type: number
    sql: ${TABLE}."AGE_IN_DAYS" ;;
  }

  dimension: age_in_weeks {
    type: number
    sql: ${TABLE}."AGE_IN_WEEKS" ;;
  }

  dimension: average_days_since_last_loging {
    type: number
    sql: ${TABLE}."AVERAGE_DAYS_SINCE_LAST_LOGING" ;;
  }

  dimension: average_total_ebooks_value {
    type: number
    sql: ${TABLE}."AVERAGE_TOTAL_EBOOKS_VALUE" ;;
  }

  dimension: everage_events_per_session {
    type: number
    sql: ${TABLE}."EVERAGE_EVENTS_PER_SESSION" ;;
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
    sql: ${TABLE}."RUN_TIME" ;;
  }

  dimension: subscription_status {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATUS" ;;
  }

  dimension: total_returning_customers {
    type: number
    sql: ${TABLE}."TOTAL_RETURNING_CUSTOMERS" ;;
  }

  dimension: unique_users {
    type: number
    sql: ${TABLE}."UNIQUE_USERS" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: unique_users_total {
    type: sum
    sql:  unique_users ;;
  }

  measure: unique_events_total {
    type: sum
    sql:  unique_events ;;
  }

}
