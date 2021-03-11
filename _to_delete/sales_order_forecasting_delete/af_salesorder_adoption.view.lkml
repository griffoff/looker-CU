# explore: af_salesorder_adoption {}
# view: af_salesorder_adoption {
#   derived_table: {
#     sql:
#     ---JOIN TOGETHER ALL FISCAL YEAR FILES FROM SALES ORDERS
#         with raw_sales as (
#         select _file, _line, short_item_no_parent, sales_type_cd, reason_cd, extended_amt_usd, territory_skey, product_skey_bu, cust_no_ship, quantity, invoice_dt, order_taken_by, order_type_cd, line_type_cd, order_no, _fivetran_synced, order_line_no, company_cd, sales_analysis_cd from STRATEGY.ADOPTION_PIVOT.FY17_SALES_ADOPTIONPIVOT
#         UNION
#         select _file, _line, short_item_no_parent, sales_type_cd, reason_cd, extended_amt_usd, territory_skey, product_skey_bu, cust_no_ship, quantity, invoice_dt, order_taken_by, order_type_cd, line_type_cd, order_no, _fivetran_synced, order_line_no, company_cd, sales_analysis_cd from STRATEGY.ADOPTION_PIVOT.FY18_SALES_ADOPTIONPIVOT
#         UNION
#         select _file, _line, short_item_no_parent, sales_type_cd, reason_cd, extended_amt_usd, territory_skey, product_skey_bu, cust_no_ship, quantity, invoice_dt, order_taken_by, order_type_cd, line_type_cd, order_no, _fivetran_synced, order_line_no, company_cd, sales_analysis_cd from STRATEGY.ADOPTION_PIVOT.FY19_SALES_ADOPTIONPIVOT
#         UNION
#         select _file, _line, short_item_no_parent, sales_type_cd, reason_cd, extended_amt_usd, territory_skey, product_skey_bu, cust_no_ship, quantity, invoice_dt, order_taken_by, order_type_cd, line_type_cd, order_no, _fivetran_synced, order_line_no, company_cd, sales_analysis_cd from STRATEGY.ADOPTION_PIVOT.FY20_SALES_ADOPTIONPIVOT),

#   ---PULL IN RESELLERS DATA FROM FY17-20
#         raw_resellers as (
#         select * from STRATEGY.ADOPTION_PIVOT.FY17_FY18_RESELLERS_ADOPTIONPIVOT
#         UNION
#         select * from STRATEGY.ADOPTION_PIVOT.FY19_FY20_RESELLERS_ADOPTIONPIVOT),

#   ---FILTER RAW SALES ORDERS DATA
#       sales_orders1 as (
#       Select sal.*,
#               ter.gsf_cd,
#               prod.isbn_13,
#               prod.division_cd,
#               coalesce(prod.pub_series_de,'Not Specified') as pub_series_de,
#               prod.tech_prod_cd,
#               prod.print_digital_config_de,
#               cust.mkt_seg_maj_de,
#               ent.institution_nm,
#               ent.state_cd,
#               dim_date.fiscalyearvalue,
#               case when pub_series_de = 'Cengage Unlimited' then 'CUADPT'
#                   else coalesce(pfmt.course_code_description,'.') end as course_code_description_1,
#               concat(concat(concat(concat(concat(concat(ent.institution_nm,'|'),ent.state_cd),'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as adoption_key,
#               concat(concat(concat(concat(ent.institution_nm,'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as old_adoption_key,
#             CASE WHEN prod.isbn_13 = '9781337792615' THEN 'Chegg Tutor' ELSE 'X' END AS chegg_tutor_flag,
#             CASE WHEN sal.order_type_cd = 'SX' AND UPPER(sal.line_type_cd) = 'X' THEN 'Consignment/Rental Inventory Transfer'
#                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) = 'RS' THEN 'Consignment/Rental Inventory Transfer'
#                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) IN ('R1','R2','R3','R4','R5') THEN 'Consignment Rental'
#                   WHEN sal.order_type_cd = 'SV' THEN 'Rental Sale'
#                   WHEN sal.order_type_cd = 'CV' AND UPPER(sal.line_type_cd) IN ('C1','C2','C3','C4','C5') THEN 'Consignment Rental Return'
#                   WHEN sal.order_type_cd = 'CV' OR UPPER(sal.order_type_cd) IN ('CE') THEN 'Rental Return'
#                   WHEN sal.order_type_cd = 'EB' THEN 'Accrual Reversal'
#                   WHEN sal.order_type_cd = 'SE' AND UPPER(sal.line_type_cd) IN ('RN') THEN 'Amazon Rental'
#               ELSE 'X' END AS cl_rental,
#               CASE WHEN order_no IN ('97281659','97378813','97379065','97379085','97424575','97424682') THEN '23K Order'
#             ELSE 'X' END AS Order23K
#             --,case when (sal.order_taken_by = 'ICHAPTERS' AND cust.mkt_seg_maj_de = 'End User') then 'D2S' else 'Channel' end as Purchase_Method
#       from  raw_sales sal
#         left JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (sal."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
#         left JOIN STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT  prod ON (sal."PRODUCT_SKEY_BU") = (prod."PRODUCT_SKEY")
#         left JOIN prod.dw_ga.dim_date  AS dim_date ON (TO_CHAR(TO_DATE(sal."INVOICE_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue), 'YYYY-MM-DD'))
#         left JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (sal."CUST_NO_SHIP") = (cust."CUST_NO")
#         left JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT  ent ON (ent."ENTITY_NO") = (cust."ENTITY_NO")
#         left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd

#       WHERE Order23K = 'X'
#           AND cl_rental IN ('X','Accrual Reversal')
#           AND chegg_tutor_flag = 'X'
#           AND UPPER(institution_nm) NOT IN ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
#                                             'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC', 'FOLLETT''S CORP')
#           AND reason_cd NOT IN ('980','AMC','CHS')
#           AND prod.division_cd in ('112', '120', '142', '161', '155', '1ON', '1WA', '609', 'CLU')
#           AND sales_type_cd = 'DOM'
#           AND short_item_no_parent = '-1'
#           AND gsf_cd = 'HED'
#           AND ((sal.invoice_dt between '2016-04-01' AND '2016-09-30') OR (sal.invoice_dt between '2017-04-01' AND '2017-09-30') OR (sal.invoice_dt between '2018-04-01' AND '2018-09-30') OR (sal.invoice_dt between '2019-04-01' AND '2019-09-30'))
#           ),

#   ---FILTER RAW RESELLERS DATA
#       resellers1 as (
#       select re.*,
#               ter.gsf_cd,
#               prod.isbn_13,
#               prod.division_cd,
#               coalesce(prod.pub_series_de,'Not Specified') as pub_series_de,
#               prod.tech_prod_cd,
#               prod.print_digital_config_de,
#               ent.institution_nm,
#               ent.state_cd,
#               dim_date.fiscalyearvalue,
#               case when pub_series_de = 'Cengage Unlimited' then 'CUADPT'
#                   else coalesce(pfmt.course_code_description,'.') end  as course_code_description_1,
#               concat(concat(concat(concat(concat(concat(ent.institution_nm,'|'),ent.state_cd),'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as adoption_key,
#               concat(concat(concat(concat(ent.institution_nm,'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as old_adoption_key,
#               CASE WHEN prod.isbn_13 = '9781337792615' THEN 'Chegg Tutor' ELSE 'X' END AS chegg_tutor_flag,
#               CASE WHEN order_no IN ('97281659','97378813','97379065','97379085','97424575','97424682') THEN '23K Order' ELSE 'X' END AS Order23K,
#               'Channel' as purchase_method
#       from raw_resellers re
#       left JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (re."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
#       left JOIN STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT  prod ON (re."PRODUCT_SKEY_OWNER") = (prod."PRODUCT_SKEY")
#       left JOIN prod.dw_ga.dim_date  AS dim_date ON (TO_CHAR(TO_DATE(re."TRANSACTION_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue), 'YYYY-MM-DD'))
#       left JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (re."CUST_NO_SHIP") = (cust."CUST_NO")
#       left JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT  ent ON (cust."ENTITY_NO") = (ent."ENTITY_NO")
#       left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd
#       WHERE Order23K = 'X'
#           AND chegg_tutor_flag = 'X'
#           AND prod.division_cd in ('112', '120', '142', '161', '155', '1ON', '1WA', '609', 'CLU')
#           AND gsf_cd = 'HED'
#           AND UPPER(ent.institution_nm) not in ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
#                                             'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC', 'FOLLETT''S CORP')
#           AND ((re.transaction_dt between '2016-04-01' AND '2016-09-30') OR (re.transaction_dt between '2017-04-01' AND '2017-09-30') OR (re.transaction_dt between '2018-04-01' AND '2018-09-30') OR (re.transaction_dt between '2019-04-01' AND '2019-09-30'))
#           ),

