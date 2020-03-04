view: sales_orders_forecasting {
  derived_table: {
    sql: With sales_ad as (
          Select sal.*,ter.gsf_cd,prod.isbn_13,prod.division_cd,prod.pub_series_de,prod.tech_prod_cd,prod.print_digital_config_de,ent.institution_nm,ent.state_de as ent_state_de,dim_date.fiscalyearvalue,pf_master.course_as_provided_by_prd_team
              ,concat(concat(concat(concat(institution_nm,'|'),course_as_provided_by_prd_team),'|'),prod.pub_series_de) as adoption_key
        from  DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_SALES_ORDERS sal
          LEFT JOIN STRATEGY.DW.DM_TERRITORIES_8_12_19 ter ON (sal."TERRITORY_SKEY")=(ter."TERRITORY_SKEY")
          LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS  prod ON (sal."PRODUCT_SKEY_BU") = (prod."PRODUCT_SKEY")
          LEFT JOIN DW_GA.DIM_DATE  AS dim_date ON (TO_CHAR(TO_DATE(sal."INVOICE_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue ), 'YYYY-MM-DD'))
          LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_CUSTOMERS  cust ON (sal."CUST_NO_SHIP") = (cust."CUST_NO")
          LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_ENTITIES  ent ON (ent."ENTITY_NO") = (cust."ENTITY_NO")
          LEFT JOIN UPLOADS.CU.E1_PRODUCT_FAMILY_MASTER pf_master ON (pf_master."PF_CODE") = (prod."PROD_FAMILY_CD")
          Where pf_master._file ilike 'E1 Product Family Master(12-20-18).csv'
        ) select * from sales_ad
       ;;
      persist_for: "240 hours"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: extended_amt_usd_measure  {
    label: "Sum Of Sales"
    type: sum
    sql:   ${TABLE}."EXTENDED_AMT_USD" ;;
  }

  dimension: concat_primary {
    sql: Concat(Concat(Concat(concat(${company_cd},${invoice_dt}),${order_no}),${order_line_no}),${order_type_cd})  ;;
    primary_key: yes
    hidden: yes
  }

  dimension: print_digital_config_de {}
  dimension: tech_prod_cd {}

  dimension: chegg_tutor_flag {
    label: "Chegg Tutor"
    description: "calculated field"
    case: {
      when: {
        sql: ${isbn_13} ilike '9781337792615' ;;
        label: "Chegg_Tutor"
      }
      else: "X"
    }
  }

  dimension: CL_Rental {
    label: "CL Rental"
    description: "calculated field"
    case: {
      when: {
        sql: ${order_type_cd} ilike 'SX' AND ${line_type_cd} ilike 'X' ;;
        label: "Consingment/Rental Inventory Transfer"
      }
      when: {
        sql: ${order_type_cd} ilike 'SV' AND ${line_type_cd} ilike 'RS' ;;
        label: "Consingment/Rental Inventory Transfer"
      }
      when: {
        sql: ${order_type_cd} ilike 'SV' AND (UPPER(${line_type_cd}) IN ('R1','R2','R3','R4','R5')) ;;
        label: "Consingment Rental"
      }
      when: {
        sql: ${order_type_cd} ilike 'CV' AND (UPPER(${line_type_cd}) IN ('C1','C2','C3','C4','C5')) ;;
        label: "Consingment Rental Return"
      }
      when: {
        sql: ${order_type_cd} ilike 'CV' OR ${line_type_cd} ilike 'CE' ;;
        label: "Rental Return"
      }
      when: {
        sql: ${order_type_cd} ilike 'EB' ;;
        label: "Accrual Reversal"
      }
      when: {
        sql: ${order_type_cd} ilike 'SE' AND  ${line_type_cd} ilike 'RN';;
        label: "Amazon Rental"
      }
      else: "X"
    }
  }

  dimension: 23K_Order{
    label: "23K order"
    description: "Calculated field"
    case: {
      when: {
        sql: ${order_no} IN (97281659,97378813,97379065,97379085,97424575,97424682) ;;
        label: "23K Order"
      }
      else: "X"
    }
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: basis_unit_price {
    type: number
    sql: ${TABLE}."BASIS_UNIT_PRICE" ;;
  }

  dimension: business_unit_cd {
    type: number
    sql: ${TABLE}."BUSINESS_UNIT_CD" ;;
  }

  dimension: business_unit_de {
    type: string
    sql: ${TABLE}."BUSINESS_UNIT_DE" ;;
  }

  dimension: carrier_no {
    type: number
    sql: ${TABLE}."CARRIER_NO" ;;
  }

  dimension: carrier_de {
    type: string
    sql: ${TABLE}."CARRIER_DE" ;;
  }

  dimension: city_nm {
    type: string
    sql: ${TABLE}."CITY_NM" ;;
  }

  dimension: company_cd {
    type: number
    sql: ${TABLE}."COMPANY_CD" ;;
  }

  dimension: company_de {
    type: string
    sql: ${TABLE}."COMPANY_DE" ;;
  }

  dimension: currency_cd {
    type: string
    sql: ${TABLE}."CURRENCY_CD" ;;
  }

  dimension: currency_de {
    type: string
    sql: ${TABLE}."CURRENCY_DE" ;;
  }

  dimension: cust_no_bill {
    type: number
    sql: ${TABLE}."CUST_NO_BILL" ;;
  }

  dimension: cust_no_ship {
    type: number
    sql: ${TABLE}."CUST_NO_SHIP" ;;
  }

  dimension: cust_po_no {
    type: string
    sql: ${TABLE}."CUST_PO_NO" ;;
  }

  dimension: discount_rate {
    type: number
    sql: ${TABLE}."DISCOUNT_RATE" ;;
  }

  dimension: extended_amt_usd {
    type: number
    sql: ${TABLE}."EXTENDED_AMT_USD" ;;
  }

  dimension: extended_amt_local_curr {
    type: number
    sql: ${TABLE}."EXTENDED_AMT_LOCAL_CURR" ;;
  }

  dimension: freight_cd {
    type: string
    sql: ${TABLE}."FREIGHT_CD" ;;
  }

  dimension: freight_de {
    type: string
    sql: ${TABLE}."FREIGHT_DE" ;;
  }

  dimension: gl_dt {
    type: date
    sql: ${TABLE}."GL_DT" ;;
  }

  dimension: inv_impact_flg {
    type: number
    sql: ${TABLE}."INV_IMPACT_FLG" ;;
  }

  dimension: invoice_no {
    type: number
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_dt {
    type: date
    sql: ${TABLE}."INVOICE_DT" ;;
  }

  dimension: jde_quantity {
    type: number
    sql: ${TABLE}."JDE_QUANTITY" ;;
  }

  dimension: kit_flg {
    type: number
    sql: ${TABLE}."KIT_FLG" ;;
  }

  dimension: line_type_cd {
    type: string
    sql: ${TABLE}."LINE_TYPE_CD" ;;
  }

  dimension: line_type_de {
    type: string
    sql: ${TABLE}."LINE_TYPE_DE" ;;
  }

  dimension: mailing_nm {
    type: string
    sql: ${TABLE}."MAILING_NM" ;;
  }

  dimension: management_entity_cd {
    type: number
    sql: ${TABLE}."MANAGEMENT_ENTITY_CD" ;;
  }

  dimension: management_entity_de {
    type: string
    sql: ${TABLE}."MANAGEMENT_ENTITY_DE" ;;
  }

  dimension: net_unit_price {
    type: number
    sql: ${TABLE}."NET_UNIT_PRICE" ;;
  }

  dimension: order_dt {
    type: date
    sql: ${TABLE}."ORDER_DT" ;;
  }

  dimension: order_no {
    type: number
    sql: ${TABLE}."ORDER_NO" ;;
  }

  dimension: order_line_no {
    type: number
    sql: ${TABLE}."ORDER_LINE_NO" ;;
  }

  dimension: order_taken_by {
    type: string
    sql: ${TABLE}."ORDER_TAKEN_BY" ;;
  }

  dimension: order_type_cd {
    type: string
    sql: ${TABLE}."ORDER_TYPE_CD" ;;
  }

  dimension: order_type_de {
    type: string
    sql: ${TABLE}."ORDER_TYPE_DE" ;;
  }

  dimension: order_via_cd {
    type: string
    sql: ${TABLE}."ORDER_VIA_CD" ;;
  }

  dimension: order_via_de {
    type: string
    sql: ${TABLE}."ORDER_VIA_DE" ;;
  }

  dimension: original_order_no {
    type: number
    sql: ${TABLE}."ORIGINAL_ORDER_NO" ;;
  }

  dimension: original_order_line_no {
    type: number
    sql: ${TABLE}."ORIGINAL_ORDER_LINE_NO" ;;
  }

  dimension: original_order_type_cd {
    type: string
    sql: ${TABLE}."ORIGINAL_ORDER_TYPE_CD" ;;
  }

  dimension: original_order_type_de {
    type: string
    sql: ${TABLE}."ORIGINAL_ORDER_TYPE_DE" ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}."POSTAL_CODE" ;;
  }

  dimension: product_skey_bu {
    type: number
    sql: ${TABLE}."PRODUCT_SKEY_BU" ;;
  }

  dimension: product_skey_owner {
    type: number
    sql: ${TABLE}."PRODUCT_SKEY_OWNER" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: returnable_flg {
    type: number
    sql: ${TABLE}."RETURNABLE_FLG" ;;
  }

  dimension: sales_analysis_cd {
    type: string
    sql: ${TABLE}."SALES_ANALYSIS_CD" ;;
  }

  dimension: sales_analysis_de {
    type: string
    sql: ${TABLE}."SALES_ANALYSIS_DE" ;;
  }

  dimension: sales_type_cd {
    type: string
    sql: ${TABLE}."SALES_TYPE_CD" ;;
  }

  dimension: sales_type_de {
    type: string
    sql: ${TABLE}."SALES_TYPE_DE" ;;
  }

  dimension: ship_dt {
    type: string
    sql: ${TABLE}."SHIP_DT" ;;
  }

  dimension: ship_method_cd {
    type: string
    sql: ${TABLE}."SHIP_METHOD_CD" ;;
  }

  dimension: ship_method_de {
    type: string
    sql: ${TABLE}."SHIP_METHOD_DE" ;;
  }

  dimension: short_item_no {
    type: number
    sql: ${TABLE}."SHORT_ITEM_NO" ;;
  }

  dimension: short_item_no_parent {
    type: number
    sql: ${TABLE}."SHORT_ITEM_NO_PARENT" ;;
  }

  dimension: source_promotion {
    type: string
    sql: ${TABLE}."SOURCE_PROMOTION" ;;
  }

  dimension: state_cd {
    type: string
    sql: ${TABLE}."STATE_CD" ;;
  }

  dimension: state_de {
    type: string
    sql: ${TABLE}."STATE_DE" ;;
  }

  dimension: street_1_ad {
    type: string
    sql: ${TABLE}."STREET_1_AD" ;;
  }

  dimension: street_2_ad {
    type: string
    sql: ${TABLE}."STREET_2_AD" ;;
  }

  dimension: street_3_ad {
    type: string
    sql: ${TABLE}."STREET_3_AD" ;;
  }

  dimension: street_4_ad {
    type: string
    sql: ${TABLE}."STREET_4_AD" ;;
  }

  dimension: territory_id {
    type: string
    sql: ${TABLE}."TERRITORY_ID" ;;
  }

  dimension: unit_cost {
    type: number
    sql: ${TABLE}."UNIT_COST" ;;
  }

  dimension: added_dt {
    type: date
    sql: ${TABLE}."ADDED_DT" ;;
  }

  dimension: changed_dt {
    type: string
    sql: ${TABLE}."CHANGED_DT" ;;
  }

  dimension: contract_pricing_flg {
    type: number
    sql: ${TABLE}."CONTRACT_PRICING_FLG" ;;
  }

  dimension: territory_skey {
    type: number
    sql: ${TABLE}."TERRITORY_SKEY" ;;
  }

  dimension: ref_2_no {
    type: string
    sql: ${TABLE}."REF_2_NO" ;;
  }

  dimension: reason_cd {
    type: string
    sql: ${TABLE}."REASON_CD" ;;
  }

  dimension: reason_de {
    type: string
    sql: ${TABLE}."REASON_DE" ;;
  }

  dimension: foreign_domestic_cd {
    type: string
    sql: ${TABLE}."FOREIGN_DOMESTIC_CD" ;;
  }

  dimension: foreign_domestic_de {
    type: string
    sql: ${TABLE}."FOREIGN_DOMESTIC_DE" ;;
  }

  dimension: sales_commission_no {
    type: number
    sql: ${TABLE}."SALES_COMMISSION_NO" ;;
  }

  dimension: microsite_skey {
    type: number
    sql: ${TABLE}."MICROSITE_SKEY" ;;
  }

  dimension: related_company_cd {
    type: string
    sql: ${TABLE}."RELATED_COMPANY_CD" ;;
  }

  dimension: related_order_no {
    type: number
    sql: ${TABLE}."RELATED_ORDER_NO" ;;
  }

  dimension: related_order_line_no {
    type: number
    sql: ${TABLE}."RELATED_ORDER_LINE_NO" ;;
  }

  dimension: related_order_type_cd {
    type: string
    sql: ${TABLE}."RELATED_ORDER_TYPE_CD" ;;
  }

  dimension: related_order_invoice_dt {
    type: date
    sql: ${TABLE}."RELATED_ORDER_INVOICE_DT" ;;
  }

  dimension: age_of_return {
    type: number
    sql: ${TABLE}."AGE_OF_RETURN" ;;
  }

  dimension: bundle_price {
    type: number
    sql: ${TABLE}."BUNDLE_PRICE" ;;
  }

  dimension: list_price {
    type: number
    sql: ${TABLE}."LIST_PRICE" ;;
  }

  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE" ;;
  }

  dimension: value_alloc_price {
    type: number
    sql: ${TABLE}."VALUE_ALLOC_PRICE" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: gsf_cd {
    type: string
    sql: ${TABLE}."GSF_CD" ;;
  }

  dimension: isbn_13 {
    type: string
    sql: ${TABLE}."ISBN_13" ;;
  }

  dimension: division_cd {
    type: string
    sql: ${TABLE}."DIVISION_CD" ;;
  }

  dimension: pub_series_de {
    type: string
    sql: ${TABLE}."PUB_SERIES_DE" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: ent_state_de {
    type: string
    sql: ${TABLE}."ENT_STATE_DE" ;;
  }

  dimension: fiscalyearvalue {
    type: string
    sql: ${TABLE}."FISCALYEARVALUE" ;;
  }

  dimension: course_as_provided_by_prd_team {
    type: string
    sql: ${TABLE}."COURSE_AS_PROVIDED_BY_PRD_TEAM" ;;
  }

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }

  measure:  Core_Digital_Standalone_Sales {
    type: sum
    sql: CASE WHEN print_digital_config_de like 'Core Digital Standalone' THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Core_Digital_Bundle_Sales {
    type: sum
    sql: CASE WHEN print_digital_config_de like 'Core Digital Bundle'  THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Custom_Print_Other_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Custom Print Other'  THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Print_Core_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Print Core'  THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Other_Standalone_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Other Digital Standalone' THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Print_Other_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Print Other'   THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Loose_Leaf_Bundle_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Loose-Leaf Bundle'   THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Other_Digital_Bundle_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Other Digital Bundle'   THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  Custom_Print_Core_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Custom Print Core'   THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  eBook_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'eBooks'   THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  CU_Sales {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Cengage Unlimited'   THEN extended_amt_usd ELSE 0 END ;;
  }

  measure:  CU_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Cengage Unlimited' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Core_Digital_Standalone_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Core Digital Standalone' AND  tech_prod_cd NOT LIKE '05E'  THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Core_Digital_Bundle_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Core Digital Bundle' AND  tech_prod_cd NOT LIKE '05E' THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Custom_Print_Other_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Custom Print Other' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Print_Core_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Print Core' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Other_Standalone_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Other Digital Standalone' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Print_Other_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Print Other' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Loose_Leaf_Bundle_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Loose-Leaf Bundle' AND  tech_prod_cd NOT LIKE '05E' THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Other_Digital_Bundle_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Other Digital Bundle' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Custom_Print_Core_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'Custom Print Core' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  eBook_Units {
    type: sum
    sql: CASE WHEN  print_digital_config_de like 'eBooks' AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure:  Total_Print_net_sales {
    label: "Total Print Net Sales "
    type: sum
    sql: CASE WHEN  print_digital_config_de IN ('Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle')   THEN extended_amt_usd ELSE 0 END ;;
  }

  measure: Total_core_digital_NetSales_Ex_CU {
    label: "Total Core Digital (ex. CU) Net Sales "
    type: sum
    sql: CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle' ) THEN extended_amt_usd ELSE 0 END ;;
  }

  measure: Total_Core_Digital_CU_Net_sales {
    label: "Total Core Digital + CU Net Sales"
    type: sum
    sql:   CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited' )
          THEN extended_amt_usd ELSE 0 END ;;
  }

  measure: Total_Net_sales {
    label: "Total Net Sales"
    type: sum
    sql: CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited','Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle')
          THEN extended_amt_usd ELSE 0 END;;
  }

  measure:  Total_Print_net_units {
    label: "Total Print Net Units "
    type: sum
    sql: CASE WHEN  print_digital_config_de IN ('Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle')
            AND  tech_prod_cd NOT LIKE '05E'  THEN ${quantity} ELSE 0 END ;;
  }

  measure: Total_core_digital_Ex_CU_Net_Units {
    label: "Total Core Digital (ex CU) Net Units"
    type: sum
    sql: CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle' ) AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure: Total_Core_Digital_CU_Net_Units {
    label: "Total Core Digital + CU Net Units "
    type: sum
    sql:   CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited' )
      AND  tech_prod_cd NOT LIKE '05E'   THEN ${quantity} ELSE 0 END ;;
  }

  measure: total_ebook_activations {
    label: "Total eBook activations"
    type: sum
    sql: CASE WHEN print_digital_config_de like 'eBooks' AND  tech_prod_cd NOT LIKE '05E' THEN ebook_consumed_salesorder_forecasting.cu_ebook_units ELSE 0 END ;;
  }




  set: detail {
    fields: [
      _file,
      _line,
      basis_unit_price,
      business_unit_cd,
      business_unit_de,
      carrier_no,
      carrier_de,
      city_nm,
      company_cd,
      company_de,
      currency_cd,
      currency_de,
      cust_no_bill,
      cust_no_ship,
      cust_po_no,
      discount_rate,
      extended_amt_usd,
      extended_amt_local_curr,
      freight_cd,
      freight_de,
      gl_dt,
      inv_impact_flg,
      invoice_no,
      invoice_dt,
      jde_quantity,
      kit_flg,
      line_type_cd,
      line_type_de,
      mailing_nm,
      management_entity_cd,
      management_entity_de,
      net_unit_price,
      order_dt,
      order_no,
      order_line_no,
      order_taken_by,
      order_type_cd,
      order_type_de,
      order_via_cd,
      order_via_de,
      original_order_no,
      original_order_line_no,
      original_order_type_cd,
      original_order_type_de,
      postal_code,
      product_skey_bu,
      product_skey_owner,
      quantity,
      returnable_flg,
      sales_analysis_cd,
      sales_analysis_de,
      sales_type_cd,
      sales_type_de,
      ship_dt,
      ship_method_cd,
      ship_method_de,
      short_item_no,
      short_item_no_parent,
      source_promotion,
      state_cd,
      state_de,
      street_1_ad,
      street_2_ad,
      street_3_ad,
      street_4_ad,
      territory_id,
      unit_cost,
      added_dt,
      changed_dt,
      contract_pricing_flg,
      territory_skey,
      ref_2_no,
      reason_cd,
      reason_de,
      foreign_domestic_cd,
      foreign_domestic_de,
      sales_commission_no,
      microsite_skey,
      related_company_cd,
      related_order_no,
      related_order_line_no,
      related_order_type_cd,
      related_order_invoice_dt,
      age_of_return,
      bundle_price,
      list_price,
      net_price,
      value_alloc_price,
      _fivetran_synced_time,
      gsf_cd,
      isbn_13,
      division_cd,
      pub_series_de,
      institution_nm,
      ent_state_de,
      fiscalyearvalue,
      course_as_provided_by_prd_team,
      adoption_key
    ]
  }
}
