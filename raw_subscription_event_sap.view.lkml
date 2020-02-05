explore: raw_subscription_event_sap  {}

view: raw_subscription_event_sap {
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
            COALESCE(m.primary_guid, r.current_guid) AS merged_guid
            --,ROW_NUMBER() OVER (PARTITION BY subscription_id, contract_id ORDER BY r.event_time DESC, subscription_start DESC) AS record_rank
            ,ROW_NUMBER() OVER (PARTITION BY merged_guid ORDER BY subscription_start, r.event_time DESC DESC) AS record_rank
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
            ,LAG(subscription_start) over(partition by merged_guid order by subscription_start, local_time) as prior_start
            ,LEAD(subscription_start) OVER (PARTITION BY merged_guid ORDER BY subscription_start, local_time) as next_subscription_start
            ,subscription_start AS effective_from
            ,COALESCE(LEAST(next_subscription_start, subscription_end), subscription_end) AS effective_to
        FROM sap_subscriptions_ranked
        )
        SELECT
           CASE
              WHEN subscription_status ILIKE '%expired' OR (subscription_end < CURRENT_TIMESTAMP()) THEN subscription_plan || ' ' || '(Expired)'
              WHEN (subscription_status ILIKE '%pending%' AND subscription_start > CURRENT_TIMESTAMP()) OR (subscription_start > CURRENT_TIMESTAMP()) THEN subscription_plan || ' ' || '(Pending)'
              WHEN subscription_status ILIKE '%cancelled%' OR (contract_status ILIKE '%cancelled%') THEN subscription_plan || ' (Cancelled)'
              WHEN contract_status = 'Inactive' THEN 'Inactive Contract'
              --WHEN subscription_status = 'Active' AND contract_status = 'Active' THEN subscription_plan
              --ELSE 'Other'
              ELSE subscription_plan
            END AS subscription_state
            ,*
         FROM subscription_event_changes
 ;;

persist_for: "3 hours"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: record_rank {
    type: number
    sql: ${TABLE}."RECORD_RANK" ;;
  }

  dimension: lms_user_status {
    type: number
    sql: ${TABLE}."LMS_USER_STATUS" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
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

  dimension_group: available_until {
    type: time
    sql: ${TABLE}."AVAILABLE_UNTIL" ;;
  }

  dimension: subscription_status {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
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

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: subscription_status_sap {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATUS" ;;
    description: "Subscription status created from SAP fields (subscription_plan_id, subscription_status, contract_status) "
  }


  set: detail {
    fields: [
      subscription_state,
      merged_guid,
      record_rank,
      lms_user_status,
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