#   ---FILTER RAW SALES ORDERS RETURNS DATA
#         returns1 as (
#       Select sal.*,
#               ter.gsf_cd,
#               prod.isbn_13,
#               prod.division_cd,
#               coalesce(prod.pub_series_de,'Not Specified') as pub_series_de,
#               prod.tech_prod_cd,
#               prod.print_digital_config_de,
#               cust.mkt_seg_maj_de,
#               ent.institution_nm,
#               ent.state_cd,
#               dim_date.fiscalyearvalue,
#               case when pub_series_de = 'Cengage Unlimited' then 'CUADPT'
#                   else coalesce(pfmt.course_code_description,'.') end as course_code_description_1,
#               concat(concat(concat(concat(concat(concat(ent.institution_nm,'|'),ent.state_cd),'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as adoption_key,
#               concat(concat(concat(concat(ent.institution_nm,'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as old_adoption_key,
#             CASE WHEN prod.isbn_13 = '9781337792615' THEN 'Chegg Tutor' ELSE 'X' END AS chegg_tutor_flag,
#             CASE WHEN sal.order_type_cd = 'SX' AND UPPER(sal.line_type_cd) = 'X' THEN 'Consignment/Rental Inventory Transfer'
#                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) = 'RS' THEN 'Consignment/Rental Inventory Transfer'
#                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) IN ('R1','R2','R3','R4','R5') THEN 'Consignment Rental'
#                   WHEN sal.order_type_cd = 'SV' THEN 'Rental Sale'
#                   WHEN sal.order_type_cd = 'CV' AND UPPER(sal.line_type_cd) IN ('C1','C2','C3','C4','C5') THEN 'Consignment Rental Return'
#                   WHEN sal.order_type_cd = 'CV' OR UPPER(sal.order_type_cd) IN ('CE') THEN 'Rental Return'
#                   WHEN sal.order_type_cd = 'EB' THEN 'Accrual Reversal'
#                   WHEN sal.order_type_cd = 'SE' AND UPPER(sal.line_type_cd) IN ('RN') THEN 'Amazon Rental'
#               ELSE 'X' END AS cl_rental,
#               CASE WHEN order_no IN ('97281659','97378813','97379065','97379085','97424575','97424682') THEN '23K Order'
#             ELSE 'X' END AS Order23K
#             --,case when (sal.order_taken_by = 'ICHAPTERS' AND cust.mkt_seg_maj_de = 'End User') then 'D2S' else 'Channel' end as Purchase_Method
#       from  raw_sales sal
#         left JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (sal."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
#         left JOIN STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT  prod ON (sal."PRODUCT_SKEY_BU") = (prod."PRODUCT_SKEY")
#         left JOIN prod.dw_ga.dim_date  AS dim_date ON (TO_CHAR(TO_DATE(sal."INVOICE_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue), 'YYYY-MM-DD'))
#         left JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (sal."CUST_NO_SHIP") = (cust."CUST_NO")
#         left JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT  ent ON (ent."ENTITY_NO") = (cust."ENTITY_NO")
#         left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd

#       WHERE Order23K = 'X'
#           AND cl_rental IN ('X','Accrual Reversal')
#           AND chegg_tutor_flag = 'X'
#           AND UPPER(institution_nm) NOT IN ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
#                                             'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC', 'FOLLETT''S CORP')
#           AND reason_cd NOT IN ('980','AMC','CHS')
#           AND prod.division_cd in ('112', '120', '142', '161', '155', '1ON', '1WA', '609', 'CLU')
#           AND sales_type_cd = 'DOM'
#           AND short_item_no_parent = '-1'
#           AND gsf_cd = 'HED'
#           AND sales_analysis_cd = 'R'
#           AND ((sal.invoice_dt between '2016-10-01' AND '2016-12-31') OR (sal.invoice_dt between '2017-10-01' AND '2017-12-31') OR (sal.invoice_dt between '2018-10-01' AND '2018-12-31')
#           --OR (sal.invoice_dt between '2019-10-01' AND '2019-12-31')
#           )
#           ),

#   ---FILTER RAW RESELLERS RETURNS DATA
#       reseller_returns1 as (
#       select re.*,
#               ter.gsf_cd,
#               prod.isbn_13,
#               prod.division_cd,
#               coalesce(prod.pub_series_de,'Not Specified') as pub_series_de,
#               prod.tech_prod_cd,
#               prod.print_digital_config_de,
#               ent.institution_nm,
#               ent.state_cd,
#               dim_date.fiscalyearvalue,
#               case when pub_series_de = 'Cengage Unlimited' then 'CUADPT'
#                   else coalesce(pfmt.course_code_description,'.') end as course_code_description_1,
#               concat(concat(concat(concat(concat(concat(ent.institution_nm,'|'),ent.state_cd),'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as adoption_key,
#               concat(concat(concat(concat(ent.institution_nm,'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as old_adoption_key,
#               CASE WHEN prod.isbn_13 = '9781337792615' THEN 'Chegg Tutor' ELSE 'X' END AS chegg_tutor_flag,
#               CASE WHEN order_no IN ('97281659','97378813','97379065','97379085','97424575','97424682') THEN '23K Order' ELSE 'X' END AS Order23K,
#               'Channel' as purchase_method
#       from raw_resellers re
#       left JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (re."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
#       left JOIN STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT  prod ON (re."PRODUCT_SKEY_OWNER") = (prod."PRODUCT_SKEY")
#       left JOIN prod.dw_ga.dim_date  AS dim_date ON (TO_CHAR(TO_DATE(re."TRANSACTION_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue), 'YYYY-MM-DD'))
#       left JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (re."CUST_NO_SHIP") = (cust."CUST_NO")
#       left JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT  ent ON (cust."ENTITY_NO") = (ent."ENTITY_NO")
#       left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd
#       WHERE Order23K = 'X'
#           AND chegg_tutor_flag = 'X'
#           AND prod.division_cd in ('112', '120', '142', '161', '155', '1ON', '1WA', '609', 'CLU')
#           AND gsf_cd = 'HED'
#           AND UPPER(ent.institution_nm) not in ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
#                                             'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC', 'FOLLETT''S CORP')
#           AND ((re.transaction_dt between '2016-10-01' AND '2016-12-31') OR (re.transaction_dt between '2017-10-01' AND '2017-12-31') OR (re.transaction_dt between '2018-10-01' AND '2018-12-31')
#           --OR (re.transaction_dt between '2019-10-01' AND '2019-12-31')
#           )
#           AND quantity <= 0
#           AND net_amt <= 0
#           ),

#   ---FILTER AMZ & RTL CU SALES/UNITS
#       AMZ_RTL1 as (
#       Select sal.*,
#               ter.gsf_cd,
#               prod.isbn_13,
#               prod.division_cd,
#               coalesce(prod.pub_series_de,'Not Specified') as pub_series_de,
#               prod.tech_prod_cd,
#               prod.print_digital_config_de,
#               cust.mkt_seg_maj_de,
#               ent.institution_nm,
#               ent.state_cd,
#               dim_date.fiscalyearvalue,
#               case when pub_series_de = 'Cengage Unlimited' then 'CUADPT'
#                   else coalesce(pfmt.course_code_description,'.') end  as course_code_description_1,
#               concat(concat(concat(concat(concat(concat(ent.institution_nm,'|'),ent.state_cd),'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as adoption_key,
#               concat(concat(concat(concat(ent.institution_nm,'|'),coalesce(course_code_description_1,'.')),'|'),coalesce(prod.pub_series_de,'Not Specified')) as old_adoption_key,
#             CASE WHEN prod.isbn_13 = '9781337792615' THEN 'Chegg Tutor' ELSE 'X' END AS chegg_tutor_flag,
#             CASE WHEN sal.order_type_cd = 'SX' AND UPPER(sal.line_type_cd) = 'X' THEN 'Consignment/Rental Inventory Transfer'
#                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) = 'RS' THEN 'Consignment/Rental Inventory Transfer'
#                   WHEN sal.order_type_cd = 'SV' AND UPPER(sal.line_type_cd) IN ('R1','R2','R3','R4','R5') THEN 'Consignment Rental'
#                   WHEN sal.order_type_cd = 'SV' THEN 'Rental Sale'
#                   WHEN sal.order_type_cd = 'CV' AND UPPER(sal.line_type_cd) IN ('C1','C2','C3','C4','C5') THEN 'Consignment Rental Return'
#                   WHEN sal.order_type_cd = 'CV' OR UPPER(sal.order_type_cd) IN ('CE') THEN 'Rental Return'
#                   WHEN sal.order_type_cd = 'EB' THEN 'Accrual Reversal'
#                   WHEN sal.order_type_cd = 'SE' AND UPPER(sal.line_type_cd) IN ('RN') THEN 'Amazon Rental'
#               ELSE 'X' END AS cl_rental,
#               CASE WHEN order_no IN ('97281659','97378813','97379065','97379085','97424575','97424682') THEN '23K Order'
#             ELSE 'X' END AS Order23K
#             --,case when (sal.order_taken_by = 'ICHAPTERS' AND cust.mkt_seg_maj_de = 'End User') then 'D2S' else 'Channel' end as Purchase_Method
#       from  raw_sales sal
#         left JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (sal."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
#         left JOIN STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT  prod ON (sal."PRODUCT_SKEY_BU") = (prod."PRODUCT_SKEY")
#         left JOIN prod.dw_ga.dim_date  AS dim_date ON (TO_CHAR(TO_DATE(sal."INVOICE_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue), 'YYYY-MM-DD'))
#         left JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (sal."CUST_NO_SHIP") = (cust."CUST_NO")
#         left JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT  ent ON (ent."ENTITY_NO") = (cust."ENTITY_NO")
#         left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd

#       WHERE Order23K = 'X'
#           AND cl_rental IN ('X','Accrual Reversal')
#           AND chegg_tutor_flag = 'X'
#           AND UPPER(institution_nm) NOT IN ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
#                                             'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC', 'FOLLETT''S CORP')
#           AND reason_cd NOT IN ('980','AMC','CHS')
#           AND prod.division_cd in ('112', '120', '142', '161', '155', '1ON', '1WA', '609', 'CLU')
#           AND sales_type_cd = 'DOM'
#           AND short_item_no_parent = '-1'
#           AND gsf_cd IN ('AMZ', 'RTL')
#           AND ((sal.invoice_dt between '2016-04-01' AND '2016-09-30') OR (sal.invoice_dt between '2017-04-01' AND '2017-09-30') OR (sal.invoice_dt between '2018-04-01' AND '2018-09-30') OR (sal.invoice_dt between '2019-04-01' AND '2019-09-30'))
#           ),

