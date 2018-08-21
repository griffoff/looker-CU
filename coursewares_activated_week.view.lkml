view: coursewares_activated_week {
  derived_table: {
    sql:
      WITH all_users AS (
        SELECT prod.user_sso_guid, DATE_TRUNC('week', prod.date_added) AS week, count(distinct prod.product_id) as unique_products
          FROM  prod.UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT Prod
              JOIN prod.unlimited.RAW_OLR_EXTENDED_IAC Iac
                ON iac.pp_pid = prod.product_id
                  AND prod.user_type like 'student'
                  AND prod."source" like 'unlimited'
                  WHERE context_id IS NOT NULL
                  AND source_id NOT LIKE '%trial%'
                  GROUP BY 1, 2 )


        SELECT
          *
        FROM all_users
        WHERE user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.clts_excluded_users) ;;
  }

dimension: user_sso_guid {}
dimension: week {
  type: date_week
}
dimension: unique_products {}


  dimension: unique_product_buckets {
    type:  tier
    tiers: [ 2, 3, 4, 5]
    style:  integer
    sql:  ${unique_products} ;;
  }

  measure: count_users {
    type:  count_distinct
    sql: ${user_sso_guid} ;;
  }

}
