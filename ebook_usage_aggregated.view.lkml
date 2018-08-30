view: ebook_usage_aggregated {
  derived_table: {
    explore_source: ebook_usage_actions {
      column: user_sso_guid {}
      column: unique_product_count {}
    }
  }
  dimension: user_sso_guid {}
  dimension: unique_product_count {
    type: number
  }

  dimension: unique_product_bucket {
    type:  tier
    tiers: [2, 4, 6, 8]
    style:  integer
    sql:  ${unique_product_count} ;;
  }

  measure: count_users {
    type:  count_distinct
    sql: ${user_sso_guid} ;;

  }
}