#   ---CREATE ADOPTION-LEVEL DATASET FROM SALES ORDERS
#       sales_orders2 as (
#         select
#           adoption_key as sales_adoption_key,
#           old_adoption_key as sales_old_adoption_key,
#           institution_nm as sales_institution_nm,
#           state_cd as sales_state_cd,
#           course_code_description_1 as sales_course_code_description,
#           pub_series_de as sales_pub_series_de,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_CU_sales
#         from sales_orders1
#         GROUP BY 1,2,3,4,5,6),

#   ---CREATE ADOPTION-LEVEL DATASET FROM RESELLERS
#       resellers2 as (
#         select
#           adoption_key as sales_adoption_key,
#           old_adoption_key as sales_old_adoption_key,
#           institution_nm as sales_institution_nm,
#           state_cd as sales_state_cd,
#           course_code_description_1 as sales_course_code_description,
#           pub_series_de as sales_pub_series_de,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_CU_sales
#         from resellers1
#         GROUP BY 1,2,3,4,5,6),

#     ---CREATE ADOPTION-LEVEL SALES ORDERS RETURNS DATA
#         returns2 as (
#         select
#           adoption_key as sales_adoption_key,
#           old_adoption_key as sales_old_adoption_key,
#           institution_nm as sales_institution_nm,
#           state_cd as sales_state_cd,
#           course_code_description_1 as sales_course_code_description,
#           pub_series_de as sales_pub_series_de,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_CU_sales
#         from returns1
#         GROUP BY 1,2,3,4,5,6),

#   ---CREATE ADOPTION-LEVEL DATASET FROM RESELLERS RETURNS
#       reseller_returns2 as (
#         select
#           adoption_key as sales_adoption_key,
#           old_adoption_key as sales_old_adoption_key,
#           institution_nm as sales_institution_nm,
#           state_cd as sales_state_cd,
#           course_code_description_1 as sales_course_code_description,
#           pub_series_de as sales_pub_series_de,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_ebook_units,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('eBooks') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_ebook_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Core') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Print Other') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_core_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Core') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_custom_print_core_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_custom_print_other_units,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Custom Print Other') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_custom_print_other_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Standalone') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_other_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_other_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Other Digital Bundle') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_other_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_standalone_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Standalone') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_core_digital_standalone_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_core_digital_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Core Digital Bundle') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_core_digital_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_LLF_bundle_units,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Loose-Leaf Bundle') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_LLF_bundle_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' THEN net_amt else 0 end) as FY17_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' THEN net_amt else 0 end) as FY18_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' THEN net_amt else 0 end) as FY19_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' THEN net_amt else 0 end) as FY20_CU_sales
#         from reseller_returns1
#         GROUP BY 1,2,3,4,5,6),

#   ---CREATE ADOPTION-LEVEL DATASET FROM SALES ORDERS
#       amz_rtl2 as (
#         select
#           adoption_key as sales_adoption_key,
#           old_adoption_key as sales_old_adoption_key,
#           institution_nm as sales_institution_nm,
#           state_cd as sales_state_cd,
#           course_code_description_1 as sales_course_code_description,
#           pub_series_de as sales_pub_series_de,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY17_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY18_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY19_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' AND tech_prod_cd NOT LIKE '05E' THEN quantity else 0 end) as FY20_CU_units,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY17' THEN extended_amt_usd else 0 end) as FY17_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY18' THEN extended_amt_usd else 0 end) as FY18_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY19' THEN extended_amt_usd else 0 end) as FY19_CU_sales,
#           SUM(CASE WHEN print_digital_config_de in ('Cengage Unlimited') AND fiscalyearvalue = 'FY20' THEN extended_amt_usd else 0 end) as FY20_CU_sales
#         from AMZ_RTL1
#         GROUP BY 1,2,3,4,5,6),


#     ---CREATE LIST OF ADOPTION KEYS
#         adoption_keys as (
#         select sales_adoption_key from sales_orders2
#         UNION
#         select sales_adoption_key from returns2
#         UNION
#         select sales_adoption_key from resellers2
#         UNION
#         select sales_adoption_key from reseller_returns2
#         UNION
#         select sales_adoption_key from amz_rtl2),

#   adoption_keys2 as (
#         select distinct sales_adoption_key
#         from adoption_keys),


