view: dashboard_use_over_time_bucketed {
    derived_table: {
      explore_source: dashboard_use_over_time {
        column: user_sso_guid {}
        column: event_day_count {}
        column: event_age {}
        column: count {}
        column: percent_days_active {}
        column: first_login {}
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
    dimension: event_day_count {
      type: number
    }
    dimension: event_age {
      type: number
    }
    dimension: count {
      type: number
    }
    dimension: percent_days_active {
      value_format: "#.00\%"
      type: number
    }
    dimension: first_login {
      type: date
    }

  dimension: usage_percentage_buckets {
    type:  tier
    tiers: [10, 20, 30, 40, 50, 60, 70, 80, 90]
    style:  integer
    sql:  ${percent_days_active} ;;
  }

  measure: unique_users {
    type: count_distinct
    sql: user_sso_guid ;;
  }

  }
