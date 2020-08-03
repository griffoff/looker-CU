explore: student_discounts_dps {}

view: student_discounts_dps {
  derived_table: {
    sql:
    WITH most_recent_run_eloqua AS
    (
        SELECT
          ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY run_time DESC) AS row_order
          ,user_sso_guid
          ,discount AS discount
          ,price
          ,isbn AS isbn
          ,run_time
       FROM prod.eloqua_discounts.student_discounts
        WHERE run_time >= CURRENT_DATE - 30
        AND isbn IS NOT NULL
    )
    ,most_recent_run_ipm AS
    (
        SELECT
          ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY run_time DESC) AS row_order
          ,user_sso_guid
          ,discount AS discount
          ,isbn AS isbn
          ,price
          ,run_time
       FROM prod.ipm_discounts.student_discounts
      WHERE run_time >= CURRENT_DATE - 30
        AND isbn IS NOT NULL
    )
    SELECT  user_sso_guid, 'eloqua' AS marketing_mechanism, price, SUM(discount) AS discount, LISTAGG(isbn) AS isbn, MAX(run_time) AS run_time
    FROM most_recent_run_eloqua
    WHERE row_order = 1
    GROUP BY 1, 2, 3
    UNION
    SELECT user_sso_guid, 'ipm' AS marketing_mechanism, price, SUM(discount) AS discount, LISTAGG(isbn) AS isbn, MAX(run_time) AS run_time
    FROM most_recent_run_ipm
    WHERE row_order = 1
    GROUP BY 1, 2, 3


      ;;
#   persist_for: "6 hours"
#   sql_trigger_value: Select COUNT(*) FROM (SELECT * from prod.eloqua_discounts.student_discounts UNION SELECT * FROM prod.ipm_discounts.student_discounts)  ;;
  }

  dimension: marketing_mechanism {
    group_label: "Discount info"

  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    primary_key: yes
  }

  dimension: discount {
    group_label: "Discount info"
    type: number
    sql: ${TABLE}.discount ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}."ISBN" ;;
  }


  dimension_group: run_time {
    group_label: "Discount info"
    type: time
    timeframes: [date, week, month, year, raw]
    sql: ${TABLE}."RUN_TIME" ;;
  }


  dimension: amount_to_upgrade_num {
    group_label: "Discount info"
    type: number
    value_format_name: decimal_2
#     value_format: "$0.00"
    sql: COALESCE(GREATEST(${TABLE}.price, 0),199.99) ;;
    #sql: GREATEST(120 - COALESCE(${TABLE}."DISCOUNT", 0), 0) ;;
  }

  dimension: amount_to_upgrade {
    group_label: "Discount info"
    type: string
    sql: concat('$',${amount_to_upgrade_num});;

  }

  dimension: amount_to_upgrade_buckets {
    group_label: "Discount info"
    label: "Amount to upgrade buckets"
    type: tier
    sql: ${amount_to_upgrade_num} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70]
    style: integer
  }




  dimension: amount_to_upgrade_string {
    group_label: "Discount info"
    type: string
    sql: CASE
            WHEN ${amount_to_upgrade_num} = 0 THEN 'for free'
            WHEN ${amount_to_upgrade_num} between 0 and 30 THEN CONCAT('for $', ${amount_to_upgrade}::string)
            WHEN ${amount_to_upgrade_num} between 30 and 65 THEN '31-65'
            ELSE '' END;;
   }


#
#   dimension: amount_to_upgrade_tiers {
#     type: string
#     sql: CASE
#             WHEN ${amount_to_upgrade} = 0 THEN '0'
#             WHEN ${amount_to_upgrade} < 10 THEN '$0.01-$9.99'
#             WHEN ${amount_to_upgrade} < 20 THEN '$10.00-$19.99'
#             WHEN ${amount_to_upgrade} < 30 THEN '$20.00-$29.99'
#             WHEN ${amount_to_upgrade} < 40 THEN '$30.00-$39.99'
#             WHEN ${amount_to_upgrade} < 50 THEN '$40.00-$49.99'
#             ELSE 'over $50.00'
#             END
#             ;;
#   }

  set: marketing_fields {fields: [amount_to_upgrade_string, amount_to_upgrade, discount
      , isbn, discount, run_time_date, marketing_mechanism
      , amount_to_upgrade_buckets]}


  set: detail {
    fields: [
      user_sso_guid,
      isbn,
      discount,
      run_time_date,
      amount_to_upgrade,
      amount_to_upgrade_string,
    ]
  }


}
