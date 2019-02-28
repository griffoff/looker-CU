explore: locker_funnel {}

view: locker_funnel {
  derived_table: {
    sql: SELECT * FROM zpg.locker_funnel
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: distinct_users_eligible_for_locker {
    type: number
    sql: ${TABLE}."DISTINCT_USERS_ELIGIBLE_FOR_LOCKER" ;;
  }

  dimension: distinct_users_renewing_four_month_subscription {
    type: number
    sql: ${TABLE}."DISTINCT_USERS_RENEWING_FOUR_MONTH_SUBSCRIPTION" ;;
  }

  dimension: distinct_users_that_used_provisional_locker {
    type: number
    sql: ${TABLE}."DISTINCT_USERS_THAT_USED_PROVISIONAL_LOCKER" ;;
  }

  dimension: distinct_users_that_built_locker {
    type: number
    sql: ${TABLE}."DISTINCT_USERS_THAT_BUILT_LOCKER" ;;
  }

  dimension: distinct_users_that_used_read_only_locker {
    type: number
    sql: ${TABLE}."DISTINCT_USERS_THAT_USED_READ_ONLY_LOCKER" ;;
  }

  dimension: people_that_moved_to_the_read_only {
    type: number
    sql: ${TABLE}."PEOPLE_THAT_MOVED_TO_THE_READ_ONLY" ;;
  }

  set: detail {
    fields: [
      distinct_users_eligible_for_locker,
      distinct_users_renewing_four_month_subscription,
      distinct_users_that_used_provisional_locker,
      distinct_users_that_built_locker,
      distinct_users_that_used_read_only_locker,
      people_that_moved_to_the_read_only
    ]
  }
}
