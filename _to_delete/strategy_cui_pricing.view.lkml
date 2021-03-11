# view: strategy_cui_pricing {
#   derived_table: {
#     sql: SELECT * FROM strategy.misc.cui_pricing
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#     hidden: yes
#   }

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#     hidden: yes
#   }

#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#     hidden: yes
#   }

#   dimension: entity_id {
#     type: number
#     sql: ${TABLE}."ENTITY_ID"::string ;;
#     hidden: yes
#   }

#   dimension: subscriber_group {
#     type: string
#     sql: ${TABLE}."SUBSCRIBER_GROUP" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension: subscription_quantity {
#     type: string
#     sql: ${TABLE}."SUBSCRIPTION_QUANTITY" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension: min_date {
#     type: date
#     sql: ${TABLE}."MIN_DATE" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension: max_date {
#     type: date
#     sql: ${TABLE}."MAX_DATE" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension: product {
#     type: number
#     sql: ${TABLE}."PRODUCT" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension: sales_price {
#     type: number
#     sql: ${TABLE}."SALES_PRICE" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension: notes {
#     type: string
#     sql: ${TABLE}."NOTES" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension: institution_nm {
#     label: "Institution Name"
#     type: string
#     sql: ${TABLE}."INSTITUTION_NM" ;;
#     group_label: "CUI Pricing"
#   }

#   dimension_group: _fivetran_synced {
#     type: time
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#     hidden: yes
#   }

#   set: detail {
#     fields: [
#       _file,
#       _line,
#       entity_id,
#       subscriber_group,
#       subscription_quantity,
#       min_date,
#       max_date,
#       product,
#       sales_price,
#       notes,
#       institution_nm,
#       _fivetran_synced_time
#     ]
#   }
# }
