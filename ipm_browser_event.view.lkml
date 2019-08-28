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
    sql:  DECODE(${event_action}, 'DISPLAYED', 0, 'DISMISSED', 10, 'DISCARDED', 20, 'CLICKED', 30, 'CONVERTED', 90, 99) ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
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
}
