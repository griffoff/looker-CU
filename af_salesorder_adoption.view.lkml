explore: af_salesorder_adoption {}
view: af_salesorder_adoption {
  derived_table: {
    sql:with sales_orders1 as (
        Select sal.*,ter.gsf_cd,prod.isbn_13,prod.division_cd,prod.pub_series_de,prod.tech_prod_cd,prod.print_digital_config_de,ent.institution_nm,ent.state_cd as ent_state,dim_date.fiscalyearvalue,pfmt.course_code_description
              ,concat(concat(concat(concat(institution_nm,'|'),pfmt.course_code_description),'|'),prod.pub_series_de) as adoption_key,
              CASE WHEN isbn_13 = '9781337792615' THEN 'Chegg Tutor' ELSE 'X' END AS chegg_tutor_flag,
              CASE WHEN UPPER(sal.order_type_cd) = 'SX' AND UPPER(sal.line_type_cd) = 'X' THEN 'Consignment/Rental Inventory Transfer'
                   WHEN UPPER(sal.order_type_cd) = 'SV' AND UPPER(sal.line_type_cd) = 'RS' THEN 'Consignment/Rental Inventory Transfer'
                   WHEN UPPER(sal.order_type_cd) = 'SV' AND UPPER(sal.line_type_cd) IN ('R1','R2','R3','R4','R5') THEN 'Consignment Rental'
                   WHEN UPPER(sal.order_type_cd) = 'SV' THEN 'Rental Sale'
                   WHEN UPPER(sal.order_type_cd) = 'CV' AND UPPER(sal.line_type_cd) IN ('C1','C2','C3','C4','C5') THEN 'Consignment Rental Return'
                   WHEN UPPER(sal.order_type_cd) = 'CV' OR UPPER(sal.order_type_cd) IN ('CE') THEN 'Rental Return'
                   WHEN UPPER(sal.order_type_cd) = 'EB' THEN 'Accrual Reversal'
                   WHEN UPPER(sal.order_type_cd) = 'SE' AND UPPER(sal.line_type_cd) IN ('RN') THEN 'Amazon Rental'
                ELSE 'X' END AS cl_rental,
               CASE WHEN order_no::String IN ('97281659','97378813','97379065','97379085','97424575','97424682') THEN '23K Order'
                ELSE 'X' END AS Order23K
        from  STRATEGY.ADOPTION_PIVOT.SALES_UNITS_ADOPTIONPIVOT sal
          LEFT JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (sal."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
          LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS  prod ON (sal."PRODUCT_SKEY_BU") = (prod."PRODUCT_SKEY")
          LEFT JOIN DW_GA.DIM_DATE  AS dim_date ON (TO_CHAR(TO_DATE(sal."INVOICE_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue ), 'YYYY-MM-DD'))
          LEFT JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (sal."CUST_NO_SHIP") = (cust."CUST_NO")
          LEFT JOIN STRATEGY.DW.DM_ENTITIES  ent ON (ent."ENTITY_NO") = (cust."ENTITY_NO")
          LEFT JOIN "STRATEGY"."ADOPTION_PIVOT"."PFMT_ADOPTIONPIVOT" pfmt on pfmt.product_family_code = prod.prod_family_cd
        ) select
            adoption_key,
            institution_nm,
            --SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_ebook_units,
            --SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_ebook_units,
            --SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_ebook_sales,
            --SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_ebook_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_core_units,
            --SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_core_units,
            --SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_core_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_core_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_other_units,
            --SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_other_units,
            --SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_other_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_other_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_core_units,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_core_units,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_core_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_core_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_other_units,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_other_units,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_other_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_other_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_standalone_units,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_standalone_units,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_standalone_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_standalone_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_bundle_units,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_bundle_units,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_bundle_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_bundle_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_standalone_units,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_standalone_units,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_standalone_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_standalone_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_bundle_units,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_bundle_units,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_bundle_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_bundle_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_LLF_bundle_units,
            --SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_LLF_bundle_units,
            --SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_LLF_bundle_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_LLF_bundle_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_CU_units,
            --SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_CU_units,
            --SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_CU_sales,
            --SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_CU_sales,
            SUM(CASE WHEN  print_digital_config_de IN ('Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle') AND fiscalyearvalue = 'FY18'  THEN extended_amt_usd ELSE 0 END) AS Total_Print_net_sales_fy18,
            SUM(CASE WHEN  print_digital_config_de IN ('Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle') AND fiscalyearvalue = 'FY19'  THEN extended_amt_usd ELSE 0 END) AS Total_Print_net_sales_fy19,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle' ) AND fiscalyearvalue = 'FY18' THEN extended_amt_usd ELSE 0 END) AS Total_core_digital_NetSales_Ex_CU_fy18,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle' ) AND fiscalyearvalue = 'FY19' THEN extended_amt_usd ELSE 0 END) AS Total_core_digital_NetSales_Ex_CU_fy19,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited' ) AND fiscalyearvalue = 'FY18' THEN extended_amt_usd ELSE 0 END) AS Total_Core_Digital_CU_Net_sales_fy18,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited' ) AND fiscalyearvalue = 'FY19' THEN extended_amt_usd ELSE 0 END) AS Total_Core_Digital_CU_Net_sales_fy19,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited','Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle')
                 AND fiscalyearvalue = 'FY18'   THEN extended_amt_usd ELSE 0 END) AS  Total_Net_sales_fy18,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited','Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle')
                 AND fiscalyearvalue = 'FY19'   THEN extended_amt_usd ELSE 0 END) AS  Total_Net_sales_fy19,
            SUM(CASE WHEN  print_digital_config_de IN ('Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle')
                AND  tech_prod_cd NOT LIKE '05E' AND fiscalyearvalue = 'FY18'  THEN quantity ELSE 0 END) AS Total_Print_net_units_fy18,
            SUM(CASE WHEN  print_digital_config_de IN ('Print Core','Print Other','Custom Print Core','Custom Print Other','eBooks','Other Digital Standalone','Other Digital Bundle')
                AND  tech_prod_cd NOT LIKE '05E' AND fiscalyearvalue = 'FY19'  THEN quantity ELSE 0 END) AS Total_Print_net_units_fy19,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle' ) AND  tech_prod_cd NOT LIKE '05E' AND fiscalyearvalue = 'FY18' THEN quantity ELSE 0 END) AS Total_core_digital_Ex_CU_Net_Units_fy18,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle' ) AND  tech_prod_cd NOT LIKE '05E' AND fiscalyearvalue = 'FY19' THEN quantity ELSE 0 END) AS Total_core_digital_Ex_CU_Net_Units_fy19,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited' )
                AND  tech_prod_cd NOT LIKE '05E' AND fiscalyearvalue = 'FY18'   THEN quantity ELSE 0 END) AS Total_Core_Digital_CU_Net_Units_fy18,
            SUM(CASE WHEN print_digital_config_de IN ('Core Digital Standalone','Loose-Leaf Bundle','Core Digital Bundle','Cengage Unlimited' )
                AND  tech_prod_cd NOT LIKE '05E' AND fiscalyearvalue = 'FY19'  THEN quantity ELSE 0 END) AS Total_Core_Digital_CU_Net_Units_fy19
          from sales_orders1

            WHERE Order23K = 'X' AND cl_rental IN ('X','Accrual Reversal') AND chegg_tutor_flag = 'X'
             AND UPPER(institution_nm) NOT IN ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
                                              'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC','WEBASSIGN MASTER BILLING','FOLLETT''S CORP')
             AND reason_cd NOT IN ('980','AMC','CHS') AND sales_type_cd = 'DOM' AND short_item_no_parent = '-1' AND gsf_cd = 'HED'
             GROUP BY 1,2
 ;;
