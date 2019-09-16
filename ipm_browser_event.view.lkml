view: ipm_browser_event_and_outcome {
  view_label: "IPM Events"
  extends: [ipm_browser_event]

  derived_table: {
    sql:
      SELECT message_id, event_action, event_category, event_time, user_sso_guid
      FROM IPM.PROD.IPM_BROWSER_EVENT
      UNION ALL
      SELECT message_id, 'CONVERTED', COALESCE(event_name, 'UNKNOWN EVENT'), first_event_time, user_sso_guid
      FROM ${ipm_campaign_to_outcome.SQL_TABLE_NAME}
      ;;

      persist_for: "60 minute"
  }
}
view: ipm_browser_event {
  sql_table_name: IPM.PROD.IPM_BROWSER_EVENT ;;

  dimension: message_id {
    type: string
    sql: ${TABLE}."MESSAGE_ID" ;;
  }

  dimension: event_action_sort {
    hidden: yes
    type: number
    sql:  DECODE(${event_action_raw}, 'DISPLAYED', 0, 'DISMISSED', 10, 'DISCARDED', 20, 'CLICKED', 30, 'CONVERTED', 90, 99) ;;
  }

  dimension: event_action_raw {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
    order_by_field: event_action_sort
    hidden: yes
  }

  dimension: event_action {
    type: string
    sql: ${event_action_raw};;
    order_by_field: event_action_sort
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
  }

  dimension_group: event {
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
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: prim_key {
    sql: CONCAT(${event_time},${user_sso_guid}) ;;
    primary_key: yes
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    label: "# Users"
    type: count_distinct
    sql: ${user_sso_guid} ;;
    drill_fields: [user_sso_guid]
  }

  measure: displayed_count {
    group_label: "Counts"
    label: "# Impressions"
    description: "# Displayed"
    type: count_distinct
    sql: DECODE(${event_action_raw}, 'DISPLAYED', ${user_sso_guid})  ;;
  }

  measure: clicked_count {
    group_label: "Counts"
    label: "# Clicks"
    type: count_distinct
    sql: DECODE(${event_action_raw}, 'CLICKED', ${user_sso_guid})  ;;
  }

  measure: dismissed_count {
    group_label: "Counts"
    label: "# Dismissals"
    type: count_distinct
    sql: DECODE(${event_action_raw}, 'DISMISSED', ${user_sso_guid})  ;;
  }

  measure: clicked_or_dismissed {
    group_label: "Counts"
    description: "# Dismissed or Clicked"
    label: "# Seen"
    type: count_distinct
    sql: CASE WHEN ${event_action_raw} IN ('DISMISSED', 'CLICKED') THEN ${user_sso_guid} END  ;;
  }

  measure: discarded_count {
    group_label: "Counts"
    label: "# Discards"
    type: count_distinct
    sql: DECODE(${event_action_raw}, 'DISCARDED', ${user_sso_guid})  ;;
  }

  measure: converted_count {
    group_label: "Counts"
    label: "# Conversions"
    type: count_distinct
    sql: DECODE(${event_action_raw}, 'CONVERTED', ${user_sso_guid})  ;;
  }

  measure: click_through_rate {
    group_label: "Rates"
    label: "Click Through"
    type: number
    sql: ${clicked_count} / NULLIF(${displayed_count}, 0) ;;
    value_format_name: percent_2
  }

  measure: conversion_rate_from_click {
    group_label: "Rates"
    label: "Conversion from Click"
    type: number
    sql: ${converted_count} / NULLIF(${clicked_count}, 0) ;;
    value_format_name: percent_2
  }

  measure: conversion_rate_from_seen {
    group_label: "Rates"
    label: "Conversion from Seen"
    type: number
    sql: ${converted_count} / NULLIF(${clicked_or_dismissed}, 0) ;;
    value_format_name: percent_2
  }

  measure: conversion_rate_from_impression{
    group_label: "Rates"
    label: "Conversion from impression"
    type: number
    sql: ${converted_count} / NULLIF(${displayed_count}, 0) ;;
    value_format_name: percent_2
  }
}
