view: coursewares_activated {
    derived_table: {
      sql:
        SELECT prod.user_sso_guid, count(distinct prod.product_id) as unique_products
          FROM  prod.UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT Prod
              JOIN prod.unlimited.RAW_OLR_EXTENDED_IAC Iac
                ON iac.pp_pid = prod.product_id
                  AND prod.user_type like 'student'
                  AND prod."source" like 'unlimited'
                  GROUP BY 1;;
    }

    dimension: user_sso_guid {}
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
