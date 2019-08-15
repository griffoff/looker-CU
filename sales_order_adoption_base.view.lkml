
view: sales_order_adoption_base {
  derived_table: {
    sql: Select sal.*,eb.FY18_total_consumed_units,eb.FY19_total_consumed_units,total_CD_actv_exCU_FY18,total_CD_actv_exCU_FY19,total_CD_actv_withCU_FY18,total_CD_actv_withCU_FY19,
      total_CD_actv_FY18,total_CD_actv_FY19,
      FY_17_IA_ADOPTION_Y_N_ AS FY_17_IA, FY_18_IA_ADOPTION_Y_N_ AS FY_18_IA,FY_19_IA_ADOPTION_Y_N_ AS FY_19_IA,
      CASE WHEN FY_19_IA_ADOPTION_Y_N_ = 'Y' THEN
        CASE WHEN total_CD_actv_FY19 > (total_CD_actv_withCU_FY19 + total_core_digital_ex_cu_net_units_fy19) THEN total_CD_actv_FY19
             WHEN total_CD_actv_FY19 < (total_CD_actv_withCU_FY19 + total_core_digital_ex_cu_net_units_fy19) THEN total_CD_actv_withCU_FY19 + total_core_digital_ex_cu_net_units_fy19
             END
         ELSE (total_CD_actv_withCU_FY19 + total_core_digital_ex_cu_net_units_fy19)
         END AS total_core_digit_units_fy19,
      CASE WHEN FY_18_IA_ADOPTION_Y_N_ = 'Y' THEN
        CASE WHEN total_CD_actv_FY18 > (total_CD_actv_withCU_FY18 + Total_core_digital_Ex_CU_Net_Units_fy18) THEN total_CD_actv_FY18
        WHEN total_CD_actv_FY18 < (total_CD_actv_withCU_FY18 + Total_core_digital_Ex_CU_Net_Units_fy18) THEN total_CD_actv_withCU_FY18 + total_core_digital_ex_cu_net_units_fy18
        END
         ELSE (total_CD_actv_withCU_FY18 + Total_core_digital_Ex_CU_Net_Units_fy18)
         END AS total_core_digit_units_fy18
      from dev.zas.SALES_ORDER_ADOPTIONS  sal
              LEFT JOIN dev.zas.activation_adoptions act
              ON sal.adoption_key = act.adoption_key
              LEFT JOIN dev.zas.ebook_units_adoptions eb
              ON sal.adoption_key = eb.adoption_key
              LEFT JOIN UPLOADS.CU.IA_ADOPTIONS_SALESORDER ia
              ON ia.adoption_key = sal.adoption_key
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: FY_17_IA {}
  dimension: FY_18_IA {}
  dimension: FY_19_IA {}
  dimension: institution_nm {}

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }

  dimension: total_print_net_sales_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY18" ;;
  }

  measure: sum_total_print_net_sales_fy18 {
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY18";;
  }

  measure: sum_total_print_net_sales_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY19" ;;
  }

#   FY19 Total Core Digital Consumed Units
  measure: total_core_digit_units_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGIT_UNITS_FY19" ;;
  }

  measure: total_core_digit_units_fy18 {
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGIT_UNITS_FY18" ;;
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

  measure: sum_total_net_sales_fy18 {
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY18" ;;
  }

  measure: sum_total_net_sales_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY19" ;;
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

  dimension: fy18_total_consumed_units {
    type: number
    sql: ${TABLE}."FY18_TOTAL_CONSUMED_UNITS" ;;
  }

  dimension: fy19_total_consumed_units {
    type: number
    sql: ${TABLE}."FY19_TOTAL_CONSUMED_UNITS" ;;
  }

  dimension: total_cd_actv_excu_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY18" ;;
  }

  dimension: total_cd_actv_excu_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY19" ;;
  }

  dimension: total_cd_actv_withcu_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY18" ;;
  }

  dimension: total_cd_actv_withcu_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY19" ;;
  }

  dimension: total_cd_actv_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY18" ;;
  }

  dimension: total_cd_actv_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY19" ;;
  }


  set: detail {
    fields: [
      adoption_key,
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
      total_core_digital_cu_net_units_fy19,
      fy18_total_consumed_units,
      fy19_total_consumed_units,
      total_cd_actv_excu_fy18,
      total_cd_actv_excu_fy19,
      total_cd_actv_withcu_fy18,
      total_cd_actv_withcu_fy19,
      total_cd_actv_fy18,
      total_cd_actv_fy19
    ]
  }
}
