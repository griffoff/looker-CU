# include: "//mongo_sync/take_node.view"
# include: "//mongo_sync/datagroups.lkml"

# explore: platform_course_date_guid {}

# view: platform_course_date_guid {
#   derived_table: {
#     sql: SELECT
#         'all take nodes' AS source
#         ,case
#           when array_size(split(activity_node_uri, ':')) = 1 then 'UNKNOWN'
#           else split_part(activity_node_uri, ':', 1)::string
#           end AS activity_platform
#           ,course_key
#           ,submission_date
#           ,user_identifier
#           ,COUNT(*)
#       FROM ${take_node.SQL_TABLE_NAME}
#       WHERE submission_date > '2018-08-01' AND submission_date <= CURRENT_DATE()
#       GROUP BY 1, 2, 3, 4, 5
#       UNION
#       SELECT
#           'all events' AS source
#           ,all_events.product_platform
#           ,dim_course.olr_course_key
#           ,all_events.local_time::DATE
#           ,all_events.user_sso_guid
#           ,COUNT(*) AS event_count
#       FROM ${all_events.SQL_TABLE_NAME} all_events
#       LEFT JOIN ${dim_course.SQL_TABLE_NAME} AS dim_course ON all_events.event_data:course_key = dim_course.olr_course_key
#       LEFT JOIN ${dim_productplatform.SQL_TABLE_NAME}  AS dim_productplatform ON dim_course.PRODUCTPLATFORMID = dim_productplatform.PRODUCTPLATFORMID
#       WHERE all_events.local_time::DATE > '2018-08-01'
#       AND all_events.local_time::DATE < CURRENT_DATE()
#       GROUP BY 1, 2, 3, 4, 5
#       UNION
#       SELECT
#           'mobile data' AS source
#           ,devicecategory
#           ,coursekey
#           ,TO_DATE(TO_TIMESTAMP(((VISITSTARTTIME*1000) + HITS_TIME)/1000)) AS event_date
#           ,userssoguid
#           ,COUNT(*)
#       FROM ${ga_mobiledata.SQL_TABLE_NAME}
#       WHERE event_date > '2018-08-01' AND event_date <= CURRENT_DATE()
#       GROUP BY 1, 2, 3, 4, 5
#       ;;

#       persist_for: "6 hours"
#   }

#   dimension: pk {
#     type: string
#     sql: ${TABLE}."SOURCE" ||  ${TABLE}."USER_IDENTIFIER" || ${TABLE}."SUBMISSION_DATE" || ${TABLE}."COURSE_KEY" ;;
#     primary_key:  yes
#   }

#   dimension: source {
#     type: string
#     sql: ${TABLE}."SOURCE" ;;
#   }

#   dimension: activity_platform {
#     type: string
#     sql: ${TABLE}."ACTIVITY_PLATFORM" ;;
#   }

#   dimension: platform {
#     type: string
#     sql: CASE WHEN ${TABLE}."ACTIVITY_PLATFORM" IN ('MT3', 'MINDTAP', 'MT4', 'mindtap') THEN 'MindTap'
#               WHEN ${TABLE}."ACTIVITY_PLATFORM" IN ('WEBASSIGN',  'WA RESPONSES') THEN 'WebAssign'
#               WHEN ${TABLE}."ACTIVITY_PLATFORM" IN ('cnow') THEN 'CNOW'
#               WHEN ${TABLE}."ACTIVITY_PLATFORM" IN ('mobile') THEN 'Mobile'
#               ELSE 'Other' END
#               ;;
#   }

#   dimension: course_key {
#     type: string
#     sql: ${TABLE}."COURSE_KEY" ;;
#   }

#   dimension_group: submission_date {
#     type: time
#     sql: ${TABLE}."SUBMISSION_DATE" ;;
#   }

#   dimension: user_identifier {
#     type: string
#     sql: ${TABLE}."USER_IDENTIFIER" ;;
#   }

#   measure: count_sum {
#     type: sum
#     sql: ${count} ;;
#   }

#   measure: user_count {
#     type: count_distinct
#     sql: ${TABLE}."USER_IDENTIFIER" ;;

#   }


#   dimension: count {
#     type: number
#     sql: ${TABLE}."COUNT(*)" ;;
#   }

#   set: detail {
#     fields: [activity_platform, course_key, submission_date_time, user_identifier, count]
#   }
# }
