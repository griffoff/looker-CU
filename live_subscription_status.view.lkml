include: "raw_subscription_event.view"
view: live_subscription_status {
  derived_table: {
    sql:
      SELECT *
      FROM ${raw_subscription_event.SQL_TABLE_NAME}
      WHERE latest = 1;;
  }
  set: marketing_fields {
    fields: [live_subscription_status.student_count, live_subscription_status.days_time_left_in_current_status, live_subscription_status.subscription_status,live_subscription_status.subscriber_count,
        live_subscription_status.days_time_in_current_status, live_subscription_status.lms_user, live_subscription_status.effective_from, live_subscription_status.effective_to
        ,live_subscription_status.local_time_date, live_subscription_status.subscription_end_date]
  }

  dimension: effective_to {
    type: date
    label: "Effective to date"
    description: "The day this status ended. e.g. different from subscription end date when a subscription gets cancelled or when a trial state upgrades to ful access early"
    hidden: no
    sql: ${TABLE}."EFFECTIVE_TO" ;;
  }

  dimension: effective_from {
    type: date
    label: "Subscription effective from date"
    description: "Start date of this status"
    hidden: no
    sql: ${TABLE}."EFFECTIVE_FROM" ;;
  }

  dimension_group: time_in_current_status {
    view_label: "Learner Profile - Live Subscription Status"
    type: duration
    intervals: [day, week, month]
    sql_start: ${effective_from} ;;
    sql_end:  CURRENT_DATE();;
    label: "Time in current status"
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    description: "Parimary user sso guid, after shadonw guid lookup and merge"
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: no
 }
  dimension: original_guid {
    description: "Origiual guid captured in raw event"
    alias: [partner_guid]
  }
  dimension: lms_user {
    type: yesno
    sql: ${TABLE}.lms_user_status = 1;;
    description: "This flag is yes if a user has ever done a subscription event from a gateway account (from a shadow or gateway guid)"
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

  dimension_group: time_since_last_subscription {
#     group_label: "Time at this status"
    type: duration
    intervals: [day, week, month]
    sql_start: CASE WHEN ${subscription_end_raw} < current_timestamp() THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
    sql_end: current_date() ;;
  }




#   dimension_group: time_since_last_trial {
# #     group_label: "Time at this status"
#     type: duration
#     intervals: [day, week, month]
#     sql_start: CASE (WHEN ${subscription_end_raw} < current_timestamp() AND ${prior_status} = 'Trial_Access') THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
#     sql_end: current_date() ;;
#   }

#
#   dimension_group: time_in_current_status {
#     group_label: "Time at this status"
#     type: duration
#     intervals: [day, week, month]
#     sql_start: ${subscription_start_raw}::date ;;
#     sql_end: current_date() ;;
#   }


#
#   dimension: time_in_curr {
#     label: "Testing time in current state"
#     sql: TIMEDIFF('d', ${subscription_end_raw}, CURRENT_TIMESTAMP()) ;;
#   }


  dimension_group: time_left_in_current_status {
    type: duration
    intervals: [day, week, month]
    sql_start: current_timestamp() ;;
    sql_end: ${subscription_end_date} ;;

}

#   dimension_group: time_in_current_status {
#     type: duration
#     intervals: [day, week, month]
#     sql_start: ${subscription_start_date};;
#     sql_end: current_timestamp()  ;;
#
#   }

  measure: latest_data_date {
    description: "The latest time at which any subscription event has been received"
    type: date_time
    sql: max(${local_time_raw}) ;;
  }

  measure: student_count {
    hidden: yes
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
