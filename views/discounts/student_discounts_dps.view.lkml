explore: student_discounts_dps {}

view: student_discounts_dps {
  derived_table: {
    sql:
    WITH most_recent_run_eloqua AS
    (
        SELECT
          rank() OVER (PARTITION BY user_sso_guid ORDER BY run_time DESC) AS row_order
             ,user_sso_guid
             ,run_time
             ,MAX(CASE WHEN isbn = '9780357693339' THEN discount END) as discount_etextbook
             ,MAX(CASE WHEN isbn = '9780357700006' THEN discount END) as discount_cu
             ,MAX(CASE WHEN isbn = '9780357693339' THEN price END) as price_etextbook
             ,MAX(CASE WHEN isbn = '9780357700006' THEN price END) as price_cu
        FROM prod.eloqua_discounts.student_discounts
        WHERE run_time >= CURRENT_DATE - 30
          AND isbn IN (
            '9780357693339' --etextbook
            ,'9780357700006' --CU
          )
        GROUP BY user_sso_guid, run_time

    )
    ,most_recent_run_ipm AS
    (
       SELECT
          rank() OVER (PARTITION BY user_sso_guid ORDER BY run_time DESC) AS row_order
             ,user_sso_guid
             ,run_time
             ,MAX(CASE WHEN isbn = '9780357693339' THEN discount END) as discount_etextbook
             ,MAX(CASE WHEN isbn = '9780357700006' THEN discount END) as discount_cu
             ,MAX(CASE WHEN isbn = '9780357693339' THEN price END) as price_etextbook
             ,MAX(CASE WHEN isbn = '9780357700006' THEN price END) as price_cu
        FROM prod.ipm_discounts.student_discounts
        WHERE run_time >= CURRENT_DATE - 30
          AND isbn IN (
            '9780357693339' --etextbook
            ,'9780357700006' --CU
          )
        GROUP BY user_sso_guid, run_time

      )
    SELECT  'eloqua' AS marketing_mechanism, *
    FROM most_recent_run_eloqua
    WHERE row_order = 1
    UNION
    SELECT 'ipm', *
    FROM most_recent_run_ipm
    WHERE row_order = 1


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
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: discount {
    group_label: "Discount info"
    type: number
    sql: ${TABLE}.discount_cu ;;
  }

  dimension: discount_etextbook {
    group_label: "Discount info"
    type: number
    sql: ${TABLE}.discount_etextbook ;;
  }

  dimension: isbn {
    type: string
    sql: 'N/A' ;;
    hidden: yes
  }


  dimension_group: run_time {
    group_label: "Discount info"
    type: time
    timeframes: [date]
    sql: ${TABLE}."RUN_TIME" ;;
  }


#   dimension: amount_to_upgrade_num {
#     group_label: "Discount info"
#     type: number
#     value_format_name: decimal_2
# #     value_format: "$0.00"
#     sql: COALESCE(GREATEST(${TABLE}.price, 0),199.99) ;;
#     #sql: GREATEST(120 - COALESCE(${TABLE}."DISCOUNT", 0), 0) ;;
#   }

#   dimension: amount_to_upgrade {
#     group_label: "Discount info"
#     type: string
#     sql: concat('$',${amount_to_upgrade_num});;
#
#   }

  dimension: amount_to_upgrade {
    group_label: "Discount info"
    type: number
    sql: COALESCE(GREATEST(${TABLE}.price_cu, 0),119.99);;
    value_format_name: usd
  }

  dimension: amount_to_upgrade_string {
    group_label: "Discount info"
    type: string
    sql: CASE
            WHEN ${amount_to_upgrade} = 0 THEN 'for free'
            WHEN ${amount_to_upgrade} between 0 and 30 THEN CONCAT('for $', ${amount_to_upgrade}::string)
            WHEN ${amount_to_upgrade} between 30 and 65 THEN '31-65'
            ELSE '' END;;
  }


  dimension: amount_to_upgrade_buckets {
    group_label: "Discount info"
    label: "Amount to upgrade buckets"
    type: tier
    sql: ${amount_to_upgrade} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70]
    style: integer
    value_format_name: usd
  }

  dimension: amount_to_upgrade_etextbook {
    group_label: "Discount info"
    type: number
    sql: COALESCE(GREATEST(${TABLE}.price_etextbook, 0),69.99);;
    value_format_name: usd
  }

  dimension: amount_to_upgrade_etextbook_string {
    group_label: "Discount info"
    type: string
    sql: CASE
            WHEN ${amount_to_upgrade_etextbook} = 0 THEN 'for free'
            WHEN ${amount_to_upgrade_etextbook} between 0 and 30 THEN CONCAT('for $', ${amount_to_upgrade_etextbook}::string)
            WHEN ${amount_to_upgrade_etextbook} between 30 and 65 THEN '31-65'
            ELSE '' END;;
  }

  dimension: amount_to_upgrade_etexbook_buckets {
    group_label: "Discount info"
    label: "Amount to upgrade to e-Textbook (buckets)"
    type: tier
    sql: ${amount_to_upgrade_etextbook} ;;
    tiers: [0, 10, 20, 30, 40]
    style: integer
    value_format_name: usd
  }


  set: marketing_fields {fields: [amount_to_upgrade_string, amount_to_upgrade, amount_to_upgrade_etextbook_string, amount_to_upgrade_etextbook, discount
      , discount, run_time_date, marketing_mechanism
      , amount_to_upgrade_buckets]}


  set: detail {
    fields: [
      user_sso_guid,
      discount,
      run_time_date,
      amount_to_upgrade,
      amount_to_upgrade_etextbook,
    ]
  }


}
