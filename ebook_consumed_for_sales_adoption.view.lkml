explore:  ebook_consumed_for_sales_adoption {}
view: ebook_consumed_for_sales_adoption {
  derived_table: {
    sql: select units.*
      ,dm_entities.state_de,dm_entities.institution_nm,dm_products.pub_series_de
      ,dm_products.prod_family_cd,e1_product_family_master.course_as_provided_by_prd_team
      ,dimdate.fiscalyearvalue as fiscalyear
      from STRATEGY.DW.DM_CONSUMED_UNITS units
      LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_ENTITIES dm_entities
      ON units.CONSUMED_ENTITY_NO = dm_entities.entity_no
      Left Join DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS dm_products
      ON units.CONSUMED_PRODUCT_SKEY = dm_products.Product_Skey
      LEFT JOIN Uploads.CU.e1_product_family_master ON (e1_product_family_master."PF_CODE") = (dm_products."PROD_FAMILY_CD")
      LEFT JOIN prod.dw_ga.dim_date dimdate ON units.consumed_month_dt = dimdate.datevalue
      where  e1_product_family_master._file ilike 'E1 Product Family Master(12-20-18).csv'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
    hidden: yes
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
    hidden: yes
  }

  dimension: fiscalyear {}

  dimension: concat_primary{
    type: string
    sql: Concat(concat(${consumed_entity_no},${consumed_product_skey}),${consumed_month_dt})  ;;
    primary_key: yes
    hidden: yes
  }

  dimension: con_unit_skey {
    type: number
    sql: ${TABLE}."CON_UNIT_SKEY" ;;
  }

  dimension: dw_added_dt {
    type: date
    sql: ${TABLE}."DW_ADDED_DT" ;;
  }

  dimension: dw_changed_dt {
    type: date
    sql: ${TABLE}."DW_CHANGED_DT" ;;
  }

  dimension: md_5_checksum {
    type: string
    sql: ${TABLE}."MD_5_CHECKSUM" ;;
  }

  dimension: consumed_month_dt {
    type: date
    sql: ${TABLE}."CONSUMED_MONTH_DT" ;;
  }

  dimension: consumed_entity_no {
    type: number
    sql: ${TABLE}."CONSUMED_ENTITY_NO" ;;
  }

  dimension: consumed_isbn {
    type: number
    sql: ${TABLE}."CONSUMED_ISBN" ;;
  }

  dimension: consumed_product_skey {
    type: number
    sql: ${TABLE}."CONSUMED_PRODUCT_SKEY" ;;
  }

  dimension: total_consumed_units {
    type: number
    sql: ${TABLE}."TOTAL_CONSUMED_UNITS" ;;
  }

  measure: sum_total_consumed_units{
    label: "TOTAL_CONSUMED_UNITS"
    type: sum
    sql: ${TABLE}."TOTAL_CONSUMED_UNITS" ;;
  }

  dimension: digital_sales_units {
    type: number
    sql: ${TABLE}."DIGITAL_SALES_UNITS" ;;
  }

  dimension: cu_activation_units {
    type: number
    sql: ${TABLE}."CU_ACTIVATION_UNITS" ;;
  }

  dimension: cu_ebook_units {
    type: number
    sql: ${TABLE}."CU_EBOOK_UNITS" ;;
  }

  dimension: organization {
    type: string
    sql: ${TABLE}."ORGANIZATION" ;;
  }

  dimension: cu_rental_units {
    type: number
    sql: ${TABLE}."CU_RENTAL_UNITS" ;;
  }

  dimension: consumed_mag_acct_id {
    type: string
    sql: ${TABLE}."CONSUMED_MAG_ACCT_ID" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: state_de {
    type: string
    sql: ${TABLE}."STATE_DE" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: pub_series_de {
    type: string
    sql: ${TABLE}."PUB_SERIES_DE" ;;
  }

  dimension: prod_family_cd {
    type: string
    sql: ${TABLE}."PROD_FAMILY_CD" ;;
  }

  dimension: course_as_provided_by_prd_team {
    type: string
    sql: ${TABLE}."COURSE_AS_PROVIDED_BY_PRD_TEAM" ;;
  }

  set: detail {
    fields: [
      _file,
      _line,
      con_unit_skey,
      dw_added_dt,
      dw_changed_dt,
      md_5_checksum,
      consumed_month_dt,
      consumed_entity_no,
      consumed_isbn,
      consumed_product_skey,
      total_consumed_units,
      digital_sales_units,
      cu_activation_units,
      cu_ebook_units,
      organization,
      cu_rental_units,
      consumed_mag_acct_id,
      _fivetran_synced_time,
      state_de,
      institution_nm,
      pub_series_de,
      prod_family_cd,
      course_as_provided_by_prd_team,
      sum_total_consumed_units

    ]
  }
}
