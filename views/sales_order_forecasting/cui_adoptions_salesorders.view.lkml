view: cui_adoptions_salesorders {
  derived_table: {
    sql: Select institution_name, FY_19_CU_I_INSTITUTION_Y_N_ AS cui_flag, 'FY19' AS fiscalyear  from UPLOADS.CU.CUI_ADOPTIONS_SALESORDERS limit 10;
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: institution_name {
    type: string
    sql: ${TABLE}."INSTITUTION_NAME" ;;
  }

  dimension: cui_flag {
    type: string
    sql: ${TABLE}."CUI_FLAG" ;;
  }

  dimension: fiscalyear {
    type: string
    sql: ${TABLE}."FISCALYEAR" ;;
  }

  set: detail {
    fields: [institution_name, cui_flag, fiscalyear]
  }
}
