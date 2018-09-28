view: dashboard_use_over_time_bucketed {
  derived_table: {
    explore_source: dashboard_use_over_time {
      column: user_sso_guid {}
      column: num_days_active {}
      column: days_since_first_login {}
      column: percent_days_active_m {}
      filters: {
        field: dashboard_use_over_time.latest_subscription
        value: "Yes"
      }
      filters: {
        field: dashboard_use_over_time.subscription_state
        value: "full^_access"
      }
    }
  }
  dimension: user_sso_guid {}
  dimension: num_days_active {
    type: number
  }
  dimension: days_since_first_login {
    type: number
  }
  dimension: percent_days_active_m {
    value_format: "#.00\%"
    type: number
  }

  dimension: usage_percentage_buckets {
    type:  tier
    tiers: [10, 26, 51, 76]
    style:  integer
    sql:  ${percent_days_active_m} ;;
  }

  measure: unique_users {
    type: count_distinct
    sql: user_sso_guid ;;
    drill_fields: [user_sso_guid,usage_percentage_buckets]
  }

  }
