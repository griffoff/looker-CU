include: "raw_subscription_event.view"
view: live_subscription_status {
  derived_table: {
    sql:
      SELECT *
      FROM ${raw_subscription_event.SQL_TABLE_NAME}
      WHERE latest;;
  }
  set: marketing_fields {
    fields: [live_subscription_status.student_count]
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: no
 }
  dimension: partner_guid {}
  dimension: lms_user {}
  dimension: prior_status {}
  dimension: subscription_status {}
  dimension_group: subscription_start {
    type: time
    timeframes: [raw, date, week, month, year]
  }
  dimension_group: subscription_end {
    type: time
    timeframes: [raw, date, week, month, year]
  }
  dimension_group: local_time {
    label: "Last Updated"
    type: time
    timeframes: [raw, date, week, month, year]
  }
  dimension: contract_id {}

  dimension: is_trial {
    sql: ${subscription_status} = 'Trial Access' ;;
    hidden: yes
  }

  dimension_group: time_in_current_status {
    group_label: "Time at this status"
    type: duration
    intervals: [day, week, month]
    sql_start: CASE WHEN ${subscription_end_raw} < current_timestamp() THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
    sql_end: current_date() ;;
  }

  measure: latest_data_date {
    description: "The latest time at which any subscription event has been received"
    type: date_time
    sql: max(${local_time_raw}) ;;
  }

  measure: student_count {
    label: "# Students"
    type: number
    sql: COUNT(DISTINCT ${user_sso_guid}) ;;
    drill_fields: [user_sso_guid]
  }

  measure: subscriber_count {
    label: "# Subscribers"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${subscription_status} = 'Full Access' THEN ${user_sso_guid} END) ;;
  }

  measure: non_subscriber_count {
    label: "# Non-subscribers"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${subscription_status} = 'Full Access' THEN NULL ELSE ${user_sso_guid} END) ;;
  }


}
