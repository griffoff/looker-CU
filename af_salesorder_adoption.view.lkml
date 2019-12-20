explore: af_salesorder_adoption {}
view: af_salesorder_adoption {
  derived_table: {
    sql:with raw_sales as (select _file, _line, short_item_no_parent, sales_type_cd, reason_cd, extended_amt_usd, territory_skey, product_skey_bu, cust_no_ship, quantity, invoice_dt, order_taken_by, order_type_cd, line_type_cd, order_no, _fivetran_synced, order_line_no, company_cd from STRATEGY.ADOPTION_PIVOT.FY17_SALES_ADOPTIONPIVOT
        UNION
        select * from STRATEGY.ADOPTION_PIVOT.FY18_SALES_ADOPTIONPIVOT
        UNION
        select * from STRATEGY.ADOPTION_PIVOT.FY19_SALES_ADOPTIONPIVOT),
        sales_orders1 as (
        Select sal.*,
               ter.gsf_cd,
               prod.isbn_13,
               prod.division_cd,
               prod.pub_series_de,
               prod.tech_prod_cd,
               prod.print_digital_config_de,
               cust.mkt_seg_maj_de,
               ent.institution_nm,
               ent.state_cd,
               dim_date.fiscalyearvalue,
               coalesce(pfmt.course_code_description,'.') as course_code_description,
               concat(concat(concat(concat(concat(concat(ent.institution_nm,'|'),ent.state_cd),'|'),coalesce(pfmt.course_code_description,'.')),'|'),prod.pub_series_de) as adoption_key,
               concat(concat(concat(concat(ent.institution_nm,'|'),coalesce(pfmt.course_code_description,'.')),'|'),prod.pub_series_de) as old_adoption_key,
              CASE WHEN prod.isbn_13 = '9781337792615' THEN 'Chegg Tutor' ELSE 'X' END AS chegg_tutor_flag,
              CASE WHEN sal.order_type_cd = 'SX' AND UPPER(sal.line_type_cd) = 'X' THEN 'Consignment/Rental Inventory Transfer'
                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) = 'RS' THEN 'Consignment/Rental Inventory Transfer'
                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) IN ('R1','R2','R3','R4','R5') THEN 'Consignment Rental'
                   WHEN sal.order_type_cd = 'SV' THEN 'Rental Sale'
                   WHEN sal.order_type_cd = 'CV' AND UPPER(sal.line_type_cd) IN ('C1','C2','C3','C4','C5') THEN 'Consignment Rental Return'
                   WHEN sal.order_type_cd = 'CV' AND UPPER(sal.line_type_cd) IN ('CE') THEN 'Rental Return'
                   WHEN sal.order_type_cd = 'EB' THEN 'Accrual Reversal'
                   WHEN sal.order_type_cd = 'SE' AND UPPER(sal.line_type_cd) IN ('RN') THEN 'Amazon Rental'
                ELSE 'X' END AS cl_rental,
               CASE WHEN order_no IN ('97281659','97378813','97379065','97379085','97424575','97424682') THEN '23K Order'
              ELSE 'X' END AS Order23K
              --,case when (sal.order_taken_by = 'ICHAPTERS' AND cust.mkt_seg_maj_de = 'End User') then 'D2S' else 'Channel' end as Purchase_Method
        from  raw_sales sal
          left JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (sal."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
          left JOIN STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT  prod ON (sal."PRODUCT_SKEY_BU") = (prod."PRODUCT_SKEY")
          left JOIN prod.dw_ga.dim_date  AS dim_date ON (TO_CHAR(TO_DATE(sal."INVOICE_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue), 'YYYY-MM-DD'))
          left JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (sal."CUST_NO_SHIP") = (cust."CUST_NO")
          left JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT  ent ON (ent."ENTITY_NO") = (cust."ENTITY_NO")
          left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd)
            select
            adoption_key as sales_adoption_key,
            old_adoption_key as sales_old_adoption_key,
            institution_nm as sales_institution_nm,
            state_cd as sales_state_cd,
            course_code_description as sales_course_code_description,
            pub_series_de as sales_pub_series_de,
            SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_ebook_units,
            SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_ebook_units,
            SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_ebook_units,
            SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_ebook_sales,
            SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_ebook_sales,
            SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_ebook_sales,
            SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_core_units,
            SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_core_units,
            SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_core_units,
            SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_print_core_sales,
            SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_core_sales,
            SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_core_sales,
            SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_other_units,
            SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_other_units,
            SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_other_units,
            SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_print_other_sales,
            SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_other_sales,
            SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_other_sales,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_core_units,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_core_units,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_core_units,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_custom_print_core_sales,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_core_sales,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_core_sales,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_other_units,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_other_units,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_other_units,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_custom_print_other_sales,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_other_sales,
            SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_other_sales,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_standalone_units,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_standalone_units,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_standalone_units,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_other_digital_standalone_sales,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_standalone_sales,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_standalone_sales,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_other_digital_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_standalone_units,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_standalone_units,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_standalone_units,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_core_digital_standalone_sales,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_standalone_sales,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_standalone_sales,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_core_digital_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_LLF_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_LLF_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_LLF_bundle_units,
            SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_LLF_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_LLF_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_LLF_bundle_sales,
            SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_CU_units,
            SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_CU_units,
            SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_CU_units,
            SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_CU_sales,
            SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_CU_sales,
            SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_CU_sales
          from sales_orders1

            WHERE Order23K = 'X'
            AND cl_rental IN ('X','Accrual Reversal')
            AND chegg_tutor_flag = 'X'
            AND UPPER(institution_nm) NOT IN ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
                                              'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC', 'FOLLETT''S CORP', 'WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
            AND reason_cd NOT IN ('980','AMC','CHS')
            AND sales_type_cd = 'DOM'
            AND short_item_no_parent = '-1'
            AND gsf_cd = 'HED'
             GROUP BY 1,2,3,4,5,6
 ;;
sql_trigger_value: Select * from DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_SALES_ORDERS ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sales_adoption_key {
    type: string
    sql: ${TABLE}."SALES_ADOPTION_KEY" ;;
  }

  dimension: sales_old_adoption_key {
    type: string
    sql: ${TABLE}."SALES_OLD_ADOPTION_KEY" ;;
  }

  dimension: sales_institution_nm {
    type: string
    sql: ${TABLE}."SALES_INSTITUTION_NM" ;;
  }

  dimension: sales_state_cd {
    type: string
    sql: ${TABLE}."SALES_STATE_CD" ;;
  }

  dimension: sales_course_code_description {
    type: string
    sql: ${TABLE}."SALES_COURSE_CODE_DESCRIPTION" ;;
  }

  dimension: sales_pub_series_de {
    type: string
    sql: ${TABLE}."SALES_PUB_SERIES_DE" ;;
  }

  dimension: purchase_method {
    type: string
    sql: ${TABLE}."Purchase_Method" ;;
  }

  dimension: FY17_ebook_units {
    type: number
    sql: ${TABLE}."FY17_EBOOK_UNITS" ;;
  }

  dimension: FY18_ebook_units {
    type: number
    sql: ${TABLE}."FY18_EBOOK_UNITS" ;;
  }

  dimension: FY19_ebook_units {
    type: number
    sql: ${TABLE}."FY19_EBOOK_UNITS" ;;
  }

  dimension: FY17_ebook_sales {
    type: number
    sql: ${TABLE}."FY17_EBOOK_SALES" ;;
  }

  dimension: FY18_ebook_sales {
    type: number
    sql: ${TABLE}."FY18_EBOOK_SALES" ;;
  }

  dimension: FY19_ebook_sales {
    type: number
    sql: ${TABLE}."FY19_EBOOK_SALES" ;;
  }

  dimension: FY17_print_core_units {
    type: number
    sql: ${TABLE}."FY17_PRINT_CORE_UNITS" ;;
  }

  dimension: FY18_print_core_units {
    type: number
    sql: ${TABLE}."FY18_PRINT_CORE_UNITS" ;;
  }

  dimension: FY19_print_core_units {
    type: number
    sql: ${TABLE}."FY19_PRINT_CORE_UNITS" ;;
  }

  dimension: FY17_print_core_sales {
    type: number
    sql: ${TABLE}."FY17_PRINT_CORE_SALES" ;;
  }

  dimension: FY18_print_core_sales {
    type: number
    sql: ${TABLE}."FY18_PRINT_CORE_SALES" ;;
  }

  dimension: FY19_print_core_sales {
    type: number
    sql: ${TABLE}."FY19_PRINT_CORE_SALES" ;;
  }

  dimension: FY17_print_other_units {
    type: number
    sql: ${TABLE}."FY17_PRINT_OTHER_UNITS" ;;
  }

  dimension: FY18_print_other_units {
    type: number
    sql: ${TABLE}."FY18_PRINT_OTHER_UNITS" ;;
  }

  dimension: FY19_print_other_units {
    type: number
    sql: ${TABLE}."FY19_PRINT_OTHER_UNITS" ;;
  }

  dimension: FY17_print_other_sales {
    type: number
    sql: ${TABLE}."FY17_PRINT_OTHER_SALES" ;;
  }

  dimension: FY18_print_other_sales {
    type: number
    sql: ${TABLE}."FY18_PRINT_OTHER_SALES" ;;
  }

  dimension: FY19_print_other_sales {
    type: number
    sql: ${TABLE}."FY19_PRINT_OTHER_SALES" ;;
  }

  dimension: FY17_custom_print_core_units {
    type: number
    sql: ${TABLE}."FY17_CUSTOM_PRINT_CORE_UNITS" ;;
  }

  dimension: FY18_custom_print_core_units {
    type: number
    sql: ${TABLE}."FY18_CUSTOM_PRINT_CORE_UNITS" ;;
  }

  dimension: FY19_custom_print_core_units {
    type: number
    sql: ${TABLE}."FY19_CUSTOM_PRINT_CORE_UNITS" ;;
  }

  dimension: FY17_custom_print_core_sales {
    type: number
    sql: ${TABLE}."FY17_CUSTOM_PRINT_CORE_SALES" ;;
  }

  dimension: FY18_custom_print_core_sales {
    type: number
    sql: ${TABLE}."FY18_CUSTOM_PRINT_CORE_SALES" ;;
  }

  dimension: FY19_custom_print_core_sales {
    type: number
    sql: ${TABLE}."FY19_CUSTOM_PRINT_CORE_SALES" ;;
  }

  dimension: FY17_custom_print_other_units {
    type: number
    sql: ${TABLE}."FY17_CUSTOM_PRINT_OTHER_UNITS" ;;
  }

  dimension: FY18_custom_print_other_units {
    type: number
    sql: ${TABLE}."FY18_CUSTOM_PRINT_OTHER_UNITS" ;;
  }

  dimension: FY19_custom_print_other_units {
    type: number
    sql: ${TABLE}."FY19_CUSTOM_PRINT_OTHER_UNITS" ;;
  }

  dimension: FY17_custom_print_other_sales {
    type: number
    sql: ${TABLE}."FY17_CUSTOM_PRINT_OTHER_SALES" ;;
  }

  dimension: FY18_custom_print_other_sales {
    type: number
    sql: ${TABLE}."FY18_CUSTOM_PRINT_OTHER_SALES" ;;
  }

  dimension: FY19_custom_print_other_sales {
    type: number
    sql: ${TABLE}."FY19_CUSTOM_PRINT_OTHER_SALES" ;;
  }

  dimension: FY17_other_digital_standalone_units {
    type: number
    sql: ${TABLE}."FY17_OTHER_DIGITAL_STANDALONE_UNITS" ;;
  }

  dimension: FY18_other_digital_standalone_units {
    type: number
    sql: ${TABLE}."FY18_OTHER_DIGITAL_STANDALONE_UNITS" ;;
  }

  dimension: FY19_other_digital_standalone_units {
    type: number
    sql: ${TABLE}."FY19_OTHER_DIGITAL_STANDALONE_UNITS" ;;
  }

  dimension: FY17_other_digital_standalone_sales {
    type: number
    sql: ${TABLE}."FY17_OTHER_DIGITAL_STANDALONE_SALES" ;;
  }

  dimension: FY18_other_digital_standalone_sales {
    type: number
    sql: ${TABLE}."FY18_OTHER_DIGITAL_STANDALONE_SALES" ;;
  }

  dimension: FY19_other_digital_standalone_sales {
    type: number
    sql: ${TABLE}."FY19_OTHER_DIGITAL_STANDALONE_SALES" ;;
  }

  dimension: FY17_other_digital_bundle_units {
    type: number
    sql: ${TABLE}."FY17_OTHER_DIGITAL_BUNDLE_UNITS" ;;
  }

  dimension: FY18_other_digital_bundle_units {
    type: number
    sql: ${TABLE}."FY18_OTHER_DIGITAL_BUNDLE_UNITS" ;;
  }

  dimension: FY19_other_digital_bundle_units {
    type: number
    sql: ${TABLE}."FY19_OTHER_DIGITAL_BUNDLE_UNITS" ;;
  }

  dimension: FY17_other_digital_bundle_sales {
    type: number
    sql: ${TABLE}."FY17_OTHER_DIGITAL_BUNDLE_SALES" ;;
  }

  dimension: FY18_other_digital_bundle_sales {
    type: number
    sql: ${TABLE}."FY18_OTHER_DIGITAL_BUNDLE_SALES" ;;
  }

  dimension: FY19_other_digital_bundle_sales {
    type: number
    sql: ${TABLE}."FY19_OTHER_DIGITAL_BUNDLE_SALES" ;;
  }

  dimension: FY17_core_digital_standalone_units {
    type: number
    sql: ${TABLE}."FY17_CORE_DIGITAL_STANDALONE_UNITS" ;;
  }

  dimension: FY18_core_digital_standalone_units {
    type: number
    sql: ${TABLE}."FY18_CORE_DIGITAL_STANDALONE_UNITS" ;;
  }

  dimension: FY19_core_digital_standalone_units {
    type: number
    sql: ${TABLE}."FY19_CORE_DIGITAL_STANDALONE_UNITS" ;;
  }

  dimension: FY17_core_digital_standalone_sales {
    type: number
    sql: ${TABLE}."FY17_CORE_DIGITAL_STANDALONE_SALES" ;;
  }

  dimension: FY18_core_digital_standalone_sales {
    type: number
    sql: ${TABLE}."FY18_CORE_DIGITAL_STANDALONE_SALES" ;;
  }

  dimension: FY19_core_digital_standalone_sales {
    type: number
    sql: ${TABLE}."FY19_CORE_DIGITAL_STANDALONE_SALES" ;;
  }

  dimension: FY17_core_digital_bundle_units {
    type: number
    sql: ${TABLE}."FY17_CORE_DIGITAL_BUNDLE_UNITS" ;;
  }

  dimension: FY18_core_digital_bundle_units {
    type: number
    sql: ${TABLE}."FY18_CORE_DIGITAL_BUNDLE_UNITS" ;;
  }

  dimension: FY19_core_digital_bundle_units {
    type: number
    sql: ${TABLE}."FY19_CORE_DIGITAL_BUNDLE_UNITS" ;;
  }

  dimension: FY17_core_digital_bundle_sales {
    type: number
    sql: ${TABLE}."FY17_CORE_DIGITAL_BUNDLE_SALES" ;;
  }

  dimension: FY18_core_digital_bundle_sales {
    type: number
    sql: ${TABLE}."FY18_CORE_DIGITAL_BUNDLE_SALES" ;;
  }

  dimension: FY19_core_digital_bundle_sales {
    type: number
    sql: ${TABLE}."FY19_CORE_DIGITAL_BUNDLE_SALES" ;;
  }

  dimension: FY17_LLF_bundle_units {
    type: number
    sql: ${TABLE}."FY17_LLF_BUNDLE_UNITS" ;;
  }

  dimension: FY18_LLF_bundle_units {
    type: number
    sql: ${TABLE}."FY18_LLF_BUNDLE_UNITS" ;;
  }

  dimension: FY19_LLF_bundle_units {
    type: number
    sql: ${TABLE}."FY19_LLF_BUNDLE_UNITS" ;;
  }

  dimension: FY17_LLF_bundle_sales {
    type: number
    sql: ${TABLE}."FY17_LLF_BUNDLE_SALES" ;;
  }

  dimension: FY18_LLF_bundle_sales {
    type: number
    sql: ${TABLE}."FY18_LLF_BUNDLE_SALES" ;;
  }

  dimension: FY19_LLF_bundle_sales {
    type: number
    sql: ${TABLE}."FY19_LLF_BUNDLE_SALES" ;;
  }

  dimension: FY17_cu_units {
    type: number
    sql: ${TABLE}."FY17_CU_UNITS" ;;
  }

  dimension: FY18_cu_units {
    type: number
    sql: ${TABLE}."FY18_CU_UNITS" ;;
  }

  dimension: FY19_cu_units {
    type: number
    sql: ${TABLE}."FY19_CU_UNITS" ;;
  }

  dimension: FY17_cu_sales {
    type: number
    sql: ${TABLE}."FY17_CU_SALES" ;;
  }

  dimension: FY18_cu_sales {
    type: number
    sql: ${TABLE}."FY18_CU_SALES" ;;
  }

  dimension: FY19_cu_sales {
    type: number
    sql: ${TABLE}."FY19_CU_SALES" ;;
  }

  set: detail {
    fields: [
      sales_adoption_key,
      sales_old_adoption_key,
      sales_institution_nm,
      sales_state_cd,
      sales_course_code_description,
      sales_pub_series_de,
      purchase_method,
      FY17_ebook_units,
      FY18_ebook_units,
      FY19_ebook_units,
      FY17_ebook_sales,
      FY18_ebook_sales,
      FY19_ebook_sales,
      FY17_print_core_units,
      FY18_print_core_units,
      FY19_print_core_units,
      FY17_print_core_sales,
      FY18_print_core_sales,
      FY19_print_core_sales,
      FY17_print_other_units,
      FY18_print_other_units,
      FY19_print_other_units,
      FY17_print_other_sales,
      FY18_print_other_sales,
      FY19_print_other_sales,
      FY17_custom_print_core_units,
      FY18_custom_print_core_units,
      FY19_custom_print_core_units,
      FY17_custom_print_core_sales,
      FY18_custom_print_core_sales,
      FY19_custom_print_core_sales,
      FY17_custom_print_other_units,
      FY18_custom_print_other_units,
      FY19_custom_print_other_units,
      FY17_custom_print_other_sales,
      FY18_custom_print_other_sales,
      FY19_custom_print_other_sales,
      FY17_other_digital_standalone_units,
      FY18_other_digital_standalone_units,
      FY19_other_digital_standalone_units,
      FY17_other_digital_standalone_sales,
      FY18_other_digital_standalone_sales,
      FY19_other_digital_standalone_sales,
      FY17_other_digital_bundle_units,
      FY18_other_digital_bundle_units,
      FY19_other_digital_bundle_units,
      FY17_other_digital_bundle_sales,
      FY18_other_digital_bundle_sales,
      FY19_other_digital_bundle_sales,
      FY17_core_digital_standalone_units,
      FY18_core_digital_standalone_units,
      FY19_core_digital_standalone_units,
      FY17_core_digital_standalone_sales,
      FY18_core_digital_standalone_sales,
      FY19_core_digital_standalone_sales,
      FY17_core_digital_bundle_units,
      FY18_core_digital_bundle_units,
      FY19_core_digital_bundle_units,
      FY17_core_digital_bundle_sales,
      FY18_core_digital_bundle_sales,
      FY19_core_digital_bundle_sales,
      FY17_LLF_bundle_units,
      FY18_LLF_bundle_units,
      FY19_LLF_bundle_units,
      FY17_LLF_bundle_sales,
      FY18_LLF_bundle_sales,
      FY19_LLF_bundle_sales,
      FY17_cu_units,
      FY18_cu_units,
      FY19_cu_units,
      FY17_cu_sales,
      FY18_cu_sales,
      FY19_cu_sales
    ]
  }
}
