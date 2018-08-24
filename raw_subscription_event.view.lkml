view: raw_subscription_event {
  derived_table: {
    sql: with state as (
    select
    TO_CHAR(TO_DATE(raw_subscription_event."SUBSCRIPTION_START" ), 'YYYY-MM-DD') as sub_start_date
    ,rank () over (partition by user_sso_guid order by LOCAL_Time desc) as latest_record
    ,* from Unlimited.Raw_Subscription_event
    ) select * from state where latest_record = 1
    and state.user_sso_guid not in (select user_sso_guid from unlimited.vw_user_blacklist);;
  }

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
    hidden: yes
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
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension_group: subscription_end {
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
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: days_until_expiry {
    type: number
    sql: datediff(day, current_timestamp(), ${subscription_end_raw})  ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: count_subscription {
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
