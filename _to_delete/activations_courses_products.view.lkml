# view: activations_courses_products {
#   derived_table: {
#     sql: SELECT
#             user_guid AS user_id
#             ,LISTAGG(a.platform) AS platforms
#             ,LISTAGG(actv_dt) AS activation_date
#             ,SUM(p.net_price) AS total_price
#         FROM stg_clts.activations_olr a
#         LEFT JOIN prod.stg_clts.olr_courses c ON a.context_id = c."#CONTEXT_ID"
#         LEFT JOIN prod.stg_clts.products_v p ON c.isbn = p.isbn13
#         WHERE organization = 'Higher Ed'
#         AND a.latest = True
#         -- AND p.net_price IS NOT NULL
#          GROUP BY 1
#  ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }
#
# #   measure: sum_price {
# #     type: sum
# #     sql: ${net_price} ;;
# #   }
#
#   dimension: CU_user {
#     sql: CASE WHEN ${raw_subscription_event.subscription_status} IN ('Trial', 'Trial Expired') OR subscription_status IS NULL THEN 1 END ;;
#   }
#
#   dimension: activationid {
#     type: number
#     sql: ${TABLE}."ACTIVATIONID" ;;
#   }
#
#   dimension: activation_date {
#     type: date
#     sql: ${TABLE}."ACTIVATION_DATE" ;;
#   }
#
#   dimension: user_id {
#     type: string
#     sql: ${TABLE}."USER_ID" ;;
#   }
#
#   dimension: organization {
#     type: string
#     sql: ${TABLE}."ORGANIZATION" ;;
#   }
#
#   dimension: platform {
#     type: string
#     sql: ${TABLE}."PLATFORM" ;;
#   }
#
#   dimension: registrationtype {
#     type: string
#     sql: ${TABLE}."REGISTRATIONTYPE" ;;
#   }
#
#   dimension: cu_flg {
#     type: string
#     sql: ${TABLE}."CU_FLG" ;;
#   }
#
#   dimension: context_id {
#     type: string
#     sql: ${TABLE}."CONTEXT_ID" ;;
#   }
#
#   dimension: total_price {
#     type: string
#     sql: ${TABLE}."TOTAL_PRICE" ;;
#   }
#
#
#   set: detail {
#     fields: [
#       activationid,
#       activation_date,
#       user_id,
#       organization,
#       platform,
#       registrationtype,
#       cu_flg,
#       context_id,
#       total_price,
#       CU_user
#
#     ]
#   }
# }
