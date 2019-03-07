explore: spring_review_renewed_vs_not_renewed_cu_user_usage {}

view: spring_review_renewed_vs_not_renewed_cu_user_usage {
  derived_table: {
    sql:  WITH
          raw_subscription_event_merged AS
          (
              SELECT
                  COALESCE(m.primary_guid, r.user_sso_guid) AS user_sso_guid_merged
                  ,r.*
              FROM unlimited.raw_subscription_event r
              LEFT JOIN unlimited.sso_merged_guids m
                  ON r.user_sso_guid = m.shadow_guid
              WHERE user_sso_guid_merged NOT IN (SELECT DISTINCT user_sso_guid FROM prod.unlimited.excluded_users)
          )
          ,raw_subscription_event_merged_next_events AS
          (
          SELECT
               user_sso_guid_merged
              ,user_sso_guid
              ,local_time
              ,_ldts
              ,subscription_state
              ,subscription_start
              ,subscription_end
              ,subscription_start AS effective_from
              ,LEAD(subscription_start, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time) AS next_event_time
              ,COALESCE(LEAST(next_event_time, subscription_end), subscription_end) AS effective_to
              ,LEAD(subscription_state, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_state_2
              ,LEAD(subscription_start, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_start_2
              ,LEAD(subscription_end, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_end_2
              ,LEAD(local_time, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS local_time_2
              ,LEAD(_ldts, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS ldts_2
              ,LEAD(subscription_state, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_state_3
              ,LEAD(subscription_start, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_start_3
              ,LEAD(subscription_end, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_end_3
              ,LEAD(local_time, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS local_time_3
              ,LEAD(_ldts, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS ldts_3
              ,COUNT(DISTINCT subscription_state) OVER (PARTITION BY user_sso_guid_merged) AS number_of_subscription_states
          FROM raw_subscription_event_merged
          )
          ,raw_subscription_event_merged_erroneous_removed AS
          (
          SELECT
              user_sso_guid_merged
              ,user_sso_guid
              ,local_time
              ,subscription_state
              ,subscription_start
              ,subscription_end
              ,local_time_2
              ,ldts_2
              ,subscription_state_2
              ,subscription_start_2
              ,subscription_end_2
              ,local_time_3
              ,ldts_3
              ,subscription_state_3
              ,subscription_start_3
              ,subscription_end_3
              ,effective_from
              ,effective_to
              ,LAST_VALUE(subscription_state) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time ASC) AS subscription_state_current
              ,LAST_VALUE(subscription_start) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time ASC) AS subscription_start_current
              ,LAST_VALUE(subscription_end) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time ASC) AS subscription_end_current
              ,LAST_VALUE(local_time) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time ASC) AS local_time_current
              ,DATEDIFF('month', subscription_start, subscription_end ) AS subscription_term_length
          FROM raw_subscription_event_merged_next_events
          WHERE
          -- Filtering out duplicate events
          NOT (COALESCE(subscription_state = subscription_state_2, FALSE) AND COALESCE(DATEDIFF('second', local_time, local_time_2),0) <= 30)
          -- Filtering out trials sent after full access
          -- Might need to add an extra condition or change condition for two events less than 30 seconds apart
          AND NOT (subscription_state = 'full_access' AND COALESCE(subscription_state_2 = 'trial_access', FALSE) AND ( NOT COALESCE(subscription_end <= subscription_start_2, FALSE)))
          -- Filtering out shadow guid move (cancellation + new full access)
          -- Two extra cancel and full_access may have the same LDTS
          -- Add each statement as a case statement instead of in wheres
          AND NOT (subscription_state = 'full_access'
                  AND subscription_state_2 = 'cancelled'
                  AND subscription_state_3 = 'full_access'
                  AND user_sso_guid <> user_sso_guid_merged
                  AND ldts_2 = ldts_3)
          AND NOT (subscription_state = 'cancelled'
                  AND subscription_state_2 = 'full_access'
                  AND user_sso_guid <> user_sso_guid_merged
                  AND _ldts = ldts_2)
          )
          ,eligible_users AS (
          SELECT
              *
          FROM raw_subscription_event_merged_erroneous_removed
          WHERE subscription_state = 'full_access'
                  AND subscription_start < '2018-12-15'
                  AND subscription_term_length = 4 OR subscription_term_length = 3 -- WHERE user_sso_guid_merged = 'e62cc53b5d2fc053:780e1f8e:160d61cb107:-312a';
          )
          ,activations_merged AS
          (
              SELECT
                  COALESCE(m.primary_guid, a.user_guid) AS user_sso_guid_merged
                  ,a.*
              FROM stg_clts.activations_olr a
              LEFT JOIN unlimited.sso_merged_guids m
                  ON a.user_guid = m.shadow_guid
              WHERE a.platform <> 'Cengage Unlimited'
          )
          ,renewed_activations_and_dashboard_clicks AS
          (
              SELECT
                  e.user_sso_guid_merged
                  ,COUNT(DISTINCT CASE WHEN actv_dt <= '2018-12-15' THEN actv_isbn END) AS activations_on_or_prior_20181215
                  ,COUNT(DISTINCT CASE WHEN actv_dt > '2018-12-15' THEN actv_isbn END) AS activations_after_20181215
                  ,COUNT(DISTINCT CASE WHEN UPPER(ae.event_name) IN (UPPER('One month Free Chegg Clicked'), UPPER('Rent from Chegg Clicked'), UPPER('study resource clicked')) THEN event_id END) AS partner_clicks_count
                  ,COUNT(DISTINCT CASE WHEN UPPER(ae.event_name) IN (UPPER('flashcards launched'), UPPER('test prep launched')) THEN event_id END) AS study_tool_launches_count
                  ,COUNT(DISTINCT CASE WHEN ae.event_name IN ('Dashboard Search - No Results', 'Dashboard Search - With Results')  THEN event_id END) AS searches_count
              FROM eligible_users e
              LEFT JOIN activations_merged a
                  ON e.user_sso_guid_merged = a.user_sso_guid_merged
              LEFT JOIN prod.cu_user_analysis.all_events ae
                  ON e.user_sso_guid_merged = ae.user_sso_guid
              WHERE e.subscription_state_current = 'full_access' AND e.subscription_end_current > CURRENT_DATE()
              AND  ae.event_time > '2018-08-01' AND ae.event_time < '2018-12-15'
              GROUP BY 1
          )
          ,non_renewing_users AS
          (
              SELECT
                  *
              FROM eligible_users
              WHERE subscription_state_current <> 'full_access'
              AND user_sso_guid_merged NOT IN (SELECT DISTINCT user_sso_guid_merged FROM renewed_activations_and_dashboard_clicks)
          )
          ,non_renew_activations_and_dashboard_clicks AS
          (
              SELECT
                  e.user_sso_guid_merged
                  ,COUNT(DISTINCT CASE WHEN actv_dt <= '2018-12-15' THEN actv_isbn END) AS activations_on_or_prior_20181215
                  ,COUNT(DISTINCT CASE WHEN actv_dt > '2018-12-15' THEN actv_isbn END) AS activations_after_20181215
                  ,COUNT(DISTINCT CASE WHEN UPPER(ae.event_name) IN (UPPER('One month Free Chegg Clicked'), UPPER('Rent from Chegg Clicked'), UPPER('study resource clicked')) THEN event_id END) AS partner_clicks_count
                  ,COUNT(DISTINCT CASE WHEN UPPER(ae.event_name) IN (UPPER('flashcards launched'), UPPER('test prep launched')) THEN event_id END) AS study_tool_launches_count
                  ,COUNT(DISTINCT CASE WHEN ae.event_name IN ('Dashboard Search - No Results', 'Dashboard Search - With Results')  THEN event_id END) AS searches_count
              FROM non_renewing_users e
              LEFT JOIN activations_merged a
                  ON e.user_sso_guid_merged = a.user_sso_guid_merged
              LEFT JOIN prod.cu_user_analysis.all_events ae
                  ON e.user_sso_guid_merged = ae.user_sso_guid
                  AND ae.event_time > e.subscription_start_current
                  AND ae.event_time < e.subscription_end_current
              WHERE ae.event_time > '2018-08-01' AND ae.event_time < '2018-12-15'
              GROUP BY 1
          )
          ,renewed_and_non_renewed_activations_and_dashboard_use AS
          (
          SELECT
              'Non-Renewal CU user' AS renewal_vs_non_renewal_user
              ,*
          FROM non_renew_activations_and_dashboard_clicks
          UNION
          SELECT
              'Renewal CU user' AS renewal_vs_non_renewal_user
               ,*
          FROM renewed_activations_and_dashboard_clicks
          )
          SELECT
            *
          FROM renewed_and_non_renewed_activations_and_dashboard_use
          WHERE user_sso_guid_merged NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users);;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid_merged} ;;
  }

  measure: average_study_tool_launches {
    label: "Average # of study tool launches per user"
    type: average
    sql: ${study_tool_launches_count} ;;
  }

  measure: average_activations_prior_20181215 {
    label: "Average # of number of activations prior to December 15th, 2018 per user"
    type: average
    sql: ${activations_on_or_prior_20181215} ;;
  }

  measure: average_partner_clicks_count {
    label: "Average # of partner clicks per user"
    type: average
    sql: ${partner_clicks_count} ;;
  }

  measure: average_searches_count {
    label: "Average # of searches per user"
    type: average
    sql: ${searches_count} ;;
  }

  dimension: renewal_vs_non_renewal_user {
    type: string
    sql: ${TABLE}."RENEWAL_VS_NON_RENEWAL_USER" ;;
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  }

  dimension: activations_on_or_prior_20181215 {
    type: number
    sql: COALESCE(${TABLE}."ACTIVATIONS_ON_OR_PRIOR_20181215", 0) ;;
  }

  dimension: activations_after_20181215 {
    type: number
    sql: COALESCE(${TABLE}."ACTIVATIONS_AFTER_20181215", 0) ;;
  }

  dimension: partner_clicks_count {
    type: number
    sql: COALESCE(${TABLE}."PARTNER_CLICKS_COUNT", 0) ;;
  }

  dimension: study_tool_launches_count {
    type: number
    sql: COALESCE(${TABLE}."STUDY_TOOL_LAUNCHES_COUNT", 0) ;;
  }

  dimension: searches_count {
    type: number
    sql: COALESCE(${TABLE}."SEARCHES_COUNT", 0) ;;
  }

  set: detail {
    fields: [
      user_sso_guid_merged,
      activations_on_or_prior_20181215,
      activations_after_20181215,
      partner_clicks_count,
      study_tool_launches_count,
      searches_count
    ]
  }
}
