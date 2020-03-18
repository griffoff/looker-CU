# explore: live_subscription_status_sap {}

view: live_subscription_status {
  derived_table: {
    sql:
        SELECT *
        FROM ${raw_subscription_event_sap.SQL_TABLE_NAME}
        WHERE record_rank = 1
       ;;
  }

  set: marketing_fields {
    fields: [live_subscription_status.student_count, live_subscription_status.days_time_left_in_current_status, live_subscription_status.subscription_status,live_subscription_status.subscriber_count,
      live_subscription_status.days_time_in_current_status, live_subscription_status.lms_user, live_subscription_status.effective_from, live_subscription_status.effective_to
      ,live_subscription_status.local_time_date, live_subscription_status.subscription_end_date]
}
  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
    description: "Active, Cancelled, Expired, Pending"
  }

  dimension: record_rank {
    type: number
    sql: ${TABLE}."RECORD_RANK" ;;
    hidden: yes
  }

  dimension: pk {
    type: string
    sql: ${subscription_id} || ${contract_id} ;;
    primary_key: yes
    description: "Subscription ID + Contract ID"
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
#     primary_key: merged_guid
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: lms_user {
    type: yesno
    sql: ${TABLE}.lms_user_status = 1;;
    description: "This flag is yes if a user has ever done a subscription event from a gateway account (from a shadow or gateway guid)"
  }

  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: subscription_plan {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_PLAN" ;;
    description: "Full Access, Limited Access, Read-Only, Trial Access"
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
    description: " Data Load Date Time Stamp"
    hidden:  yes
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden:  yes
  }

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
    description: "= 2"
    hidden:  yes
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
    description: "Subscription / SubscriptionTransfer"
    hidden:  yes
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
    description: "SAPSubscription"
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
    description: "production"
    hidden:  yes
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
    description: "production"
    hidden:  yes
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: current_guid {
    type: string
    sql: ${TABLE}."CURRENT_GUID" ;;
    description: "Most recent GUID"
  }

  dimension: original_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_GUID" ;;
    description: "GUID at initial user subscription"
  }

  dimension_group: initialization_time {
    type: time
    sql: ${TABLE}."INITIALIZATION_TIME" ;;
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  dimension: contract_status {
    type: string
    sql: ${TABLE}."CONTRACT_STATUS" ;;
    description: "Active / Inactive / Pending"
  }

  dimension: subscription_id {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_ID" ;;
  }

  dimension_group: subscription_start {
    type: time
    sql: ${TABLE}."SUBSCRIPTION_START" ;;
  }

  dimension_group: subscription_end {
    type: time
    sql: ${TABLE}."SUBSCRIPTION_END" ;;
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
    description: "Start date of subscription status"
    hidden: no
    sql: ${TABLE}."EFFECTIVE_FROM" ;;
  }

  dimension_group: time_in_current_status {
    view_label: "Learner Profile - Live Subscription Status"
    type: duration
    intervals: [day, week, month]
    sql_start: ${subscription_start_date} ;;
    sql_end:  CURRENT_DATE();;
    label: "Time in current status"
    description: "Time since subscription start date"
  }


  dimension_group: available_until {
    type: time
    sql: ${TABLE}."AVAILABLE_UNTIL" ;;
    hidden:  yes
  }

  dimension: subscription_status {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
    description: "Subscription status created from SAP fields (subscription_plan_id, subscription_status, contract_status) "
  }


  dimension: is_trial {
    sql: ${subscription_status} = 'Trial Access' ;;
    hidden: yes
  }

  dimension: subscription_status_sap {
    type: string
    description: "SAP subscription status"
    sql: ${TABLE}."SUBSCRIPTION_STATUS" ;;
  }

  dimension: subscription_plan_id {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_PLAN_ID" ;;
    description: "Full-Access-120, 2  Full-Access-365, Full-Access-730, Limited-Access-180,Read-Only, Trial"
  }

  dimension: subscription_duration {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
    description: "14, 120, 122, 180, 365, 730 days"
  }

  dimension_group: placed_time {
    type: time
    sql: ${TABLE}."PLACED_TIME" ;;
    description: "Time subscription was placed"
  }

  dimension_group: cancelled_time {
    type: time
    sql: ${TABLE}."CANCELLED_TIME" ;;
  }

  dimension: cancellation_reason {
    type: string
    sql: ${TABLE}."CANCELLATION_REASON" ;;
  }

  dimension: payment_source_type {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_TYPE" ;;
  }

  dimension: payment_source_id {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_ID" ;;
  }

  dimension: payment_source_guid {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_GUID" ;;
  }

  dimension: payment_source_line {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_LINE" ;;
    description: "= 1"
  }

  dimension: prior_status {
    hidden:  yes
    #this field doesn't exist in the source table
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
    description: "Numeric ID associated with Subscription Plan ID"
  }

  dimension_group: time_since_last_subscription {
#     group_label: "Time at this status"
    type: duration
    intervals: [day, week, month]
    sql_start: CASE WHEN ${subscription_end_raw} < current_timestamp() THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
    sql_end: current_date() ;;
    description: "Time since subscription start if active subscription is ongoing, otherwise time since subscription end"
  }

  dimension_group: time_left_in_current_status {
    type: duration
    intervals: [day, week, month]
    sql_start: current_timestamp() ;;
    sql_end: ${subscription_end_date} ;;
  description: "Time remaining until subscription end"
  }

  dimension: gateway_guid {
    label: "Gateway GUID"
    description: "This event was done from the users gateway guid"
    type: yesno
    sql: ${user_sso_guid} <> ${original_guid} ;;
    hidden: no
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
    description: "Distinct count of full access subscribers"
  }

  measure: non_subscriber_count {
    label: "# Non-subscribers"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${subscription_status} = 'Full Access' THEN NULL ELSE ${user_sso_guid} END) ;;
    hidden: yes
  }

  measure: latest_data_date {
    description: "The latest time at which any subscription event has been received"
    type: date_time
    sql: max(${local_time_raw}) ;;
  }

  measure: user_count {
    type: count_distinct
    label: "# Users"
    sql: ${TABLE}."USER_SSO_GUID" ;;
    hidden: yes
  }

  set: detail {
    fields: [
      subscription_state,
      record_rank,
      merged_guid,
      user_sso_guid,
      local_time_time,
      subscription_plan,
      _ldts_time,
      _rsrc,
      message_format_version,
      message_type,
      product_platform,
      platform_environment,
      user_environment,
      event_time_time,
      current_guid,
      original_guid,
      initialization_time_time,
      contract_id,
      contract_status,
      subscription_id,
      subscription_start_time,
      subscription_end_time,
      available_until_time,
      subscription_status,
      subscription_plan_id,
      subscription_duration,
      placed_time_time,
      cancelled_time_time,
      cancellation_reason,
      payment_source_type,
      payment_source_id,
      payment_source_guid,
      payment_source_line,
      item_id
    ]
  }
}
