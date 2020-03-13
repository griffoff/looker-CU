# view: first_session_events {
#   derived_table: {
#   sql: SELECT
#           *
#        FROM ZPG.FIRST_SESSION_EVENTS
#       ;;
#       persist_for: "24 hours"
#       }
#
#   dimension: click_number {
#     type: number
#     sql: ${TABLE}."CLICK_NUMBER" ;;
#   }
#
#   dimension: event_action {
#     type: string
#     sql: ${TABLE}."EVENT_ACTION" ;;
#   }
#
#   dimension: event_data {
#     type: string
#     sql: ${TABLE}."EVENT_DATA" ;;
#   }
#
#   dimension: event_type {
#     type: string
#     sql: ${TABLE}."EVENT_TYPE" ;;
#   }
#
#
#
#   dimension: fifth_click {
#     type: string
#     sql: ${TABLE}."FIFTH_CLICK" ;;
#   }
#
#   dimension: fourth_click {
#     type: string
#     sql: ${TABLE}."FOURTH_CLICK" ;;
#   }
#
#   dimension: load_metadata {
#     type: string
#     sql: ${TABLE}."LOAD_METADATA" ;;
#   }
#
#   dimension_group: local {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."LOCAL_TIME" ;;
#   }
#
#   dimension: number_session_clicks {
#     type: number
#     sql: ${TABLE}."NUMBER_SESSION_CLICKS" ;;
#   }
#
#   dimension: second_click {
#     type: string
#     sql: ${TABLE}."SECOND_CLICK" ;;
#   }
#
#   dimension_group: session_end {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."SESSION_END" ;;
#   }
#
#   dimension: session_id {
#     type: number
#     sql: ${TABLE}."SESSION_ID" ;;
#   }
#
#   dimension: session_number {
#     type: number
#     sql: ${TABLE}."SESSION_NUMBER" ;;
#   }
#
#   dimension_group: session_start {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."SESSION_START" ;;
#   }
#
#   dimension: third_click {
#     type: string
#     sql: ${TABLE}."THIRD_CLICK" ;;
#   }
#
#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: [user_sso_guid]
#   }
# }
