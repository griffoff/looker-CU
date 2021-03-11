# explore: guid_first_last_date_seen {hidden:yes}
# view: guid_first_last_date_seen {
#   derived_table: {
#     create_process: {
#       sql_step:
#         CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.guid_first_last_date_seen
#         (
#           merged_guid STRING
#           ,instructor BOOLEAN
#           ,first_seen DATE
#           ,last_seen DATE
#         )
#       ;;
#       sql_step:
#         MERGE INTO LOOKER_SCRATCH.guid_first_last_date_seen k USING
#         (
#         WITH all_events_merged AS (
#           SELECT e.user_sso_guid AS merged_guid, CASE WHEN e.user_type = 'Instructor' then TRUE ELSE FALSE END AS instructor, e.date as event_time
#           FROM ${guid_date_active.SQL_TABLE_NAME} e
#         )
#         ,first_mutation AS (
#           SELECT COALESCE(e.linked_guid, hu.uid) AS merged_guid, e.instructor, e.rsrc_timestamp::date AS event_time
#           FROM prod.datavault.hub_user hu
#                   INNER JOIN prod.datavault.SAT_USER_V2 e ON hu.hub_user_key = e.hub_user_key AND e._LATEST
#                   LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
#           WHERE merged_guid IS NOT NULL
#             AND event_time NOT IN ('2018-08-03','2019-08-22')
#             AND ui.hub_user_key IS NULL
#         )
#         ,users AS (
#           SELECT *
#           FROM all_events_merged
#           UNION ALL
#           SELECT *
#           FROM first_mutation
#         )
#         SELECT
#           MERGED_GUID
#           , INSTRUCTOR
#           , min(EVENT_TIME) as first_seen
#           , max(EVENT_TIME) as last_seen
#         FROM users
#         group by MERGED_GUID, INSTRUCTOR

#         ) c
#         ON k.merged_guid = c.merged_guid and k.instructor = c.instructor
#         WHEN MATCHED AND (k.first_seen <> c.first_seen OR k.last_seen <> c.last_seen) THEN UPDATE
#           SET
#             k.first_seen = c.first_seen
#             ,k.last_seen = c.last_seen
#         WHEN NOT MATCHED THEN INSERT
#         (
#           merged_guid
#           ,instructor
#           ,first_seen
#           ,last_seen
#         )
#         VALUES
#         (
#           c.merged_guid
#           ,c.instructor
#           ,c.first_seen
#           ,c.last_seen
#         )

#       ;;

#       sql_step:
#       CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
#       CLONE LOOKER_SCRATCH.guid_first_last_date_seen;;

#       }
#       datagroup_trigger: daily_refresh
#     }

#     dimension: merged_guid {}
#     dimension: user_type {
#       sql: case when ${TABLE}.instructor then 'Instructor' else 'Student' end ;;
#     }
#     dimension_group: first_seen {
#       hidden: no
#       label: "User First Seen"
#       type:time
#       timeframes: [raw,date,month,year]
#     }

#     dimension_group: last_seen {
#       hidden: no
#       label: "User Last Seen"
#       type:time
#       timeframes: [raw,date,month,year]
#     }

#   }
