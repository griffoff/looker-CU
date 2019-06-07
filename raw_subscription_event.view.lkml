view: raw_subscription_event {
  derived_table: {
    sql:
    WITH
    primary_map AS
    (
      SELECT
        *
        ,LEAD(event_time) OVER (PARTITION BY primary_guid ORDER BY event_time ASC) IS NULL AS latest
      FROM prod.unlimited.VW_PARTNER_TO_PRIMARY_USER_GUID
    )
    ,guid_map AS
    (
        SELECT * FROM primary_map WHERE latest
    )
    ,distinct_primary AS
    (
        SELECT DISTINCT primary_guid, partner_guid FROM guid_map
    )
    ,raw_subscription_event_merged AS
    (
        SELECT
            COALESCE(m.primary_guid, r.user_sso_guid) AS merged_guid
            ,CASE WHEN m.primary_guid IS NOT NULL OR m2.primary_guid IS NOT NULL THEN 1 ELSE 0 END AS lms_user
--            ,CASE WHEN m.partner_guid IS NOT NULL OR m2.partner_guid IS NOT NULL THEN 'Yes' ELSE 'No' END AS lms_user
            ,COALESCE(m.partner_guid, m2.partner_guid) AS partner_guid
            ,r.*
        FROM unlimited.raw_subscription_event r
        LEFT JOIN guid_map m
            ON r.user_sso_guid = m.partner_guid
        LEFT JOIN distinct_primary m2
            ON  r.user_sso_guid = m2.primary_guid
        WHERE merged_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users)
    )
    ,raw_subscription_event_merged_next_events AS
    (
    SELECT
         merged_guid
        ,user_sso_guid
        ,partner_guid
        ,lms_user
        ,local_time
        ,_ldts
        ,_hash
        ,_rsrc
        ,contract_id
        ,platform_environment
        ,product_platform
        ,user_environment
        ,message_type
        ,subscription_state
        ,subscription_start
        ,subscription_end
        ,LEAD(subscription_state, 1) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS subscription_state_2
        ,LEAD(subscription_start, 1) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS subscription_start_2
        ,LEAD(subscription_end, 1) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS subscription_end_2
        ,LEAD(local_time, 1) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS local_time_2
        ,LEAD(_ldts, 1) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS ldts_2
        ,LEAD(subscription_state, 2) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS subscription_state_3
        ,LEAD(subscription_start, 2) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS subscription_start_3
        ,LEAD(subscription_end, 2) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS subscription_end_3
        ,LEAD(local_time, 2) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS local_time_3
        ,LEAD(_ldts, 2) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_state) AS ldts_3
        ,COUNT(DISTINCT subscription_state) OVER (PARTITION BY merged_guid) AS number_of_subscription_states
    FROM raw_subscription_event_merged
    )
    ,raw_subscription_event_merged_erroneous_removed AS
    (
    SELECT
        merged_guid
        ,user_sso_guid
        ,partner_guid
        ,MAX(lms_user) OVER (PARTITION BY merged_guid) AS lms_user
        ,local_time
        ,_ldts
        ,_hash
        ,_rsrc
        ,contract_id
        ,platform_environment
        ,product_platform
        ,user_environment
        ,message_type
        ,subscription_state
        ,subscription_start
        ,subscription_end
        ,subscription_start AS effective_from
        ,LEAD(local_time, 1) OVER (PARTITION BY merged_guid ORDER BY local_time, subscription_start) AS next_event_time
        ,COALESCE(LEAST(next_event_time, subscription_end), subscription_end) AS effective_to
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
        ,LAST_VALUE(subscription_state) OVER (PARTITION BY merged_guid ORDER BY local_time ASC) AS subscription_state_current
        ,LAST_VALUE(subscription_start) OVER (PARTITION BY merged_guid ORDER BY local_time ASC) AS subscription_start_current
        ,LAST_VALUE(subscription_end) OVER (PARTITION BY merged_guid ORDER BY local_time ASC) AS subscription_end_current
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
            AND user_sso_guid <> merged_guid
            AND ldts_2 = ldts_3)
    AND NOT (subscription_state = 'cancelled'
            AND subscription_state_2 = 'full_access'
            AND user_sso_guid <> merged_guid
            AND _ldts = ldts_2)
    )
    ,subscription_event AS
    (
      SELECT
        *
        ,LEAD(subscription_state) over (partition by user_sso_guid order by local_time) = 'cancelled' as cancelled
      FROM raw_subscription_event_merged_erroneous_removed e
      WHERE UPPER(user_environment) = 'PRODUCTION'
    )
    SELECT
          e.*
          ,REPLACE(INITCAP(subscription_state), '_', ' ') || CASE WHEN subscription_state not in ('cancelled', 'banned','read_only', 'no_access', 'provisional_locker') AND subscription_end < CURRENT_TIMESTAMP() THEN ' (Expired)' ELSE '' END as subscription_status
          ,FIRST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as first_status
          ,FIRST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as first_start
          ,LAST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as current_status
          ,LAST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as current_start
          ,LAST_VALUE(subscription_end) over(partition by merged_guid order by local_time) as current_end
          ,LAG(subscription_status) over(partition by merged_guid order by local_time) as prior_status
          ,LAG(subscription_start) over(partition by merged_guid order by local_time) as prior_start
          ,LAG(subscription_end) over(partition by merged_guid order by local_time) as prior_end
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
      FROM subscription_event e
      LEFT JOIN guid_map m
        ON e.user_sso_guid = m.partner_guid
      ;;
