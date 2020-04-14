view: trials {
  # # You can specify the table name if it's different from the view name:
  sql_table_name: strategy.covid_support_prod.trials ;;
  #
  # # Define your dimensions and measures here, like this:
  dimension: merged_guid {
    description: "merged guid"
    type: string
    sql: ${TABLE}.merged_guid ;;
  }

  measure: count {
    description: "Count of unique trials"
    type: count_distinct
    sql: ${TABLE}.merged_guid||${TABLE}.subscription_start_dt ;;
  }
  #
  dimension_group: subscription_start_dt {
    description: "date trial began"
    type: time
    timeframes: [date, week, month, year]
  }

  dimension: covid_trial {
    description: "trial after 3/1/20"
    type: yesno
  }
  dimension: covid_trial_no {
    description: "covid trial renewal number"
    type: yesno
  }


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



# view: trials {
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
