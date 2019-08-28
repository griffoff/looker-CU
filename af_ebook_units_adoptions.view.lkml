view: af_ebook_units_adoptions {
  derived_table: {
    sql: With ebook_unit1 as (
         select units.*
            ,dm_entities.state_cd as ent_state_cd
            ,dm_entities.institution_nm
            ,dm_products.pub_series_de
            ,dm_products.prod_family_cd
            ,pfmt.course_code_description
            ,dimdate.fiscalyearvalue as fiscalyear
            ,concat(concat(concat(concat(institution_nm,'|'),pfmt.course_code_description),'|'),dm_products.pub_series_de) as adoption_key
            from STRATEGY.ADOPTION_PIVOT.CONSUMED_UNITS_ADOPTIONPIVOT units
            LEFT JOIN STRATEGY.DW.DM_ENTITIES dm_entities
            ON units.CONSUMED_ENTITY_NO = dm_entities.entity_no
            LEFT Join DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS dm_products
            ON units.CONSUMED_PRODUCT_SKEY = dm_products.Product_Skey
            LEFT JOIN "STRATEGY"."ADOPTION_PIVOT"."PFMT_ADOPTIONPIVOT" pfmt on pfmt.product_family_code = dm_products.prod_family_cd
            JOIN prod.dw_ga.dim_date dimdate ON to_date(units.consumed_month_dt) = to_date(dimdate.datevalue)
          )
          Select
              adoption_key,
             institution_nm,
              SUM(CASE WHEN fiscalyear = 'FY18' THEN cu_ebook_units END) AS FY18_ebook_units_byCU,
              SUM(CASE WHEN fiscalyear = 'FY19' THEN cu_ebook_units END) AS FY19_ebook_units_byCU
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
