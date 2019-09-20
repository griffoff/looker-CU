view: raw_subscription_event {
  derived_table: {
    sql:
     WITH
  distinct_primary AS
  (
      SELECT DISTINCT primary_guid FROM prod.unlimited.vw_partner_to_primary_user_guid
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
          ,CASE WHEN SUBSCRIPTION_STATE = 'provisional_locker' THEN SUBSCRIPTION_END ELSE SUBSCRIPTION_START END AS SUBSCRIPTION_START
          ,CASE WHEN SUBSCRIPTION_STATE = 'provisional_locker' THEN DATEADD(YEAR, 1, SUBSCRIPTION_END) ELSE SUBSCRIPTION_END END AS SUBSCRIPTION_END
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
          ,REPLACE(INITCAP(subscription_state), '_', ' ') || CASE WHEN subscription_state not in ('cancelled', 'banned','read_only', 'no_access', 'provisional_locker') AND subscription_end < CURRENT_TIMESTAMP() THEN ' (Expired)' ELSE '' END as subscription_status
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
          ,COALESCE(LEAST(next_event_time, subscription_end), subscription_end) AS effective_to
      FROM raw_subscription_event_merged_clean e
    ;;

#     sql:
#
#     WITH
#       distinct_primary AS
#       (
#           SELECT DISTINCT primary_guid FROM prod.unlimited.vw_partner_to_primary_user_guid
#       )
#       ,raw_subscription_event_merged AS
#       (
#           SELECT
#               COALESCE(m.primary_guid, r.user_sso_guid) AS user_sso_guid_merged
#               ,CASE WHEN m.primary_guid IS NOT NULL OR m2.primary_guid IS NOT NULL THEN 1 ELSE 0 END AS lms_user
#               ,r.*
#           FROM unlimited.raw_subscription_event r
#           LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
#               ON r.user_sso_guid = m.partner_guid
#           LEFT JOIN distinct_primary m2
#               ON  r.user_sso_guid = m2.primary_guid
#           WHERE user_sso_guid_merged NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users)
#       )
#       ,raw_subscription_event_merged_next_events AS
#       (
#       SELECT
#            user_sso_guid_merged
#           ,user_sso_guid
#           ,lms_user
#           ,local_time
#           ,_ldts
#           ,_hash
#           ,_rsrc
#           ,contract_id
#           ,platform_environment
#           ,product_platform
#           ,user_environment
#           ,message_type
#           ,subscription_state
#           ,subscription_start
#           ,subscription_end
#           ,LEAD(subscription_state, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_state_2
#           ,LEAD(subscription_start, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_start_2
#           ,LEAD(subscription_end, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_end_2
#           ,LEAD(local_time, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS local_time_2
#           ,LEAD(_ldts, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS ldts_2
#           ,LEAD(subscription_state, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_state_3
#           ,LEAD(subscription_start, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_start_3
#           ,LEAD(subscription_end, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS subscription_end_3
#           ,LEAD(local_time, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS local_time_3
#           ,LEAD(_ldts, 2) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_state) AS ldts_3
#           ,COUNT(DISTINCT subscription_state) OVER (PARTITION BY user_sso_guid_merged) AS number_of_subscription_states
#       FROM raw_subscription_event_merged
#       )
#       ,raw_subscription_event_merged_erroneous_removed AS
#       (
#       SELECT
#           user_sso_guid_merged AS merged_guid
#           ,user_sso_guid
#           ,MAX(lms_user) OVER (PARTITION BY user_sso_guid_merged) AS lms_user_status
#           ,local_time
#           ,_ldts
#           ,_hash
#           ,_rsrc
#           ,contract_id
#           ,platform_environment
#           ,product_platform
#           ,user_environment
#           ,message_type
#           ,subscription_state
#           ,subscription_start
#           ,subscription_end
#           ,subscription_start AS effective_from
#           ,LEAD(local_time, 1) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time, subscription_start) AS next_event_time
#           ,COALESCE(LEAST(next_event_time, subscription_end), subscription_end) AS effective_to
#           ,local_time_2
#           ,ldts_2
#           ,subscription_state_2
#           ,subscription_start_2
#           ,subscription_end_2
#           ,local_time_3
#           ,ldts_3
#           ,subscription_state_3
#           ,subscription_start_3
#           ,subscription_end_3
#           ,LAST_VALUE(subscription_state) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time ASC) AS subscription_state_current
#           ,LAST_VALUE(subscription_start) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time ASC) AS subscription_start_current
#           ,LAST_VALUE(subscription_end) OVER (PARTITION BY user_sso_guid_merged ORDER BY local_time ASC) AS subscription_end_current
#           ,DATEDIFF('month', subscription_start, subscription_end ) AS subscription_term_length
#       FROM raw_subscription_event_merged_next_events
#       )
#        SELECT
#           e.*
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
#       FROM raw_subscription_event_merged_erroneous_removed e
#     ;;


#   sql:
#     with
#     subscription_event AS
#     (
#       SELECT
#         *
#         ,user_sso_guid_merged as merged_guid
#         ,LEAD(subscription_state) over (partition by user_sso_guid order by local_time) = 'cancelled' as cancelled
#         FROM  /* prod.unlimited.raw_subscription_event */ prod.cu_user_analysis.subscription_event_merged
#       --FROM raw_subscription_event_merged_erroneous_removed e
#       WHERE UPPER(user_environment) = 'PRODUCTION'
#     )
#     SELECT
#           e.*
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
#       FROM subscription_event e
#       --LEFT JOIN guid_map m ON e.user_sso_guid = m.partner_guid
#       ;;

      persist_for: "60 minutes"
  }

  dimension: effective_to {
    type: date
    label: "Effective to date"
    description: "The day this status ended. e.g. different from subscription end date when a subscription gets cancelled or when a trial state upgrades to ful access early"
    hidden: no
    sql: ${TABLE}."effective_to" ;;
  }

  dimension: effective_from {
    type: date
    label: "Subscription effective from date"
    description: "Start date of this status"
    hidden: no
    sql: ${TABLE}."effective_from" ;;
  }

  dimension_group: time_in_current_status {
    view_label: "Learner Profile - Live Subscription Status"
    type: duration
    intervals: [day, week, month]
    sql_start: ${effective_from} ;;
    sql_end: ${effective_to} ;;
    label: "Time in current status"
  }

#   dimension_group: time_in_current_status {
#     view_label: "Learner Profile - Live Subscription Status"
#     type: duration
#     intervals: [day, week, month]
#     sql_start: ${raw_subscription_event.effective_from} ;;
#     sql_end: ${raw_subscription_event.effective_to} ;;
#     label: "Time in current status"
#   }

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
    hidden: yes
  }

  dimension: original_guid {
    description: "SSO Guid captured in event.  This could be a shadow guid or primary guid"
    alias: [partner_guid]
    type: string
    hidden: no
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    type: string
    sql: ${merged_guid} ;;
    description: "Primary SSO User Identifier (Merged)"
  }

  # source of raw_subscription_event is SSO - all guids are good
  dimension: merged_guid {
    type: string
    description: "Primary SSO GUID (After shadow guids have been identified and merged)"
    hidden: no
  }


  dimension: lms_user {
    type: yesno
    sql: ${TABLE}.lms_user_status = 1;;
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
    label: "# New Subscriptions"
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
