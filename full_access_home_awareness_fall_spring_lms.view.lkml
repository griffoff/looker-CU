explore: full_access_home_awareness_fall_spring_lms {}

view: full_access_home_awareness_fall_spring_lms {

    derived_table: {
      sql:
        WITH
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
              SELECT
                  r.user_sso_guid_merged
                  ,CASE WHEN r.user_sso_guid_merged <> r.user_sso_guid THEN 'LMS User' ELSE 'Non-LMS User' END AS lms_vs_non_lms_user
                  ,CASE
                      WHEN r.effective_from < '2018-12-15' AND r.effective_from > '2018-08-01' THEN 'Fall 2019 user'
                      WHEN r.effective_from > '2018-12-15' AND r.effective_from < CURRENT_TIMESTAMP() THEN 'Spring 2019 user'
                      WHEN r.effective_from < '2018-08-01' THEN 'Before CU user'
                      ELSE 'Unknown' END AS fall_vs_spring_user
                  ,Count(distinct case when event_name ilike 'back to Cu Home Page' THEN user_sso_guid_merged else null END) as Explored_myHome
                  ,COUNT(DISTINCT user_sso_guid_merged) AS all_events
              FROM raw_subscription_event_merged_erroneous_removed r
              LEFT JOIN zpg.all_events e
                  ON r.user_sso_guid_merged = e.user_sso_guid
                  AND e.event_time >= r.effective_from
                  AND e.event_time < r.effective_to
              WHERE e.subscription_state = 'Full Access'
              GROUP BY 1, 2, 3 ;;

    }

    measure: count {
      type: count
    }


    dimension: user_sso_guid_merged {
      type: string
      sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
    }

    dimension: lms_vs_non_lms_user {
      type: string
      sql: ${TABLE}."LMS_VS_NON_LMS_USER" ;;
    }

    dimension: fall_vs_spring_user {
      type: string
      sql: ${TABLE}."FALL_VS_SPRING_USER" ;;
    }

    dimension: explored_myhome {
      type: number
      sql: ${TABLE}."EXPLORED_MYHOME" ;;
    }

    measure: explored_myhome_m {
      label: "Users that clicked 'Explore my home'"
      type: sum
      sql: ${TABLE}."EXPLORED_MYHOME" ;;
    }

    dimension: all_events {
      type: number
      sql: ${TABLE}."ALL_EVENTS" ;;
    }

    measure: all_events_m {
      label: "Users that have not clicked 'Explore my home'"
      type: sum
      sql: ${TABLE}."ALL_EVENTS" - ${explored_myhome} ;;
    }




  }
