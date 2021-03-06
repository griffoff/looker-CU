# view: coursewares_activated_week {
#   derived_table: {
#     sql:
#       WITH all_users AS (
#         SELECT
#             prod.user_sso_guid
#             ,DATE_TRUNC('week', prod.date_added) AS week
#             ,count(distinct prod.product_id) as unique_products
#         FROM  olr.prod.provisioned_product prod
#         JOIN prod.unlimited.raw_olr_extended_iac iac
#         ON iac.pp_pid = prod.product_id
#         JOIN unlimited.raw_subscription_event se
#         ON prod.user_sso_guid = se.user_sso_guid
#         AND prod.source_id = se.contract_id
#         JOIN olr.prod.raw_enrollment e
#         ON prod.context_id = e.course_key
#         AND prod.user_sso_guid = e.user_sso_guid
#         WHERE context_id IS NOT NULL
#         AND prod.user_type like 'student'
#         AND prod."source" like 'unlimited'
#         AND source_id <> '%trial%'
#         AND prod.user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users)
#         GROUP BY 1, 2)

#         SELECT
#           *
#         FROM all_users ;;
#   }

# dimension: user_sso_guid {}
# dimension: week {
#   type: date_week
# }
# dimension: unique_products {}


#   dimension: unique_product_buckets {
#     type:  tier
#     tiers: [ 2, 3, 4, 5]
#     style:  integer
#     sql:  ${unique_products} ;;
#   }

#   measure: count_users {
#     type:  count_distinct
#     sql: ${user_sso_guid} ;;
#   }

# }
