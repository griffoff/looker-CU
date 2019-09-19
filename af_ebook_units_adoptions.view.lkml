view: af_ebook_units_adoptions {
  derived_table: {
    sql: With ebook_unit1 as (
         select units.*
            ,ent.state_cd
            ,ent.institution_nm
            ,dm_products.pub_series_de
            ,dm_products.prod_family_cd
            ,coalesce(pfmt.course_code_description,'.') as course_code_description
            ,dimdate.fiscalyearvalue as fiscalyear
            ,concat(concat(concat(concat(concat(concat(ent.institution_nm,'|'),ent.state_cd),'|'),coalesce(pfmt.course_code_description,'.')),'|'),dm_products.pub_series_de) as adoption_key
            ,concat(concat(concat(concat(ent.institution_nm,'|'),coalesce(pfmt.course_code_description,'.')),'|'),dm_products.pub_series_de) as old_adoption_key
            from STRATEGY.ADOPTION_PIVOT.CONSUMED_UNITS_ADOPTIONPIVOT units
            LEFT JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT ent
            ON units.CONSUMED_ENTITY_NO = ent.entity_no
            LEFT Join STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT dm_products
            ON units.CONSUMED_PRODUCT_SKEY = dm_products.Product_Skey
            LEFT JOIN STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = dm_products.prod_family_cd
            JOIN prod.dw_ga.dim_date dimdate ON to_date(units.consumed_month_dt) = to_date(dimdate.datevalue)
            where units.organization = 'Higher Ed'
          )
          Select
              adoption_key,
              old_adoption_key,
              institution_nm,
              state_cd,
              course_code_description,
              pub_series_de,
              SUM(CASE WHEN fiscalyear = 'FY17' THEN cu_ebook_units END) AS FY17_ebook_units_byCU,
              SUM(CASE WHEN fiscalyear = 'FY18' THEN cu_ebook_units END) AS FY18_ebook_units_byCU,
              SUM(CASE WHEN fiscalyear = 'FY19' THEN cu_ebook_units END) AS FY19_ebook_units_byCU
          from ebook_unit1
              group by 1,2,3,4,5,6

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

  dimension: old_adoption_key {
    type: string
    sql: ${TABLE}."OLD_ADOPTION_KEY" ;;
  }


  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: state_cd {
    type: string
    sql: ${TABLE}."STATE_CD" ;;
  }

  dimension: course_code_description {
    type: string
    sql: ${TABLE}."COURSE_CODE_DESCRIPTION" ;;
  }

  dimension: pub_series_de {
    type: string
    sql: ${TABLE}."PUB_SERIES_DE" ;;
  }

  dimension: FY17_ebook_units_byCU {
    type: number
    sql: ${TABLE}."FY17_EBOOK_UNITS_BYCU" ;;
  }

  dimension: FY18_ebook_units_byCU {
    type: number
    sql: ${TABLE}."FY18_EBOOK_UNITS_BYCU" ;;
  }

  dimension: FY19_ebook_units_byCU {
    type: number
    sql: ${TABLE}."FY19_EBOOK_UNITS_BYCU" ;;
  }

  set: detail {
    fields: [adoption_key, old_adoption_key, institution_nm, state_cd, course_code_description, pub_series_de, FY17_ebook_units_byCU, FY18_ebook_units_byCU, FY19_ebook_units_byCU]
  }
}