#    sql:
#    with state AS (
#     SELECT
#         TO_CHAR(TO_DATE(raw_subscription_event."SUBSCRIPTION_START" ), 'YYYY-MM-DD') AS sub_start_date
#         ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time DESC) AS latest_record
#         ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time ASC) AS earliest_record
#         ,LEAD(subscription_state) over(partition by user_sso_guid order by local_time) as next_state
#         ,LEAD(subscription_start) over(partition by user_sso_guid order by local_time) as next_start_date
#         ,*
#     FROM Unlimited.Raw_Subscription_event
#     )
#     SELECT
#       state.*
#       ,CASE WHEN latest_record = 1 THEN 'yes' ELSE 'no' END AS latest_filter
#       ,CASE WHEN earliest_record = 1 THEN 'yes' ELSE 'no' END AS earliest_filter
#     FROM state
#     LEFT JOIN unlimited.excluded_users bk
#     ON state.user_sso_guid = bk.user_sso_guid
#     WHERE bk.user_sso_guid IS NULL
#     ;;

#   sql:
#     WITH subscription_event AS (
#         SELECT
#           *
#           ,LEAD(subscription_state) over (partition by user_sso_guid order by local_time) = 'cancelled' as cancelled
#         FROM prod.unlimited.raw_Subscription_event e
#         WHERE UPPER(user_environment) = 'PRODUCTION'
#       ) --select * from subscription_event where user_sso_guid like '293269ae1817be40:-63ee92c7:1657820b8da:-38f3';
#       ,prim_map AS(
#         SELECT *,LEAD(event_time) OVER (PARTITION BY primary_guid ORDER BY event_time ASC) IS NULL AS latest from prod.unlimited.VW_PARTNER_TO_PRIMARY_USER_GUID
#       )
#       ,guid_mapping AS(
#         Select * from prim_map where latest
#       )
#       ,state AS (
#       SELECT
#           e.*
#           ,COALESCE(m.primary_guid, e.user_sso_guid) AS merged_guid
#           ,REPLACE(INITCAP(subscription_state), '_', ' ') || CASE WHEN subscription_state not in ('cancelled', 'banned','read_only', 'no_access', 'provisional_locker') AND subscription_end < CURRENT_TIMESTAMP() THEN ' (Expired)' ELSE '' END as subscription_status
#           ,FIRST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as first_status
#           ,FIRST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as first_start
#           ,LAST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as current_status
#           ,LAST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as current_start
#           ,LAST_VALUE(subscription_end) over(partition by merged_guid order by local_time) as current_end
#           ,LAG(subscription_status) over(partition by merged_guid order by local_time) as prior_status
#           ,LAG(subscription_start) over(partition by merged_guid order by local_time) as prior_start
#           ,LAG(subscription_end) over(partition by merged_guid order by local_time) as prior_end
#           ,MAX(CASE
#                 WHEN subscription_state = 'full_access'
#                 /*    AND NOT cancelled  */
#                 THEN subscription_start
#                 END) over(partition by merged_guid order by local_time rows between unbounded preceding and 1 preceding) as previous_full_access_start
#           ,MAX(CASE
#                 WHEN subscription_state = 'full_access'
#                 /*    AND NOT cancelled  */
#                 THEN subscription_end
#                 END) over(partition by merged_guid order by local_time rows between unbounded preceding and 1 preceding) as previous_full_access_end
#           ,LEAD(subscription_status) over(partition by merged_guid order by local_time) as next_status
#           ,LEAD(subscription_start) over(partition by merged_guid order by local_time) as next_start
#           ,subscription_start < current_timestamp() AND subscription_end > current_timestamp() as active
#           ,MAX(local_time) over(partition by merged_guid) as latest_update
#           ,next_status IS NULL as latest
#           ,prior_status IS NULL as earliest
#           ,m.partner_guid as partner1
#       FROM subscription_event e
#       LEFT JOIN guid_mapping m on e.user_sso_guid = m.partner_guid
#     ), states_merged2 as(
#     Select
#       ss.*
#       ,COALESCE(ss.partner1,m2.partner_guid) as partner_guid
#       from state ss
#       LEFT JOIN guid_mapping m2
#               ON ss.user_sso_guid = m2.primary_guid
#     )
#
#  --   Select partner_guid as part,merged_guid as primguid, * from states_merged2 where merged_guid ilike '35e773452fcd4f2d:a7d88bd:1613d8d2f1c:7e2c';
#
#     SELECT states_merged2.*,
#       CASE WHEN states_merged2.partner_guid IS NOT NULL THEN 'yes' ELSE 'no' END AS lms_user
#     FROM states_merged2
#     WHERE user_sso_guid NOT IN (SELECT user_sso_guid FROM unlimited.excluded_users)
#     AND  merged_guid NOT IN (SELECT user_sso_guid FROM unlimited.excluded_users)
#     ;;

  }

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
    hidden: yes
  }

  dimension: partner_guid {
    type: string
    sql: ${TABLE}.partner_guid;;
    hidden: no
  }

  dimension: lms_user {
    type: yesno
    sql: ${TABLE}.lms_user = 1;;
    description: "This flag is yes if a user has ever done a subscription event from a gateway account (from a shadow or gateway guid)"

  }

  dimension: latest_subscription {
    label: "Current subscription record"
    description: "filter used to retrive the latest subscription status for a user"
    type: yesno
    sql: ${TABLE}.latest  ;;
  }

  dimension: earliest_subscription {
    label: "Earliest subcription record"
    description: "filter used to retrive the earliest subscription status for a user"
    type: yesno
    sql: ${TABLE}.earliest  ;;
  }

  dimension: active {
    type: yesno
    label: "Subscription State Active"
    description: "Whether the subscription state is active (subscription end is in the future)
    Use this as a filter to only include records that represet a user's current status
    n.b. This applies to any subscription state (trial, cancelled, etc.) It DOES NOT reflect whether a subscription is a Full Access subscription or not."
  }

  dimension: next_status {
    label: "Next Status"
    description: "Displays what subscription status a user changed to."
    sql: ${TABLE}.next_state ;;
    alias: [change_in_state]
  }

  dimension_group: next_start {
    group_label: "Next Status Start Date"
    description: "Displays the start time of the next subscription status record"
    sql: ${TABLE}.next_start_date ;;
    type: time
    timeframes: [raw, date, month]
    alias: [change_in_start]
  }

  dimension: first_status {
    label: "First Status"
    description: "Displays the first subscription status a user had."
    sql: ${TABLE}.first_status ;;
  }

  dimension_group: first_start {
    group_label: "First Start Date"
    description: "Displays the start time of the first subscription status record"
    sql: ${TABLE}.first_start ;;
    type: time
    timeframes: [raw, date, month]
  }

  dimension: current_status {
    label: "Current Status"
    description: "Displays the latest subscription status a user has."
    sql: ${TABLE}.current_status ;;
  }

  dimension_group: current_start {
    group_label: "Current Start Date"
    description: "Displays the start time of the latest subscription status record"
    type: time
    timeframes: [raw, date, month]
  }

  dimension_group: latest_update {
    description: "Displays the last time of an event related to this user"
    sql: ${TABLE}.latest_date ;;
    type: time
    timeframes: [raw, date, month]
  }

  dimension_group: current_end {
    group_label: "Current End Date"
    description: "Displays the end time of the latest subscription status record"
    type: time
    timeframes: [raw, date, month]
  }

  dimension_group: _ldts {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."_LDTS" ;;
    hidden: yes
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden: yes
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  dimension_group: local {
    group_label: "Time of Event"
    description: "The local time at which the subscription event occurred"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
    hidden: yes
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
    hidden: yes
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
    hidden: yes
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
    hidden: yes
  }

  dimension_group: subscription_end {
    description: "The date at which the current subscription will end"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SUBSCRIPTION_END" ;;
  }

  dimension_group: subscription_start {
    description: "The date at which the current subscription started"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SUBSCRIPTION_START" ;;
  }

  dimension: subscription_state {
    description: "The subscription state"
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE";;
  }

  dimension: previous_full_access_valid {
    sql: ${TABLE}.previous_full_access_end  < ${subscription_end_raw}  ;;

  }

  dimension_group: previous_full_access_start {
    #label: "Previous Full Access End"
    description: "The date on which the preceding full access subscription started"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CASE WHEN ${previous_full_access_valid} THEN ${TABLE}.previous_full_access_start END;;
  }


  dimension_group: previous_full_access_end {
    #label: "Previous Full Access End"
    description: "The date on which the preceding full access subscription ended"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CASE WHEN ${previous_full_access_valid} THEN ${TABLE}.previous_full_access_end END;;
  }


  dimension: subscription_status {
    description: "Friendlier subscription state description"
    type: string
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
    hidden: yes
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    description: "Primary SSO User Identifier"
  }

  # source of raw_subscription_event is SSO - all guids are good
  dimension: merged_guid {
    type: string
    description: "Primary SSO GUID (After shadow guids have been identified and merged)"
    hidden: yes
  }

  dimension: days_until_expiry {
    description: "The number of days until the subscription will expire"
    type: number
    sql: CASE WHEN current_timestamp() < ${subscription_end_raw}
            THEN datediff(day, current_timestamp(), ${subscription_end_raw})
            END ;;
  }

  dimension_group: time_until_expiry {
    label: "Until Expiry"
    group_label: "Length of Time Until Expiry"
    type: duration
    intervals: [day, week, month]
    description: "The length of time until the subscription will expire"
    sql_start: current_timestamp() ;;
    sql_end: CASE WHEN ${active}
            THEN ${subscription_end_raw}
            END ;;
  }

  dimension_group: time_active {
    label: "Active"
    group_label: "Length of Time Active"
    type: duration
    intervals: [day, week, month]
    description: "The length of time the subscription has been active"
    sql_start: CASE WHEN ${active}
            THEN ${subscription_start_raw}
            END ;;
    sql_end: current_timestamp() ;;
  }

#   measure: count {
#     type: count
#     drill_fields: []
#   }

  measure: count_subscription {
    description: "A count of the unique user guids which represents the number of unique subscriptions"
    label: "# Subscriptions"
    type: count_distinct
    sql: ${TABLE}.user_sso_guid ;;
    drill_fields: [detail*]
  }

  # source of raw_subscription_event is SSO - all guids are good
  measure: count_subscription_merged {
    description: "A count of the unique user guids which represents the number of unique subscriptions"
    label: "# Subscriptions (after merge)"
    type: count_distinct
    sql: ${TABLE}.merged_guid ;;
    drill_fields: [detail*]
    hidden: yes
  }

  measure: count_subscription_state{
    label: "# Subscription States"
    type: count_distinct
    sql: ${TABLE}.subscription_state ;;
    hidden: yes
  }

  set: detail {
    fields: [
      user_sso_guid,
      local_time,
      contract_id,
      subscription_state,
      subscription_start_date,
      subscription_end_date
    ]
  }

}
