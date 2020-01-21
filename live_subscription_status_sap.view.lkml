explore: live_subscription_status_sap {}

view: live_subscription_status_sap {
  derived_table: {
    sql: WITH
        distinct_primary AS
        (
          SELECT
            DISTINCT primary_guid
          FROM prod.unlimited.vw_partner_to_primary_user_guid
          WHERE partner_guid IS NOT NULL
        )
        ,sap_subscriptions_ranked AS
        (
          SELECT
            ROW_NUMBER() OVER (PARTITION BY contract_id ORDER BY r.event_time DESC, subscription_start DESC) AS record_rank
            ,COALESCE(m.primary_guid, r.current_guid) AS merged_guid
             ,CASE WHEN m.primary_guid IS NOT NULL OR m2.primary_guid IS NOT NULL THEN 1 ELSE 0 END AS lms_user_status
            ,current_guid AS user_sso_guid
            ,r.event_time AS local_time
            ,CASE
                WHEN subscription_plan_id ILIKE '%full%' THEN 'Full Access'
                WHEN subscription_plan_id ILIKE '%trial%' THEN 'Trial Access'
                WHEN subscription_plan_id ILIKE '%read%' THEN subscription_plan_id
                WHEN subscription_plan_id ILIKE '%limited%' THEN 'Limited Access'
                ELSE subscription_plan_id
             END AS subscription_plan
             ,r.*
          FROM subscription.prod.sap_subscription_event r
          LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
              ON r.current_guid = m.partner_guid
          LEFT JOIN distinct_primary m2
              ON  r.current_guid = m2.primary_guid
          WHERE user_environment = 'production'
          AND platform_environment = 'production'
          AND NOT
                (
                  EXISTS
                      (
                          SELECT
                              1
                          FROM PROD.UNLIMITED.EXCLUDED_USERS excluded
                          LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids_forexcl
                              ON excluded.user_sso_guid = guids_forexcl.partner_guid
                          WHERE COALESCE(guids_forexcl.primary_guid, excluded.user_sso_guid) = COALESCE(m.primary_guid, r.current_guid)
                      )
                )
        )
        ,subscription_event_changes AS
        (
          SELECT
            *
            ,LAG(subscription_start) over(partition by merged_guid order by local_time) as prior_start
            ,LEAD(subscription_start) OVER (PARTITION BY merged_guid ORDER BY local_time) as next_subscription_start
            ,subscription_start AS effective_from
            ,COALESCE(LEAST(next_subscription_start, subscription_end), subscription_end) AS effective_to
        FROM sap_subscriptions_ranked
        )

        SELECT
           CASE
              WHEN subscription_status = 'Active' AND contract_status = 'Active' THEN subscription_plan
              WHEN subscription_status ILIKE '%cancelled%' THEN subscription_plan || ' (Cancelled)'
              WHEN subscription_status ILIKE '%expired' THEN subscription_plan || ' ' || '(Expired)'
              WHEN subscription_status ILIKE '%pending%' THEN subscription_plan || ' ' || '(Pending)'
              WHEN contract_status = 'Inactive' THEN 'Inactive Contract'
              ELSE 'Other'
            END AS subscription_state
            ,*
         FROM sap_subscriptions_ranked
         WHERE record_rank = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: record_rank {
    type: number
    sql: ${TABLE}."RECORD_RANK" ;;
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
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
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: current_guid {
    type: string
    sql: ${TABLE}."CURRENT_GUID" ;;
  }

  dimension: original_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_GUID" ;;
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


  dimension_group: available_until {
    type: time
    sql: ${TABLE}."AVAILABLE_UNTIL" ;;
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
  }

  dimension: subscription_duration {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
  }

  dimension_group: placed_time {
    type: time
    sql: ${TABLE}."PLACED_TIME" ;;
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
  }

  dimension: prior_status {}

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension_group: time_since_last_subscription {
#     group_label: "Time at this status"
    type: duration
    intervals: [day, week, month]
    sql_start: CASE WHEN ${subscription_end_raw} < current_timestamp() THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
    sql_end: current_date() ;;
  }

  dimension_group: time_left_in_current_status {
    type: duration
    intervals: [day, week, month]
    sql_start: current_timestamp() ;;
    sql_end: ${subscription_end_date} ;;

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
  }

  measure: non_subscriber_count {
    label: "# Non-subscribers"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${subscription_status} = 'Full Access' THEN NULL ELSE ${user_sso_guid} END) ;;
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
