
view: sales_order_adoption_base {
  derived_table: {
    sql:
    WITH sales_adoption as
    (
      Select sal.*,
             (coalesce(sal.FY17_ebook_units,0) + coalesce(eb.FY17_ebook_units_byCU,0)) as FY17_total_ebook_activations,
             (coalesce(sal.FY18_ebook_units,0) + coalesce(eb.FY18_ebook_units_byCU,0)) as FY18_total_ebook_activations,
             (coalesce(sal.FY19_ebook_units,0) + coalesce(eb.FY19_ebook_units_byCU,0)) as FY19_total_ebook_activations,
             ((FY17_core_digital_standalone_sales)+(FY17_core_digital_bundle_sales)+(FY17_LLF_bundle_sales)) as Total_core_digital_NetSales_ex_CU_fy17,
             ((FY18_core_digital_standalone_sales)+(FY18_core_digital_bundle_sales)+(FY18_LLF_bundle_sales)) as Total_core_digital_NetSales_ex_CU_fy18,
             ((FY19_core_digital_standalone_sales)+(FY19_core_digital_bundle_sales)+(FY19_LLF_bundle_sales)) as Total_core_digital_NetSales_ex_CU_fy19,
             ((FY17_core_digital_standalone_sales)+(FY17_core_digital_bundle_sales)+(FY17_LLF_bundle_sales)+(FY17_cu_sales)) as Total_core_digital_NetSales_fy17,
             ((FY18_core_digital_standalone_sales)+(FY18_core_digital_bundle_sales)+(FY18_LLF_bundle_sales)+(FY18_cu_sales)) as Total_core_digital_NetSales_fy18,
             ((FY19_core_digital_standalone_sales)+(FY19_core_digital_bundle_sales)+(FY19_LLF_bundle_sales)+(FY19_cu_sales)) as Total_core_digital_NetSales_fy19,
             ((FY17_core_digital_standalone_sales)+(FY17_core_digital_bundle_sales)+(FY17_LLF_bundle_sales)+(FY17_cu_sales)+(FY17_custom_print_core_sales)+(FY17_print_core_sales)+(FY17_print_other_sales)+(FY17_custom_print_other_sales)+(FY17_ebook_sales)+(FY17_other_digital_standalone_sales)+(FY17_other_digital_bundle_sales)) as Total_Net_sales_fy17,
             ((FY18_core_digital_standalone_sales)+(FY18_core_digital_bundle_sales)+(FY18_LLF_bundle_sales)+(FY18_cu_sales)+(FY18_custom_print_core_sales)+(FY18_print_core_sales)+(FY18_print_other_sales)+(FY18_custom_print_other_sales)+(FY18_ebook_sales)+(FY18_other_digital_standalone_sales)+(FY18_other_digital_bundle_sales)) as Total_Net_sales_fy18,
             ((FY19_core_digital_standalone_sales)+(FY19_core_digital_bundle_sales)+(FY19_LLF_bundle_sales)+(FY19_cu_sales)+(FY19_custom_print_core_sales)+(FY19_print_core_sales)+(FY19_print_other_sales)+(FY19_custom_print_other_sales)+(FY19_ebook_sales)+(FY19_other_digital_standalone_sales)+(FY19_other_digital_bundle_sales)) as Total_Net_sales_fy19,
             ((FY17_custom_print_core_sales)+(FY17_print_core_sales)+(FY17_print_other_sales)+(FY17_custom_print_other_sales)+(FY17_ebook_sales)+(FY17_other_digital_standalone_sales)+(FY17_other_digital_bundle_sales)) as Total_print_net_sales_fy17,
             ((FY18_custom_print_core_sales)+(FY18_print_core_sales)+(FY18_print_other_sales)+(FY18_custom_print_other_sales)+(FY18_ebook_sales)+(FY18_other_digital_standalone_sales)+(FY18_other_digital_bundle_sales)) as Total_print_net_sales_fy18,
             ((FY19_custom_print_core_sales)+(FY19_print_core_sales)+(FY19_print_other_sales)+(FY19_custom_print_other_sales)+(FY19_ebook_sales)+(FY19_other_digital_standalone_sales)+(FY19_other_digital_bundle_sales)) as Total_print_net_sales_fy19,
             ((FY17_custom_print_core_units)+(FY17_print_core_units)+(FY17_print_other_units)+(FY17_custom_print_other_units)+(FY17_ebook_units)+(FY17_other_digital_standalone_units)+(FY17_other_digital_bundle_units)) as Total_Print_net_units_fy17,
             ((FY18_custom_print_core_units)+(FY18_print_core_units)+(FY18_print_other_units)+(FY18_custom_print_other_units)+(FY18_ebook_units)+(FY18_other_digital_standalone_units)+(FY18_other_digital_bundle_units)) as Total_Print_net_units_fy18,
             ((FY19_custom_print_core_units)+(FY19_print_core_units)+(FY19_print_other_units)+(FY19_custom_print_other_units)+(FY19_ebook_units)+(FY19_other_digital_standalone_units)+(FY19_other_digital_bundle_units)) as Total_Print_net_units_fy19,
             ((FY17_core_digital_standalone_units)+(FY17_core_digital_bundle_units)+(FY17_LLF_bundle_units)) as Total_core_digital_Ex_CU_Net_Units_fy17,
             ((FY18_core_digital_standalone_units)+(FY18_core_digital_bundle_units)+(FY18_LLF_bundle_units)) as Total_core_digital_Ex_CU_Net_Units_fy18,
             ((FY19_core_digital_standalone_units)+(FY19_core_digital_bundle_units)+(FY19_LLF_bundle_units)) as Total_core_digital_Ex_CU_Net_Units_fy19,
             ((FY17_core_digital_standalone_units)+(FY17_core_digital_bundle_units)+(FY17_LLF_bundle_units)+(FY17_cu_units)) as Total_Core_Digital_CU_Net_Units_fy17,
             ((FY18_core_digital_standalone_units)+(FY18_core_digital_bundle_units)+(FY18_LLF_bundle_units)+(FY18_cu_units)) as Total_Core_Digital_CU_Net_Units_fy18,
             ((FY19_core_digital_standalone_units)+(FY19_core_digital_bundle_units)+(FY19_LLF_bundle_units)+(FY19_cu_units)) as Total_Core_Digital_CU_Net_Units_fy19,
             act_adoption_key
             act_old_adoption_key,
             act_institution_nm,
             act_state_cd,
             act_course_code_description,
             act_pub_series_de,
             coalesce(act_fy17_primary_platform,'No Activations') as FY17_primary_platform,
             coalesce(act_fy18_primary_platform,'No Activations') as FY18_primary_platform,
             coalesce(act_fy19_primary_platform,'No Activations') as FY19_primary_platform,
             coalesce(sales_adoption_key, act_adoption_key) as adoption_key,
             coalesce(sales_old_adoption_key, act_old_adoption_key) as old_adoption_key,
             coalesce(sales_institution_nm, act_institution_nm) as institution_nm,
             coalesce(sales_state_cd, act_state_cd) as state_cd,
             coalesce(sales_course_code_description, act_course_code_description) as course_code_description,
             coalesce(sales_pub_series_de, act_pub_series_de) as pub_series_de,
             eb.FY17_ebook_units_byCU,
             eb.FY18_ebook_units_byCU,
             eb.FY19_ebook_units_byCU,
             total_CD_actv_exCU_FY17,
             total_CD_actv_exCU_FY18,
             total_CD_actv_exCU_FY19,
             total_CD_actv_withCU_FY17,
             total_CD_actv_withCU_FY18,
             total_CD_actv_withCU_FY19,
             total_CD_actv_FY17,
             total_CD_actv_FY18,
             total_CD_actv_FY19,
             coalesce(FY_17_IA_ADOPTION_Y_N_,'N') AS FY_17_IA,
             coalesce(FY_18_IA_ADOPTION_Y_N_,'N') AS FY_18_IA,
             coalesce(FY_19_IA_ADOPTION_Y_N_,'N') AS FY_19_IA,
             coalesce(FY_19_CU_I_INSTITUTION_Y_N_,'N') AS FY_19_CUI,
        CASE WHEN FY_19_IA_ADOPTION_Y_N_ = 'Y' THEN
        CASE WHEN coalesce(total_CD_actv_FY19,0) > (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0)) THEN coalesce(total_CD_actv_FY19,0)
             WHEN coalesce(total_CD_actv_FY19,0) < (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0)) THEN (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0))
             END
         ELSE (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0))
         END AS FY19_total_core_digital_consumed_units,
        CASE WHEN FY_18_IA_ADOPTION_Y_N_ = 'Y' THEN
        (CASE WHEN (coalesce(total_CD_actv_FY18,0) > (coalesce(total_core_digital_ex_cu_net_units_fy18,0))) THEN coalesce(total_CD_actv_FY18,0)
             WHEN (coalesce(total_CD_actv_FY18,0) < (coalesce(total_core_digital_ex_cu_net_units_fy18,0))) THEN coalesce(total_core_digital_ex_cu_net_units_fy18,0)
             END)
         ELSE coalesce(total_core_digital_ex_cu_net_units_fy18,0)
         END AS FY18_total_core_digital_consumed_units,
        CASE WHEN FY_17_IA_ADOPTION_Y_N_ = 'Y' THEN
        (CASE WHEN (coalesce(total_CD_actv_FY17,0) > (coalesce(total_core_digital_ex_cu_net_units_fy17,0))) THEN coalesce(total_CD_actv_FY17,0)
             WHEN (coalesce(total_CD_actv_FY17,0) < (coalesce(total_core_digital_ex_cu_net_units_fy17,0))) THEN coalesce(total_core_digital_ex_cu_net_units_fy17,0)
             END)
         ELSE coalesce(total_core_digital_ex_cu_net_units_fy17,0)
         END AS FY17_total_core_digital_consumed_units,
      CASE WHEN ((coalesce(FY17_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY17,0) = 0)) THEN 0 ELSE (total_CD_actv_FY17/FY17_total_core_digital_consumed_units) END as actv_rate_fy17,
      CASE WHEN ((coalesce(FY18_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY18,0) = 0)) THEN 0 ELSE (total_CD_actv_FY18/FY18_total_core_digital_consumed_units) END as actv_rate_fy18,
      CASE WHEN ((coalesce(FY19_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY19,0) = 0)) THEN 0 ELSE (total_CD_actv_FY19/FY19_total_core_digital_consumed_units) END as actv_rate_fy19,
      CASE WHEN (coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0)) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY19_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy19,
       CASE WHEN (coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + coalesce(FY18_total_core_digital_consumed_units,0)) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY18_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + coalesce(FY18_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy18,
       CASE WHEN (coalesce(TOTAL_PRINT_NET_UNITS_FY17,0) + coalesce(FY17_total_core_digital_consumed_units,0)) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY17_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY17,0) + coalesce(FY17_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy17,
        coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0) AS total_net_units_fy19,
        Coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + Coalesce(FY18_total_core_digital_consumed_units,0) AS total_net_units_fy18,
        Coalesce(TOTAL_PRINT_NET_UNITS_FY17,0) + Coalesce(FY17_total_core_digital_consumed_units,0) AS total_net_units_fy17,
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
        CASE WHEN Coalesce(total_net_units_fy18,0) > 0.5 AND Coalesce(total_net_units_fy17,0) > 0.5
          THEN
            CASE WHEN total_net_units_fy18/total_net_units_fy17 >= 10 THEN '10x larger'
                WHEN total_net_units_fy18/total_net_units_fy17 > 1 THEN 'larger not 10x'
                WHEN total_net_units_fy18/total_net_units_fy17 = 1 THEN 'equal'
                WHEN total_net_units_fy18/total_net_units_fy17 <= 0.1 THEN '10x smaller'
                WHEN total_net_units_fy18/total_net_units_fy17 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy18,0) < 0.5 AND Coalesce(total_net_units_fy17,0) > 0.5
          THEN
            CASE WHEN 0.5/Coalesce(total_net_units_fy17,0) >= 10 THEN '10x larger'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) > 1 THEN 'larger not 10x'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) = 1 THEN 'equal'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) <= 0.1 THEN '10x smaller'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy18,0) > 0.5 AND Coalesce(total_net_units_fy17,0) < 0.5
          THEN
            CASE WHEN Coalesce(total_net_units_fy18,0)/0.5 >= 10 THEN '10x larger'
                WHEN Coalesce(total_net_units_fy18,0)/0.5 > 1 THEN 'larger not 10x'
                WHEN Coalesce(total_net_units_fy18,0)/0.5 = 1 THEN 'equal'
                WHEN Coalesce(total_net_units_fy18,0)/0.5 <= 0.1 THEN '10x smaller'
                WHEN Coalesce(total_net_units_fy18,0)/0.5 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
       WHEN Coalesce(total_net_units_fy18,0) < 0.5 AND Coalesce(total_net_units_fy17,0) < 0.5
          THEN
          CASE WHEN 1 = 1 THEN 'equal'
        END
      ELSE 'error'
        END AS FY17_FY18_Adoption_Unit_Gain_Loss,
        Concat(Concat(concat(concat(Adoption_type_Fy17,'->'),Adoption_type_Fy18),' | '),FY17_FY18_Adoption_Unit_Gain_Loss) AS FY17_FY18_adoptions_transition_type_2,
        Concat(Concat(concat(concat(Adoption_type_Fy18,'->'),Adoption_type_Fy19),' | '),FY18_FY19_Adoption_Unit_Gain_Loss) AS FY18_FY19_adoptions_transition_type_2


      from  ${af_salesorder_adoption.SQL_TABLE_NAME} sal
              FULL OUTER JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act
              ON sal.sales_adoption_key = act.act_adoption_key
              LEFT JOIN ${af_ebook_units_adoptions.SQL_TABLE_NAME} AS eb
              ON sal.sales_adoption_key = eb.adoption_key
              LEFT JOIN STRATEGY.ADOPTION_PIVOT.IA_ADOPTIONS_ADOPTION_PIVOT ia
              ON ia.adoption_key = sal.sales_old_adoption_key
              LEFT JOIN UPLOADS.CU.CUI_ADOPTIONS_SALESORDERS cui
              ON cui.institution_name = sal.sales_institution_nm
      ) SELECT s.*, adp_tr_19.adoption_transition as FY18_FY19_Adoption_Transition, adp_tr_18.adoption_transition as FY17_FY18_Adoption_Transition
        FROM sales_adoption s
        LEFT JOIN UPLOADS.CU.ADOPTION_TRANSITIONS_SALESORDERS adp_tr_19
              ON lower(adp_tr_19.TYPE_2_ADOPTION_TRANSITION) = lower(s.FY18_FY19_adoptions_transition_type_2)
        LEFT JOIN UPLOADS.CU.ADOPTION_TRANSITIONS_SALESORDERS adp_tr_18
              ON lower(adp_tr_18.TYPE_2_ADOPTION_TRANSITION) = lower(s.FY17_FY18_adoptions_transition_type_2)
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
  dimension: old_adoption_key {}
  dimension: purchase_method {}
  dimension: institution_nm {}
  dimension: state_cd {}
  dimension: course_code_description {}
  dimension: pub_series_de {}
  dimension: FY17_primary_platform {}
  dimension: FY18_primary_platform {}
  dimension: FY19_primary_platform {}
  dimension: Adoption_type_Fy17 {}
  dimension: Adoption_type_Fy18 {}
  dimension: Adoption_type_Fy19 {}

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }

  dimension: FY17_FY18_adoption_transition_type1 {
    label: "FY17->FY18 Adoption Transition – Type 1"
    sql: concat(concat(Adoption_type_Fy17,' -> '),Adoption_type_Fy18) ;;
  }

  dimension: FY18_FY19_adoption_transition_type1 {
    label: "FY18->FY19 Adoption Transition – Type 1"
    sql: concat(concat(Adoption_type_Fy18,' -> '),Adoption_type_Fy19) ;;
  }

  dimension:FY17_FY18_adoptions_transition_type_2  {
    label: "FY17 -> FY18 Adoption Transition Type 2"
    sql: ${TABLE}."FY17_FY18_adoptions_transition_type_2" ;;
  }

  dimension:FY18_FY19_adoptions_transition_type_2  {
    label: "FY18 -> FY19 Adoption Transition Type 2"
    sql: ${TABLE}."FY18_FY19_adoptions_transition_type_2" ;;
  }

  dimension: FY17_FY18_Adoption_Transition {}

  dimension: FY18_FY19_Adoption_Transition {}

  dimension: FY17_FY18_Adoption_Unit_Gain_Loss {}

  dimension: FY18_FY19_Adoption_Unit_Gain_Loss {}

  dimension: actv_rate_fy17  {}

  dimension: actv_rate_fy18  {}

  dimension: actv_rate_fy19  {}

  dimension: actv_rate_fy17_bucket {
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy17} ;;
  }

  dimension: actv_rate_fy18_bucket {
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy18} ;;
  }

  dimension: actv_rate_fy19_bucket {
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy19} ;;
  }

  dimension: FY17_ebook_units {}

  dimension: FY18_ebook_units {}

  dimension: FY19_ebook_units {}

  measure: sum_ebook_units_exCU_fy17 {
    type: sum
    sql: ${TABLE}."FY17_EBOOK_UNITS";;
  }

  measure: sum_ebook_units_exCU_fy18 {
    type: sum
    sql: ${TABLE}."FY18_EBOOK_UNITS";;
  }

  measure: sum_ebook_units_exCU_fy19 {
    type: sum
    sql: ${TABLE}."FY19_EBOOK_UNITS";;
  }

  dimension: FY17_ebook_units_byCU {}

  dimension: FY18_ebook_units_byCU {}

  dimension: FY19_ebook_units_byCU {}

  measure: sum_ebook_units_byCU_fy17 {
    type: sum
    sql: ${TABLE}."FY17_EBOOK_UNITS_BYCU";;
  }

  measure: sum_ebook_units_byCU_fy18 {
    type: sum
    sql: ${TABLE}."FY18_EBOOK_UNITS_BYCU";;
  }

  measure: sum_ebook_units_byCU_fy19 {
    type: sum
    sql: ${TABLE}."FY19_EBOOK_UNITS_BYCU";;
  }

  dimension: FY17_total_ebook_activations {}

  dimension: FY18_total_ebook_activations {}

  dimension: FY19_total_ebook_activations {}

  measure: sum_total_ebook_activations_fy17 {
    type: sum
    sql: ${TABLE}."FY17_TOTAL_EBOOK_ACTIVATIONS";;
  }

  measure: sum_total_ebook_activations_fy18 {
    type: sum
    sql: ${TABLE}."FY18_TOTAL_EBOOK_ACTIVATIONS";;
  }

  measure: sum_total_ebook_activations_fy19 {
    type: sum
    sql: ${TABLE}."FY19_TOTAL_EBOOK_ACTIVATIONS";;
  }

  dimension: FY19_total_core_digital_consumed_units {}

  dimension: FY18_total_core_digital_consumed_units {}

  dimension: FY17_total_core_digital_consumed_units {}

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

  measure: sum_FY17_total_core_digital_consumed_units {
    label: "FY17 Total Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."FY17_TOTAL_CORE_DIGITAL_CONSUMED_UNITS" ;;
  }

  dimension: total_net_units_fy17 {
  }

  dimension: total_net_units_fy18 {
  }

  dimension: total_net_units_fy19 {
  }

  dimension: net_units_bucket_Fy17 {
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${total_net_units_fy17} ;;
  }

  dimension: net_units_bucket_Fy18 {
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${total_net_units_fy18} ;;
  }

  dimension: net_units_bucket_Fy19 {
    type: tier
  tiers: [0,5,10,15,25,50,100,200,500,1000]
  style: integer
  sql: ${total_net_units_fy19} ;;
  }

  measure: sum_total_net_units_fy17 {
    type: sum
    sql: ${total_net_units_fy17} ;;
  }

  measure: sum_total_net_units_fy18 {
    type: sum
    sql: ${total_net_units_fy18} ;;
  }

  measure: sum_total_net_units_fy19 {
    type: sum
    sql: ${total_net_units_fy19} ;;
  }

  dimension: total_core_digital_netsales_ex_cu_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY17" ;;
  }

  dimension: total_core_digital_netsales_ex_cu_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY18" ;;
  }

  dimension: total_core_digital_netsales_ex_cu_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY19" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_SALES_FY17" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_SALES_FY18" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_SALES_FY19" ;;
  }

  dimension: total_net_sales_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_NET_SALES_FY17" ;;
  }

  measure: sum_total_net_sales_fy17 {
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY17" ;;
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

  dimension: total_print_net_units_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY17" ;;
  }

  dimension: total_print_net_units_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY18" ;;
  }

  dimension: total_print_net_units_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY19" ;;
  }

  measure: sum_total_print_net_units_fy17{
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY17" ;;
  }

  measure: sum_total_print_net_units_fy18{
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY18" ;;
  }

  measure: sum_total_print_net_units_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY19" ;;
  }

  dimension: total_print_net_sales_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY17" ;;
  }

  measure: sum_total_print_net_sales_fy17 {
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY17";;
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

  dimension: total_core_digital_ex_cu_net_units_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY17" ;;
  }

  dimension: total_core_digital_ex_cu_net_units_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY18" ;;
  }

  dimension: total_core_digital_ex_cu_net_units_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY19" ;;
  }

  measure: sum_total_core_digital_ex_cu_net_units_fy17{
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY17" ;;
  }

  measure: sum_total_core_digital_ex_cu_net_units_fy18{
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY18" ;;
  }

  measure: sum_total_core_digital_ex_cu_net_units_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY19" ;;
  }

  dimension: total_core_digital_cu_net_units_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY17" ;;
  }

  dimension: total_core_digital_cu_net_units_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY18" ;;
  }

  dimension: total_core_digital_cu_net_units_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY19" ;;
  }

  dimension: total_cd_actv_excu_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY17" ;;
  }

  dimension: total_cd_actv_excu_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY18" ;;
  }

  dimension: total_cd_actv_excu_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY19" ;;
  }

  measure: sum_total_cd_actv_excu_fy17{
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY17" ;;
  }

  measure: sum_total_cd_actv_excu_fy18{
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY18" ;;
  }

  measure: sum_total_cd_actv_excu_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY19" ;;
  }

  dimension: total_cd_actv_withcu_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY17" ;;
  }

  dimension: total_cd_actv_withcu_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY18" ;;
  }

  dimension: total_cd_actv_withcu_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY19" ;;
  }

  measure: sum_total_cd_actv_withcu_fy17{
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY17" ;;
  }

  measure: sum_total_cd_actv_withcu_fy18{
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY18" ;;
  }

  measure: sum_total_cd_actv_withcu_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY19" ;;
  }

  dimension: total_cd_actv_fy17 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY17" ;;
  }

  dimension: total_cd_actv_fy18 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY18" ;;
  }

  dimension: total_cd_actv_fy19 {
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY19" ;;
  }

  measure: sum_total_cd_actv_fy17 {
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY17" ;;
  }

  measure: sum_total_cd_actv_fy18 {
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY18" ;;
  }

 measure: sum_total_cd_actv_fy19 {
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY19" ;;
  }




  set: detail {
    fields: [
      adoption_key,
      old_adoption_key,
      FY17_primary_platform,
      FY18_primary_platform,
      FY19_primary_platform,
      total_print_net_sales_fy17,
      total_print_net_sales_fy18,
      total_print_net_sales_fy19,
      total_core_digital_netsales_ex_cu_fy17,
      total_core_digital_netsales_ex_cu_fy18,
      total_core_digital_netsales_ex_cu_fy19,
      total_core_digital_cu_net_sales_fy17,
      total_core_digital_cu_net_sales_fy18,
      total_core_digital_cu_net_sales_fy19,
      total_net_sales_fy17,
      total_net_sales_fy18,
      total_net_sales_fy19,
      total_print_net_units_fy17,
      total_print_net_units_fy18,
      total_print_net_units_fy19,
      total_core_digital_ex_cu_net_units_fy17,
      total_core_digital_ex_cu_net_units_fy18,
      total_core_digital_ex_cu_net_units_fy19,
      total_core_digital_cu_net_units_fy17,
      total_core_digital_cu_net_units_fy18,
      total_core_digital_cu_net_units_fy19,
      total_cd_actv_excu_fy17,
      total_cd_actv_excu_fy18,
      total_cd_actv_excu_fy19,
      total_cd_actv_withcu_fy17,
      total_cd_actv_withcu_fy18,
      total_cd_actv_withcu_fy19,
      total_cd_actv_fy17,
      total_cd_actv_fy18,
      total_cd_actv_fy19
    ]
  }
}
