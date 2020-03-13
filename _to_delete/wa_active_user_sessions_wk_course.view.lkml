# # explore:  wa_active_user_sessions_wk_course {}
#
# view: wa_active_user_sessions_wk_course {
#   derived_table: {
#     sql: SELECT * FROM dev.zkc.wa_active_users_sessions_by_course_week LIMIT 100
#       ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }
#
#   measure: users {
#     type: sum
#     sql: ${TABLE}."UNIQUE_USERS" ;;
#   }
#
#   measure: sessions {
#     type: sum
#     sql: ${TABLE}."UNIQUE_SESSIONS" ;;
#   }
#
#
#   dimension: event_date {
#     type: date
#     sql: ${TABLE}."EVENT_DATE" ;;
#   }
#
#   dimension: course_start_date {
#     type: date
#     sql: ${TABLE}."COURSE_START_DATE" ;;
#   }
#
#   dimension: relative_day_in_course {
#     type: number
#     sql: ${TABLE}."RELATIVE_DAY_IN_COURSE" ;;
#   }
#
#   dimension: unique_users {
#     type: number
#     sql: ${TABLE}."UNIQUE_USERS" ;;
#   }
#
#   dimension: unique_sessions {
#     type: number
#     sql: ${TABLE}."UNIQUE_SESSIONS" ;;
#   }
#
#   set: detail {
#     fields: [event_date, course_start_date, relative_day_in_course, unique_users, unique_sessions]
#   }
# }
