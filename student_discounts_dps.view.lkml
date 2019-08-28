explore: student_discounts_dps {}

view: student_discounts_dps {
  derived_table: {
    sql:
    WITH most_recent_run_time AS (SELECT MAX(run_time) AS most_recent_run FROM prod.cu_user_analysis_dev.student_discounts)
    ,most_recent_run AS
    (
        SELECT
          ROW_NUMBER() OVER (PARTITION BY user_sso_guid, ISBN ORDER BY run_time DESC) AS row_order
          ,user_sso_guid
          ,discount AS discount
          ,isbn AS isbn
          ,run_time
       FROM prod.cu_user_analysis_dev.student_discounts WHERE run_time = (SELECT most_recent_run FROM most_recent_run_time)
    )
    SELECT user_sso_guid, SUM(discount) AS discount, LISTAGG(isbn) AS isbn, MAX(run_time) AS run_time FROM most_recent_run GROUP BY 1
      ;;
#   persist_for: "6 hours"
  sql_trigger_value: Select * from prod.eloqua_discounts.student_discounts   ;;
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
    type: time
    timeframes: [date, week, month, year, raw]
    sql: ${TABLE}."RUN_TIME" ;;
  }


  dimension: amount_to_upgrade {
    group_label: "Discount info"
    type: number
    sql: CASE WHEN (120 - COALESCE(${TABLE}."DISCOUNT", 0)) < 0 THEN 0 ELSE (120 - COALESCE(${TABLE}."DISCOUNT", 0)) END ;;
  }


  dimension: amount_to_upgrade_string {
    group_label: "Discount info"
    type: string
    sql: CASE
            WHEN ${amount_to_upgrade} = 0 THEN 'for free'
            WHEN ${amount_to_upgrade} > 50 THEN ' '
            ELSE CONCAT('for only $', ${amount_to_upgrade}::string) END;;
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

  set: marketing_fields {fields: [amount_to_upgrade_string, amount_to_upgrade, discount, isbn, discount, run_time_date]}


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
