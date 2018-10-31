view: courseware_activations_per_user {
  derived_table: {
    sql:
      WITH all_users AS (
        SELECT
          prod.user_sso_guid
          ,CASE WHEN {% parameter timeframe_picker %} = 'Date' THEN DATE_TRUNC('day', prod.date_added)
                WHEN {% parameter timeframe_picker %} = 'Week' THEN DATE_TRUNC('week', prod.date_added)
                WHEN {% parameter timeframe_picker %} = 'Month' THEN DATE_TRUNC('month', prod.date_added)
                WHEN {% parameter timeframe_picker %} = 'All time' THEN NULL
                END AS time_period
          ,COUNT(DISTINCT prod.product_id) as unique_products
        FROM prod.UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT Prod
        JOIN prod.unlimited.RAW_OLR_EXTENDED_IAC Iac
        ON iac.pp_pid = prod.product_id
        AND prod.user_type like 'student'
        AND prod."source" like 'unlimited'
        WHERE context_id IS NOT NULL
        AND source_id NOT LIKE '%trial%'
        GROUP BY prod.user_sso_guid, time_period)


        SELECT
          *
        FROM all_users
        WHERE user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users) ;;
  }

  parameter: timeframe_picker {
    label: "Date Granularity"
    allowed_value: {value:"Date"}
    allowed_value: {value: "Week"}
    allowed_value: {value: "Month"}
    allowed_value: {value: "All Time"}
  }

dimension: test_time {
  type: number
}

  dimension: user_sso_guid {}
  dimension: time_period {
    type: date
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
