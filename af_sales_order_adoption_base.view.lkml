
view: sales_order_adoption_base {
  derived_table: {
    sql:
    WITH sales_adoption as
    (
      Select sal.*,eb.FY18_ebook_units_byCU,eb.FY19_ebook_units_byCU,total_CD_actv_exCU_FY18,total_CD_actv_exCU_FY19,total_CD_actv_withCU_FY18,total_CD_actv_withCU_FY19,
          total_CD_actv_FY18,total_CD_actv_FY19,
          FY_17_IA_ADOPTION_Y_N_ AS FY_17_IA, FY_18_IA_ADOPTION_Y_N_ AS FY_18_IA,FY_19_IA_ADOPTION_Y_N_ AS FY_19_IA,FY_19_CU_I_INSTITUTION_Y_N_ AS FY_19_CUI,
        CASE WHEN FY_19_IA_ADOPTION_Y_N_ = 'Y' THEN
        CASE WHEN coalesce(total_CD_actv_FY19,0) > (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0)) THEN coalesce(total_CD_actv_FY19,0)
             WHEN coalesce(total_CD_actv_FY19,0) < (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0)) THEN (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0))
             END
         ELSE (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0))
         END AS FY19_total_core_digital_consumed_units,
        CASE WHEN FY_18_IA_ADOPTION_Y_N_ = 'Y' THEN
        CASE WHEN coalesce(total_CD_actv_FY18,0) > (coalesce(total_CD_actv_withCU_FY18,0) + coalesce(total_core_digital_ex_cu_net_units_fy18,0)) THEN total_CD_actv_FY18
             WHEN coalesce(total_CD_actv_FY18,0) < (coalesce(total_CD_actv_withCU_FY18,0) + coalesce(total_core_digital_ex_cu_net_units_fy18,0)) THEN (coalesce(total_CD_actv_withCU_FY18,0) + coalesce(total_core_digital_ex_cu_net_units_fy18,0))
             END
         ELSE (coalesce(total_CD_actv_withCU_FY18,0) + coalesce(total_core_digital_ex_cu_net_units_fy18,0))
         END AS FY18_total_core_digital_consumed_units,
      --(sal.FY18_ebook_units + eb.FY18_ebook_units_byCU) as FY18_total_ebook_activations,
      --(sal.FY19_ebook_units + eb.FY19_ebook_units_byCU) as FY19_total_ebook_activations,
      CASE WHEN (coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0)) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY19_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy19,
       CASE WHEN (coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + coalesce(FY18_total_core_digital_consumed_units,0)) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY18_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + coalesce(FY18_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy18,
        coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0) AS total_net_units_fy19,
        Coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + Coalesce(FY18_total_core_digital_consumed_units,0) AS total_net_units_fy18,
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


      from  ${af_salesorder_adoption.SQL_TABLE_NAME} sal
              FULL OUTER JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act
              ON sal.adoption_key = act.adoption_key
              FULL OUTER JOIN ${af_ebook_units_adoptions.SQL_TABLE_NAME} AS eb
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
  dimension: FY19_total_core_digital_consumed_units {}
  dimension: FY18_total_core_digital_consumed_units {}
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
    sql: CASE WHEN FY19_total_core_digital_consumed_units = 0 OR total_CD_actv_FY19 = 0 THEN 0
          ELSE total_CD_actv_FY19/FY19_total_core_digital_consumed_units
          END;;
  }

  dimension: actv_rate_fy18  {
    type: number
    sql: CASE WHEN FY18_total_core_digital_consumed_units = 0 OR total_CD_actv_FY18 = 0 THEN 0
          ELSE total_CD_actv_FY18/FY18_total_core_digital_consumed_units
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

  dimension: total_print_net_sales_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY19" ;;
  }

  measure: sum_total_print_net_sales_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY19" ;;
  }

#   FY19 Total Core Digital Consumed Units
  measure: sum_FY19_total_core_digital_consumed_units {
    label: "FY19 Total Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS" ;;
  }

  measure: sum_FY18_total_core_digital_consumed_units {
    label: "FY18 Total Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS" ;;
  }

  dimension: total_net_units_fy19 {
  }

  dimension: total_net_units_fy18 {
  }

  dimension: net_units_bucket_Fy19 {
    type: tier
  tiers: [0,5,10,15,25,50,100,200,500,1000]
  style: integer
  sql: ${total_net_units_fy19} ;;
  }

  dimension: net_units_bucket_Fy18 {
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${total_net_units_fy18} ;;
  }

  dimension: actv_rate_fy18_bucket {
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy18} ;;
  }

  measure: sum_total_net_units_fy19 {
    type: sum
    sql: ${total_net_units_fy19} ;;
  }

  measure: sum_total_net_units_fy18 {
    type: sum
    sql: ${total_net_units_fy18} ;;
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
