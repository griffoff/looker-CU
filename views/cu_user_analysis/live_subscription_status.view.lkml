include: "./raw_subscription_event_sap.view"
# explore: live_subscription_status_sap {}

view: live_subscription_status {

  view_label: "User Details - Live Subscription Status"

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
    label: "Subscription Plan + Status"
    description: "Subscription Plan + Status (e.g. Trial Access (Expired))"
    suggest_explore: filter_cache_live_subscription_status_subscription_state
    suggest_dimension: subscription_state
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
  hidden:  yes
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
#     primary_key: merged_guid
    hidden: yes
  }

  dimension: user_sso_guid {
    label: "USER SSO GUID - live subscription state"
    description: "this is the user guid on a real time feed of subscription data
    ** only use this is you want to filter on current subscription data **"
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    hidden: yes
  }

  dimension: lms_user {
    type: yesno
    sql: ${TABLE}.lms_user_status = 1;;
    description: "This flag is yes if a user has ever done a subscription event from a gateway account (from a shadow or gateway guid)"
    hidden: yes
  }

  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
    hidden: yes
  }

  dimension: subscription_plan {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_PLAN" ;;
    description: "Read-Only / Full Access / Trial Access / etc."
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
    hidden: yes
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
    hidden: yes
  }

  dimension: current_guid {
    type: string
    sql: ${TABLE}."CURRENT_GUID" ;;
    description: "Most recent GUID"
    hidden: yes
  }

  dimension: original_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_GUID" ;;
    description: "GUID at initial user subscription"
    hidden: yes
  }

  dimension_group: initialization_time {
    type: time
    sql: ${TABLE}."INITIALIZATION_TIME" ;;
    hidden: yes
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
    hidden: yes
  }

  dimension: contract_status {
    type: string
    sql: ${TABLE}."CONTRACT_STATUS" ;;
    description: "Active / Inactive / Pending"
    hidden:  yes
  }

  dimension: subscription_id {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_ID" ;;
    hidden: yes
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
    hidden: yes
    sql: ${TABLE}."EFFECTIVE_TO" ;;
  }

  dimension: effective_from {
    type: date
    label: "Subscription effective from date"
    description: "Start date of subscription status"
    hidden: yes
    sql: ${TABLE}."EFFECTIVE_FROM" ;;
  }

  dimension_group: time_in_current_status {
    type: duration
    intervals: [day, week, month]
    sql_start: ${subscription_start_date} ;;
    sql_end:  CURRENT_DATE();;
    label: "Time in current status"
    description: "Time since subscription start date"
    hidden: yes
  }


  dimension_group: available_until {
    type: time
    sql: ${TABLE}."AVAILABLE_UNTIL" ;;
    hidden:  yes
  }

  dimension: subscription_status {
    # same as subscription_state
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
    hidden: yes
  }


  dimension: is_trial {
    sql: ${subscription_status} = 'Trial Access' ;;
    hidden: yes
  }

  dimension: subscription_status_sap {
    label: ""
    type: string
    description: "Active / Cancelled / Expired / Pending"
    sql: ${TABLE}."SUBSCRIPTION_STATUS" ;;
  }

  dimension: subscription_plan_id {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_PLAN_ID" ;;
    description: "Full-Access-365 / CU-Trial-7-PV / CU-ETextBook-120 / etc."
  }

  dimension: cu_subscription_length {
    type: string
    label: "CU subscription state duration/length"
    description: "Duration of current CU subscription state in months (Needs to be used with Subscription Status filter or dimension)"
    case: {
      when: {label: "1 Week" sql: ${subscription_plan_id} in ('CU-ETextBook-Trial-7','CU-ETextBook-Trial-7-PV','CU-Trial-7','CU-Trial-7-PV') ;;}
      when: {label: "2 Weeks" sql: ${subscription_plan_id} in ('Trial','CU-Trial-14') ;;}
      when: {label: "4 months" sql: ${subscription_plan_id} in ('CU-ETextBook-120','Full-Access-120') ;;}
      when: {label: "12 months" sql: ${subscription_plan_id} = ('Full-Access-365') ;;}
      when: {label: "24 months" sql: ${subscription_plan_id} = ('Full-Access-730') ;;}
      else: "Other"
    }
    hidden: no
  }

  dimension: subscription_duration {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
    description: "14, 120, 122, 180, 365, 730 days"
    hidden: yes
  }

  dimension_group: placed_time {
    type: time
    sql: ${TABLE}."PLACED_TIME" ;;
    description: "Time subscription was placed"
    hidden:  yes
  }

  dimension_group: cancelled_time {
    type: time
    sql: ${TABLE}."CANCELLED_TIME" ;;
    hidden: no
  }

  dimension: cancellation_reason {
    type: string
    sql: ${TABLE}."CANCELLATION_REASON" ;;
    hidden: yes
  }

  dimension: payment_source_type {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_TYPE" ;;
    hidden: yes
  }

  dimension: payment_source_id {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_ID" ;;
    hidden: yes
  }

  dimension: payment_source_guid {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_GUID" ;;
    hidden: yes
  }

  dimension: payment_source_line {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_LINE" ;;
    description: "= 1"
    hidden: yes
  }

  dimension: prior_status {
    hidden:  yes
    #this field doesn't exist in the source table
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
    description: "Numeric ID associated with Subscription Plan ID"
    hidden: yes
  }

  dimension_group: time_since_last_subscription {
#     group_label: "Time at this status"
    type: duration
    intervals: [day, week, month]
    sql_start: CASE WHEN ${subscription_end_raw} < current_timestamp() THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
    sql_end: current_date() ;;
    description: "Time since subscription start if active subscription is ongoing, otherwise time since subscription end"
    hidden: yes
  }

  dimension_group: time_left_in_current_status {
    type: duration
    intervals: [day, week, month]
    sql_start: current_timestamp() ;;
    sql_end: ${subscription_end_date} ;;
    description: "Time remaining until subscription end"
    hidden: yes
  }

  dimension: gateway_guid {
    label: "Gateway GUID"
    description: "This event was done from the users gateway guid"
    type: yesno
    sql: ${user_sso_guid} <> ${original_guid} ;;
    hidden: yes
  }

  dimension: marketing_intention {
    description: "Bucket for determining how to commuicate with users"
    label: "Marketing Bucket"
#     Trial source is via courselink
# Trial source is via ala carte trial-opt in
# Trial source is via Cengage.com
    sql:  ;;
     hidden: yes
  }

  measure: student_count {
    hidden: no
    label: "# Subscribers (All types inc. trial)"
    type: number
    sql: COUNT(DISTINCT ${user_sso_guid}) ;;
    drill_fields: [user_sso_guid]
  }

  measure: subscriber_count {
    label: "# Full Access Subscribers"
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
    hidden: yes
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
