# #fields hidden 2020-06-08
# view: strategy_ecom_sales_orders {
#   view_label: "User Revenue"
#   derived_table: {
#     sql:

#       select
#         COALESCE(primary_guid, contact_user_guid) AS user_sso_guid
#         ,HASH(user_sso_guid, order_no) as pk
#         ,ecom.invoice_dt
#         ,ecom.ORDER_NO
#         ,ecom.EXTENDED_AMT_USD
#         ,ecom.PRODUCT_SKEY_BU
#         ,ecom.QUANTITY
#         ,ecom.SALES_ANALYSIS_CD
#         ,ecom.ISBN_13
#         ,ecom.REF_2_NO
#         ,ecom.GSF_CD
#         ,ecom.CONTACT_USER_GUID
#       FROM  strategy.non_dw_uploads.hed_sales_orders_ecom ecom
#       LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids
#         ON   ecom.contact_user_guid = guids.partner_guid;;

#       datagroup_trigger: daily_refresh
#   }

#   dimension: pk {primary_key:yes hidden:yes}

#   dimension: user_sso_guid {
#     hidden: yes
#   }

#   dimension_group: invoice_dt {
#   description: "Year for invoice date from strategies upload higher ed sales orders e-comm"
#   type:time
#   timeframes: [year, raw]
#     hidden: yes
#   }

#   dimension: isbn_13 {
#     hidden: yes
#   }

#   measure:  revenue {
#     hidden: yes
#     label: "Total Revenue"
#     description: "EXTENDED_AMT_USD"
#     type: sum
#     sql: ${TABLE}.EXTENDED_AMT_USD;;
#     value_format_name: usd_0
#   }

#   measure:  revenue_td {
#     hidden: yes
#     label: "Total Revenue (To date by year)"
#     required_fields: [invoice_dt_year]
#     description: "EXTENDED_AMT_USD"
#     type: number
#     sql: SUM(${TABLE}.EXTENDED_AMT_USD) OVER (PARTITION BY ${invoice_dt_year});;
#     value_format_name: usd_0
#   }

#   measure: user_count {
#     hidden: yes
#     description: "Number of users from strategies upload higher ed sales orders e-comm"
#     label: "# Users"
#     type: count_distinct
#     sql: ${user_sso_guid} ;;
#     value_format_name: decimal_0
#   }



#   measure: arpu {
#     hidden: yes
#     description: "Average Revenue Per User from strategies upload higher ed sales orders e-comm"
#     alias: [ARPU]
#     type: number
#     sql: ${revenue} / ${user_count};;
#     value_format_name: usd_0
#   }

#   measure: arpu_yoy {
#     hidden:  yes
#     type: number
#     sql: ${revenue} / ${user_count};;
#     value_format_name: usd_0
#   }
# }
