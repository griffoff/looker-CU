# view: dm_sales_orders {
#   sql_table_name: DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_SALES_ORDERS ;;

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#     hidden: yes
#   }

#   dimension_group: _fivetran_synced {
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
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#     hidden: yes
#   }

#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#     hidden: yes
#   }

#   measure: FY19_Core_Digital_Standalone_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Core Digital Standalone' THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Core_Digital_Bundle_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Core Digital Bundle'  THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Custom_Print_Other_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Custom Print Other'  THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Print_Core_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Print Core'  THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Other_Standalone_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Other Digital Standalone' THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Print_Other_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Print Other'   THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Loose_Leaf_Bundle_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Loose-Leaf Bundle'   THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Other_Digital_Bundle_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Other Digital Bundle'   THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_Custom_Print_Core_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Custom Print Core'   THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_eBook_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'eBooks'   THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_CU_Sales {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Cengage Unlimited'   THEN extended_amt_usd ELSE 0 END ;;
#   }

#   measure: FY19_CU_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Cengage Unlimited' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Core_Digital_Standalone_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Core Digital Standalone' AND dm_products.tech_prod_cd NOT LIKE '05E'  THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Core_Digital_Bundle_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Core Digital Bundle' AND dm_products.tech_prod_cd NOT LIKE '05E' THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Custom_Print_Other_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Custom Print Other' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Print_Core_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Print Core' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Other_Standalone_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Other Digital Standalone' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Print_Other_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Print Other' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Loose_Leaf_Bundle_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Loose-Leaf Bundle' AND dm_products.tech_prod_cd NOT LIKE '05E' THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Other_Digital_Bundle_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Other Digital Bundle' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_Custom_Print_Core_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'Custom Print Core' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }

#   measure: FY19_eBook_Units {
#     type: sum
#     sql: CASE WHEN dm_products.print_digital_config_de like 'eBooks' AND dm_products.tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
#   }



#   dimension_group: added_dt {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."ADDED_DT" ;;
#   }

#   dimension: age_of_return {
#     type: number
#     sql: ${TABLE}."AGE_OF_RETURN" ;;
#   }

#   dimension: basis_unit_price {
#     type: number
#     sql: ${TABLE}."BASIS_UNIT_PRICE" ;;
#   }

#   dimension: bundle_price {
#     type: number
#     sql: ${TABLE}."BUNDLE_PRICE" ;;
#   }

#   dimension: business_unit_cd {
#     type: number
#     sql: ${TABLE}."BUSINESS_UNIT_CD" ;;
#   }

#   dimension: business_unit_de {
#     type: string
#     sql: ${TABLE}."BUSINESS_UNIT_DE" ;;
#   }

#   dimension: carrier_de {
#     type: string
#     sql: ${TABLE}."CARRIER_DE" ;;
#   }

#   dimension: carrier_no {
#     type: number
#     sql: ${TABLE}."CARRIER_NO" ;;
#   }

#   dimension: changed_dt {
#     type: string
#     sql: ${TABLE}."CHANGED_DT" ;;
#   }

#   dimension: city_nm {
#     type: string
#     sql: ${TABLE}."CITY_NM" ;;
#   }

#   dimension: company_cd {
#     type: number
#     sql: ${TABLE}."COMPANY_CD" ;;
#   }

#   dimension: company_de {
#     type: string
#     sql: ${TABLE}."COMPANY_DE" ;;
#   }

#   dimension: contract_pricing_flg {
#     type: number
#     sql: ${TABLE}."CONTRACT_PRICING_FLG" ;;
#   }

#   dimension: currency_cd {
#     type: string
#     sql: ${TABLE}."CURRENCY_CD" ;;
#   }

#   dimension: currency_de {
#     type: string
#     sql: ${TABLE}."CURRENCY_DE" ;;
#   }

#   dimension: cust_no_bill {
#     type: number
#     sql: ${TABLE}."CUST_NO_BILL" ;;
#   }

