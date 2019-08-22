
view: sales_order_adoption_base {
  derived_table: {
    sql:
    WITH sales_adoption as
    (
      Select sal.*,eb.FY18_total_consumed_units,eb.FY19_total_consumed_units,total_CD_actv_exCU_FY18,total_CD_actv_exCU_FY19,total_CD_actv_withCU_FY18,total_CD_actv_withCU_FY19,
          total_CD_actv_FY18,total_CD_actv_FY19,
          FY_17_IA_ADOPTION_Y_N_ AS FY_17_IA, FY_18_IA_ADOPTION_Y_N_ AS FY_18_IA,FY_19_IA_ADOPTION_Y_N_ AS FY_19_IA,FY_19_CU_I_INSTITUTION_Y_N_ AS FY_19_CUI,
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
         END AS total_core_digit_units_fy18,
      CASE WHEN (TOTAL_PRINT_NET_UNITS_FY19 + TOTAL_CORE_DIGIT_UNITS_FY19) < 5 THEN 'Non Adoption'
            WHEN (TOTAL_CORE_DIGIT_UNITS_FY19/(TOTAL_PRINT_NET_UNITS_FY19 + TOTAL_CORE_DIGIT_UNITS_FY19)) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy19,
       CASE WHEN (TOTAL_PRINT_NET_UNITS_FY18 + TOTAL_CORE_DIGIT_UNITS_FY18) < 5 THEN 'Non Adoption'
            WHEN (TOTAL_CORE_DIGIT_UNITS_FY18/(TOTAL_PRINT_NET_UNITS_FY18 + TOTAL_CORE_DIGIT_UNITS_FY18)) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy18,
        TOTAL_PRINT_NET_UNITS_FY19 + TOTAL_CORE_DIGIT_UNITS_FY19 AS total_net_units_fy19,
        TOTAL_PRINT_NET_UNITS_FY18 + TOTAL_CORE_DIGIT_UNITS_FY18 AS total_net_units_fy18,
        CASE WHEN Coalesce(total_net_units_fy19,0) > 0.5 AND Coalesce(total_net_units_fy18,0) > 0.5
          THEN
            CASE WHEN total_net_units_fy19/total_net_units_fy18 >= 10 THEN '10x larger'
                WHEN total_net_units_fy19/total_net_units_fy18 > 1 THEN 'larger not 10x'
                WHEN total_net_units_fy19/total_net_units_fy18 = 1 THEN 'equal'
                WHEN total_net_units_fy19/total_net_units_fy18 <= 0.1 THEN '10x smaller'
                WHEN total_net_units_fy19/total_net_units_fy18 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy19,0) < 0.5 AND Coalesce(total_net_units_fy18,0) > 0.5
          THEN
            CASE WHEN 0.5/Coalesce(total_net_units_fy18,0) >= 10 THEN '10x larger'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) > 1 THEN 'larger not 10x'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) = 1 THEN 'equal'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) <= 0.1 THEN '10x smaller'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy19,0) > 0.5 AND Coalesce(total_net_units_fy18,0) < 0.5
          THEN
            CASE WHEN Coalesce(total_net_units_fy19,0)/0.5 >= 10 THEN '10x larger'
                WHEN Coalesce(total_net_units_fy19,0)/0.5 > 1 THEN 'larger not 10x'
                WHEN Coalesce(total_net_units_fy19,0)/0.5 = 1 THEN 'equal'
                WHEN Coalesce(total_net_units_fy19,0)/0.5 <= 0.1 THEN '10x smaller'
                WHEN Coalesce(total_net_units_fy19,0)/0.5 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
       WHEN Coalesce(total_net_units_fy19,0) < 0.5 AND Coalesce(total_net_units_fy18,0) < 0.5
          THEN
          CASE WHEN 1 = 1 THEN 'equal'
        END
      ELSE 'error'
        END AS FY18_FY19_Adoption_Unit_Gain_Loss,
        Concat(Concat(concat(concat(Adoption_type_Fy18,'->'),Adoption_type_Fy19),' | '),FY18_FY19_Adoption_Unit_Gain_Loss) AS FY18_FY19_adoptions_transition_type_2


      from dev.zas.SALES_ORDER_ADOPTIONS  sal
              LEFT JOIN dev.zas.activation_adoptions act
              ON sal.adoption_key = act.adoption_key
              LEFT JOIN dev.zas.ebook_units_adoptions eb
              ON sal.adoption_key = eb.adoption_key
              LEFT JOIN UPLOADS.CU.IA_ADOPTIONS_SALESORDER ia
              ON ia.adoption_key = sal.adoption_key
              LEFT JOIN UPLOADS.CU.CUI_ADOPTIONS_SALESORDERS cui
              ON cui.institution_name = sal.institution_nm
      ) SELECT * FROM sales_adoption s
        LEFT JOIN UPLOADS.CU.ADOPTION_TRANSITIONS_SALESORDERS adp_tr
              ON lower(adp_tr.TYPE_2_ADOPTION_TRANSITION) = lower(s.FY18_FY19_adoptions_transition_type_2)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: FY_17_IA {}
  dimension: FY_18_IA {}
  dimension: FY_19_IA {}
  dimension: FY_19_CUI {}
  dimension: institution_nm {}
  dimension: total_core_digit_units_fy19 {}
  dimension: total_core_digit_units_fy18 {}
  dimension: Adoption_type_Fy19 {}
  dimension: Adoption_type_Fy18 {}
  dimension: FY18_FY19_adoption_transition_type1 {
    label: "FY18->FY19 Adoption Transition – Type 1"
    sql: concat(concat(Adoption_type_Fy18,' -> '),Adoption_type_Fy19) ;;
  }
  dimension:FY18_FY19_adoptions_transition_type_2  {
    label: "FY18 -> FY19 Adoption Transition Type 2"
    sql: Concat(Concat(concat(concat(Adoption_type_Fy18,'->'),Adoption_type_Fy19),' | '),FY18_FY19_Adoption_Unit_Gain_Loss) ;;
  }

  dimension: ADOPTION_TRANSITION {}


  dimension: FY18_FY19_Adoption_Unit_Gain_Loss {}

  dimension: actv_rate_fy19  {
    type: number
    sql: CASE WHEN total_core_digit_units_fy19 = 0 OR total_CD_actv_FY19 = 0 THEN 0
          ELSE total_CD_actv_FY19/total_core_digit_units_fy19
          END;;
  }

  dimension: actv_rate_fy18  {
    type: number
    sql: CASE WHEN total_core_digit_units_fy18 = 0 OR total_CD_actv_FY18 = 0 THEN 0
          ELSE total_CD_actv_FY18/total_core_digit_units_fy18
          END;;
  }



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
  measure: sum_total_core_digit_units_fy19 {
    label: "Total Core Digital Consumed Units FY 19"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGIT_UNITS_FY19" ;;
  }

  measure: sum_total_core_digit_units_fy18 {
    label: "Total Core Digital Consumed Units FY 18"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGIT_UNITS_FY18" ;;
  }

  dimension: total_net_units_fy19 {
  }

  dimension: total_net_units_fy18 {
  }

  dimension: net_units_tiers_Fy19 {
    type: tier
  tiers: [0,5,10,15,25,50,100,200,500,1000]
  style: interval
  sql: total_net_units_fy19 ;;
  }

  measure: sum_total_net_units_fy19 {
    type: sum
    sql: ${total_net_units_fy19} ;;
  }

  measure: sum_total_net_units_fy18 {
    type: sum
    sql: ${total_net_units_fy18} ;;
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

  measure: sum_total_cd_actv_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY19" ;;
  }

  measure: sum_total_cd_actv_fy18 {
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY18" ;;
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
