include: "raw_subscription_event.view"
view: live_subscription_status {
  derived_table: {
#     sql:
#       WITH state AS (
#         SELECT
#             e.*
#             ,COALESCE(m.primary_guid, e.user_sso_guid) AS merged_guid
#             ,REPLACE(INITCAP(subscription_state), '_', ' ') as subscription_status
#             ,LAG(subscription_status) over(partition by user_sso_guid order by local_time) as prior_status
#             ,LEAD(subscription_status) over(partition by user_sso_guid order by local_time) as next_status
#             ,next_status IS NULL as latest
#         FROM unlimited.raw_Subscription_event e
#         LEFT JOIN unlimited.sso_merged_guids m on e.user_sso_guid = m.shadow_guid
#       )
#       SELECT *
#       FROM state
#       WHERE latest
#       ;;
    sql:
      SELECT *
      FROM ${raw_subscription_event.SQL_TABLE_NAME}
      WHERE latest;;
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: no
 }

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
  }


}
