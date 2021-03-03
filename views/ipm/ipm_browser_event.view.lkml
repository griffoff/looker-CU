include: "/views/ipm/ipm.campaign_to_outcome.view"

explore: ipm_browser_event {hidden:yes}

view: ipm_browser_event {
  sql_table_name: IPM.PROD.IPM_BROWSER_EVENT ;;
  view_label: "IPM Events"
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

  dimension: user_platform {
    type: string
    sql: ${TABLE}."USER_PLATFORM";;
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
    sql: convert_timezone('UTC', ${TABLE}."EVENT_TIME") ;;
    group_label: "Event Time (UTC)"
    label: "Event (UTC)"
    description: "Components of the events timestamp converted to UTC"

  }

  dimension_group: local_est {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week, hour_of_day]
    sql: convert_timezone('America/New_York', ${TABLE}."EVENT_TIME") ;;
    group_label: "Event Time (EST)"
    label: "Event (EST)"
    description: "Components of the events timestamp converted to EST"
  }

  dimension_group: raw_time {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week, hour_of_day]
    sql:  ${TABLE}."EVENT_TIME" ;;
    group_label: "Raw Time"
    label: "Event raw"
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
    label: "# Successful outcomes"
    description: ""
    type: count_distinct
    sql: DECODE(${event_action_raw}, 'CONVERTED', ${user_sso_guid})  ;;
  }

  measure: click_through_rate {
    group_label: "Rates"
    label: "% Click Through"
    description: "What proprtion of those to whom the message was delivered actually clicked it"
    type: number
    sql: ${clicked_count} / NULLIF(${displayed_count}, 0) ;;
    value_format_name: percent_2
  }

  measure: conversion_rate_from_click {
    group_label: "Rates"
    label: "% Successful outcome from click"
    description: "What proportion of those who opened the notification (Clicked) exhibited the desired action?"
    type: number
    sql: ${converted_count} / NULLIF(${clicked_count}, 0) ;;
    value_format_name: percent_2
  }

  measure: conversion_rate_from_seen {
    group_label: "Rates"
    label: "% Successful outcome from seen"
    description: "What proportion of those who saw (dismissed or clicked) the notification (Displayed) exhibited the desired action?"
    type: number
    sql: ${converted_count} / NULLIF(${clicked_or_dismissed}, 0) ;;
    value_format_name: percent_2
  }

  measure: conversion_rate_from_impression{
    group_label: "Rates"
    label: "% Successful outcome from impression"
    description: "What proportion of those to whom the message was delivered (Displayed) exhibited the desired action?"
    type: number
    sql: ${converted_count} / NULLIF(${displayed_count}, 0) ;;
    value_format_name: percent_2
  }
}
