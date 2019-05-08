view: all_sessions_check {
  sql_table_name:cu_user_analysis_dev.all_sessions_check ;;

  dimension: run_id {
    type: number
    sql: ${TABLE}."RUN_ID" ;;
  }

  dimension_group: run {
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
    sql: ${TABLE}."RUN_TIME" ;;
  }

  dimension: session_no {
    type: string
    sql: ${TABLE}."SESSION_NO" ;;
  }

  dimension_group: session_week {
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
    sql: ${TABLE}."SESSION_WEEK" ;;
  }

  dimension: total_dashboard_clicks {
    type: number
    sql: ${TABLE}."TOTAL_DASHBOARD_CLICKS" ;;
  }

  dimension: total_partner_clicks {
    type: number
    sql: ${TABLE}."TOTAL_PARTNER_CLICKS" ;;
  }

  dimension: total_searches {
    type: number
    sql: ${TABLE}."TOTAL_SEARCHES" ;;
  }

  dimension: unique_sessions {
    type: number
    sql: ${TABLE}."UNIQUE_SESSIONS" ;;
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

  measure: unique_sessions_total {
    type: sum
    sql:  unique_sessions ;;
  }
}