#   ---CREATE JOINED ADOPTION LEVEL DATASET
#   final1 as (
#   select akey.sales_adoption_key,
#         coalesce(sal.sales_old_adoption_key, re.sales_old_adoption_key, ret.sales_old_adoption_key, re_ret.sales_old_adoption_key, amz_rtl.sales_old_adoption_key) as sales_old_adoption_key,
#         coalesce(sal.sales_institution_nm, re.sales_institution_nm, ret.sales_institution_nm, re_ret.sales_institution_nm, amz_rtl.sales_institution_nm) as sales_institution_nm,
#         coalesce(sal.sales_state_cd, re.sales_state_cd, ret.sales_state_cd, re_ret.sales_state_cd, amz_rtl.sales_state_cd) as sales_state_cd,
#         coalesce(sal.sales_course_code_description, re.sales_course_code_description, ret.sales_course_code_description, re_ret.sales_course_code_description, amz_rtl.sales_course_code_description) as sales_course_code_description,
#         coalesce(sal.sales_pub_series_de, re.sales_pub_series_de, ret.sales_pub_series_de, re_ret.sales_pub_series_de, amz_rtl.sales_pub_series_de) as sales_pub_series_de,
#         (nvl(sal.FY17_ebook_units,0) + nvl(re.FY17_ebook_units,0) + nvl(ret.FY17_ebook_units,0) + nvl(re_ret.FY17_ebook_units,0)) as FY17_ebook_units,
#         (nvl(sal.FY18_ebook_units,0) + nvl(re.FY18_ebook_units,0) + nvl(ret.FY18_ebook_units,0) + nvl(re_ret.FY18_ebook_units,0)) as FY18_ebook_units,
#         (nvl(sal.FY19_ebook_units,0) + nvl(re.FY19_ebook_units,0) + nvl(ret.FY19_ebook_units,0) + nvl(re_ret.FY19_ebook_units,0)) as FY19_ebook_units,
#         (nvl(sal.FY20_ebook_units,0) + nvl(re.FY20_ebook_units,0) + nvl(ret.FY20_ebook_units,0) + nvl(re_ret.FY20_ebook_units,0)) as FY20_ebook_units,
#         (nvl(sal.FY17_ebook_sales,0) + nvl(re.FY17_ebook_sales,0) + nvl(ret.FY17_ebook_sales,0) + nvl(re_ret.FY17_ebook_sales,0)) as FY17_ebook_sales,
#         (nvl(sal.FY18_ebook_sales,0) + nvl(re.FY18_ebook_sales,0) + nvl(ret.FY18_ebook_sales,0) + nvl(re_ret.FY18_ebook_sales,0)) as FY18_ebook_sales,
#         (nvl(sal.FY19_ebook_sales,0) + nvl(re.FY19_ebook_sales,0) + nvl(ret.FY19_ebook_sales,0) + nvl(re_ret.FY19_ebook_sales,0)) as FY19_ebook_sales,
#         (nvl(sal.FY20_ebook_sales,0) + nvl(re.FY20_ebook_sales,0) + nvl(ret.FY20_ebook_sales,0) + nvl(re_ret.FY20_ebook_sales,0)) as FY20_ebook_sales,
#         (nvl(sal.FY17_print_core_units,0) + nvl(re.FY17_print_core_units,0) + nvl(ret.FY17_print_core_units,0) + nvl(re_ret.FY17_print_core_units,0)) as FY17_print_core_units,
#         (nvl(sal.FY18_print_core_units,0) + nvl(re.FY18_print_core_units,0) + nvl(ret.FY18_print_core_units,0) + nvl(re_ret.FY18_print_core_units,0)) as FY18_print_core_units,
#         (nvl(sal.FY19_print_core_units,0) + nvl(re.FY19_print_core_units,0) + nvl(ret.FY19_print_core_units,0) + nvl(re_ret.FY19_print_core_units,0)) as FY19_print_core_units,
#         (nvl(sal.FY20_print_core_units,0) + nvl(re.FY20_print_core_units,0) + nvl(ret.FY20_print_core_units,0) + nvl(re_ret.FY20_print_core_units,0)) as FY20_print_core_units,
#         (nvl(sal.FY17_print_core_sales,0) + nvl(re.FY17_print_core_sales,0) + nvl(ret.FY17_print_core_sales,0) + nvl(re_ret.FY17_print_core_sales,0)) as FY17_print_core_sales,
#         (nvl(sal.FY18_print_core_sales,0) + nvl(re.FY18_print_core_sales,0) + nvl(ret.FY18_print_core_sales,0) + nvl(re_ret.FY18_print_core_sales,0)) as FY18_print_core_sales,
#         (nvl(sal.FY19_print_core_sales,0) + nvl(re.FY19_print_core_sales,0) + nvl(ret.FY19_print_core_sales,0) + nvl(re_ret.FY19_print_core_sales,0)) as FY19_print_core_sales,
#         (nvl(sal.FY20_print_core_sales,0) + nvl(re.FY20_print_core_sales,0) + nvl(ret.FY20_print_core_sales,0) + nvl(re_ret.FY20_print_core_sales,0)) as FY20_print_core_sales,
#         (nvl(sal.FY17_print_other_units,0) + nvl(re.FY17_print_other_units,0) + nvl(ret.FY17_print_other_units,0) + nvl(re_ret.FY17_print_other_units,0)) as FY17_print_other_units,
#         (nvl(sal.FY18_print_other_units,0) + nvl(re.FY18_print_other_units,0) + nvl(ret.FY18_print_other_units,0) + nvl(re_ret.FY18_print_other_units,0)) as FY18_print_other_units,
#         (nvl(sal.FY19_print_other_units,0) + nvl(re.FY19_print_other_units,0) + nvl(ret.FY19_print_other_units,0) + nvl(re_ret.FY19_print_other_units,0)) as FY19_print_other_units,
#         (nvl(sal.FY20_print_other_units,0) + nvl(re.FY20_print_other_units,0) + nvl(ret.FY20_print_other_units,0) + nvl(re_ret.FY20_print_other_units,0)) as FY20_print_other_units,
#         (nvl(sal.FY17_print_other_sales,0) + nvl(re.FY17_print_other_sales,0) + nvl(ret.FY17_print_other_sales,0) + nvl(re_ret.FY17_print_other_sales,0)) as FY17_print_other_sales,
#         (nvl(sal.FY18_print_other_sales,0) + nvl(re.FY18_print_other_sales,0) + nvl(ret.FY18_print_other_sales,0) + nvl(re_ret.FY18_print_other_sales,0)) as FY18_print_other_sales,
#         (nvl(sal.FY19_print_other_sales,0) + nvl(re.FY19_print_other_sales,0) + nvl(ret.FY19_print_other_sales,0) + nvl(re_ret.FY19_print_other_sales,0)) as FY19_print_other_sales,
#         (nvl(sal.FY20_print_other_sales,0) + nvl(re.FY20_print_other_sales,0) + nvl(ret.FY20_print_other_sales,0) + nvl(re_ret.FY20_print_other_sales,0)) as FY20_print_other_sales,
#         (nvl(sal.FY17_custom_print_core_units,0) + nvl(re.FY17_custom_print_core_units,0) + nvl(ret.FY17_custom_print_core_units,0) + nvl(re_ret.FY17_custom_print_core_units,0)) as FY17_custom_print_core_units,
#         (nvl(sal.FY18_custom_print_core_units,0) + nvl(re.FY18_custom_print_core_units,0) + nvl(ret.FY18_custom_print_core_units,0) + nvl(re_ret.FY18_custom_print_core_units,0)) as FY18_custom_print_core_units,
#         (nvl(sal.FY19_custom_print_core_units,0) + nvl(re.FY19_custom_print_core_units,0) + nvl(ret.FY19_custom_print_core_units,0) + nvl(re_ret.FY19_custom_print_core_units,0)) as FY19_custom_print_core_units,
#         (nvl(sal.FY20_custom_print_core_units,0) + nvl(re.FY20_custom_print_core_units,0) + nvl(ret.FY20_custom_print_core_units,0) + nvl(re_ret.FY20_custom_print_core_units,0)) as FY20_custom_print_core_units,
#         (nvl(sal.FY17_custom_print_core_sales,0) + nvl(re.FY17_custom_print_core_sales,0) + nvl(ret.FY17_custom_print_core_sales,0) + nvl(re_ret.FY17_custom_print_core_sales,0)) as FY17_custom_print_core_sales,
#         (nvl(sal.FY18_custom_print_core_sales,0) + nvl(re.FY18_custom_print_core_sales,0) + nvl(ret.FY18_custom_print_core_sales,0) + nvl(re_ret.FY18_custom_print_core_sales,0)) as FY18_custom_print_core_sales,
#         (nvl(sal.FY19_custom_print_core_sales,0) + nvl(re.FY19_custom_print_core_sales,0) + nvl(ret.FY19_custom_print_core_sales,0) + nvl(re_ret.FY19_custom_print_core_sales,0)) as FY19_custom_print_core_sales,
#         (nvl(sal.FY20_custom_print_core_sales,0) + nvl(re.FY20_custom_print_core_sales,0) + nvl(ret.FY20_custom_print_core_sales,0) + nvl(re_ret.FY20_custom_print_core_sales,0)) as FY20_custom_print_core_sales,
#         (nvl(sal.FY17_custom_print_other_units,0) + nvl(re.FY17_custom_print_other_units,0) + nvl(ret.FY17_custom_print_other_units,0) + nvl(re_ret.FY17_custom_print_other_units,0)) as FY17_custom_print_other_units,
#         (nvl(sal.FY18_custom_print_other_units,0) + nvl(re.FY18_custom_print_other_units,0) + nvl(ret.FY18_custom_print_other_units,0) + nvl(re_ret.FY18_custom_print_other_units,0)) as FY18_custom_print_other_units,
#         (nvl(sal.FY19_custom_print_other_units,0) + nvl(re.FY19_custom_print_other_units,0) + nvl(ret.FY19_custom_print_other_units,0) + nvl(re_ret.FY19_custom_print_other_units,0)) as FY19_custom_print_other_units,
#         (nvl(sal.FY20_custom_print_other_units,0) + nvl(re.FY20_custom_print_other_units,0) + nvl(ret.FY20_custom_print_other_units,0) + nvl(re_ret.FY20_custom_print_other_units,0)) as FY20_custom_print_other_units,
#         (nvl(sal.FY17_custom_print_other_sales,0) + nvl(re.FY17_custom_print_other_sales,0) + nvl(ret.FY17_custom_print_other_sales,0) + nvl(re_ret.FY17_custom_print_other_sales,0)) as FY17_custom_print_other_sales,
#         (nvl(sal.FY18_custom_print_other_sales,0) + nvl(re.FY18_custom_print_other_sales,0) + nvl(ret.FY18_custom_print_other_sales,0) + nvl(re_ret.FY18_custom_print_other_sales,0)) as FY18_custom_print_other_sales,
#         (nvl(sal.FY19_custom_print_other_sales,0) + nvl(re.FY19_custom_print_other_sales,0) + nvl(ret.FY19_custom_print_other_sales,0) + nvl(re_ret.FY19_custom_print_other_sales,0)) as FY19_custom_print_other_sales,
#         (nvl(sal.FY20_custom_print_other_sales,0) + nvl(re.FY20_custom_print_other_sales,0) + nvl(ret.FY20_custom_print_other_sales,0) + nvl(re_ret.FY20_custom_print_other_sales,0)) as FY20_custom_print_other_sales,
#         (nvl(sal.FY17_other_digital_standalone_units,0) + nvl(re.FY17_other_digital_standalone_units,0) + nvl(ret.FY17_other_digital_standalone_units,0) + nvl(re_ret.FY17_other_digital_standalone_units,0)) as FY17_other_digital_standalone_units,
#         (nvl(sal.FY18_other_digital_standalone_units,0) + nvl(re.FY18_other_digital_standalone_units,0) + nvl(ret.FY18_other_digital_standalone_units,0) + nvl(re_ret.FY18_other_digital_standalone_units,0)) as FY18_other_digital_standalone_units,
#         (nvl(sal.FY19_other_digital_standalone_units,0) + nvl(re.FY19_other_digital_standalone_units,0) + nvl(ret.FY19_other_digital_standalone_units,0) + nvl(re_ret.FY19_other_digital_standalone_units,0)) as FY19_other_digital_standalone_units,
#         (nvl(sal.FY20_other_digital_standalone_units,0) + nvl(re.FY20_other_digital_standalone_units,0) + nvl(ret.FY20_other_digital_standalone_units,0) + nvl(re_ret.FY20_other_digital_standalone_units,0)) as FY20_other_digital_standalone_units,
#         (nvl(sal.FY17_other_digital_standalone_sales,0) + nvl(re.FY17_other_digital_standalone_sales,0) + nvl(ret.FY17_other_digital_standalone_sales,0) + nvl(re_ret.FY17_other_digital_standalone_sales,0)) as FY17_other_digital_standalone_sales,
#         (nvl(sal.FY18_other_digital_standalone_sales,0) + nvl(re.FY18_other_digital_standalone_sales,0) + nvl(ret.FY18_other_digital_standalone_sales,0) + nvl(re_ret.FY18_other_digital_standalone_sales,0)) as FY18_other_digital_standalone_sales,
#         (nvl(sal.FY19_other_digital_standalone_sales,0) + nvl(re.FY19_other_digital_standalone_sales,0) + nvl(ret.FY19_other_digital_standalone_sales,0) + nvl(re_ret.FY19_other_digital_standalone_sales,0)) as FY19_other_digital_standalone_sales,
#         (nvl(sal.FY20_other_digital_standalone_sales,0) + nvl(re.FY20_other_digital_standalone_sales,0) + nvl(ret.FY20_other_digital_standalone_sales,0) + nvl(re_ret.FY20_other_digital_standalone_sales,0)) as FY20_other_digital_standalone_sales,
#         (nvl(sal.FY17_other_digital_bundle_units,0) + nvl(re.FY17_other_digital_bundle_units,0) + nvl(ret.FY17_other_digital_bundle_units,0) + nvl(re_ret.FY17_other_digital_bundle_units,0)) as FY17_other_digital_bundle_units,
#         (nvl(sal.FY18_other_digital_bundle_units,0) + nvl(re.FY18_other_digital_bundle_units,0) + nvl(ret.FY18_other_digital_bundle_units,0) + nvl(re_ret.FY18_other_digital_bundle_units,0)) as FY18_other_digital_bundle_units,
#         (nvl(sal.FY19_other_digital_bundle_units,0) + nvl(re.FY19_other_digital_bundle_units,0) + nvl(ret.FY19_other_digital_bundle_units,0) + nvl(re_ret.FY19_other_digital_bundle_units,0)) as FY19_other_digital_bundle_units,
#         (nvl(sal.FY20_other_digital_bundle_units,0) + nvl(re.FY20_other_digital_bundle_units,0) + nvl(ret.FY20_other_digital_bundle_units,0) + nvl(re_ret.FY20_other_digital_bundle_units,0)) as FY20_other_digital_bundle_units,
#         (nvl(sal.FY17_other_digital_bundle_sales,0) + nvl(re.FY17_other_digital_bundle_sales,0) + nvl(ret.FY17_other_digital_bundle_sales,0) + nvl(re_ret.FY17_other_digital_bundle_sales,0)) as FY17_other_digital_bundle_sales,
#         (nvl(sal.FY18_other_digital_bundle_sales,0) + nvl(re.FY18_other_digital_bundle_sales,0) + nvl(ret.FY18_other_digital_bundle_sales,0) + nvl(re_ret.FY18_other_digital_bundle_sales,0)) as FY18_other_digital_bundle_sales,
#         (nvl(sal.FY19_other_digital_bundle_sales,0) + nvl(re.FY19_other_digital_bundle_sales,0) + nvl(ret.FY19_other_digital_bundle_sales,0) + nvl(re_ret.FY19_other_digital_bundle_sales,0)) as FY19_other_digital_bundle_sales,
#         (nvl(sal.FY20_other_digital_bundle_sales,0) + nvl(re.FY20_other_digital_bundle_sales,0) + nvl(ret.FY20_other_digital_bundle_sales,0) + nvl(re_ret.FY20_other_digital_bundle_sales,0)) as FY20_other_digital_bundle_sales,
#         (nvl(sal.FY17_core_digital_standalone_units,0) + nvl(re.FY17_core_digital_standalone_units,0) + nvl(ret.FY17_core_digital_standalone_units,0) + nvl(re_ret.FY17_core_digital_standalone_units,0)) as FY17_core_digital_standalone_units,
#         (nvl(sal.FY18_core_digital_standalone_units,0) + nvl(re.FY18_core_digital_standalone_units,0) + nvl(ret.FY18_core_digital_standalone_units,0) + nvl(re_ret.FY18_core_digital_standalone_units,0)) as FY18_core_digital_standalone_units,
#         (nvl(sal.FY19_core_digital_standalone_units,0) + nvl(re.FY19_core_digital_standalone_units,0) + nvl(ret.FY19_core_digital_standalone_units,0) + nvl(re_ret.FY19_core_digital_standalone_units,0)) as FY19_core_digital_standalone_units,
#         (nvl(sal.FY20_core_digital_standalone_units,0) + nvl(re.FY20_core_digital_standalone_units,0) + nvl(ret.FY20_core_digital_standalone_units,0) + nvl(re_ret.FY20_core_digital_standalone_units,0)) as FY20_core_digital_standalone_units,
#         (nvl(sal.FY17_core_digital_standalone_sales,0) + nvl(re.FY17_core_digital_standalone_sales,0) + nvl(ret.FY17_core_digital_standalone_sales,0) + nvl(re_ret.FY17_core_digital_standalone_sales,0)) as FY17_core_digital_standalone_sales,
#         (nvl(sal.FY18_core_digital_standalone_sales,0) + nvl(re.FY18_core_digital_standalone_sales,0) + nvl(ret.FY18_core_digital_standalone_sales,0) + nvl(re_ret.FY18_core_digital_standalone_sales,0)) as FY18_core_digital_standalone_sales,
#         (nvl(sal.FY19_core_digital_standalone_sales,0) + nvl(re.FY19_core_digital_standalone_sales,0) + nvl(ret.FY19_core_digital_standalone_sales,0) + nvl(re_ret.FY19_core_digital_standalone_sales,0)) as FY19_core_digital_standalone_sales,
#         (nvl(sal.FY20_core_digital_standalone_sales,0) + nvl(re.FY20_core_digital_standalone_sales,0) + nvl(ret.FY20_core_digital_standalone_sales,0) + nvl(re_ret.FY20_core_digital_standalone_sales,0)) as FY20_core_digital_standalone_sales,
#         (nvl(sal.FY17_core_digital_bundle_units,0) + nvl(re.FY17_core_digital_bundle_units,0) + nvl(ret.FY17_core_digital_bundle_units,0) + nvl(re_ret.FY17_core_digital_bundle_units,0)) as FY17_core_digital_bundle_units,
#         (nvl(sal.FY18_core_digital_bundle_units,0) + nvl(re.FY18_core_digital_bundle_units,0) + nvl(ret.FY18_core_digital_bundle_units,0) + nvl(re_ret.FY18_core_digital_bundle_units,0)) as FY18_core_digital_bundle_units,
#         (nvl(sal.FY19_core_digital_bundle_units,0) + nvl(re.FY19_core_digital_bundle_units,0) + nvl(ret.FY19_core_digital_bundle_units,0) + nvl(re_ret.FY19_core_digital_bundle_units,0)) as FY19_core_digital_bundle_units,
#         (nvl(sal.FY20_core_digital_bundle_units,0) + nvl(re.FY20_core_digital_bundle_units,0) + nvl(ret.FY20_core_digital_bundle_units,0) + nvl(re_ret.FY20_core_digital_bundle_units,0)) as FY20_core_digital_bundle_units,
#         (nvl(sal.FY17_core_digital_bundle_sales,0) + nvl(re.FY17_core_digital_bundle_sales,0) + nvl(ret.FY17_core_digital_bundle_sales,0) + nvl(re_ret.FY17_core_digital_bundle_sales,0)) as FY17_core_digital_bundle_sales,
#         (nvl(sal.FY18_core_digital_bundle_sales,0) + nvl(re.FY18_core_digital_bundle_sales,0) + nvl(ret.FY18_core_digital_bundle_sales,0) + nvl(re_ret.FY18_core_digital_bundle_sales,0)) as FY18_core_digital_bundle_sales,
#         (nvl(sal.FY19_core_digital_bundle_sales,0) + nvl(re.FY19_core_digital_bundle_sales,0) + nvl(ret.FY19_core_digital_bundle_sales,0) + nvl(re_ret.FY19_core_digital_bundle_sales,0)) as FY19_core_digital_bundle_sales,
#         (nvl(sal.FY20_core_digital_bundle_sales,0) + nvl(re.FY20_core_digital_bundle_sales,0) + nvl(ret.FY20_core_digital_bundle_sales,0) + nvl(re_ret.FY20_core_digital_bundle_sales,0)) as FY20_core_digital_bundle_sales,
#         (nvl(sal.FY17_LLF_bundle_units,0) + nvl(re.FY17_LLF_bundle_units,0) + nvl(ret.FY17_LLF_bundle_units,0) + nvl(re_ret.FY17_LLF_bundle_units,0)) as FY17_LLF_bundle_units,
#         (nvl(sal.FY18_LLF_bundle_units,0) + nvl(re.FY18_LLF_bundle_units,0) + nvl(ret.FY18_LLF_bundle_units,0) + nvl(re_ret.FY18_LLF_bundle_units,0)) as FY18_LLF_bundle_units,
#         (nvl(sal.FY19_LLF_bundle_units,0) + nvl(re.FY19_LLF_bundle_units,0) + nvl(ret.FY19_LLF_bundle_units,0) + nvl(re_ret.FY19_LLF_bundle_units,0)) as FY19_LLF_bundle_units,
#         (nvl(sal.FY20_LLF_bundle_units,0) + nvl(re.FY20_LLF_bundle_units,0) + nvl(ret.FY20_LLF_bundle_units,0) + nvl(re_ret.FY20_LLF_bundle_units,0)) as FY20_LLF_bundle_units,
#         (nvl(sal.FY17_LLF_bundle_sales,0) + nvl(re.FY17_LLF_bundle_sales,0) + nvl(ret.FY17_LLF_bundle_sales,0) + nvl(re_ret.FY17_LLF_bundle_sales,0)) as FY17_LLF_bundle_sales,
#         (nvl(sal.FY18_LLF_bundle_sales,0) + nvl(re.FY18_LLF_bundle_sales,0) + nvl(ret.FY18_LLF_bundle_sales,0) + nvl(re_ret.FY18_LLF_bundle_sales,0)) as FY18_LLF_bundle_sales,
#         (nvl(sal.FY19_LLF_bundle_sales,0) + nvl(re.FY19_LLF_bundle_sales,0) + nvl(ret.FY19_LLF_bundle_sales,0) + nvl(re_ret.FY19_LLF_bundle_sales,0)) as FY19_LLF_bundle_sales,
#         (nvl(sal.FY20_LLF_bundle_sales,0) + nvl(re.FY20_LLF_bundle_sales,0) + nvl(ret.FY20_LLF_bundle_sales,0) + nvl(re_ret.FY20_LLF_bundle_sales,0)) as FY20_LLF_bundle_sales,
#         (nvl(sal.FY17_CU_units,0) + nvl(re.FY17_CU_units,0) + nvl(ret.FY17_CU_units,0) + nvl(re_ret.FY17_CU_units,0) + nvl(amz_rtl.FY17_CU_units,0)) as FY17_CU_units,
#         (nvl(sal.FY18_CU_units,0) + nvl(re.FY18_CU_units,0) + nvl(ret.FY18_CU_units,0) + nvl(re_ret.FY18_CU_units,0) + nvl(amz_rtl.FY18_CU_units,0)) as FY18_CU_units,
#         (nvl(sal.FY19_CU_units,0) + nvl(re.FY19_CU_units,0) + nvl(ret.FY19_CU_units,0) + nvl(re_ret.FY19_CU_units,0) + nvl(amz_rtl.FY19_CU_units,0)) as FY19_CU_units,
#         (nvl(sal.FY20_CU_units,0) + nvl(re.FY20_CU_units,0) + nvl(ret.FY20_CU_units,0) + nvl(re_ret.FY20_CU_units,0) + nvl(amz_rtl.FY20_CU_units,0)) as FY20_CU_units,
#         (nvl(sal.FY17_CU_sales,0) + nvl(re.FY17_CU_sales,0) + nvl(ret.FY17_CU_sales,0) + nvl(re_ret.FY17_CU_sales,0) + nvl(amz_rtl.FY17_CU_sales,0)) as FY17_CU_sales,
#         (nvl(sal.FY18_CU_sales,0) + nvl(re.FY18_CU_sales,0) + nvl(ret.FY18_CU_sales,0) + nvl(re_ret.FY18_CU_sales,0) + nvl(amz_rtl.FY18_CU_sales,0)) as FY18_CU_sales,
#         (nvl(sal.FY19_CU_sales,0) + nvl(re.FY19_CU_sales,0) + nvl(ret.FY19_CU_sales,0) + nvl(re_ret.FY19_CU_sales,0) + nvl(amz_rtl.FY19_CU_sales,0)) as FY19_CU_sales,
#         (nvl(sal.FY20_CU_sales,0) + nvl(re.FY20_CU_sales,0) + nvl(ret.FY20_CU_sales,0) + nvl(re_ret.FY20_CU_sales,0) + nvl(amz_rtl.FY20_CU_sales,0)) as FY20_CU_sales
#   from adoption_keys2 akey
#   LEFT JOIN sales_orders2 sal on sal.sales_adoption_key = akey.sales_adoption_key
#   LEFT JOIN resellers2 re on re.sales_adoption_key = akey.sales_adoption_key
#   LEFT JOIN returns2 ret on ret.sales_adoption_key = akey.sales_adoption_key
#   LEFT JOIN reseller_returns2 re_ret on re_ret.sales_adoption_key = akey.sales_adoption_key
#   LEFT JOIN AMZ_RTL2 amz_rtl on amz_rtl.sales_adoption_key = akey.sales_adoption_key
#   ),

