view: courseware_usage_tiers_csms {
    derived_table: {
      sql:  SELECT * FROM strategy.rmcdonough.cw_usage_csm_dashboard
      ;;
  }

    measure: sum {
      type:  sum
      sql:  ${TABLE}.CW_ACTIVITIES_PER_USER
      ;;
  }

    dimension: calendar_year {
      type: number
      sql:  ${TABLE}."CALENDAR YEAR""
      ;;
  }

    dimension: semester {
      type: string
      sql:  ${TABLE}.SEMESTER
      ;;
    }

    dimension: state {
      type: string
      sql:  ${TABLE}.STATE
       ;;
    }

    dimension: institution {
      type:  string
      sql:  ${TABLE}.INSTITUTION
      ;;
    }

    dimension:  instructor_name {
      type: string
      sql:  ${TABLE}."INSTRUCTOR NAME"
      ;;
    }

    dimension: course {
      type: string
      sql:  ${TABLE}.COURSE
      ;;
    }

    dimension: discipline {
      type: string
      sql:  ${TABLE}.DISCIPLINE
      ;;
    }

    dimension: specialization {
      type: string
      sql:  ${TABLE}.SPECIALIZATION
      ;;
    }

    dimension: category {
      type: string
      sql:  ${TABLE}.CATEGORY
      ;;
    }

    dimension: platform {
      type: string
      sql: ${TABLE}.PLATFORM
      ;;
    }

    dimension: medium_usage_threshold {
      type: number
      sql:  ${TABLE}.MEDIUM_USAGE_THRESHOLD
      ;;
    }

  dimension: high_usage_threshold {
    type: number
    sql:  ${TABLE}.HIGH_USAGE_THRESHOLD
      ;;
  }

  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: courseware_usage_tiers_csms {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
