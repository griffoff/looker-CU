# explore: z_kpi_sales_orders_dm {}

# view: z_kpi_sales_orders_dm {
#   derived_table: {
#     sql: SELECT
#           subscription_duration
#           ,CASE WHEN title ILIKE '%IAC%' THEN 'IAC'
#                 WHEN title ILIKE '%PAC%' THEN 'PAC'
#                 ELSE 'Other' END AS code_type
#           ,SUM(quantity) AS quantity
#           ,SUM(so.extended_amt_usd) AS revenue -- extended_amt_usd - actual sales amount recognized by financial systems
#       FROM dev.aa_kpi.dm_sales_orders so
#       inner join dev.aa_kpi.dm_products product
#           on so.product_skey_owner = product.product_skey
#       WHERE  product.print_digital_config_cd in ('026') -- CU subscriptions sold
#       AND invoice_dt >= '2019-04-01'
#       GROUP BY 1, 2 ORDER BY 3 DESC
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }



#   measure: quantity_m {
#     type: sum
#     sql: ${TABLE}."QUANTITY" ;;
#     drill_fields: [detail*]
#   }


#   dimension: subscription_duration {
#     type: number
#     sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
#   }

#   dimension: code_type {
#     type: string
#     sql: ${TABLE}."CODE_TYPE" ;;
#   }

#   dimension: quantity {
#     type: number
#     sql: ${TABLE}."QUANTITY" ;;
#   }

#   dimension: revenue {
#     type: number
#     sql: ${TABLE}."REVENUE" ;;
#   }

#   set: detail {
#     fields: [subscription_duration, code_type, quantity, revenue]
#   }
# }
