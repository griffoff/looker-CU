# view: olr_non_olr_combined {
#   derived_table: {
#     sql: with orgs AS (
#         SELECT
#             actv_olr_id AS activationid
#             ,DATE_TRUNC('week', actv_dt) AS week
#             ,user_guid AS user_id
#             ,organization
#             ,platform
#             ,'OLR' AS registrationtype
#             ,cu_flg
#         FROM stg_clts.activations_olr
#         WHERE organization is NOT NULL
#         AND latest
#         --and in_actv_flg = 1
#         UNION all
#         SELECT
#             actv_non_olr_id
#             ,DATE_TRUNC('week', actv_dt) AS week
#             ,UNIQUE_USER_ID AS user_id
#             ,organization
#             ,platform
#             ,'Non_OLR'
#             ,cu_flg
#         FROM stg_clts.activations_non_olr
#         WHERE organization is NOT NULL
#         AND latest
#         --and in_actv_flg = 1
#         -- group by 1, 2, 3, 4, 6
#       )
#
#       SELECT
#         *
#
#       FROM orgs
#       LEFT JOIN prod.stg_clts.olr_courses c ON a.context_id = c."#CONTEXT_ID"
#
#  ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }
#
#   dimension: week {
#     type: date
#     sql: ${TABLE}."WEEK" ;;
#   }
#
#   dimension: user_id {
#     type: string
#     sql: ${TABLE}."USER_ID" ;;
#   }
#
#   dimension: count_activationid {
#     type: number
#     label: "COUNT( ACTIVATIONID)"
#     sql: ${TABLE}."COUNT( ACTIVATIONID)" ;;
#   }
#
#   set: detail {
#     fields: [week, user_id, count_activationid]
#   }
# }
