view: raw_subscription_event {
  derived_table: {
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

  sql:
    WITH subscription_event AS (
        SELECT
          *
          ,LEAD(subscription_state) over (partition by user_sso_guid order by local_time) = 'cancelled' as cancelled
        FROM unlimited.raw_Subscription_event e
        WHERE UPPER(user_environment) = 'PRODUCTION'
      )
      ,state AS (
      SELECT
          e.*
          ,COALESCE(m.primary_guid, e.user_sso_guid) AS merged_guid
          ,REPLACE(INITCAP(subscription_state), '_', ' ') || CASE WHEN subscription_end < CURRENT_TIMESTAMP() THEN ' (Expired)' ELSE '' END as subscription_status
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
      LEFT JOIN unlimited.sso_merged_guids m on e.user_sso_guid = m.shadow_guid
    )
    SELECT state.*
    FROM state
    WHERE user_sso_guid NOT IN (SELECT user_sso_guid FROM unlimited.excluded_users)
    AND  merged_guid NOT IN (SELECT user_sso_guid FROM unlimited.excluded_users)
    ;;

  }

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
    hidden: yes
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
    sql: ${TABLE}.first_state ;;
  }

  dimension_group: first_start {
    group_label: "First Start Date"
    description: "Displays the start time of the first subscription status record"
    sql: ${TABLE}.first_date ;;
    type: time
    timeframes: [raw, date, month]
  }

  dimension: current_status {
    label: "Current Status"
    description: "Displays the latest subscription status a user has."
    sql: ${TABLE}.first_state ;;
  }

  dimension_group: current_start {
    group_label: "Current Start Date"
    description: "Displays the start time of the latest subscription status record"
    sql: ${TABLE}.first_date ;;
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
    sql: ${TABLE}.first_date ;;
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
