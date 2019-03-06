explore: read_only_ebook_usage {}

view: read_only_ebook_usage {
  derived_table: {
    sql:
WITH
    raw_subscription_event_merged AS
    (
        SELECT
            COALESCE(m.primary_guid, r.user_sso_guid) AS user_sso_guid_merged
            ,r.*
        FROM prod.unlimited.raw_subscription_event r
        LEFT JOIN prod.unlimited.sso_merged_guids m
            ON r.user_sso_guid = m.shadow_guid
    )
    ,raw_subscription_event_merged_next_events AS
    (
    SELECT
        raw_subscription_event_merged.*
        ,LEAD(subscription_state, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_state_2
        ,LEAD(subscription_start, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_start_2
        ,LEAD(subscription_end, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_end_2
        ,LEAD(local_time, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS local_time_2
        ,LEAD(subscription_state, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_state_3
        ,LEAD(subscription_start, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_start_3
        ,LEAD(subscription_end, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_end_3
        ,LEAD(local_time, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS local_time_3
    FROM raw_subscription_event_merged
    WHERE user_sso_guid_merged NOT IN (SELECT DISTINCT user_sso_guid FROM prod.unlimited.excluded_users)
    )
    ,raw_subscription_event_merged_erroneous_removed AS
    (
    SELECT
         user_sso_guid_merged
        ,user_sso_guid
        ,local_time
        ,local_time_2
        , subscription_state
        , subscription_state_2
        , subscription_start
        , subscription_start_2
        , subscription_end
        , subscription_end_2
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
    AND NOT (subscription_state = 'full_access' AND subscription_state_2 = 'cancelled' AND subscription_state_3 = 'full_access' AND user_sso_guid <> user_sso_guid_merged)
    )
    ,subscription_next_events AS
    (
        SELECT
            r.user_sso_guid_merged
            ,r.user_sso_guid
            ,r.local_time
            ,r.subscription_state
            ,r.subscription_start
            ,r.subscription_end
            ,r.subscription_term_length
        ,LEAD(r.subscription_state, 1) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_state_2
            ,LEAD(r.subscription_start, 1) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_start_2
            ,LEAD(r.subscription_end, 1) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_end_2
            ,LEAD(r.subscription_state, 2) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_state_3
            ,LEAD(r.subscription_start, 2) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_start_3
            ,LEAD(r.subscription_end, 2) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_end_3
            ,LEAD(r.subscription_state, 3) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_state_4
            ,LEAD(r.subscription_start, 3) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_start_4
            ,LEAD(r.subscription_end, 3) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS subscription_end_4
            ,LAST_VALUE(r.subscription_state) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time ASC) AS subscription_state_current
            ,LAST_VALUE(r.subscription_start) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time ASC) AS subscription_start_current
            ,LAST_VALUE(r.subscription_end) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time ASC) AS subscription_end_current
            ,r.local_time AS effective_from
            ,LEAD(r.local_time, 1) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS effective_from_2
            ,LEAD(r.local_time, 2) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS effective_from_3
            ,LEAD(r.local_time, 3) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS effective_from_4
            ,LEAD(r.local_time, 1) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS effective_to
            ,LEAD(r.local_time, 2) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS effective_to_2
            ,LEAD(r.local_time, 3) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS effective_to_3
            ,LEAD(r.local_time, 4) OVER (PARTITION BY r.user_sso_guid_merged ORDER BY r.local_time) AS effective_to_4
        FROM raw_subscription_event_merged_erroneous_removed r
    )
    ,eligible_users AS (
    SELECT
        *
    FROM subscription_next_events
    WHERE subscription_state = 'full_access'
        AND subscription_start < '2018-12-15'
        AND subscription_term_length = 4 OR subscription_term_length = 3 -- WHERE user_sso_guid_merged = 'e62cc53b5d2fc053:780e1f8e:160d61cb107:-312a';
    )
    ,read_only AS
    (
      SELECT
        *
      FROM eligible_users
      WHERE subscription_state_current IN ('read_only')
    )
     ,ebook_actions_per_user AS
     (
      SELECT
          r.user_sso_guid_merged
          ,SUM(CASE WHEN e.event_name = 'Download eBook' THEN 1 ELSE 0 END) AS downloaded_ebook
          ,SUM(CASE WHEN e.event_name = 'Print eBook' THEN 1 ELSE 0 END) AS printed_ebook
          ,SUM(CASE WHEN e.event_name = 'View eBook' THEN 1 ELSE 0 END) AS viewed_ebook
          ,SUM(CASE WHEN e.event_name = 'eBook Bookmarked' THEN 1 ELSE 0 END) AS bookmarked_ebook
          ,SUM(CASE WHEN e.event_name = 'eBook Highlighted' THEN 1 ELSE 0 END) AS highlighted_ebook
          ,SUM(CASE WHEN e.event_name = 'eBook Launched' THEN 1 ELSE 0 END) AS launched_ebook
//          ,AVG(downloaded_ebook + printed_ebook + viewed_ebook + bookmarked_ebook + highlighted_ebook + launched_ebook) AS total_ebook_actions
      FROM read_only r
      LEFT JOIN prod.zpg.all_events e
          ON r.user_sso_guid_merged = e.user_sso_guid
      WHERE e.event_time > r.subscription_start_current
      GROUP BY 1
     )
     ,total_ebook_actions AS
     (
    SELECT
       *
       ,downloaded_ebook + printed_ebook + viewed_ebook + bookmarked_ebook + highlighted_ebook + launched_ebook AS total_ebook_actions
    FROM ebook_actions_per_user
    )
    SELECT * FROM total_ebook_actions
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid_merged} ;;
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
    primary_key: yes
  }

  dimension: downloaded_ebook {
    type: number
    sql: ${TABLE}."DOWNLOADED_EBOOK" ;;
  }

  dimension: printed_ebook {
    type: number
    sql: ${TABLE}."PRINTED_EBOOK" ;;
  }

  dimension: viewed_ebook {
    type: number
    sql: ${TABLE}."VIEWED_EBOOK" ;;
  }

  dimension: bookmarked_ebook {
    type: number
    sql: ${TABLE}."BOOKMARKED_EBOOK" ;;
  }

  dimension: highlighted_ebook {
    type: number
    sql: ${TABLE}."HIGHLIGHTED_EBOOK" ;;
  }

  dimension: launched_ebook {
    type: number
    sql: ${TABLE}."LAUNCHED_EBOOK" ;;
  }

  dimension: total_ebook_actions {
    type: number
    sql: ${TABLE}."TOTAL_EBOOK_ACTIONS" ;;
  }

  dimension: total_ebook_actions_tiers {
    type: tier
    sql: ${total_ebook_actions} ;;
    style: integer
    tiers: [10, 50, 100, 200, 300]
  }

  dimension: launched_ebook_tiers {
    type: tier
    sql: ${launched_ebook} ;;
    style: integer
    tiers: [10, 50, 100, 200, 300]
  }



  set: detail {
    fields: [
      user_sso_guid_merged,
      downloaded_ebook,
      printed_ebook,
      viewed_ebook,
      bookmarked_ebook,
      highlighted_ebook,
      launched_ebook,
      total_ebook_actions
    ]
  }
}
