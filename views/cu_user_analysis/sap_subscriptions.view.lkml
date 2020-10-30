view: sap_subscriptions {
  derived_table: {
    sql:
      select distinct
        ss.*
        , coalesce(su.LINKED_GUID, hu.UID) as merged_guid
      from prod.DATAVAULT.SAT_SUBSCRIPTION_SAP ss
      inner join prod.datavault.hub_user hu on hu.uid = ss.current_guid
      inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
      where ss._latest and ss.SUBSCRIPTION_PLAN_ID <> 'Read-Only'
    ;;
    persist_for: "8 hours"
  }

  dimension: merged_guid {hidden: yes}

  dimension_group: _effective_from {
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
    sql: CAST(${TABLE}."_EFFECTIVE_FROM" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension_group: _effective_to {
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
    sql: CAST(${TABLE}."_EFFECTIVE_TO" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: _latest {
    type: yesno
    sql: ${TABLE}."_LATEST" ;;
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

  dimension_group: available_until {
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
    sql: CAST(${TABLE}."AVAILABLE_UNTIL" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: cancellation_reason {
    type: string
    sql: ${TABLE}."CANCELLATION_REASON" ;;
  }

  dimension_group: cancelled {
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
    sql: CAST(${TABLE}."CANCELLED_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
    hidden: yes
  }

  dimension: current_guid {
    type: string
    sql: ${TABLE}."CURRENT_GUID" ;;
    hidden: yes
  }

  dimension: hash_diff {
    type: string
    sql: ${TABLE}."HASH_DIFF" ;;
    hidden: yes
  }

  dimension: hub_subscription_key {
    type: string
    sql: ${TABLE}."HUB_SUBSCRIPTION_KEY" ;;
    hidden: yes
    primary_key: yes
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
    hidden: yes
  }

  dimension: payment_source_guid {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_GUID" ;;
    hidden: yes
  }

  dimension: payment_source_id {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_ID" ;;
    hidden: yes
  }

  dimension: payment_source_line {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_LINE" ;;
    hidden: yes
  }

  dimension: payment_source_type {
    type: string
    sql: ${TABLE}."PAYMENT_SOURCE_TYPE" ;;
    hidden: yes
  }

  dimension_group: placed {
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
    sql: CAST(${TABLE}."PLACED_TIME" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension_group: rsrc_timestamp {
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
    sql: CAST(${TABLE}."RSRC_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: src_environment {
    type: string
    sql: ${TABLE}."SRC_ENVIRONMENT" ;;
    hidden: yes
  }

  dimension: src_platform {
    type: string
    sql: ${TABLE}."SRC_PLATFORM" ;;
    hidden: yes
  }

  dimension: subscription_duration {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
    hidden: yes
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
    sql: CAST(${TABLE}."SUBSCRIPTION_END" AS TIMESTAMP_NTZ) ;;
  }

  dimension: subscription_plan_id {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_PLAN_ID" ;;
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
    sql: CAST(${TABLE}."SUBSCRIPTION_START" AS TIMESTAMP_NTZ) ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: []
    hidden: yes
  }
}