#   dimension: cust_no_ship {
#     type: number
#     sql: ${TABLE}."CUST_NO_SHIP" ;;
#   }

#   dimension: cust_po_no {
#     type: string
#     sql: ${TABLE}."CUST_PO_NO" ;;
#   }

#   dimension: discount_rate {
#     type: number
#     sql: ${TABLE}."DISCOUNT_RATE" ;;
#   }

#   dimension: extended_amt_local_curr {
#     type: number
#     sql: ${TABLE}."EXTENDED_AMT_LOCAL_CURR" ;;
#   }

#   dimension: extended_amt_usd {
#     type: number
#     sql: ${TABLE}."EXTENDED_AMT_USD" ;;
#   }

# measure: extended_amt_usd_measure  {
#   label: "sales"
#   type: sum
#   sql:   ${TABLE}."EXTENDED_AMT_USD" ;;
# }


#   dimension: foreign_domestic_cd {
#     type: string
#     sql: ${TABLE}."FOREIGN_DOMESTIC_CD" ;;
#   }

#   dimension: foreign_domestic_de {
#     type: string
#     sql: ${TABLE}."FOREIGN_DOMESTIC_DE" ;;
#   }

#   dimension: freight_cd {
#     type: string
#     sql: ${TABLE}."FREIGHT_CD" ;;
#   }

#   dimension: freight_de {
#     type: string
#     sql: ${TABLE}."FREIGHT_DE" ;;
#   }

#   dimension_group: gl_dt {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."GL_DT" ;;
#   }

#   dimension: inv_impact_flg {
#     type: number
#     sql: ${TABLE}."INV_IMPACT_FLG" ;;
#   }

#   dimension_group: invoice_dt {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year,
#       fiscal_year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."INVOICE_DT" ;;
#   }

#   dimension: concat_primary {
#     sql: Concat(Concat(Concat(concat(${company_cd},${invoice_dt_date}),${order_no}),${order_line_no}),${order_type_cd})  ;;
#     primary_key: yes
#     hidden: yes
#   }

#   dimension: invoice_no {
#     type: number
#     sql: ${TABLE}."INVOICE_NO" ;;
#   }

#   dimension: jde_quantity {
#     type: number
#     sql: ${TABLE}."JDE_QUANTITY" ;;
#   }

#   dimension: kit_flg {
#     type: number
#     sql: ${TABLE}."KIT_FLG" ;;
#   }

#   dimension: line_type_cd {
#     type: string
#     sql: ${TABLE}."LINE_TYPE_CD" ;;
#   }

#   dimension: line_type_de {
#     type: string
#     sql: ${TABLE}."LINE_TYPE_DE" ;;
#   }

#   dimension: list_price {
#     type: number
#     sql: ${TABLE}."LIST_PRICE" ;;
#   }

#   dimension: mailing_nm {
#     type: string
#     sql: ${TABLE}."MAILING_NM" ;;
#   }

#   dimension: management_entity_cd {
#     type: number
#     sql: ${TABLE}."MANAGEMENT_ENTITY_CD" ;;
#   }

#   dimension: management_entity_de {
#     type: string
#     sql: ${TABLE}."MANAGEMENT_ENTITY_DE" ;;
#   }

#   dimension: microsite_skey {
#     type: number
#     sql: ${TABLE}."MICROSITE_SKEY" ;;
#   }

#   dimension: net_price {
#     type: number
#     sql: ${TABLE}."NET_PRICE" ;;
#   }

#   dimension: net_unit_price {
#     type: number
#     sql: ${TABLE}."NET_UNIT_PRICE" ;;
#   }

#   dimension_group: order_dt {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."ORDER_DT" ;;
#   }

#   dimension: order_line_no {
#     type: number
#     sql: ${TABLE}."ORDER_LINE_NO" ;;
#   }