#   --CREATE PRODUCT TYPE LEVEL RETURNS ADJUSTMENTS
#   q3_returns as (
#   SELECT 67900 as FY20_q3return_core_digital_standalone_units,
#         4936353 as FY20_q3return_core_digital_standalone_sales,
#         45783 as FY20_q3return_core_digital_bundle_units,
#         4617519 as FY20_q3return_core_digital_bundle_sales,
#         11234 as FY20_q3return_CU_units,
#         1236364 as FY20_q3return_CU_sales,
#         103806 as FY20_q3return_LLF_bundle_units,
#         10435072 as FY20_q3return_LLF_bundle_sales,
#         197723 as FY20_q3return_print_core_units,
#         21003329 as FY20_q3return_print_core_sales,
#         24188 as FY20_q3return_print_other_units,
#         1384253 as FY20_q3return_print_other_sales,
#         660 as FY20_q3return_ebook_units,
#         23522 as FY20_q3return_ebook_sales,
#         7875 as FY20_q3return_other_digital_bundle_units,
#         488309 as FY20_q3return_other_digital_bundle_sales),

#   --FIND TOTAL FY20 UNITS BY PRODUCT TYPE
#   fy20_non_ia as (
#   select * from final1
#   left join STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
#   ON ia.adoption_key = final1.sales_old_adoption_key
#   where coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') = 'N'),



