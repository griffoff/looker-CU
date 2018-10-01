view: ebook_usage_aggregated {
  derived_table: {
    explore_source: ebook_usage {
      column: user_sso_guid { field: ebook_usage_actions.user_sso_guid }
      column: unique_product_count { field: ebook_usage_actions.unique_product_count }
      filters: {
        field: clts_excluded_users.user_sso_guid
        value: "NULL"
      }
      filters: {
        field: raw_subscription_event.latest_subscription
        value: "Yes"
      }
    }

  }
  dimension: user_sso_guid {}
  dimension: unique_product_count {
     sql: ${TABLE}.unique_product_count ;;
    type: number
  }

  dimension: unique_product_bucket {
    type:  tier
    tiers: [2, 4, 6, 8]
    style:  integer
    sql:  ${TABLE}.unique_product_count ;;
  }

  measure: count_users {
    type:  count_distinct
    sql: ${user_sso_guid};;

  }
}
