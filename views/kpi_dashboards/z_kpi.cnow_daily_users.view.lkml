# include: "//mongo_sync/*.view"
# include: "//mongo_sync/realtime.*"
# include: "//cube/dim_course.view"
#
# explore: cnow_daily_users {}
#
# view: cnow_daily_users {
#   derived_table: {
#     explore_source: all_take_nodes {
#       column: submission_date { field: take_node.submission_date }
#       column: user_sso_guid { field: all_users.user_sso_guid }
#       column: activity_node_system { field: take_node.activity_node_system }
#       column: course_key { field: olr_courses.course_key }
#       column: take_count { field: take_node.take_count }
#       filters: {
#         field: take_node.activity_node_system
#         value: "cnow"
#       }
#       filters: {
#         field: take_node.submission_date
#         value: "1 years"
#       }
#       filters: {
#         field: dim_filter.is_external
#         value: "Yes"
#       }
#       filters: {
#         field: dim_institution.HED_filter
#         value: "Yes"
#       }
#     }
#   }
#   dimension: submission_date {
#     type: date
#   }
#   dimension: user_sso_guid {
#     label: "LMS User Info User Sso Guid"
#   }
#   dimension: activity_node_system {
#     label: "Take Node Activity Platform"
#   }
#   dimension: course_key {
#     label: "Course / Section Details Course Key"
#   }
#   dimension: take_count {
#     label: "Take Node # Takes"
#     type: number
#   }
# }


# explore: process_test {}

# view: process_test {
#   derived_table: {
#     create_process: {
#       sql_step:
#       CREATE TABLE IF NOT EXISTS looker_scratch.platform_course_date_guid
#       (
#         platform STRING,
#         course_key STRING,
#         event_date DATE,
#         user_sso_guid STRING,
#         event_count INT
#       )
#       ;;
#
#       sql_step:
#           CASE WHEN platform NOT IN ('MindTap', 'WA') THEN 'Other' ELSE platform END AS platform,
#           course_key,
#           event_date,
#           user_sso_guid,
#           SUM(event_count) AS event_count,
#       INSERT INTO looker_scratch.cnow_daily_users
#       SELECT * FROM ${all_events.SQL_TABLE_NAME}
#       ;;
#
#       sql_step:
#       -- inssert (Other, MT, and WA from all_events)
#       INSERT INTO looker_scratch.cnow_daily_users
#       SELECT * FROM ${z_kpi_cnow_daily_users.SQL_TABLE_NAME} LIMIT 100
#       ;;
#
#       sql_step:
#       CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} CLONE looker_scratch.cnow_daily_users
#       ;;
#     }

#     persist_for: "24 hours"
#   }
#
# dimension: sumbission_date {
# }
#
# dimension: users_taken {}
#
# }