#   fy20_units as (
#   select sum(FY20_ebook_units) as FY20_total_ebook_units,
#         sum(FY20_print_core_units) as FY20_total_print_core_units,
#         sum(FY20_print_other_units) as FY20_total_print_other_units,
#         sum(FY20_custom_print_core_units) as FY20_total_custom_print_core_units,
#         sum(FY20_custom_print_other_units) as FY20_total_custom_print_other_units,
#         sum(FY20_other_digital_bundle_units) as FY20_total_other_digital_bundle_units,
#         sum(FY20_other_digital_standalone_units) as FY20_total_other_digital_standalone_units,
#         sum(FY20_core_digital_bundle_units) as FY20_total_core_digital_bundle_units,
#         sum(FY20_core_digital_standalone_units) as FY20_total_core_digital_standalone_units,
#         sum(FY20_CU_units) as FY20_total_CU_units,
#         sum(FY20_LLF_bundle_units) as FY20_total_LLF_bundle_units
#   from fy20_non_ia),

#   --CREATE ADOPTION LEVEL ALLOCATIONS
#   fy20_returns as (
#   select sales_adoption_key,
#   (nvl(fy20_ebook_units,0)/(select FY20_total_ebook_units from fy20_units)*(select FY20_q3return_ebook_units from q3_returns)) as q3return_ebook_units,
#   (nvl(fy20_ebook_units,0)/(select FY20_total_ebook_units from fy20_units)*(select FY20_q3return_ebook_sales from q3_returns)) as q3return_ebook_sales,
#   (nvl(fy20_print_core_units,0)/(select FY20_total_print_core_units from fy20_units)*(select FY20_q3return_print_core_units from q3_returns)) as q3return_print_core_units,
#   (nvl(fy20_print_core_units,0)/(select FY20_total_print_core_units from fy20_units)*(select FY20_q3return_print_core_sales from q3_returns)) as q3return_print_core_sales,
#   (nvl(fy20_print_other_units,0)/(select FY20_total_print_other_units from fy20_units)*(select FY20_q3return_print_other_units from q3_returns)) as q3return_print_other_units,
#   (nvl(fy20_print_other_units,0)/(select FY20_total_print_other_units from fy20_units)*(select FY20_q3return_print_other_sales from q3_returns)) as q3return_print_other_sales,
#   (nvl(fy20_other_digital_bundle_units,0)/(select FY20_total_other_digital_bundle_units from fy20_units)*(select FY20_q3return_other_digital_bundle_units from q3_returns)) as q3return_other_digital_bundle_units,
#   (nvl(fy20_other_digital_bundle_units,0)/(select FY20_total_other_digital_bundle_units from fy20_units)*(select FY20_q3return_other_digital_bundle_sales from q3_returns)) as q3return_other_digital_bundle_sales,
#   (nvl(fy20_core_digital_bundle_units,0)/(select FY20_total_core_digital_bundle_units from fy20_units)*(select FY20_q3return_core_digital_bundle_units from q3_returns)) as q3return_core_digital_bundle_units,
#   (nvl(fy20_core_digital_bundle_units,0)/(select FY20_total_core_digital_bundle_units from fy20_units)*(select FY20_q3return_core_digital_bundle_sales from q3_returns)) as q3return_core_digital_bundle_sales,
#   (nvl(fy20_core_digital_standalone_units,0)/(select FY20_total_core_digital_standalone_units from fy20_units)*(select FY20_q3return_core_digital_standalone_units from q3_returns)) as q3return_core_digital_standalone_units,
#   (nvl(fy20_core_digital_standalone_units,0)/(select FY20_total_core_digital_standalone_units from fy20_units)*(select FY20_q3return_core_digital_standalone_sales from q3_returns)) as q3return_core_digital_standalone_sales,
#   (nvl(fy20_CU_units,0)/(select FY20_total_CU_units from fy20_units)*(select FY20_q3return_CU_units from q3_returns)) as q3return_CU_units,
#   (nvl(fy20_CU_units,0)/(select FY20_total_CU_units from fy20_units)*(select FY20_q3return_CU_sales from q3_returns)) as q3return_CU_sales,
#   (nvl(fy20_LLF_bundle_units,0)/(select FY20_total_LLF_bundle_units from fy20_units)*(select FY20_q3return_LLF_bundle_units from q3_returns)) as q3return_LLF_bundle_units,
#   (nvl(fy20_LLF_bundle_units,0)/(select FY20_total_LLF_bundle_units from fy20_units)*(select FY20_q3return_LLF_bundle_sales from q3_returns)) as q3return_LLF_bundle_sales
#   from final1
#   left join STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
#   ON ia.adoption_key = final1.sales_old_adoption_key
#   where coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') = 'N')