sql_trigger_value: Select * from DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_SALES_ORDERS ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: total_print_net_sales_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY18" ;;
  }

  dimension: total_print_net_sales_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY19" ;;
  }

  dimension: total_core_digital_netsales_ex_cu_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY18" ;;
  }

  dimension: total_core_digital_netsales_ex_cu_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY19" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_SALES_FY18" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_SALES_FY19" ;;
  }

  dimension: total_net_sales_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_NET_SALES_FY18" ;;
  }

  dimension: total_net_sales_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_NET_SALES_FY19" ;;
  }

  dimension: total_print_net_units_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY18" ;;
  }

  dimension: total_print_net_units_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY19" ;;
  }

  dimension: total_core_digital_ex_cu_net_units_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY18" ;;
  }

  dimension: total_core_digital_ex_cu_net_units_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY19" ;;
  }

  dimension: total_core_digital_cu_net_units_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY18" ;;
  }

  dimension: total_core_digital_cu_net_units_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY19" ;;
  }

  measure: sum_fy18 {
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY18" ;;
  }

  measure: sum_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY19" ;;
  }

  set: detail {
    fields: [
      adoption_key,
      institution_nm,
      total_print_net_sales_fy18,
      total_print_net_sales_fy19,
      total_core_digital_netsales_ex_cu_fy18,
      total_core_digital_netsales_ex_cu_fy19,
      total_core_digital_cu_net_sales_fy18,
      total_core_digital_cu_net_sales_fy19,
      total_net_sales_fy18,
      total_net_sales_fy19,
      total_print_net_units_fy18,
      total_print_net_units_fy19,
      total_core_digital_ex_cu_net_units_fy18,
      total_core_digital_ex_cu_net_units_fy19,
      total_core_digital_cu_net_units_fy18,
      total_core_digital_cu_net_units_fy19
    ]
  }
}