#   dimension: order_no {
#     type: number
#     sql: ${TABLE}."ORDER_NO" ;;
#   }

#   dimension: order_taken_by {
#     type: string
#     sql: ${TABLE}."ORDER_TAKEN_BY" ;;
#   }

#   dimension: CL_Rental {
#     label: "CL Rental"
#     description: "calculated field"
#     case: {
#       when: {
#         sql: ${order_type_cd} ilike 'SX' AND ${line_type_cd} ilike 'X' ;;
#         label: "Consingment/Rental Inventory Transfer"
#       }
#       when: {
#         sql: ${order_type_cd} ilike 'SV' AND ${line_type_cd} ilike 'RS' ;;
#         label: "Consingment/Rental Inventory Transfer"
#       }
#       when: {
#         sql: ${order_type_cd} ilike 'SV' AND (UPPER(${line_type_cd}) IN ('R1','R2','R3','R4','R5')) ;;
#         label: "Consingment Rental"
#       }
#       when: {
#         sql: ${order_type_cd} ilike 'CV' AND (UPPER(${line_type_cd}) IN ('C1','C2','C3','C4','C5')) ;;
#         label: "Consingment Rental Return"
#       }
#       when: {
#         sql: ${order_type_cd} ilike 'CV' OR ${line_type_cd} ilike 'CE' ;;
#         label: "Rental Return"
#       }
#       when: {
#         sql: ${order_type_cd} ilike 'EB' ;;
#         label: "Accrual Reversal"
#       }
#       when: {
#         sql: ${order_type_cd} ilike 'SE' AND  ${line_type_cd} ilike 'RN';;
#         label: "Amazon Rental"
#       }
#       else: "X"
#     }
#   }

#   dimension: 23K_Order{
#     label: "23K order"
#     description: "Calculated field"
#     case: {
#       when: {
#         sql: ${order_no} IN (97281659,97378813,97379065,97379085,97424575,97424682) ;;
#         label: "23K Order"
#       }
#       else: "X"
#     }
#   }

#   dimension: order_type_cd {
#     type: string
#     sql: ${TABLE}."ORDER_TYPE_CD" ;;
#   }

#   dimension: order_type_de {
#     type: string
#     sql: ${TABLE}."ORDER_TYPE_DE" ;;
#   }

#   dimension: order_via_cd {
#     type: string
#     sql: ${TABLE}."ORDER_VIA_CD" ;;
#   }

#   dimension: order_via_de {
#     type: string
#     sql: ${TABLE}."ORDER_VIA_DE" ;;
#   }

#   dimension: original_order_line_no {
#     type: number
#     sql: ${TABLE}."ORIGINAL_ORDER_LINE_NO" ;;
#   }

#   dimension: original_order_no {
#     type: number
#     sql: ${TABLE}."ORIGINAL_ORDER_NO" ;;
#   }

#   dimension: original_order_type_cd {
#     type: string
#     sql: ${TABLE}."ORIGINAL_ORDER_TYPE_CD" ;;
#   }

#   dimension: original_order_type_de {
#     type: string
#     sql: ${TABLE}."ORIGINAL_ORDER_TYPE_DE" ;;
#   }

#   dimension: postal_code {
#     type: string
#     sql: ${TABLE}."POSTAL_CODE" ;;
#   }

#   dimension: product_skey_bu {
#     type: number
#     sql: ${TABLE}."PRODUCT_SKEY_BU" ;;
#   }

#   dimension: product_skey_owner {
#     type: number
#     sql: ${TABLE}."PRODUCT_SKEY_OWNER" ;;
#   }

#   dimension: quantity {
#     type: number
#     sql: ${TABLE}."QUANTITY" ;;
#   }

#   dimension: quan_units {
#     label: "Units"
#     type: number
#     sql: CASE WHEN dm_products.tec_prod_cd like '05E' THEN ${TABLE}."QUANTITY" ELSE 0 END ;;
#   }

