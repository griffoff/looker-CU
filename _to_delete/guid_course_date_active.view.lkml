# # If necessary, uncomment the line below to include explore_source.
# include: "all_sessions.view"
# include: "all_sessions.view"

# # include: "cengage_unlimited.model.lkml"
# explore: guid_course_date_active {
#   #hidden: yes
# }

# view: guid_course_date_active {
#   derived_table: {
#     create_process: {
#       sql_step:
#       CREATE TABLE IF NOT EXISTS looker_scratch.guid_course_date_active
#       (
#         date DATE
#         ,user_sso_guid STRING
#         ,course_key STRING
#         ,productplatform STRING
#         ,event_count INT
#         ,event_duration_total NUMERIC(12, 4)
#         ,latest BOOLEAN
#         ,latest_by_platform BOOLEAN
#         ,latest_by_course BOOLEAN
#         ,number_of_course_use_events INT
#       )
#       ;;
#       sql_step:
#       INSERT INTO looker_scratch.guid_course_date_active
#       SELECT
#           all_events.local_time::DATE
#           ,all_events.user_sso_guid
#           ,all_events.course_key as olr_course_key
#           ,COALESCE(all_events.product_platform, product_info.product_platform) AS platform
#           ,COUNT(*) AS event_count
#           ,SUM(all_events.event_data:event_duration / 3600 / 24) AS event_duration_total
#           ,ROW_NUMBER() OVER (PARTITION BY all_events.user_sso_guid ORDER BY local_time::DATE DESC) = 1 AS latest
#           ,ROW_NUMBER() OVER (PARTITION BY all_events.user_sso_guid, platform ORDER BY all_events.local_time::DATE DESC) = 1 AS latest_by_platform
#           ,ROW_NUMBER() OVER (PARTITION BY all_events.user_sso_guid, dim_course.olr_course_key ORDER BY all_events.local_time::DATE DESC) = 1 AS latest_by_course
#           ,COUNT(CASE WHEN all_events.product_platform NOT IN ('ENROLLMENT', 'PROVISIONED PRODUCT', 'OLR Activations') THEN 1 END) AS number_of_course_use_events
#       FROM ${all_events.SQL_TABLE_NAME} all_events
#       LEFT JOIN ${product_info.SQL_TABLE_NAME} product_info ON all_events.user_products_isbn = product_info.isbn13
#       WHERE all_events.local_time::DATE > (SELECT COALESCE(MAX(date), '2018-08-01') FROM looker_scratch.guid_course_date_active)
#       AND all_events.local_time::DATE < CURRENT_DATE()
#       GROUP BY 1, 2, 3, 4;
#       ;;
#       sql_step:
#         CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
#         CLONE looker_scratch.guid_course_date_active
#       ;;
#     }

#     datagroup_trigger: daily_refresh

#   }



#   dimension: user_sso_guid {
#     label: "User SSO GUID"
#     hidden: no
#   }
#   measure: user_count {
#     type: count_distinct
#     sql: ${user_sso_guid} ;;
#   }

#   dimension: latest {
#     type: yesno
#   }
#   dimension: latest_by_platform {
#     type: yesno
#   }
#   dimension: latest_by_course {
#     type: yesno
#   }
#   dimension: course_key {
#     label: "Course Key"
#   }
#   dimension: productplatform {
#     label: "Product Platform"
#     description: "MindTap, Aplia, CNOW, etc."
#   }
#   dimension: date {
#     label: "Event Date"
#     description: "Components of the events local timestamp"
#     type: date
#   }
#   dimension: event_count {
#     label: "Events # Events"
#     description: "Measure for counting events (drill fields)"
#     type: number
#   }
#   dimension: event_duration_total {
#     label: "Events Total Time Active"
#     value_format: "hh:mm:ss"
#     type: number
#   }

#   measure: average_time_spent_per_student_per_day {
#     type: average
#     sql: ${event_duration_total} ;;
#     value_format: "hh:mm:ss"
#   }

#   measure: number_of_course_use_events {
#     type: sum
#   }
# }
