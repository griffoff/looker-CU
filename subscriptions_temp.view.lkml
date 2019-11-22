view: subscriptions_temp {
  derived_table: {
    sql: WITH
        distinct_primary AS
        (
            SELECT DISTINCT primary_guid
            FROM prod.unlimited.vw_partner_to_primary_user_guid
            WHERE partner_guid IS NOT NULL
        )
        ,raw_subscription_event_merged_clean AS
        (
            SELECT
                COALESCE(m.primary_guid, r.user_sso_guid) AS merged_guid
                ,CASE WHEN m.primary_guid IS NOT NULL OR m2.primary_guid IS NOT NULL THEN 1 ELSE 0 END AS lms_user_status
                ,LOCAL_TIME
                ,USER_SSO_GUID as original_guid
                ,USER_SSO_GUID
                ,USER_ENVIRONMENT
                ,PRODUCT_PLATFORM
                ,PLATFORM_ENVIRONMENT
                ,CASE WHEN SUBSCRIPTION_STATE = 'provisional_locker' THEN SUBSCRIPTION_END ELSE greatest(local_time, subscription_start) END AS MOD_SUBSCRIPTION_START
                ,MOD_SUBSCRIPTION_START AS SUBSCRIPTION_START
                ,CASE SUBSCRIPTION_STATE WHEN 'cancelled' THEN CURRENT_DATE() WHEN 'provisional_locker' THEN DATEADD(YEAR, 1, SUBSCRIPTION_END) ELSE SUBSCRIPTION_END END AS SUBSCRIPTION_END
                ,LEAD(mod_subscription_start) OVER (PARTITION BY merged_guid ORDER BY local_time) as next_subscription_start
                ,SUBSCRIPTION_STATE
                ,CONTRACT_ID
                ,TRANSFERRED_CONTRACT
                ,ACCESS_CODE
            FROM prod.unlimited.raw_subscription_event r
            LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
                ON r.user_sso_guid = m.partner_guid
            LEFT JOIN distinct_primary m2
                ON  r.user_sso_guid = m2.primary_guid
            WHERE r.user_environment = 'production'
            AND r.platform_environment = 'production'
            AND r._ldts >= to_date('01-Aug-2018')
            AND NOT
                  (
                    EXISTS(SELECT 1 FROM STRATEGY.spr_review_fy19.offset_transactions offset_transactions WHERE offset_transactions.contract_id = r.contract_id)
                     AND
                    (r._LDTS >= TO_DATE('16-Dec-2018') AND r._LDTS < TO_DATE('01-Jan-2019') )
                    AND r.subscription_state in ('full_access')
                  )
             AND NOT
                  (
                    EXISTS(
                      SELECT 1 FROM PROD.UNLIMITED.EXCLUDED_USERS excluded LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids_forexcl ON excluded.user_sso_guid = guids_forexcl.partner_guid
                           WHERE COALESCE(guids_forexcl.primary_guid, excluded.user_sso_guid) = COALESCE(m.primary_guid, r.user_sso_guid)
                    )
                  )
          )
              SELECT
                e.*
                --,REPLACE(INITCAP(subscription_state), '_', ' ') AS subscription_status
                ,REPLACE(INITCAP(subscription_state), '_', ' ') || CASE WHEN subscription_state not in ('cancelled', 'banned','read_only', 'no_access', 'provisional_locker') AND subscription_end < CURRENT_TIMESTAMP() THEN ' (Expired)' ELSE '' END as subscription_status
                ,subscription_state not in ('cancelled', 'banned', 'no_access') AND subscription_end < CURRENT_TIMESTAMP() AS expired
                ,FIRST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as first_status
                ,FIRST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as first_start
                ,LAST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as current_status
                ,LAST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as current_start
                ,LAST_VALUE(subscription_end) over(partition by merged_guid order by local_time) as current_end
                ,LAG(subscription_status) over(partition by merged_guid order by local_time) as prior_status
                ,LAG(subscription_start) over(partition by merged_guid order by local_time) as prior_start
                ,LAG(subscription_end) over(partition by merged_guid order by local_time) as prior_end
                ,LEAD(local_time) over(partition by merged_guid order by local_time, subscription_start) as next_event_time
                ,MAX(CASE
                      WHEN subscription_state = 'full_access'
                      /*    AND NOT cancelled  */
                      THEN subscription_start
                      END) over(partition by merged_guid order by local_time rows between unbounded preceding and 1 preceding) as previous_full_access_start
                ,MAX(CASE
                      WHEN subscription_state = 'full_access'
                      /*    AND NOT cancelled  */
                      THEN subscription_end
                      END) over(partition by merged_guid order by local_time rows between unbounded preceding and 1 preceding) as previous_full_access_end
                ,LEAD(subscription_status) over(partition by merged_guid order by local_time) as next_status
                ,LEAD(subscription_start) over(partition by merged_guid order by local_time) as next_start
                ,subscription_start < current_timestamp() AND subscription_end > current_timestamp() as active
                ,MAX(local_time) over(partition by merged_guid) as latest_update
                ,next_status IS NULL as latest
                ,prior_status IS NULL as earliest
                ,subscription_start AS effective_from
                ,COALESCE(LEAST(next_subscription_start, subscription_end), subscription_end) AS effective_to
                ,MAX(CASE WHEN subscription_state = 'full_access' THEN subscription_start END) OVER (PARTITION BY merged_guid) AS latest_full_access_subscription_start_date
            FROM raw_subscription_event_merged_clean e
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: lms_user_status {
    type: number
    sql: ${TABLE}."LMS_USER_STATUS" ;;
  }

  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: original_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_GUID" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension_group: mod_subscription_start {
    type: time
    sql: ${TABLE}."MOD_SUBSCRIPTION_START" ;;
  }

  dimension_group: subscription_start {
    type: time
    sql: ${TABLE}."SUBSCRIPTION_START" ;;
  }

  dimension_group: subscription_end {
    type: time
    sql: ${TABLE}."SUBSCRIPTION_END" ;;
  }

  dimension_group: next_subscription_start {
    type: time
    sql: ${TABLE}."NEXT_SUBSCRIPTION_START" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  dimension: transferred_contract {
    type: string
    sql: ${TABLE}."TRANSFERRED_CONTRACT" ;;
  }

  dimension: access_code {
    type: string
    sql: ${TABLE}."ACCESS_CODE" ;;
  }

  dimension: subscription_status {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATUS" ;;
  }

  dimension: expired {
    type: string
    sql: ${TABLE}."EXPIRED" ;;
  }

  dimension: first_status {
    type: string
    sql: ${TABLE}."FIRST_STATUS" ;;
  }

  dimension_group: first_start {
    type: time
    sql: ${TABLE}."FIRST_START" ;;
  }

  dimension: current_status {
    type: string
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }

  dimension_group: current_start {
    type: time
    sql: ${TABLE}."CURRENT_START" ;;
  }

  dimension_group: current_end {
    type: time
    sql: ${TABLE}."CURRENT_END" ;;
  }

  dimension: prior_status {
    type: string
    sql: ${TABLE}."PRIOR_STATUS" ;;
  }

  dimension_group: prior_start {
    type: time
    sql: ${TABLE}."PRIOR_START" ;;
  }

  dimension_group: prior_end {
    type: time
    sql: ${TABLE}."PRIOR_END" ;;
  }

  dimension_group: next_event_time {
    type: time
    sql: ${TABLE}."NEXT_EVENT_TIME" ;;
  }

  dimension_group: previous_full_access_start {
    type: time
    sql: ${TABLE}."PREVIOUS_FULL_ACCESS_START" ;;
  }

  dimension_group: previous_full_access_end {
    type: time
    sql: ${TABLE}."PREVIOUS_FULL_ACCESS_END" ;;
  }

  dimension: next_status {
    type: string
    sql: ${TABLE}."NEXT_STATUS" ;;
  }

  dimension_group: next_start {
    type: time
    sql: ${TABLE}."NEXT_START" ;;
  }

  dimension: active {
    type: string
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension_group: latest_update {
    type: time
    sql: ${TABLE}."LATEST_UPDATE" ;;
  }

  dimension: latest {
    type: string
    sql: ${TABLE}."LATEST" ;;
  }

  dimension: earliest {
    type: string
    sql: ${TABLE}."EARLIEST" ;;
  }

  dimension: latest_full_access_subscription_start_date {
    type: date
    sql: ${TABLE}."LATEST_FULL_ACCESS_SUBSCRIPTION_START_DATE" ;;
    label: "Most recent full access start date"
  }

  dimension_group: effective_from {
    type: time
    sql: ${TABLE}."EFFECTIVE_FROM" ;;
  }

  dimension_group: effective_to {
    type: time
    sql: ${TABLE}."EFFECTIVE_TO" ;;
  }

  measure: max_date {
    type: max
    sql:  ${TABLE}."SUBSCRIPTION_START" ;;
  }

  set: detail {
    fields: [
      merged_guid,
      lms_user_status,
      local_time_time,
      original_guid,
      user_sso_guid,
      user_environment,
      product_platform,
      platform_environment,
      mod_subscription_start_time,
      subscription_start_time,
      subscription_end_time,
      next_subscription_start_time,
      subscription_state,
      contract_id,
      transferred_contract,
      access_code,
      subscription_status,
      expired,
      first_status,
      first_start_time,
      current_status,
      current_start_time,
      current_end_time,
      prior_status,
      prior_start_time,
      prior_end_time,
      next_event_time_time,
      previous_full_access_start_time,
      previous_full_access_end_time,
      next_status,
      next_start_time,
      active,
      latest_update_time,
      latest,
      earliest,
      effective_from_time,
      effective_to_time
    ]
  }
}