#   dimension: reason_cd {
#     type: string
#     sql: ${TABLE}."REASON_CD" ;;
#   }

#   dimension: reason_de {
#     type: string
#     sql: ${TABLE}."REASON_DE" ;;
#   }

#   dimension: ref_2_no {
#     type: string
#     sql: ${TABLE}."REF_2_NO" ;;
#   }

#   dimension: related_company_cd {
#     type: string
#     sql: ${TABLE}."RELATED_COMPANY_CD" ;;
#   }

#   dimension_group: related_order_invoice_dt {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."RELATED_ORDER_INVOICE_DT" ;;
#   }

#   dimension: related_order_line_no {
#     type: number
#     sql: ${TABLE}."RELATED_ORDER_LINE_NO" ;;
#   }

#   dimension: related_order_no {
#     type: number
#     sql: ${TABLE}."RELATED_ORDER_NO" ;;
#   }

#   dimension: related_order_type_cd {
#     type: string
#     sql: ${TABLE}."RELATED_ORDER_TYPE_CD" ;;
#   }

#   dimension: returnable_flg {
#     type: number
#     sql: ${TABLE}."RETURNABLE_FLG" ;;
#   }

#   dimension: sales_analysis_cd {
#     type: string
#     sql: ${TABLE}."SALES_ANALYSIS_CD" ;;
#   }

#   dimension: sales_analysis_de {
#     type: string
#     sql: ${TABLE}."SALES_ANALYSIS_DE" ;;
#   }

#   dimension: sales_commission_no {
#     type: number
#     sql: ${TABLE}."SALES_COMMISSION_NO" ;;
#   }

#   dimension: sales_type_cd {
#     type: string
#     sql: ${TABLE}."SALES_TYPE_CD" ;;
#   }

#   dimension: sales_type_de {
#     type: string
#     sql: ${TABLE}."SALES_TYPE_DE" ;;
#   }

#   dimension: ship_dt {
#     type: string
#     sql: ${TABLE}."SHIP_DT" ;;
#   }

#   dimension: ship_method_cd {
#     type: string
#     sql: ${TABLE}."SHIP_METHOD_CD" ;;
#   }

#   dimension: ship_method_de {
#     type: string
#     sql: ${TABLE}."SHIP_METHOD_DE" ;;
#   }

#   dimension: short_item_no {
#     type: number
#     sql: ${TABLE}."SHORT_ITEM_NO" ;;
#   }

#   dimension: short_item_no_parent {
#     type: number
#     sql: ${TABLE}."SHORT_ITEM_NO_PARENT" ;;
#   }

#   dimension: source_promotion {
#     type: string
#     sql: ${TABLE}."SOURCE_PROMOTION" ;;
#   }

#   dimension: state_cd {
#     type: string
#     sql: ${TABLE}."STATE_CD" ;;
#   }

#   dimension: state_de {
#     type: string
#     sql: ${TABLE}."STATE_DE" ;;
#   }

#   dimension: street_1_ad {
#     type: string
#     sql: ${TABLE}."STREET_1_AD" ;;
#   }

#   dimension: street_2_ad {
#     type: string
#     sql: ${TABLE}."STREET_2_AD" ;;
#   }

#   dimension: street_3_ad {
#     type: string
#     sql: ${TABLE}."STREET_3_AD" ;;
#   }

#   dimension: street_4_ad {
#     type: string
#     sql: ${TABLE}."STREET_4_AD" ;;
#   }

#   dimension: territory_id {
#     type: string
#     sql: ${TABLE}."TERRITORY_ID" ;;
#   }

#   dimension: territory_skey {
#     type: number
#     sql: ${TABLE}."TERRITORY_SKEY" ;;
#   }

#   dimension: unit_cost {
#     type: number
#     sql: ${TABLE}."UNIT_COST" ;;
#   }

#   dimension: value_alloc_price {
#     type: number
#     sql: ${TABLE}."VALUE_ALLOC_PRICE" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }
# }