#   select final1.sales_adoption_key,
#         sales_old_adoption_key,
#         sales_institution_nm,
#         sales_state_cd,
#         sales_course_code_description,
#         sales_pub_series_de,
#         nvl(FY17_ebook_units,0) as FY17_ebook_units,
#         nvl(FY18_ebook_units,0) as FY18_ebook_units,
#         nvl(FY19_ebook_units,0) as FY19_ebook_units,
#         nvl(FY20_ebook_units,0) - nvl(q3return_ebook_units,0) as FY20_ebook_units,
#         nvl(FY17_ebook_sales,0) as FY17_ebook_sales,
#         nvl(FY18_ebook_sales,0) as FY18_ebook_sales,
#         nvl(FY19_ebook_sales,0) as FY19_ebook_sales,
#         nvl(FY20_ebook_sales,0) - nvl(q3return_ebook_sales,0) as FY20_ebook_sales,
#         nvl(FY17_print_core_units,0) as FY17_print_core_units,
#         nvl(FY18_print_core_units,0) as FY18_print_core_units,
#         nvl(FY19_print_core_units,0) as FY19_print_core_units,
#         nvl(FY20_print_core_units,0) - nvl(q3return_print_core_units,0) as FY20_print_core_units,
#         nvl(FY17_print_core_sales,0) as FY17_print_core_sales,
#         nvl(FY18_print_core_sales,0) as FY18_print_core_sales,
#         nvl(FY19_print_core_sales,0) as FY19_print_core_sales,
#         nvl(FY20_print_core_sales,0) - nvl(q3return_print_core_sales,0) as FY20_print_core_sales,
#         nvl(FY17_print_other_units,0) as FY17_print_other_units,
#         nvl(FY18_print_other_units,0) as FY18_print_other_units,
#         nvl(FY19_print_other_units,0) as FY19_print_other_units,
#         nvl(FY20_print_other_units,0) - nvl(q3return_print_other_units,0) as FY20_print_other_units,
#         nvl(FY17_print_other_sales,0) as FY17_print_other_sales,
#         nvl(FY18_print_other_sales,0) as FY18_print_other_sales,
#         nvl(FY19_print_other_sales,0) as FY19_print_other_sales,
#         nvl(FY20_print_other_sales,0) - nvl(q3return_print_other_sales,0) as FY20_print_other_sales,
#         nvl(FY17_custom_print_core_units,0) as FY17_custom_print_core_units,
#         nvl(FY18_custom_print_core_units,0) as FY18_custom_print_core_units,
#         nvl(FY19_custom_print_core_units,0) as FY19_custom_print_core_units,
#         nvl(FY20_custom_print_core_units,0) as FY20_custom_print_core_units,
#         nvl(FY17_custom_print_core_sales,0) as FY17_custom_print_core_sales,
#         nvl(FY18_custom_print_core_sales,0) as FY18_custom_print_core_sales,
#         nvl(FY19_custom_print_core_sales,0) as FY19_custom_print_core_sales,
#         nvl(FY20_custom_print_core_sales,0) as FY20_custom_print_core_sales,
#         nvl(FY17_custom_print_other_units,0) as FY17_custom_print_other_units,
#         nvl(FY18_custom_print_other_units,0) as FY18_custom_print_other_units,
#         nvl(FY19_custom_print_other_units,0) as FY19_custom_print_other_units,
#         nvl(FY20_custom_print_other_units,0) as FY20_custom_print_other_units,
#         nvl(FY17_custom_print_other_sales,0) as FY17_custom_print_other_sales,
#         nvl(FY18_custom_print_other_sales,0) as FY18_custom_print_other_sales,
#         nvl(FY19_custom_print_other_sales,0) as FY19_custom_print_other_sales,
#         nvl(FY20_custom_print_other_sales,0) as FY20_custom_print_other_sales,
#         nvl(FY17_other_digital_standalone_units,0) FY17_other_digital_standalone_units,
#         nvl(FY18_other_digital_standalone_units,0) FY18_other_digital_standalone_units,
#         nvl(FY19_other_digital_standalone_units,0) FY19_other_digital_standalone_units,
#         nvl(FY20_other_digital_standalone_units,0) FY20_other_digital_standalone_units,
#         nvl(FY17_other_digital_standalone_sales,0) FY17_other_digital_standalone_sales,
#         nvl(FY18_other_digital_standalone_sales,0) FY18_other_digital_standalone_sales,
#         nvl(FY19_other_digital_standalone_sales,0) FY19_other_digital_standalone_sales,
#         nvl(FY20_other_digital_standalone_sales,0) FY20_other_digital_standalone_sales,
#         nvl(FY17_other_digital_bundle_units,0) as FY17_other_digital_bundle_units,
#         nvl(FY18_other_digital_bundle_units,0) as FY18_other_digital_bundle_units,
#         nvl(FY19_other_digital_bundle_units,0) as FY19_other_digital_bundle_units,
#         nvl(FY20_other_digital_bundle_units,0) - nvl(q3return_other_digital_bundle_units,0) as FY20_other_digital_bundle_units,
#         nvl(FY17_other_digital_bundle_sales,0) as FY17_other_digital_bundle_sales,
#         nvl(FY18_other_digital_bundle_sales,0) as FY18_other_digital_bundle_sales,
#         nvl(FY19_other_digital_bundle_sales,0) as FY19_other_digital_bundle_sales,
#         nvl(FY20_other_digital_bundle_sales,0) - nvl(q3return_other_digital_bundle_sales,0) as FY20_other_digital_bundle_sales,
#         nvl(FY17_core_digital_standalone_units,0) as FY17_core_digital_standalone_units,
#         nvl(FY18_core_digital_standalone_units,0) as FY18_core_digital_standalone_units,
#         nvl(FY19_core_digital_standalone_units,0) as FY19_core_digital_standalone_units,
#         nvl(FY20_core_digital_standalone_units,0) - nvl(q3return_core_digital_standalone_units,0) as FY20_core_digital_standalone_units,
#         nvl(FY17_core_digital_standalone_sales,0) as FY17_core_digital_standalone_sales,
#         nvl(FY18_core_digital_standalone_sales,0) as FY18_core_digital_standalone_sales,
#         nvl(FY19_core_digital_standalone_sales,0) as FY19_core_digital_standalone_sales,
#         nvl(FY20_core_digital_standalone_sales,0) - nvl(q3return_core_digital_standalone_sales,0) as FY20_core_digital_standalone_sales,
#         nvl(FY17_core_digital_bundle_units,0) as FY17_core_digital_bundle_units,
#         nvl(FY18_core_digital_bundle_units,0) as FY18_core_digital_bundle_units,
#         nvl(FY19_core_digital_bundle_units,0) as FY19_core_digital_bundle_units,
#         nvl(FY20_core_digital_bundle_units,0) - nvl(q3return_core_digital_bundle_units,0) as FY20_core_digital_bundle_units,
#         nvl(FY17_core_digital_bundle_sales,0) as FY17_core_digital_bundle_sales,
#         nvl(FY18_core_digital_bundle_sales,0) as FY18_core_digital_bundle_sales,
#         nvl(FY19_core_digital_bundle_sales,0) as FY19_core_digital_bundle_sales,
#         nvl(FY20_core_digital_bundle_sales,0) - nvl(q3return_core_digital_bundle_sales,0) as FY20_core_digital_bundle_sales,
#         nvl(FY17_LLF_bundle_units,0) as FY17_LLF_bundle_units,
#         nvl(FY18_LLF_bundle_units,0) as FY18_LLF_bundle_units,
#         nvl(FY19_LLF_bundle_units,0) as FY19_LLF_bundle_units,
#         nvl(FY20_LLF_bundle_units,0) - nvl(q3return_LLF_bundle_units,0) as FY20_LLF_bundle_units,
#         nvl(FY17_LLF_bundle_sales,0) as FY17_LLF_bundle_sales,
#         nvl(FY18_LLF_bundle_sales,0) as FY18_LLF_bundle_sales,
#         nvl(FY19_LLF_bundle_sales,0) as FY19_LLF_bundle_sales,
#         nvl(FY20_LLF_bundle_sales,0) - nvl(q3return_LLF_bundle_sales,0) as FY20_LLF_bundle_sales,
#         nvl(FY17_CU_units,0) as FY17_CU_units,
#         nvl(FY18_CU_units,0) as FY18_CU_units,
#         nvl(FY19_CU_units,0) as FY19_CU_units,
#         nvl(FY20_CU_units,0) - nvl(q3return_CU_units,0) as FY20_CU_units,
#         nvl(FY17_CU_sales,0) as FY17_CU_sales,
#         nvl(FY18_CU_sales,0) as FY18_CU_sales,
#         nvl(FY19_CU_sales,0) as FY19_CU_sales,
#         nvl(FY20_CU_sales,0) - nvl(q3return_CU_sales,0) as FY20_CU_sales
#   from final1
#   left join fy20_returns returns
#   ON returns.sales_adoption_key = final1.sales_adoption_key




# ;;
# sql_trigger_value: Select * from DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_SALES_ORDERS ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: sales_adoption_key {
#     type: string
#     sql: ${TABLE}."SALES_ADOPTION_KEY" ;;
#   }

#   dimension: sales_old_adoption_key {
#     type: string
#     sql: ${TABLE}."SALES_OLD_ADOPTION_KEY" ;;
#   }

#   dimension: sales_institution_nm {
#     type: string
#     sql: ${TABLE}."SALES_INSTITUTION_NM" ;;
#   }

#   dimension: sales_state_cd {
#     type: string
#     sql: ${TABLE}."SALES_STATE_CD" ;;
#   }

#   dimension: sales_course_code_description {
#     type: string
#     sql: ${TABLE}."SALES_COURSE_CODE_DESCRIPTION" ;;
#   }

#   dimension: sales_pub_series_de {
#     type: string
#     sql: ${TABLE}."SALES_PUB_SERIES_DE" ;;
#   }

#   dimension: purchase_method {
#     type: string
#     sql: ${TABLE}."Purchase_Method" ;;
#   }

#   dimension: FY17_ebook_units {
#     type: number
#     sql: ${TABLE}."FY17_EBOOK_UNITS" ;;
#   }

#   dimension: FY18_ebook_units {
#     type: number
#     sql: ${TABLE}."FY18_EBOOK_UNITS" ;;
#   }

#   dimension: FY19_ebook_units {
#     type: number
#     sql: ${TABLE}."FY19_EBOOK_UNITS" ;;
#   }

#   dimension: FY20_ebook_units {
#     type: number
#     sql: ${TABLE}."FY20_EBOOK_UNITS" ;;
#   }

#   dimension: FY17_ebook_sales {
#     type: number
#     sql: ${TABLE}."FY17_EBOOK_SALES" ;;
#   }

#   dimension: FY18_ebook_sales {
#     type: number
#     sql: ${TABLE}."FY18_EBOOK_SALES" ;;
#   }

#   dimension: FY19_ebook_sales {
#     type: number
#     sql: ${TABLE}."FY19_EBOOK_SALES" ;;
#   }

#   dimension: FY20_ebook_sales {
#     type: number
#     sql: ${TABLE}."FY20_EBOOK_SALES" ;;
#   }

