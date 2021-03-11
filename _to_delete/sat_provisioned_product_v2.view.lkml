# view: sat_provisioned_product_v2 {
#   derived_table: {
#     sql:
#     select coalesce(su.linked_guid, spp.USER_SSO_GUID) as merged_guid, p.net_price, sum(p.net_price) over(partition by merged_guid) as total_user_product_value, spp.*
#     from prod.datavault.sat_provisioned_product_v2 spp
#     left join prod.datavault.hub_user hu on spp.USER_SSO_GUID = hu.uid
#     left join prod.datavault.sat_user_v2 su on su.hub_user_key = hu.hub_user_key and su._latest
#     left join prod.STG_CLTS.PRODUCTS p on p.ISBN13 = spp.iac_isbn
#     where spp._latest
#     ;;
#   }



#   dimension_group: _effective_from {
#     hidden: yes
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: CAST(${TABLE}."_EFFECTIVE_FROM" AS TIMESTAMP_NTZ) ;;
#   }

#   dimension_group: _effective_to {
#     hidden: yes
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: CAST(${TABLE}."_EFFECTIVE_TO" AS TIMESTAMP_NTZ) ;;
#   }

#   dimension: _latest {
#     hidden: yes
#     type: yesno
#     sql: ${TABLE}."_LATEST" ;;
#   }

#   dimension_group: _ldts {
#     hidden: yes
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."_LDTS" ;;
#   }

#   dimension: _rsrc {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."_RSRC" ;;
#   }

#   dimension: code_type {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."CODE_TYPE" ;;
#   }

#   dimension: context_id {
#     hidden: yes
#     description: "Context ID of provisioned product"
#     type: string
#     sql: ${TABLE}."CONTEXT_ID" ;;
#   }

#   dimension: core_text_isbn {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."CORE_TEXT_ISBN" ;;
#   }

#   dimension_group: date_added {
#     description: "Provisioned product added date"
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: CAST(${TABLE}."DATE_ADDED" AS TIMESTAMP_NTZ) ;;
#   }

#   dimension: deleted {
#     hidden: yes
#     type: yesno
#     sql: ${TABLE}."DELETED" ;;
#   }

#   dimension_group: expiration {
#     hidden: yes
#     description: "Provisioned product expiration date"
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: CAST(${TABLE}."EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
#   }

#   dimension: hash_diff {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."HASH_DIFF" ;;
#   }

#   dimension: hub_provisioned_product_key {
#     hidden: yes
#     primary_key: yes
#     type: string
#     sql: ${TABLE}."HUB_PROVISIONED_PRODUCT_KEY" ;;
#   }

#   dimension: iac_isbn {
#     hidden: yes
#     description: "IAC ISBN of provisioned product"
#     type: string
#     sql: ${TABLE}."IAC_ISBN" ;;
#   }

#   dimension: institution_id {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."INSTITUTION_ID" ;;
#   }

#   dimension: modified_by {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."MODIFIED_BY" ;;
#   }

#   dimension: order_number {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."ORDER_NUMBER" ;;
#   }

#   dimension_group: payment {
#     hidden: yes
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: CAST(${TABLE}."PAYMENT_DATE" AS TIMESTAMP_NTZ) ;;
#   }

#   dimension: payment_type {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."PAYMENT_TYPE" ;;
#   }

#   dimension: product_id {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."PRODUCT_ID" ;;
#   }

#   dimension: provisioning_type {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."PROVISIONING_TYPE" ;;
#   }

#   dimension: region {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."REGION" ;;
#   }

#   dimension_group: rsrc_timestamp {
#     hidden: yes
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: CAST(${TABLE}."RSRC_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
#   }

#   dimension: source {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."SOURCE" ;;
#   }

#   dimension: source_id {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."SOURCE_ID" ;;
#   }

#   dimension: src_environment {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."SRC_ENVIRONMENT" ;;
#   }

#   dimension: src_platform {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."SRC_PLATFORM" ;;
#   }

#   dimension: user_environment {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."USER_ENVIRONMENT" ;;
#   }

#   dimension: user_sso_guid {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#   }

#   dimension: user_type {
#     hidden: yes
#     type: string
#     sql: ${TABLE}."USER_TYPE" ;;
#   }

#   dimension: merged_guid {
#     hidden: yes
#     type: string
#   }

#   dimension: net_price {
#     hidden: yes
#     type: number
#     value_format: "$#.00;($#.00)"
#     sql: ${TABLE}.net_price ;;
#     description: "Net price of provisioned product"
#   }

#   dimension: total_user_product_value  {
#     description: "Sum of net price for all of a users provisioned products"
#     hidden: no
#     type: number
#     value_format: "$#.00;($#.00)"
#   }

#   measure: average_total_product_value_per_user {
#     type: number
#     sql: sum(${net_price}) / nullif(count(distinct ${merged_guid}),0)  ;;
#     value_format: "$#.00;($#.00)"
#   }

#   measure: provisioned_products_per_user {
#     type: number
#     sql: count(distinct ${hub_provisioned_product_key}) / nullif(count(distinct ${merged_guid}),0)  ;;
#   }

#   measure: count {
#     hidden: yes
#     type: count
#     drill_fields: []
#   }
# }
