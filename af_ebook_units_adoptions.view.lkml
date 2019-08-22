view: af_ebook_units_adoptions {
  derived_table: {
    sql: With ebook_unit1 as (
         select units.*
            ,dm_entities.state_de as ent_state_de,dm_entities.institution_nm,dm_products.pub_series_de
            ,dm_products.prod_family_cd,e1_product_family_master.course_as_provided_by_prd_team
            ,dimdate.fiscalyearvalue as fiscalyear
            ,concat(concat(concat(concat(institution_nm,'|'),course_as_provided_by_prd_team),'|'),dm_products.pub_series_de) as adoption_key
            from STRATEGY.DW.DM_CONSUMED_UNITS units
            LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_ENTITIES dm_entities
            ON units.CONSUMED_ENTITY_NO = dm_entities.entity_no
            Left Join DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS dm_products
            ON units.CONSUMED_PRODUCT_SKEY = dm_products.Product_Skey
            LEFT JOIN Uploads.CU.e1_product_family_master ON (e1_product_family_master."PF_CODE") = (dm_products."PROD_FAMILY_CD")
            LEFT JOIN prod.dw_ga.dim_date dimdate ON units.consumed_month_dt = dimdate.datevalue
            where  e1_product_family_master._file ilike 'E1 Product Family Master(12-20-18).csv'
          )
          Select
              adoption_key,
             institution_nm,
              SUM(CASE WHEN fiscalyear = 'FY18' THEN cu_ebook_units END) AS FY18_total_consumed_units,
              SUM(CASE WHEN fiscalyear = 'FY19' THEN cu_ebook_units END) AS FY19_total_consumed_units
          from ebook_unit1
              group by 1,2

       ;;
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

  dimension: fy18_total_consumed_units {
    type: number
    sql: ${TABLE}."FY18_TOTAL_CONSUMED_UNITS" ;;
  }

  dimension: fy19_total_consumed_units {
    type: number
    sql: ${TABLE}."FY19_TOTAL_CONSUMED_UNITS" ;;
  }

  set: detail {
    fields: [adoption_key, institution_nm, fy18_total_consumed_units, fy19_total_consumed_units]
  }
}