#   dimension: FY17_print_core_units {
#     type: number
#     sql: ${TABLE}."FY17_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY18_print_core_units {
#     type: number
#     sql: ${TABLE}."FY18_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY19_print_core_units {
#     type: number
#     sql: ${TABLE}."FY19_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY20_print_core_units {
#     type: number
#     sql: ${TABLE}."FY20_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY17_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY17_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY18_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY18_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY19_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY19_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY20_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY20_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY17_print_other_units {
#     type: number
#     sql: ${TABLE}."FY17_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY18_print_other_units {
#     type: number
#     sql: ${TABLE}."FY18_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY19_print_other_units {
#     type: number
#     sql: ${TABLE}."FY19_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY20_print_other_units {
#     type: number
#     sql: ${TABLE}."FY20_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY17_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY17_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY18_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY18_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY19_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY19_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY20_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY20_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY17_custom_print_core_units {
#     type: number
#     sql: ${TABLE}."FY17_CUSTOM_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY18_custom_print_core_units {
#     type: number
#     sql: ${TABLE}."FY18_CUSTOM_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY19_custom_print_core_units {
#     type: number
#     sql: ${TABLE}."FY19_CUSTOM_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY20_custom_print_core_units {
#     type: number
#     sql: ${TABLE}."FY20_CUSTOM_PRINT_CORE_UNITS" ;;
#   }

#   dimension: FY17_custom_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY17_CUSTOM_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY18_custom_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY18_CUSTOM_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY19_custom_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY19_CUSTOM_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY20_custom_print_core_sales {
#     type: number
#     sql: ${TABLE}."FY20_CUSTOM_PRINT_CORE_SALES" ;;
#   }

#   dimension: FY17_custom_print_other_units {
#     type: number
#     sql: ${TABLE}."FY17_CUSTOM_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY18_custom_print_other_units {
#     type: number
#     sql: ${TABLE}."FY18_CUSTOM_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY19_custom_print_other_units {
#     type: number
#     sql: ${TABLE}."FY19_CUSTOM_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY20_custom_print_other_units {
#     type: number
#     sql: ${TABLE}."FY20_CUSTOM_PRINT_OTHER_UNITS" ;;
#   }

#   dimension: FY17_custom_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY17_CUSTOM_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY18_custom_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY18_CUSTOM_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY19_custom_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY19_CUSTOM_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY20_custom_print_other_sales {
#     type: number
#     sql: ${TABLE}."FY20_CUSTOM_PRINT_OTHER_SALES" ;;
#   }

#   dimension: FY17_other_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY17_OTHER_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY18_other_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY18_OTHER_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY19_other_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY19_OTHER_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY20_other_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY20_OTHER_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY17_other_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY17_OTHER_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY18_other_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY18_OTHER_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY19_other_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY19_OTHER_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY20_other_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY20_OTHER_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY17_other_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY17_OTHER_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY18_other_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY18_OTHER_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY19_other_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY19_OTHER_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY20_other_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY20_OTHER_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY17_other_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY17_OTHER_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY18_other_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY18_OTHER_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY19_other_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY19_OTHER_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY20_other_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY20_OTHER_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY17_core_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY17_CORE_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY18_core_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY18_CORE_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY19_core_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY19_CORE_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY20_core_digital_standalone_units {
#     type: number
#     sql: ${TABLE}."FY20_CORE_DIGITAL_STANDALONE_UNITS" ;;
#   }

#   dimension: FY17_core_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY17_CORE_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY18_core_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY18_CORE_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY19_core_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY19_CORE_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY20_core_digital_standalone_sales {
#     type: number
#     sql: ${TABLE}."FY20_CORE_DIGITAL_STANDALONE_SALES" ;;
#   }

#   dimension: FY17_core_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY17_CORE_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY18_core_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY18_CORE_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY19_core_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY19_CORE_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY20_core_digital_bundle_units {
#     type: number
#     sql: ${TABLE}."FY20_CORE_DIGITAL_BUNDLE_UNITS" ;;
#   }

#   dimension: FY17_core_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY17_CORE_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY18_core_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY18_CORE_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY19_core_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY19_CORE_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY20_core_digital_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY20_CORE_DIGITAL_BUNDLE_SALES" ;;
#   }

#   dimension: FY17_LLF_bundle_units {
#     type: number
#     sql: ${TABLE}."FY17_LLF_BUNDLE_UNITS" ;;
#   }

#   dimension: FY18_LLF_bundle_units {
#     type: number
#     sql: ${TABLE}."FY18_LLF_BUNDLE_UNITS" ;;
#   }

#   dimension: FY19_LLF_bundle_units {
#     type: number
#     sql: ${TABLE}."FY19_LLF_BUNDLE_UNITS" ;;
#   }

#   dimension: FY20_LLF_bundle_units {
#     type: number
#     sql: ${TABLE}."FY20_LLF_BUNDLE_UNITS" ;;
#   }

#   dimension: FY17_LLF_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY17_LLF_BUNDLE_SALES" ;;
#   }

#   dimension: FY18_LLF_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY18_LLF_BUNDLE_SALES" ;;
#   }

#   dimension: FY19_LLF_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY19_LLF_BUNDLE_SALES" ;;
#   }

#   dimension: FY20_LLF_bundle_sales {
#     type: number
#     sql: ${TABLE}."FY20_LLF_BUNDLE_SALES" ;;
#   }

#   dimension: FY17_cu_units {
#     type: number
#     sql: ${TABLE}."FY17_CU_UNITS" ;;
#   }

#   dimension: FY18_cu_units {
#     type: number
#     sql: ${TABLE}."FY18_CU_UNITS" ;;
#   }

#   dimension: FY19_cu_units {
#     type: number
#     sql: ${TABLE}."FY19_CU_UNITS" ;;
#   }

#   dimension: FY20_cu_units {
#     type: number
#     sql: ${TABLE}."FY20_CU_UNITS" ;;
#   }

#   dimension: FY17_cu_sales {
#     type: number
#     sql: ${TABLE}."FY17_CU_SALES" ;;
#   }

#   dimension: FY18_cu_sales {
#     type: number
#     sql: ${TABLE}."FY18_CU_SALES" ;;
#   }

#   dimension: FY19_cu_sales {
#     type: number
#     sql: ${TABLE}."FY19_CU_SALES" ;;
#   }

#   dimension: FY20_cu_sales {
#     type: number
#     sql: ${TABLE}."FY20_CU_SALES" ;;
#   }

#   set: detail {
#     fields: [
#       sales_adoption_key,
#       sales_old_adoption_key,
#       sales_institution_nm,
#       sales_state_cd,
#       sales_course_code_description,
#       sales_pub_series_de,
#       purchase_method,
#       FY17_ebook_units,
#       FY18_ebook_units,
#       FY19_ebook_units,
#       FY20_ebook_units,
#       FY17_ebook_sales,
#       FY18_ebook_sales,
#       FY19_ebook_sales,
#       FY20_ebook_sales,
#       FY17_print_core_units,
#       FY18_print_core_units,
#       FY19_print_core_units,
#       FY20_print_core_units,
#       FY17_print_core_sales,
#       FY18_print_core_sales,
#       FY19_print_core_sales,
#       FY20_print_core_sales,
#       FY17_print_other_units,
#       FY18_print_other_units,
#       FY19_print_other_units,
#       FY20_print_other_units,
#       FY17_print_other_sales,
#       FY18_print_other_sales,
#       FY19_print_other_sales,
#       FY20_print_other_sales,
#       FY17_custom_print_core_units,
#       FY18_custom_print_core_units,
#       FY19_custom_print_core_units,
#       FY20_custom_print_core_units,
#       FY17_custom_print_core_sales,
#       FY18_custom_print_core_sales,
#       FY19_custom_print_core_sales,
#       FY20_custom_print_core_sales,
#       FY17_custom_print_other_units,
#       FY18_custom_print_other_units,
#       FY19_custom_print_other_units,
#       FY20_custom_print_other_units,
#       FY17_custom_print_other_sales,
#       FY18_custom_print_other_sales,
#       FY19_custom_print_other_sales,
#       FY20_custom_print_other_sales,
#       FY17_other_digital_standalone_units,
#       FY18_other_digital_standalone_units,
#       FY19_other_digital_standalone_units,
#       FY20_other_digital_standalone_units,
#       FY17_other_digital_standalone_sales,
#       FY18_other_digital_standalone_sales,
#       FY19_other_digital_standalone_sales,
#       FY20_other_digital_standalone_sales,
#       FY17_other_digital_bundle_units,
#       FY18_other_digital_bundle_units,
#       FY19_other_digital_bundle_units,
#       FY20_other_digital_bundle_units,
#       FY17_other_digital_bundle_sales,
#       FY18_other_digital_bundle_sales,
#       FY19_other_digital_bundle_sales,
#       FY20_other_digital_bundle_sales,
#       FY17_core_digital_standalone_units,
#       FY18_core_digital_standalone_units,
#       FY19_core_digital_standalone_units,
#       FY20_core_digital_standalone_units,
#       FY17_core_digital_standalone_sales,
#       FY18_core_digital_standalone_sales,
#       FY19_core_digital_standalone_sales,
#       FY20_core_digital_standalone_sales,
#       FY17_core_digital_bundle_units,
#       FY18_core_digital_bundle_units,
#       FY19_core_digital_bundle_units,
#       FY20_core_digital_bundle_units,
#       FY17_core_digital_bundle_sales,
#       FY18_core_digital_bundle_sales,
#       FY19_core_digital_bundle_sales,
#       FY20_core_digital_bundle_sales,
#       FY17_LLF_bundle_units,
#       FY18_LLF_bundle_units,
#       FY19_LLF_bundle_units,
#       FY20_LLF_bundle_units,
#       FY17_LLF_bundle_sales,
#       FY18_LLF_bundle_sales,
#       FY19_LLF_bundle_sales,
#       FY20_LLF_bundle_sales,
#       FY17_cu_units,
#       FY18_cu_units,
#       FY19_cu_units,
#       FY20_cu_units,
#       FY17_cu_sales,
#       FY18_cu_sales,
#       FY19_cu_sales,
#       FY20_cu_sales
#     ]
#   }
# }
