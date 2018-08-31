view: raw_subscription_event {
  derived_table: {
    sql: with state AS (
    SELECT
        TO_CHAR(TO_DATE(raw_subscription_event."SUBSCRIPTION_START" ), 'YYYY-MM-DD') AS sub_start_date
        ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time DESC) AS latest_record
        ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time ASC) AS earliest_record
        ,LEAD(subscription_state) over(partition by user_sso_guid order by local_time) as change_in_state
        ,LEAD(subscription_start) over(partition by user_sso_guid order by local_time) as change_in_start_date
        ,*
    FROM Unlimited.Raw_Subscription_event
    )

    SELECT
      state.*
      ,CASE WHEN latest_record = 1 THEN 'yes' ELSE 'no' END AS latest_filter
      ,CASE WHEN earliest_record = 1 THEN 'yes' ELSE 'no' END AS earliest_filter
    FROM state
    LEFT JOIN unlimited.vw_user_blacklist bk
    ON state.user_sso_guid = bk.user_sso_guid
    WHERE bk.user_sso_guid IS NULL
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
    sql: ${TABLE}.latest_filter = 'yes'  ;;
  }

  dimension: earliest_subscription {
    label: "Earliest subcription record"
    description: "filter used to retrive the earliest subscription status for a user"
    type: yesno
    sql: ${TABLE}.earliest_filter = 'yes'  ;;
  }

  dimension: change_in_state {
    label: "Subscription State Change"
    description: "Displays what subscription state a user changed to."
    sql: ${TABLE}.change_in_state ;;
  }

  dimension: change_in_start_date {
    label: "Subscription Start Date Change"
    description: "Displays the date that a user subscription state changed."
    sql: ${TABLE}.change_in_start_date ;;
    type: date
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

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: days_until_expiry {
    description: "The number of days until the subscription will expire"
    type: number
    sql: datediff(day, current_timestamp(), ${subscription_end_raw})  ;;
  }

#   dimension: weeks_since_subscription_start {
#     type: number
#     sql: datediff(week, to_timestamp(${ga_dashboarddata.visitstarttime}), ${subscription_start_date})  ;;
#   }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: count_subscription {
    description: "A count of the unique user guids which represents the number of unique subscriptions"
    label: "# subscriptions"
    type: count_distinct
    sql: ${TABLE}.user_sso_guid ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      user_sso_guid,
      local_time,
      contract_id,
      subscription_state,
      subscription_start_date
    ]
  }

}
