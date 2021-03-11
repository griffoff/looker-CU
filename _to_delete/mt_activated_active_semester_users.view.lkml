# explore: mt_activated_active_semester_users {label: "Ad-hoc: Mindtap activations and activity by semester"
#   description: "Fall Review - ad-hoc"}

# view: mt_activated_active_semester_users {
#   derived_table: {
#     sql: WITH
#         user_activations_count AS
#         (
#           SELECT
#             COALESCE(m.primary_guid, ma.user_guid) AS merged_guid
#             ,CASE
#               WHEN actv_dt BETWEEN '2018-08-01' AND '2018-09-30' THEN 'Fall 18'
#               WHEN actv_dt BETWEEN '2019-08-01' AND '2019-09-30' THEN 'Fall 19'
#               ELSE 'other'
#             END AS semester
#             ,COUNT(DISTINCT ma.actv_code) AS activation_count
#           FROM prod.stg_clts.activations_olr ma
#           LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
#               ON ma.user_guid = m.partner_guid
#           LEFT JOIN prod.unlimited.excluded_users e1
#               ON ma.user_guid = e1.user_sso_guid
#           LEFT JOIN prod.unlimited.excluded_users e2
#               ON m.primary_guid = e2.user_sso_guid
#           WHERE ma.user_guid NOT IN (SELECT DISTINCT user_sso_guid FROM prod.unlimited.excluded_users)
#           AND e1.user_sso_guid IS NULL AND e2.user_sso_guid IS NULL
#           AND platform ILIKE '%mindtap%'
#           AND actv_dt >= '2018-08-01'
#           GROUP BY 1, 2
#         )
#       //  SELECT * FROM user_activations_count;
#         ,mt_activity AS
#         (
#           SELECT
#               COALESCE(m.primary_guid, user_identifier) AS merged_guid
#               ,CASE
#               WHEN mt.event_time::date BETWEEN '2018-08-01' AND '2018-09-30' THEN 'Fall 18'
#               WHEN mt.event_time::date BETWEEN '2019-08-01' AND '2019-09-30' THEN 'Fall 19'
#               ELSE 'other'
#             END AS semester
#               ,COUNT(DISTINCT mt_session_id) AS unique_sessions
#           FROM cap_er.prod.raw_mt_resource_interactions mt
#           LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
#               ON mt.user_identifier = m.partner_guid
#           WHERE semester IN ('Fall 18', 'Fall 19')
#           GROUP BY 1, 2
#         )
#         ,active_users_mt_semester AS
#         (
#         SELECT
#             uac.semester
#             ,COUNT(DISTINCT ma.merged_guid) AS distinct_users
#         FROM user_activations_count uac
#         LEFT JOIN mt_activity ma
#           ON uac.semester = ma.semester
#           AND uac.merged_guid = ma.merged_guid
#           AND uac.activation_count > 0
#           AND ma.unique_sessions > 0
#         WHERE uac.semester IN ('Fall 18', 'Fall 19')
#         GROUP BY 1
#         )
#         SELECT
#             uac.semester
#             ,CASE WHEN uac.activation_count > 4 THEN '5+' ELSE uac.activation_count::string END AS activation_count
#             ,COUNT(DISTINCT ma.merged_guid) AS distinct_users
#         FROM user_activations_count uac
#         LEFT JOIN mt_activity ma
#           ON uac.semester = ma.semester
#           AND uac.merged_guid = ma.merged_guid
#           AND uac.activation_count > 0
#           AND ma.unique_sessions > 0
#         WHERE uac.semester IN ('Fall 18', 'Fall 19')
#         GROUP BY 1, 2
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   measure: users {
#     type: sum
#     sql: ${distinct_users} ;;
#     label: "# Users"
#   }



#   dimension: semester {
#     type: string
#     sql: ${TABLE}."SEMESTER" ;;
#   }

#   dimension: activation_count {
#     type: string
#     sql: ${TABLE}."ACTIVATION_COUNT" ;;
#   }

#   dimension: distinct_users {
#     type: number
#     sql: ${TABLE}."DISTINCT_USERS" ;;
#   }

#   set: detail {
#     fields: [semester, activation_count, distinct_users]
#   }
# }
