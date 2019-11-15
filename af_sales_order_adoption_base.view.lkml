
view: sales_order_adoption_base {
  derived_table: {
    sql:
    ---FIND TOTAL WA MASTER BILLING UNITS TO BE ALLOCATED
    WITH wa_units as (
      select sal.sales_pub_series_de as pub_series_de,
             sum(nvl(FY17_core_digital_standalone_units,0)+nvl(FY17_core_digital_bundle_units,0)+nvl(FY17_LLF_bundle_units,0)) as FY17_WA_cd_units_allocation,
             sum(nvl(FY17_custom_print_core_units,0)+nvl(FY17_print_core_units,0)) as FY17_WA_print_units_allocation,
             sum(nvl(FY18_core_digital_standalone_units,0)+nvl(FY18_core_digital_bundle_units,0)+nvl(FY18_LLF_bundle_units,0)) as FY18_WA_cd_units_allocation,
             sum(nvl(FY17_core_digital_standalone_sales,0)+nvl(FY17_core_digital_bundle_sales,0)+nvl(FY17_LLF_bundle_sales,0)) as FY17_WA_cd_sales_allocation,
             sum(nvl(FY17_custom_print_core_sales,0)+nvl(FY17_print_core_sales,0)) as FY17_WA_print_sales_allocation,
             sum(nvl(FY18_core_digital_standalone_sales,0)+nvl(FY18_core_digital_bundle_sales,0)+nvl(FY18_LLF_bundle_sales,0)) as FY18_WA_cd_sales_allocation
      from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
      WHERE UPPER(sal.sales_institution_nm) = 'WEBASSIGN MASTER BILLING'
      group by 1),

    --GET UNIQUE LIST OF ADOPTION KEYS
       adoption_keys as (
       select act_adoption_key as adoption_key from ${af_activation_adoptions.SQL_TABLE_NAME}
       UNION
       select sales_adoption_key as adoption_key from ${af_salesorder_adoption.SQL_TABLE_NAME}
       ),

      adoption_keys2 as (
      select distinct adoption_key
      from adoption_keys),


    ---FIND FY17 WA CORE DIGITAL GAP BY ADOPTION
       wa_fy17 as (
        select keys.adoption_key as wa17_adoption_key,
               coalesce(sal.sales_pub_series_de, act.act_pub_series_de) as wa17_pub_series_de,
               sum(CASE WHEN ((coalesce(sal.FY17_core_digital_standalone_units,0)+coalesce(sal.FY17_core_digital_bundle_units,0)+coalesce(sal.FY17_LLF_bundle_units,0)) > 0)
               THEN (coalesce(act.total_CD_actv_exCU_FY17,0) - (coalesce(sal.FY17_core_digital_standalone_units,0)+coalesce(sal.FY17_core_digital_bundle_units,0)+coalesce(sal.FY17_LLF_bundle_units,0)))
               ELSE coalesce(total_CD_actv_exCU_FY17,0) end) as FY17_adoption_WA_cd_units_gap
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        where coalesce(act.act_FY17_primary_platform,'No Activations') = 'WebAssign'
        and total_CD_actv_exCU_FY17 > 0
        and UPPER(coalesce(sal.sales_institution_nm, act.act_institution_nm)) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(ia.FY_17_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY17_adoption_WA_cd_units_gap > 0
        ),

    ---FIND FY17 WA CORE DIGITAL GAP BY DISCIPLINE
        wa_fy17_disc as (
        select wa17_pub_series_de,
               sum(nvl(FY17_adoption_WA_cd_units_gap,0)) as FY17_disc_WA_cd_units_gap
        from wa_fy17
        group by 1
        having FY17_disc_WA_cd_units_gap > 0),

    ---FIND FY17 WA PRINT UNITS BY ADOPTION
       wa_fy17_print as (
        select keys.adoption_key as wa17_adoption_key,
               coalesce(sal.sales_pub_series_de, act.act_pub_series_de) as wa17_pub_series_de,
               sum(nvl(sal.FY17_custom_print_core_units,0)+nvl(sal.FY17_print_core_units,0)+nvl(sal.FY17_print_other_units,0)+nvl(sal.FY17_custom_print_other_units,0)+nvl(sal.FY17_ebook_units,0)+nvl(sal.FY17_other_digital_standalone_units,0)+nvl(sal.FY17_other_digital_bundle_units,0)) as wa17_adoption_print_net_units
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = sal.sales_old_adoption_key
        where UPPER(coalesce(sal.sales_institution_nm, act.act_institution_nm)) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(act.act_FY17_primary_platform,'No Activations') = 'WebAssign'
        and coalesce(ia.FY_17_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having wa17_adoption_print_net_units > 0),

    ---FIND FY17 WA PRINT UNITS BY DISCIPLINE
        wa_fy17_disc_print as (
        select wa17_pub_series_de,
               sum(nvl(wa17_adoption_print_net_units,0)) as FY17_disc_WA_print_units
        from wa_fy17_print
        group by 1
        having FY17_disc_WA_print_units > 0),




       ---FIND FY18 WA CORE DIGITAL GAP BY ADOPTION
       wa_fy18 as (
        select keys.adoption_key as wa18_adoption_key,
               coalesce(sal.sales_pub_series_de, act.act_pub_series_de) as wa18_pub_series_de,
               sum(CASE WHEN ((coalesce(sal.FY18_core_digital_standalone_units,0)+coalesce(sal.FY18_core_digital_bundle_units,0)+coalesce(sal.FY18_LLF_bundle_units,0)) > 0)
               THEN (coalesce(act.total_CD_actv_exCU_FY18,0) - (coalesce(sal.FY18_core_digital_standalone_units,0)+coalesce(sal.FY18_core_digital_bundle_units,0)+coalesce(sal.FY18_LLF_bundle_units,0)))
               ELSE coalesce(total_CD_actv_exCU_FY18,0) end) as FY18_adoption_WA_cd_units_gap
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        where coalesce(act.act_FY18_primary_platform,'No Activations') = 'WebAssign'
        and nvl(total_CD_actv_exCU_FY18,0) > 0
        and UPPER(coalesce(sal.sales_institution_nm, act.act_institution_nm)) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(ia.FY_18_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having nvl(FY18_adoption_WA_cd_units_gap,0) > 0
        ),

    ---FIND FY18 WA CORE DIGITAL GAP BY DISCIPLINE
        wa_fy18_disc as (
        select wa18_pub_series_de,
               sum(nvl(FY18_adoption_WA_cd_units_gap,0)) as FY18_disc_WA_cd_units_gap
        from wa_fy18
        group by 1
        having FY18_disc_WA_cd_units_gap > 0),

    --GET UNIQUE LIST OF ADOPTION KEYS
       wa_keys as (
       select wa17_adoption_key as adoption_key from wa_fy17
       UNION
       select wa18_adoption_key as adoption_key from wa_fy18
       UNION
       select wa17_adoption_key as adoption_key from wa_fy17_print),

      wa_keys2 as (
      select distinct adoption_key
      from wa_keys),



    --JOIN TOGETHER ALL FISCAL YEARS BY ADOPTION AND CREATE WEB ASSIGN ALLOCATIONS BY DISCIPLINE
        wa_allocation as (
        select keys.adoption_key as adoption_key,
               coalesce(wa_fy17.wa17_pub_series_de, wa_fy18.wa18_pub_series_de, wa_fy17_print.wa17_pub_series_de) as pub_series_de,
               max(nvl(wa_units.FY17_WA_cd_units_allocation,0)) as FY17_WA_cd_units_allocation_1,
               max(nvl(wa_units.FY17_WA_cd_sales_allocation,0)) as FY17_WA_cd_sales_allocation_1,
               max(nvl(wa_units.FY18_WA_cd_units_allocation,0)) as FY18_WA_cd_units_allocation_1,
               max(nvl(wa_units.FY18_WA_cd_sales_allocation,0)) as FY18_WA_cd_sales_allocation_1,
               max(nvl(wa_units.FY17_WA_print_units_allocation,0)) as FY17_WA_print_units_allocation_1,
               max(nvl(wa_units.FY17_WA_print_sales_allocation,0)) as FY17_WA_print_sales_allocation_1,
               max(disc17.FY17_disc_WA_cd_units_gap) as FY17_disc_WA_cd_units_gap_1,
               max(disc18.FY18_disc_WA_cd_units_gap) as FY18_disc_WA_cd_units_gap_1,
               max(disc17_print.FY17_disc_WA_print_units) as FY17_disc_WA_print_units_1,
               sum(coalesce(wa_fy17.FY17_adoption_WA_cd_units_gap,0)) as FY17_adoption_WA_cd_units_gap_1,
               sum(coalesce(wa_fy18.FY18_adoption_WA_cd_units_gap,0)) as FY18_adoption_WA_cd_units_gap_1,
               sum(coalesce(wa_fy17_print.wa17_adoption_print_net_units,0)) as wa17_adoption_print_net_units_1,
               (nvl(FY17_adoption_WA_cd_units_gap_1,0)/FY17_disc_WA_cd_units_gap_1*nvl(FY17_WA_cd_units_allocation_1,0)) as FY17_WA_cd_units_adjustment,
               (nvl(FY17_adoption_WA_cd_units_gap_1,0)/FY17_disc_WA_cd_units_gap_1*nvl(FY17_WA_cd_sales_allocation_1,0)) as FY17_WA_cd_sales_adjustment,
               (nvl(FY18_adoption_WA_cd_units_gap_1,0)/FY18_disc_WA_cd_units_gap_1*nvl(FY18_WA_cd_units_allocation_1,0)) as FY18_WA_cd_units_adjustment,
               (nvl(FY18_adoption_WA_cd_units_gap_1,0)/FY18_disc_WA_cd_units_gap_1*nvl(FY18_WA_cd_sales_allocation_1,0)) as FY18_WA_cd_sales_adjustment,
               (nvl(wa17_adoption_print_net_units_1,0)/FY17_disc_WA_print_units_1*nvl(FY17_WA_print_units_allocation_1,0)) as FY17_WA_print_units_adjustment,
               (nvl(wa17_adoption_print_net_units_1,0)/FY17_disc_WA_print_units_1*nvl(FY17_WA_print_sales_allocation_1,0)) as FY17_WA_print_sales_adjustment
        from wa_keys2 keys
        LEFT JOIN wa_fy17 on wa_fy17.wa17_adoption_key = keys.adoption_key
        LEFT JOIN wa_fy18 on wa_fy18.wa18_adoption_key = keys.adoption_key
        LEFT JOIN wa_fy17_print on wa_fy17_print.wa17_adoption_key = keys.adoption_key
        left join wa_units on coalesce(wa_fy17.wa17_pub_series_de, wa_fy18.wa18_pub_series_de, wa_fy17_print.wa17_pub_series_de) = wa_units.pub_series_de
        left join wa_fy17_disc disc17 on disc17.wa17_pub_series_de = wa_fy17.wa17_pub_series_de
        left join wa_fy18_disc disc18 on disc18.wa18_pub_series_de = wa_fy18.wa18_pub_series_de
        left join wa_fy17_disc_print disc17_print on disc17_print.wa17_pub_series_de = wa_fy17_print.wa17_pub_series_de
        group by 1,2),

 ---FIND TOTAL QUIA CORPORATION UNITS TO BE ALLOCATED
      quia_units as (
      select sal.sales_pub_series_de as pub_series_de,
             sum(nvl(FY17_core_digital_standalone_units,0)+nvl(FY17_core_digital_bundle_units,0)+nvl(FY17_LLF_bundle_units,0)) as FY17_quia_cd_units_allocation,
             sum(nvl(FY18_core_digital_standalone_units,0)+nvl(FY18_core_digital_bundle_units,0)+nvl(FY18_LLF_bundle_units,0)) as FY18_quia_cd_units_allocation,
             sum(nvl(FY19_core_digital_standalone_units,0)+nvl(FY19_core_digital_bundle_units,0)+nvl(FY19_LLF_bundle_units,0)) as FY19_quia_cd_units_allocation,
             sum(nvl(FY17_core_digital_standalone_sales,0)+nvl(FY17_core_digital_bundle_sales,0)+nvl(FY17_LLF_bundle_sales,0)) as FY17_quia_cd_sales_allocation,
             sum(nvl(FY18_core_digital_standalone_sales,0)+nvl(FY18_core_digital_bundle_sales,0)+nvl(FY18_LLF_bundle_sales,0)) as FY18_quia_cd_sales_allocation,
             sum(nvl(FY19_core_digital_standalone_sales,0)+nvl(FY19_core_digital_bundle_sales,0)+nvl(FY19_LLF_bundle_sales,0)) as FY19_quia_cd_sales_allocation
      from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
      WHERE UPPER(sal.sales_institution_nm) = 'QUIA CORPORATION'
      group by 1),

    ---FIND FY17 QUIA CORE DIGITAL GAP BY ADOPTION
       quia_fy17 as (
        select keys.adoption_key as quia17_adoption_key,
               coalesce(sal.sales_pub_series_de, act.act_pub_series_de) as quia17_pub_series_de,
               sum(CASE WHEN ((coalesce(sal.FY17_core_digital_standalone_units,0)+coalesce(sal.FY17_core_digital_bundle_units,0)+coalesce(sal.FY17_LLF_bundle_units,0)) > 0)
               THEN (coalesce(act.total_CD_actv_exCU_FY17,0) - (coalesce(sal.FY17_core_digital_standalone_units,0)+coalesce(sal.FY17_core_digital_bundle_units,0)+coalesce(sal.FY17_LLF_bundle_units,0)))
               ELSE coalesce(total_CD_actv_exCU_FY17,0) end) as FY17_adoption_quia_cd_units_gap
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        where coalesce(act.act_FY17_primary_platform,'No Activations') = 'Quia'
        and total_CD_actv_exCU_FY17 > 0
        and UPPER(coalesce(sal.sales_institution_nm, act.act_institution_nm)) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(ia.FY_17_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY17_adoption_quia_cd_units_gap > 0
        ),

    ---FIND FY17 QUIA CORE DIGITAL GAP BY DISCIPLINE
        quia_fy17_disc as (
        select quia17_pub_series_de,
               sum(nvl(FY17_adoption_quia_cd_units_gap,0)) as FY17_disc_quia_cd_units_gap
        from quia_fy17
        group by 1),

     ---FIND FY18 QUIA CORE DIGITAL GAP BY ADOPTION
       quia_fy18 as (
        select keys.adoption_key as quia18_adoption_key,
               coalesce(sal.sales_pub_series_de, act.act_pub_series_de) as quia18_pub_series_de,
               sum(CASE WHEN ((coalesce(sal.FY18_core_digital_standalone_units,0)+coalesce(sal.FY18_core_digital_bundle_units,0)+coalesce(sal.FY18_LLF_bundle_units,0)) > 0)
               THEN (coalesce(act.total_CD_actv_exCU_FY18,0) - (coalesce(sal.FY18_core_digital_standalone_units,0)+coalesce(sal.FY18_core_digital_bundle_units,0)+coalesce(sal.FY18_LLF_bundle_units,0)))
               ELSE coalesce(total_CD_actv_exCU_FY18,0) end) as FY18_adoption_quia_cd_units_gap
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        where coalesce(act.act_FY18_primary_platform,'No Activations') = 'Quia'
        and total_CD_actv_exCU_FY18 > 0
        and UPPER(coalesce(sal.sales_institution_nm, act.act_institution_nm)) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(ia.FY_18_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY18_adoption_quia_cd_units_gap > 0
        ),

    ---FIND FY18 QUIA CORE DIGITAL GAP BY DISCIPLINE
        quia_fy18_disc as (
        select quia18_pub_series_de,
               sum(FY18_adoption_quia_cd_units_gap) as FY18_disc_quia_cd_units_gap
        from quia_fy18
        group by 1),

     ---FIND FY19 QUIA CORE DIGITAL GAP BY ADOPTION
       quia_fy19 as (
        select keys.adoption_key as quia19_adoption_key,
               coalesce(sal.sales_pub_series_de, act.act_pub_series_de) as quia19_pub_series_de,
               sum(CASE WHEN ((coalesce(sal.FY19_core_digital_standalone_units,0)+coalesce(sal.FY19_core_digital_bundle_units,0)+coalesce(sal.FY19_LLF_bundle_units,0)) > 0)
               THEN (coalesce(act.total_CD_actv_exCU_FY19,0) - (coalesce(sal.FY19_core_digital_standalone_units,0)+coalesce(sal.FY19_core_digital_bundle_units,0)+coalesce(sal.FY19_LLF_bundle_units,0)))
               ELSE coalesce(total_CD_actv_exCU_FY19,0) end) as FY19_adoption_quia_cd_units_gap
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        where coalesce(act.act_FY19_primary_platform,'No Activations') = 'Quia'
        and total_CD_actv_exCU_FY19 > 0
        and UPPER(coalesce(sal.sales_institution_nm, act.act_institution_nm)) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(ia.FY_19_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY19_adoption_quia_cd_units_gap > 0
        ),

    ---FIND FY19 QUIA CORE DIGITAL GAP BY DISCIPLINE
        quia_fy19_disc as (
        select quia19_pub_series_de,
               sum(FY19_adoption_quia_cd_units_gap) as FY19_disc_quia_cd_units_gap
        from quia_fy19
        group by 1),

    --GET UNIQUE LIST OF ADOPTION KEYS
       quia_keys as (
       select quia17_adoption_key as adoption_key from quia_fy17
       UNION
       select quia18_adoption_key as adoption_key from quia_fy18
       UNION
       select quia19_adoption_key as adoption_key from quia_fy19),

      quia_keys2 as (
      select distinct adoption_key
      from quia_keys),

    --JOIN TOGETHER ALL FISCAL YEARS BY ADOPTION AND CREATE QUIA ALLOCATIONS BY DISCIPLINE
        quia_allocation as (
        select coalesce(quia_fy17.quia17_adoption_key, quia_fy18.quia18_adoption_key, quia_fy19.quia19_adoption_key) as adoption_key,
               coalesce(quia_fy17.quia17_pub_series_de, quia_fy18.quia18_pub_series_de, quia_fy19.quia19_pub_series_de) as pub_series_de,
               max(nvl(quia_units.FY17_quia_cd_units_allocation,0)) as FY17_quia_cd_units_allocation_1,
               max(nvl(quia_units.FY17_quia_cd_sales_allocation,0)) as FY17_quia_cd_sales_allocation_1,
               max(nvl(quia_units.FY18_quia_cd_units_allocation,0)) as FY18_quia_cd_units_allocation_1,
               max(nvl(quia_units.FY18_quia_cd_sales_allocation,0)) as FY18_quia_cd_sales_allocation_1,
               max(nvl(quia_units.FY19_quia_cd_units_allocation,0)) as FY19_quia_cd_units_allocation_1,
               max(nvl(quia_units.FY19_quia_cd_sales_allocation,0)) as FY19_quia_cd_sales_allocation_1,
               max(disc17.FY17_disc_quia_cd_units_gap) as FY17_disc_quia_cd_units_gap_1,
               max(disc18.FY18_disc_quia_cd_units_gap) as FY18_disc_quia_cd_units_gap_1,
               max(disc19.FY19_disc_quia_cd_units_gap) as FY19_disc_quia_cd_units_gap_1,
               sum(coalesce(quia_fy17.FY17_adoption_quia_cd_units_gap,0)) as FY17_adoption_quia_cd_units_gap_1,
               sum(coalesce(quia_fy18.FY18_adoption_quia_cd_units_gap,0)) as FY18_adoption_quia_cd_units_gap_1,
               sum(coalesce(quia_fy19.FY19_adoption_quia_cd_units_gap,0)) as FY19_adoption_quia_cd_units_gap_1,
               (nvl(FY17_adoption_quia_cd_units_gap_1,0)/FY17_disc_quia_cd_units_gap_1*nvl(FY17_quia_cd_units_allocation_1,0)) as FY17_quia_cd_units_adjustment,
               (nvl(FY17_adoption_quia_cd_units_gap_1,0)/FY17_disc_quia_cd_units_gap_1*nvl(FY17_quia_cd_sales_allocation_1,0)) as FY17_quia_cd_sales_adjustment,
               (nvl(FY18_adoption_quia_cd_units_gap_1,0)/FY18_disc_quia_cd_units_gap_1*nvl(FY18_quia_cd_units_allocation_1,0)) as FY18_quia_cd_units_adjustment,
               (nvl(FY18_adoption_quia_cd_units_gap_1,0)/FY18_disc_quia_cd_units_gap_1*nvl(FY18_quia_cd_sales_allocation_1,0)) as FY18_quia_cd_sales_adjustment,
               (nvl(FY19_adoption_quia_cd_units_gap_1,0)/FY19_disc_quia_cd_units_gap_1*nvl(FY19_quia_cd_units_allocation_1,0)) as FY19_quia_cd_units_adjustment,
               (nvl(FY19_adoption_quia_cd_units_gap_1,0)/FY19_disc_quia_cd_units_gap_1*nvl(FY19_quia_cd_sales_allocation_1,0)) as FY19_quia_cd_sales_adjustment
        from quia_keys2 keys
        LEFT JOIN quia_fy17 on quia_fy17.quia17_adoption_key = keys.adoption_key
        LEFT JOIN quia_fy18 on quia_fy18.quia18_adoption_key = keys.adoption_key
        LEFT JOIN quia_fy19 on quia_fy19.quia19_adoption_key = keys.adoption_key
        left join quia_units on coalesce(quia_fy17.quia17_pub_series_de, quia_fy18.quia18_pub_series_de, quia_fy19.quia19_pub_series_de) = quia_units.pub_series_de
        left join quia_fy17_disc disc17 on disc17.quia17_pub_series_de = quia_fy17.quia17_pub_series_de
        left join quia_fy18_disc disc18 on disc18.quia18_pub_series_de = quia_fy18.quia18_pub_series_de
        left join quia_fy19_disc disc19 on disc19.quia19_pub_series_de = quia_fy19.quia19_pub_series_de
        group by 1,2),

    ---PULL SEPTEMBER CU API SALES AND UNITS TO BE ALLOCATED
       cu_api as (
       select sum(api_cu_net_sales) as FY20_Sep_CU_API_net_sales,
              sum(api_cu_net_units) as FY20_Sep_CU_API_net_units
       from STRATEGY.ADOPTION_PIVOT.FY20_SEPTEMBER_CU_API_SALES
       where order_date between '2019-09-01' and '2019-09-30'),

    ---FIND ACTIVATIONS WITHIN CU BY INSTITUTION
       cu_act as (
       select act.act_institution_nm,
              act.act_state_cd,
              concat(concat(concat(concat(concat(concat(act.act_institution_nm,'|'),act.act_state_cd),'|'),'CUADPT'),'|'),'Cengage Unlimited') as act_adoption_key,
              sum(total_CD_actv_withCU_FY20) as total_CD_actv_withCU_FY20_1
       from ${af_activation_adoptions.SQL_TABLE_NAME} act
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = act.act_institution_nm
       where act_institution_nm not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
       AND coalesce(cui.FY_20_CU_I_INSTITUTION_Y_N_,'N') = 'N'
       group by 1,2,3
       having total_CD_actv_withCU_FY20_1 > 0),

    ---ALLOCATE API SALES AND UNITS ACROSS CU ADOPTIONS
       cu_api_allocation as (
       select act_adoption_key,
              nvl(total_CD_actv_withCU_FY20_1,0) as adopt_CD_actv_withCU_FY20_1,
              (select sum(total_CD_actv_withCU_FY20_1) from cu_act) as FY20_total_actv_withCU,
              (select api1.FY20_Sep_CU_API_net_sales from cu_api api1) as FY20_total_API_CU_sales_1,
              (select api2.FY20_Sep_CU_API_net_units from cu_api api2) as FY20_total_API_CU_units_1,
              nvl(((adopt_CD_actv_withCU_FY20_1/FY20_total_actv_withCU)*FY20_total_API_CU_sales_1),0) as FY20_API_CU_sales_allocation,
              nvl(((adopt_CD_actv_withCU_FY20_1/FY20_total_actv_withCU)*FY20_total_API_CU_units_1),0) as FY20_API_CU_units_allocation
       from cu_act act),

      cu_not_spec_arpu as (
      select sum(FY19_cu_sales) as FY19_notspec_total_cu_sales,
             sum(FY19_cu_units) as FY19_notspec_total_cu_units,
             sum(FY20_cu_sales) as FY20_notspec_total_cu_sales,
             sum(FY20_cu_units) as FY20_notspec_total_cu_units
      from ${af_salesorder_adoption.SQL_TABLE_NAME}
      where sales_institution_nm = 'Not Specified'),

    ---FIND NUMBER OF NOT SPECIFIED CU NET SALES AND UNITS TO KEEP BASED ON ACTUAL "NOT SPECIFIED" ACTIVATIONS WITHIN CU (CU Activations and ARPU
       cu_not_spec_keep as (
       select 1053 / 1.21 as FY19_notspec_keep_cu_units,
              858 / 1.21 as FY20_notspec_keep_cu_units,
              FY19_notspec_keep_cu_units * 32.18 as FY19_notspec_keep_cu_sales,
              FY20_notspec_keep_cu_units * 88.08 as FY20_notspec_keep_cu_sales
        ),

    ---PULL NOT SPECIFIED CU NET SALES AND UNITS TO BE ALLOCATED
       cu_not_spec as (
       select (select FY19_notspec_total_cu_units from cu_not_spec_arpu) - (select FY19_notspec_keep_cu_units from cu_not_spec_keep) as FY19_notspec_cu_units,
              (select FY20_notspec_total_cu_units from cu_not_spec_arpu) - (select FY20_notspec_keep_cu_units from cu_not_spec_keep) as FY20_notspec_cu_units,
              (select FY19_notspec_total_cu_sales from cu_not_spec_arpu) - (select FY19_notspec_keep_cu_sales from cu_not_spec_keep) as FY19_notspec_cu_sales,
              (select FY20_notspec_total_cu_sales from cu_not_spec_arpu) - (select FY20_notspec_keep_cu_sales from cu_not_spec_keep) as FY20_notspec_cu_sales
               ),

    ---FIND FY19 CU ACTIVATIONS AND UNITS BY INSTITUTION
       cu_act_fy19 as (
       select act_institution_nm,
              act_state_cd,
              sum(nvl(total_CD_actv_withCU_FY19,0)) as FY19_inst_actv_byCU
       from ${af_activation_adoptions.SQL_TABLE_NAME} act
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = act.act_institution_nm
       where act.total_CD_actv_withCU_FY19 > 0
        and act_institution_nm <> 'Not Specified'
        and coalesce(ia.FY_19_IA_ADOPTION_Y_N_,'N') = 'N'
        AND coalesce(cui.FY_19_CU_I_INSTITUTION_Y_N_,'N') = 'N'
       group by 1,2
       having FY19_inst_actv_byCU > 0),

       cu_units_fy19 as (
       select sales_institution_nm,
              sales_state_cd,
              sum(nvl(FY19_CU_units,0)) as FY19_inst_cu_units
       from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = sal.sales_old_adoption_key
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = sal.sales_institution_nm
        where sales_institution_nm <> 'Not Specified'
        and coalesce(ia.FY_19_IA_ADOPTION_Y_N_,'N') = 'N'
        AND coalesce(cui.FY_19_CU_I_INSTITUTION_Y_N_,'N') = 'N'
       group by 1,2
       having FY19_inst_cu_units > 0),

    ---FIND FY19 ACTIVATIONS TO UNITS SURPLUS BY INSTITUTION TO ALLOCATE ON
       not_spec_fy19 as (
        select sal.sales_institution_nm as not_spec_institution_nm,
               sal.sales_state_cd as not_spec_state_cd,
               concat(concat(concat(concat(concat(concat(not_spec_institution_nm,'|'),not_spec_state_cd),'|'),'CUADPT'),'|'),'Cengage Unlimited') as FY19_not_spec_adoption_key,
               nvl(act.FY19_inst_actv_byCU,0) as FY19_inst_actv_byCU_1,
               nvl(sal.FY19_inst_cu_units,0) as FY19_inst_cu_units,
               (FY19_inst_actv_byCU_1 - FY19_inst_cu_units) as FY19_inst_cu_units_gap
        from cu_units_fy19 sal
        LEFT JOIN cu_act_fy19 act on act.act_institution_nm = sal.sales_institution_nm AND act.act_state_cd = sal.sales_state_cd
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = sal.sales_institution_nm
        where not_spec_institution_nm <> 'Not Specified'
        AND coalesce(cui.FY_19_CU_I_INSTITUTION_Y_N_,'N') = 'N'
        and FY19_inst_cu_units_gap > 0
        ),



    ---FIND FY20 CU ACTIVATIONS AND UNITS BY INSTITUTION
       cu_act_fy20 as (
       select act_institution_nm,
              act_state_cd,
              sum(nvl(total_CD_actv_withCU_FY20,0)) as FY20_inst_actv_byCU
       from ${af_activation_adoptions.SQL_TABLE_NAME} act
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = act.act_institution_nm
       where act.total_CD_actv_withCU_FY20 > 0
        and act_institution_nm <> 'Not Specified'
        and coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') = 'N'
        AND coalesce(cui.FY_20_CU_I_INSTITUTION_Y_N_,'N') = 'N'
       group by 1,2
       having FY20_inst_actv_byCU > 0),

       cu_units_fy20 as (
       select sales_institution_nm,
              sales_state_cd,
              sum(nvl(FY20_CU_units,0)) as FY20_inst_cu_units
       from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = sal.sales_old_adoption_key
       LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = sal.sales_institution_nm
        where sales_institution_nm <> 'Not Specified'
        and coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') = 'N'
        AND coalesce(cui.FY_20_CU_I_INSTITUTION_Y_N_,'N') = 'N'
       group by 1,2
       having FY20_inst_cu_units > 0),

    ---FIND FY20 ACTIVATIONS TO UNITS SURPLUS BY INSTITUTION TO ALLOCATE ON
       not_spec_fy20 as (
        select sal.sales_institution_nm as not_spec_institution_nm,
               sal.sales_state_cd as not_spec_state_cd,
               concat(concat(concat(concat(concat(concat(not_spec_institution_nm,'|'),not_spec_state_cd),'|'),'CUADPT'),'|'),'Cengage Unlimited') as FY20_not_spec_adoption_key,
               nvl(act.FY20_inst_actv_byCU,0) as FY20_inst_actv_byCU_1,
               nvl(sal.FY20_inst_cu_units,0) as FY20_inst_cu_units,
               (FY20_inst_actv_byCU_1 - FY20_inst_cu_units) as FY20_inst_cu_units_gap
        from cu_units_fy20 sal
        LEFT JOIN cu_act_fy20 act on act.act_institution_nm = sal.sales_institution_nm AND act.act_state_cd = sal.sales_state_cd
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = sal.sales_institution_nm
        where not_spec_institution_nm <> 'Not Specified'
        AND coalesce(cui.FY_20_CU_I_INSTITUTION_Y_N_,'N') = 'N'
        and FY20_inst_cu_units_gap > 0
        ),

    ---FIND NOT SPECIFIED ADOPTION KEYS
       not_spec_keys as (
       select FY19_not_spec_adoption_key as adoption_key from not_spec_fy19
       UNION
       select fy20_not_spec_adoption_key as adoption_key from not_spec_fy20),

       not_spec_keys2 as (
       select distinct adoption_key from not_spec_keys),

    ---ALLOCATE NOT SPECIFIED CU SALES AND UNITS ACROSS CU ADOPTIONS
       not_spec_allocation as (
       select keys.adoption_key as not_spec_adoption_key,
              coalesce(ns19.FY19_inst_cu_units_gap,0) as FY19_inst_cu_units_gap_1,
              coalesce(ns20.FY20_inst_cu_units_gap,0) as FY20_inst_cu_units_gap_1,
              (select sum(FY19_inst_cu_units_gap) from not_spec_fy19) as FY19_total_cu_units_gap,
              (select sum(FY20_inst_cu_units_gap) from not_spec_fy20) as FY20_total_cu_units_gap,
              (select FY19_notspec_cu_units from cu_not_spec) as FY19_notspec_CU_units,
              (select FY20_notspec_cu_units from cu_not_spec) as FY20_notspec_CU_units,
              (select FY19_notspec_cu_sales from cu_not_spec) as FY19_notspec_CU_sales,
              (select FY20_notspec_cu_sales from cu_not_spec) as FY20_notspec_CU_sales,
              nvl(((FY19_inst_cu_units_gap_1/FY19_total_cu_units_gap)*FY19_notspec_CU_units),0) as FY19_notspec_CU_units_allocation,
              nvl(((FY20_inst_cu_units_gap_1/FY20_total_cu_units_gap)*FY20_notspec_CU_units),0) as FY20_notspec_CU_units_allocation,
              nvl(((FY19_inst_cu_units_gap_1/FY19_total_cu_units_gap)*FY19_notspec_CU_sales),0) as FY19_notspec_CU_sales_allocation,
              nvl(((FY20_inst_cu_units_gap_1/FY20_total_cu_units_gap)*FY20_notspec_CU_sales),0) as FY20_notspec_CU_sales_allocation
       from not_spec_keys2 keys
       LEFT JOIN not_spec_fy19 ns19 on ns19.FY19_not_spec_adoption_key = keys.adoption_key
       LEFT JOIN not_spec_fy20 ns20 on ns20.FY20_not_spec_adoption_key = keys.adoption_key
      ),

      not_spec_allocation_1 as (
      select not_spec_adoption_key,
             FY19_notspec_CU_units_allocation,
             FY20_notspec_CU_units_allocation,
             FY19_notspec_CU_sales_allocation,
             FY20_notspec_CU_sales_allocation
      from not_spec_allocation),

    ---CREATE ISBN TO COURSE LOOKUP TABLE
       course_lookup1 as (
       select prod.isbn_13,
              coalesce(pfmt.course_code_description,'.') as course_code_description,
              sum(quantity) as units,
              row_number() over (partition by prod.isbn_13 order by units desc) as quantity_order
       from STRATEGY.ADOPTION_PIVOT.FY20_SALES_ADOPTIONPIVOT sal
       left JOIN STRATEGY.ADOPTION_PIVOT.TERRITORIES_ADOPTIONPIVOT ter ON (sal."TERRITORY_SKEY") = (ter."TERRITORY_SKEY")
       left JOIN STRATEGY.ADOPTION_PIVOT.PRODUCTS_ADOPTIONPIVOT  prod ON (sal."PRODUCT_SKEY_BU") = (prod."PRODUCT_SKEY")
       left JOIN prod.dw_ga.dim_date  AS dim_date ON (TO_CHAR(TO_DATE(sal."INVOICE_DT" ), 'YYYY-MM-DD'))::DATE = (TO_CHAR(TO_DATE(dim_date.datevalue), 'YYYY-MM-DD'))
       left JOIN STRATEGY.ADOPTION_PIVOT.CUSTOMERS_ADOPTIONPIVOT  cust ON (sal."CUST_NO_SHIP") = (cust."CUST_NO")
       left JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT  ent ON (ent."ENTITY_NO") = (cust."ENTITY_NO")
       left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd
       WHERE UPPER(institution_nm) NOT IN ('AKADEMOS INC','BARNES & NOBLE 000 WAREHOUSE','BARNES & NOBLE COLLEGE STORES','BOOK COMPANY LLC','CHEGG.COM','COURSESMART','FOLLETT DIGITAL RESOURCES',
                                         'FOLLETT LIBRARY SERVICES','FOLLETTS CORPORATE OFFICE','FOLLETTS RESEARCH DEPT','MBS TEXTBOOK EXCHANGE','TEXAS BOOK CO CBD','GOOGLE INC', 'FOLLETT''S CORP', 'WEBASSIGN MASTER BILLING', 'QUIA CORPORATION' )
       AND reason_cd NOT IN ('980','AMC','CHS')
       AND prod.division_cd NOT IN ('101', 'GLO')
       AND sales_type_cd = 'DOM'
       AND short_item_no_parent = '-1'
       AND gsf_cd = 'HED'
       AND (sal.invoice_dt between '2019-04-01' AND '2019-09-30')
       group by 1,2),

       course_lookup2 as (
       select isbn_13,
              course_code_description
       from course_lookup1
       where quantity_order = '1'),

    ---FIND FY19 TOTAL API STANDALONE UNITS BY COURSE TO BE ALLOCATED
       api_units_19 as (
       select coalesce(course.course_code_description,'.') as course_code_description,
              sum(nvl(to_char(sal.net_units),0)) as FY19_API_standalone_units_allocation,
              sum(nvl(to_char(sal.net_sales),0)) as FY19_API_standalone_sales_allocation
       from STRATEGY.ADOPTION_PIVOT.FY19_SEPTEMBER_STANDALONE_API_SALES sal
       left join course_lookup2 course on course.isbn_13 = sal.isbn
       group by 1),

    ---FIND FY20 TOTAL API STANDALONE UNITS BY COURSE TO BE ALLOCATED
       api_units_20 as (
       select coalesce(course.course_code_description,'.') as course_code_description,
              sum(nvl(to_char(sal.net_units),0)) as FY20_API_standalone_units_allocation,
              sum(nvl(to_char(sal.net_sales),0)) as FY20_API_standalone_sales_allocation
       from STRATEGY.ADOPTION_PIVOT.FY20_SEPTEMBER_STANDALONE_API_SALES sal
       left join course_lookup2 course on course.isbn_13 = sal.isbn
       group by 1),

    ---FIND FY19 ACTIVATIONS TO UNITS GAP BY ADOPTION
       api_fy19 as (
        select keys.adoption_key as api_adoption_key,
               coalesce(sal.sales_course_code_description, act.act_course_code_description) as api_course_code_description,
               sum(CASE WHEN ((coalesce(sal.FY19_core_digital_standalone_units,0)+coalesce(sal.FY19_core_digital_bundle_units,0)+coalesce(sal.FY19_LLF_bundle_units,0)) > 0)
               THEN (coalesce(act.total_CD_actv_exCU_FY19,0) - (coalesce(sal.FY19_core_digital_standalone_units,0)+coalesce(sal.FY19_core_digital_bundle_units,0)+coalesce(sal.FY19_LLF_bundle_units,0)))
               ELSE coalesce(total_CD_actv_exCU_FY19,0) end) as FY19_adoption_api_cd_units_gap
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        where total_CD_actv_exCU_FY19 > 0
        and coalesce(ia.FY_19_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY19_adoption_api_cd_units_gap > 0
        ),

    ---FIND FY20 ACTIVATIONS TO UNITS GAP BY COURSE
        api_fy19_course as (
        select api_course_code_description,
               sum(nvl(FY19_adoption_api_cd_units_gap,0)) as FY19_course_api_cd_units_gap
        from api_fy19
        group by 1),

    ---FIND FY20 ACTIVATIONS TO UNITS GAP BY ADOPTION
       api_fy20 as (
        select keys.adoption_key as api_adoption_key,
               coalesce(sal.sales_course_code_description, act.act_course_code_description) as api_course_code_description,
               sum(CASE WHEN ((coalesce(sal.FY20_core_digital_standalone_units,0)+coalesce(sal.FY20_core_digital_bundle_units,0)+coalesce(sal.FY20_LLF_bundle_units,0)) > 0)
               THEN (coalesce(act.total_CD_actv_exCU_FY20,0) - (coalesce(sal.FY20_core_digital_standalone_units,0)+coalesce(sal.FY20_core_digital_bundle_units,0)+coalesce(sal.FY20_LLF_bundle_units,0)))
               ELSE coalesce(total_CD_actv_exCU_FY20,0) end) as FY20_adoption_api_cd_units_gap
        from adoption_keys2 keys
        LEFT JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act on act.act_adoption_key = keys.adoption_key
        LEFT JOIN ${af_salesorder_adoption.SQL_TABLE_NAME} sal on sal.sales_adoption_key = keys.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        where total_CD_actv_exCU_FY20 > 0
        and coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY20_adoption_api_cd_units_gap > 0
        ),

    ---FIND FY20 ACTIVATIONS TO UNITS GAP BY COURSE
        api_fy20_course as (
        select api_course_code_description,
               sum(nvl(FY20_adoption_api_cd_units_gap,0)) as FY20_course_api_cd_units_gap
        from api_fy20
        group by 1),

    --JOIN TOGETHER TO CREATE FY19 API STANDALONE ALLOCATIONS BY COURSE
        standalone_api_allocation_19 as (
        select api_fy19.api_adoption_key as adoption_key,
               api_fy19.api_course_code_description as course_code_description,
               max(nvl(api_units_19.FY19_API_standalone_units_allocation,0)) as FY19_API_standalone_units_allocation_1,
               max(nvl(api_units_19.FY19_API_standalone_sales_allocation,0)) as FY19_API_standalone_sales_allocation_1,
               max(course19.FY19_course_api_cd_units_gap) as FY19_course_api_cd_units_gap_1,
               sum(coalesce(api_fy19.FY19_adoption_api_cd_units_gap,0)) as FY19_adoption_api_cd_units_gap_1,
               (nvl(FY19_adoption_api_cd_units_gap_1,0)/FY19_course_api_cd_units_gap_1*nvl(FY19_API_standalone_units_allocation_1,0)) as FY19_api_cd_standalone_units_adjustment,
               (nvl(FY19_adoption_api_cd_units_gap_1,0)/FY19_course_api_cd_units_gap_1*nvl(FY19_API_standalone_sales_allocation_1,0)) as FY19_api_cd_standalone_sales_adjustment
        from api_fy19
        left join api_units_19 on api_fy19.api_course_code_description = api_units_19.course_code_description
        left join api_fy19_course course19 on api_fy19.api_course_code_description = course19.api_course_code_description
        group by 1,2),

    --JOIN TOGETHER TO CREATE FY20 API STANDALONE ALLOCATIONS BY COURSE
        standalone_api_allocation_20 as (
        select api_fy20.api_adoption_key as adoption_key,
               api_fy20.api_course_code_description as course_code_description,
               max(nvl(api_units_20.FY20_API_standalone_units_allocation,0)) as FY20_API_standalone_units_allocation_1,
               max(nvl(api_units_20.FY20_API_standalone_sales_allocation,0)) as FY20_API_standalone_sales_allocation_1,
               max(course20.FY20_course_api_cd_units_gap) as FY20_course_api_cd_units_gap_1,
               sum(coalesce(api_fy20.FY20_adoption_api_cd_units_gap,0)) as FY20_adoption_api_cd_units_gap_1,
               (nvl(FY20_adoption_api_cd_units_gap_1,0)/FY20_course_api_cd_units_gap_1*nvl(FY20_API_standalone_units_allocation_1,0)) as FY20_api_cd_standalone_units_adjustment,
               (nvl(FY20_adoption_api_cd_units_gap_1,0)/FY20_course_api_cd_units_gap_1*nvl(FY20_API_standalone_sales_allocation_1,0)) as FY20_api_cd_standalone_sales_adjustment
        from api_fy20
        left join api_units_20 on api_fy20.api_course_code_description = api_units_20.course_code_description
        left join api_fy20_course course20 on api_fy20.api_course_code_description = course20.api_course_code_description
        group by 1,2),

     ---FIND FY19 ACTIVATIONS WITHIN CU BY ADOPTION
       cu_fy19 as (
        select act.act_adoption_key as cu19_adoption_key,
               sum(coalesce(act.total_CD_actv_withCU_FY19,0)) as FY19_adoption_actv_withCU
        from ${af_activation_adoptions.SQL_TABLE_NAME} act
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = act.act_institution_nm
        where UPPER(act.act_institution_nm) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(ia.FY_19_IA_ADOPTION_Y_N_,'N') = 'N'
        AND coalesce(cui.FY_19_CU_I_INSTITUTION_Y_N_,'N') = 'N'
        group by 1
        having FY19_adoption_actv_withCU > 0
        ),

     ---FIND FY20 ACTIVATIONS WITHIN CU BY ADOPTION
       cu_fy20 as (
        select act.act_adoption_key as cu20_adoption_key,
               sum(coalesce(act.total_CD_actv_withCU_FY20,0)) as FY20_adoption_actv_withCU
        from ${af_activation_adoptions.SQL_TABLE_NAME} act
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = act.act_old_adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = act.act_institution_nm
        where UPPER(act.act_institution_nm) not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')
        and coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') = 'N'
        AND coalesce(cui.FY_20_CU_I_INSTITUTION_Y_N_,'N') = 'N'
        group by 1
        having FY20_adoption_actv_withCU > 0
        ),

    --FIND ALL ADOPTION KEYS
       unactivated_keys as (
       select cu19_adoption_key as adoption_key from cu_fy19
       UNION
       select cu20_adoption_key as adoption_key from cu_fy20),

       unactivated_keys2 as (
       select distinct adoption_key from unactivated_keys),

    --JOIN TOGETHER ALL FISCAL YEARS BY ADOPTION AND CREATE UNACTIVATED CU UNITS ALLOCATIONS
        unactivated_cu_allocation as (
        select keys.adoption_key,
               102044 as FY19_unactivated_CU_units_1,
               46464 as  FY20_unactivated_CU_units_1,
               sum(coalesce(cu_fy19.FY19_adoption_actv_withCU,0)) as FY19_adoption_actv_withCU_1,
               sum(coalesce(cu_fy20.FY20_adoption_actv_withCU,0)) as FY20_adoption_actv_withCU_1,
               (select sum(FY19_adoption_actv_withCU) from cu_fy19) as FY19_total_actv_withCU,
               (select sum(FY20_adoption_actv_withCU) from cu_fy20) as FY20_total_actv_withCU,
               (nvl(FY19_adoption_actv_withCU_1,0)/FY19_total_actv_withCU*nvl(FY19_unactivated_CU_units_1,0)) as FY19_unactivated_cu_units_adjustment,
               (nvl(FY20_adoption_actv_withCU_1,0)/FY20_total_actv_withCU*nvl(FY20_unactivated_CU_units_1,0)) as FY20_unactivated_cu_units_adjustment
        from unactivated_keys2 keys
        LEFT JOIN cu_fy19 on cu19_adoption_key = keys.adoption_key
        LEFT JOIN cu_fy20 on cu20_adoption_key = keys.adoption_key
        group by 1),

    --FIND TOTAL EBOOKS BILLED IN OCTOBER BY COURSE FOR FY17-19
        oct_ebook_units as (
        select pfmt.course_code_description,
               sum(case when fiscal_year = 2017 then units else 0 end) as FY17_oct_ebook_units_allocation,
               sum(case when fiscal_year = 2017 then sales else 0 end) as FY17_oct_ebook_sales_allocation,
               sum(case when fiscal_year = 2018 then units else 0 end) as FY18_oct_ebook_units_allocation,
               sum(case when fiscal_year = 2018 then sales else 0 end) as FY18_oct_ebook_sales_allocation,
               sum(case when fiscal_year = 2019 then units else 0 end) as FY19_oct_ebook_units_allocation,
               sum(case when fiscal_year = 2019 then sales else 0 end) as FY19_oct_ebook_sales_allocation
        from STRATEGY.ADOPTION_PIVOT.FY17_FY20_OCTOBER_EBOOK_BILLINGS ebook
        left join STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = ebook.prod_family_cd
        where ebook.gsf_cd = 'HED'
        AND ((invoice_dt between '2016-10-19' AND '2016-10-31') OR (invoice_dt between '2017-10-19' AND '2017-10-31') OR (invoice_dt between '2018-10-19' AND '2018-10-31') OR (invoice_dt between '2019-10-19' AND '2019-10-31'))
        group by 1),

    --CALL FY20 TOTAL EBOOKS TO BE ALLOCATED
        fy20_oct_ebooks as (
        select 130325 as FY20_oct_ebook_units_allocation,
               4664512 as FY20_oct_ebook_sales_allocation),

    --FIND FY17 ACTUAL EBOOK UNITS BY ADOPTION WITH COURSE INFORMATION
        fy17_ebook as (
        select sales_adoption_key,
               sales_course_code_description,
               sum(FY17_ebook_units) as FY17_adoption_ebook_units
        from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
        left join STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = sal.sales_old_adoption_key
        where coalesce(ia.FY_17_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY17_adoption_ebook_units > 0),

        fy17_ebook_course as (
        select sales_course_code_description,
               sum(FY17_adoption_ebook_units) as FY17_course_ebook_units
        from fy17_ebook
        group by 1),

    --FIND FY18 ACTUAL EBOOK UNITS BY ADOPTION WITH COURSE INFORMATION
        fy18_ebook as (
        select sales_adoption_key,
               sales_course_code_description,
               sum(FY18_ebook_units) as FY18_adoption_ebook_units
        from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
        left join STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = sal.sales_old_adoption_key
        where coalesce(ia.FY_18_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY18_adoption_ebook_units > 0),

        fy18_ebook_course as (
        select sales_course_code_description,
               sum(FY18_adoption_ebook_units) as FY18_course_ebook_units
        from fy18_ebook
        group by 1),

    --FIND FY19 ACTUAL EBOOK UNITS BY ADOPTION WITH COURSE INFORMATION
        fy19_ebook as (
        select sales_adoption_key,
               sales_course_code_description,
               sum(FY19_ebook_units) as FY19_adoption_ebook_units
        from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
        left join STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = sal.sales_old_adoption_key
        where coalesce(ia.FY_19_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY19_adoption_ebook_units > 0),

        fy19_ebook_course as (
        select sales_course_code_description,
               sum(FY19_adoption_ebook_units) as FY19_course_ebook_units
        from fy19_ebook
        group by 1),

    --FIND FY20 ACTUAL EBOOK UNITS BY ADOPTION WITH COURSE INFORMATION
        fy20_ebook as (
        select sales_adoption_key,
               sales_course_code_description,
               sum(FY20_ebook_units) as FY20_adoption_ebook_units
        from ${af_salesorder_adoption.SQL_TABLE_NAME} sal
        left join STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = sal.sales_old_adoption_key
        where coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') = 'N'
        group by 1,2
        having FY20_adoption_ebook_units > 0),

    --GET UNIQUE LIST OF ADOPTION KEYS
       ebook_keys as (
       select sales_adoption_key as adoption_key from fy17_ebook
       UNION
       select sales_adoption_key as adoption_key from fy18_ebook
       UNION
       select sales_adoption_key as adoption_key from fy19_ebook
       UNION
       select sales_adoption_key as adoption_key from fy20_ebook),

      ebook_keys2 as (
      select distinct adoption_key
      from ebook_keys),

     --JOIN TOGETHER FISCAL YEARS TO CREATE EBOOK ALLOCATION
        oct_ebook_allocation as (
        select keys.adoption_key,
               coalesce(fy17_ebook.sales_course_code_description, fy18_ebook.sales_course_code_description, fy19_ebook.sales_course_code_description, fy20_ebook.sales_course_code_description) as course_code_description,
               max(nvl(units.FY17_oct_ebook_units_allocation,0)) as FY17_oct_ebook_units_allocation_1,
               max(nvl(units.FY17_oct_ebook_sales_allocation,0)) as FY17_oct_ebook_sales_allocation_1,
               max(nvl(units.FY18_oct_ebook_units_allocation,0)) as FY18_oct_ebook_units_allocation_1,
               max(nvl(units.FY18_oct_ebook_sales_allocation,0)) as FY18_oct_ebook_sales_allocation_1,
               max(nvl(units.FY19_oct_ebook_units_allocation,0)) as FY19_oct_ebook_units_allocation_1,
               max(nvl(units.FY19_oct_ebook_sales_allocation,0)) as FY19_oct_ebook_sales_allocation_1,
               (select FY20_oct_ebook_units_allocation from fy20_oct_ebooks) as FY20_oct_ebook_units_allocation_1,
               (select FY20_oct_ebook_sales_allocation from fy20_oct_ebooks) as FY20_oct_ebook_sales_allocation_1,
               max(fy17_course.FY17_course_ebook_units) as FY17_course_ebook_units_1,
               max(fy18_course.FY18_course_ebook_units) as FY18_course_ebook_units_1,
               max(fy19_course.FY19_course_ebook_units) as FY19_course_ebook_units_1,
               (select sum(FY20_adoption_ebook_units) from fy20_ebook) as FY20_total_ebook_units_1,
               sum(coalesce(fy17_ebook.FY17_adoption_ebook_units,0)) as FY17_adoption_ebook_units_1,
               sum(coalesce(fy18_ebook.FY18_adoption_ebook_units,0)) as FY18_adoption_ebook_units_1,
               sum(coalesce(fy19_ebook.FY19_adoption_ebook_units,0)) as FY19_adoption_ebook_units_1,
               sum(coalesce(fy20_ebook.FY20_adoption_ebook_units,0)) as FY20_adoption_ebook_units_1,
               (nvl(FY17_adoption_ebook_units_1,0)/FY17_course_ebook_units_1*nvl(FY17_oct_ebook_units_allocation_1,0)) as FY17_oct_ebook_units_adjustment,
               (nvl(FY17_adoption_ebook_units_1,0)/FY17_course_ebook_units_1*nvl(FY17_oct_ebook_sales_allocation_1,0)) as FY17_oct_ebook_sales_adjustment,
               (nvl(FY18_adoption_ebook_units_1,0)/FY18_course_ebook_units_1*nvl(FY18_oct_ebook_units_allocation_1,0)) as FY18_oct_ebook_units_adjustment,
               (nvl(FY18_adoption_ebook_units_1,0)/FY18_course_ebook_units_1*nvl(FY18_oct_ebook_sales_allocation_1,0)) as FY18_oct_ebook_sales_adjustment,
               (nvl(FY19_adoption_ebook_units_1,0)/FY19_course_ebook_units_1*nvl(FY19_oct_ebook_units_allocation_1,0)) as FY19_oct_ebook_units_adjustment,
               (nvl(FY19_adoption_ebook_units_1,0)/FY19_course_ebook_units_1*nvl(FY19_oct_ebook_sales_allocation_1,0)) as FY19_oct_ebook_sales_adjustment,
               (nvl(FY20_adoption_ebook_units_1,0)/FY20_total_ebook_units_1*nvl(FY20_oct_ebook_units_allocation_1,0)) as FY20_oct_ebook_units_adjustment,
               (nvl(FY20_adoption_ebook_units_1,0)/FY20_total_ebook_units_1*nvl(FY20_oct_ebook_sales_allocation_1,0)) as FY20_oct_ebook_sales_adjustment
        from ebook_keys2 keys
        LEFT JOIN fy17_ebook on fy17_ebook.sales_adoption_key = keys.adoption_key
        LEFT JOIN fy18_ebook on fy18_ebook.sales_adoption_key = keys.adoption_key
        LEFT JOIN fy19_ebook on fy19_ebook.sales_adoption_key = keys.adoption_key
        LEFT JOIN fy20_ebook on fy20_ebook.sales_adoption_key = keys.adoption_key
        left join oct_ebook_units units on units.course_code_description = coalesce(fy17_ebook.sales_course_code_description, fy18_ebook.sales_course_code_description, fy19_ebook.sales_course_code_description)
        left join fy17_ebook_course fy17_course on fy17_course.sales_course_code_description = fy17_ebook.sales_course_code_description
        left join fy18_ebook_course fy18_course on fy18_course.sales_course_code_description = fy18_ebook.sales_course_code_description
        left join fy19_ebook_course fy19_course on fy19_course.sales_course_code_description = fy19_ebook.sales_course_code_description
        group by 1,2),

        oct_ebook_allocation_1 as (
        select  adoption_key,
                FY17_oct_ebook_units_adjustment,
                FY17_oct_ebook_sales_adjustment,
                FY18_oct_ebook_units_adjustment,
                FY18_oct_ebook_sales_adjustment,
                FY19_oct_ebook_units_adjustment,
                FY19_oct_ebook_sales_adjustment,
                FY20_oct_ebook_units_adjustment,
                FY20_oct_ebook_sales_adjustment
        from oct_ebook_allocation),

    ---CREATE SALES TABLE WITHOUT QUIA OR WEBASSIGN
        sales as (
        select *
        from  ${af_salesorder_adoption.SQL_TABLE_NAME}
        where sales_institution_nm not in ('WEBASSIGN MASTER BILLING', 'QUIA CORPORATION')),

    ---CREATE FINAL LIST OF ADOPTION KEYS
       final_adoption_keys as (
       select sales_adoption_key as adoption_key from sales
       UNION
       select act_adoption_key as adoption_key from ${af_activation_adoptions.SQL_TABLE_NAME}),

       final_adoption_keys2 as (
       select distinct adoption_key from final_adoption_keys),



    ---GENERATE CORE TABLE JOINING TOGETHER SALES, ACTIVATIONS, EBOOK, RESELLERS, AND ALLOCATIONS
    sales_adoption as
    (
      Select
             sal.*,
             coalesce(act_fy20_primary_platform,'No Activations') as FY20_primary_platform,
             coalesce(sal.sales_adoption_key, act.act_adoption_key) as adoption_key,
             coalesce(sales_old_adoption_key, act_old_adoption_key) as old_adoption_key,
             coalesce(sales_institution_nm, act_institution_nm) as institution_nm,
             coalesce(sales_state_cd, act_state_cd) as state_cd,
             coalesce(sales_course_code_description, act_course_code_description) as course_code_description,
             coalesce(sales_pub_series_de, act_pub_series_de) as pub_series_de,
             nvl(wa.FY17_WA_cd_units_adjustment,0) as FY17_WA_cd_units_adjustment_1,
             nvl(wa.FY17_WA_cd_sales_adjustment,0) as FY17_WA_cd_sales_adjustment_1,
             nvl(wa.FY17_WA_print_units_adjustment,0) as FY17_WA_print_units_adjustment_1,
             nvl(wa.FY17_WA_print_sales_adjustment,0) as FY17_WA_print_sales_adjustment_1,
             nvl(wa.FY18_WA_cd_units_adjustment,0) as FY18_WA_cd_units_adjustment_1,
             nvl(wa.FY18_WA_cd_sales_adjustment,0) as FY18_WA_cd_sales_adjustment_1,
             nvl(quia.FY17_quia_cd_units_adjustment,0) as FY17_quia_cd_units_adjustment_1,
             nvl(quia.FY17_quia_cd_sales_adjustment,0) as FY17_quia_cd_sales_adjustment_1,
             nvl(quia.FY18_quia_cd_units_adjustment,0) as FY18_quia_cd_units_adjustment_1,
             nvl(quia.FY18_quia_cd_sales_adjustment,0) as FY18_quia_cd_sales_adjustment_1,
             nvl(quia.FY19_quia_cd_units_adjustment,0) as FY19_quia_cd_units_adjustment_1,
             nvl(quia.FY19_quia_cd_sales_adjustment,0) as FY19_quia_cd_sales_adjustment_1,
             nvl(cu.FY20_API_CU_units_allocation,0) as FY20_API_CU_units_allocation_1,
             nvl(cu.FY20_API_CU_sales_allocation,0) as FY20_API_CU_sales_allocation_1,
             nvl(stand19.FY19_api_cd_standalone_units_adjustment,0) as FY19_api_cd_standalone_units_adjustment_1,
             nvl(stand19.FY19_api_cd_standalone_sales_adjustment,0) as FY19_api_cd_standalone_sales_adjustment_1,
             nvl(stand20.FY20_api_cd_standalone_units_adjustment,0) as FY20_api_cd_standalone_units_adjustment_1,
             nvl(stand20.FY20_api_cd_standalone_sales_adjustment,0) as FY20_api_cd_standalone_sales_adjustment_1,
             nvl(cu2.FY19_unactivated_cu_units_adjustment,0) as FY19_unactivated_cu_units_adjustment_1,
             nvl(cu2.FY20_unactivated_cu_units_adjustment,0) as FY20_unactivated_cu_units_adjustment_1,
             nvl(ebook.FY17_oct_ebook_units_adjustment,0) as FY17_oct_ebook_units_adjustment_1,
             nvl(ebook.FY17_oct_ebook_sales_adjustment,0) as FY17_oct_ebook_sales_adjustment_1,
             nvl(ebook.FY18_oct_ebook_units_adjustment,0) as FY18_oct_ebook_units_adjustment_1,
             nvl(ebook.FY18_oct_ebook_sales_adjustment,0) as FY18_oct_ebook_sales_adjustment_1,
             nvl(ebook.FY19_oct_ebook_units_adjustment,0) as FY19_oct_ebook_units_adjustment_1,
             nvl(ebook.FY19_oct_ebook_sales_adjustment,0) as FY19_oct_ebook_sales_adjustment_1,
             nvl(ebook.FY20_oct_ebook_units_adjustment,0) as FY20_oct_ebook_units_adjustment_1,
             nvl(ebook.FY20_oct_ebook_sales_adjustment,0) as FY20_oct_ebook_sales_adjustment_1,
             nvl(notspec.FY19_notspec_CU_units_allocation,0) as FY19_notspec_CU_units_allocation_1,
             nvl(notspec.FY20_notspec_CU_units_allocation,0) as FY20_notspec_CU_units_allocation_1,
             nvl(notspec.FY19_notspec_CU_sales_allocation,0) as FY19_notspec_CU_sales_allocation_1,
             nvl(notspec.FY20_notspec_CU_sales_allocation,0) as FY20_notspec_CU_sales_allocation_1,
             (nvl(sal.FY17_ebook_units,0) + nvl(eb.FY17_ebook_units_byCU,0) + nvl(FY17_oct_ebook_units_adjustment_1,0)) as FY17_total_ebook_activations,
             (nvl(sal.FY18_ebook_units,0) + nvl(eb.FY18_ebook_units_byCU,0) + nvl(FY18_oct_ebook_units_adjustment_1,0)) as FY18_total_ebook_activations,
             (nvl(sal.FY19_ebook_units,0) + nvl(eb.FY19_ebook_units_byCU,0) + nvl(FY19_oct_ebook_units_adjustment_1,0)) as FY19_total_ebook_activations,
             (nvl(sal.FY20_ebook_units,0) + nvl(eb.FY20_ebook_units_byCU,0) + nvl(FY20_oct_ebook_units_adjustment_1,0)) as FY20_total_ebook_activations,
             (nvl(FY17_core_digital_standalone_sales,0)+nvl(FY17_core_digital_bundle_sales,0)+nvl(FY17_LLF_bundle_sales,0)+nvl(FY17_WA_cd_sales_adjustment_1,0)+nvl(FY17_quia_cd_sales_adjustment_1,0)) as Total_core_digital_NetSales_ex_CU_fy17,
             (nvl(FY18_core_digital_standalone_sales,0)+nvl(FY18_core_digital_bundle_sales,0)+nvl(FY18_LLF_bundle_sales,0)+nvl(FY18_WA_cd_sales_adjustment_1,0)+nvl(FY18_quia_cd_sales_adjustment_1,0)) as Total_core_digital_NetSales_ex_CU_fy18,
             (nvl(FY19_core_digital_standalone_sales,0)+nvl(FY19_core_digital_bundle_sales,0)+nvl(FY19_LLF_bundle_sales,0)+nvl(FY19_quia_cd_sales_adjustment_1,0) + nvl(FY19_api_cd_standalone_sales_adjustment_1,0)) as Total_core_digital_NetSales_ex_CU_fy19,
             (nvl(FY20_core_digital_standalone_sales,0)+nvl(FY20_core_digital_bundle_sales,0)+nvl(FY20_LLF_bundle_sales,0)+nvl(FY20_api_cd_standalone_sales_adjustment_1,0)) as Total_core_digital_NetSales_ex_CU_fy20,
             (nvl(FY17_core_digital_standalone_sales,0)+nvl(FY17_core_digital_bundle_sales,0)+nvl(FY17_LLF_bundle_sales,0)+nvl(FY17_cu_sales,0)+nvl(FY17_WA_cd_sales_adjustment_1,0)+nvl(FY17_quia_cd_sales_adjustment_1,0)) as Total_core_digital_NetSales_fy17,
             (nvl(FY18_core_digital_standalone_sales,0)+nvl(FY18_core_digital_bundle_sales,0)+nvl(FY18_LLF_bundle_sales,0)+nvl(FY18_cu_sales,0)+nvl(FY18_WA_cd_sales_adjustment_1,0)+nvl(FY18_quia_cd_sales_adjustment_1,0)) as Total_core_digital_NetSales_fy18,
             (nvl(FY19_core_digital_standalone_sales,0)+nvl(FY19_core_digital_bundle_sales,0)+nvl(FY19_LLF_bundle_sales,0)+nvl(FY19_cu_sales,0)+nvl(FY19_quia_cd_sales_adjustment_1,0) + nvl(FY19_api_cd_standalone_sales_adjustment_1,0) + nvl(FY19_notspec_CU_sales_allocation_1,0)) as Total_core_digital_NetSales_fy19,
             (nvl(FY20_core_digital_standalone_sales,0)+nvl(FY20_core_digital_bundle_sales,0)+nvl(FY20_LLF_bundle_sales,0)+nvl(FY20_cu_sales,0)+nvl(FY20_API_CU_sales_allocation_1,0)+nvl(FY20_api_cd_standalone_sales_adjustment_1,0) + nvl(FY20_notspec_CU_sales_allocation_1,0)) as Total_core_digital_NetSales_fy20,
             (nvl(FY17_core_digital_standalone_sales,0)+nvl(FY17_core_digital_bundle_sales,0)+nvl(FY17_LLF_bundle_sales,0)+nvl(FY17_cu_sales,0)+nvl(FY17_custom_print_core_sales,0)+nvl(FY17_print_core_sales,0)+nvl(FY17_print_other_sales,0)+nvl(FY17_custom_print_other_sales,0)+nvl(FY17_ebook_sales,0)+nvl(FY17_other_digital_standalone_sales,0)+nvl(FY17_other_digital_bundle_sales,0)+nvl(FY17_WA_cd_sales_adjustment_1,0)+nvl(FY17_quia_cd_sales_adjustment_1,0)+nvl(FY17_WA_print_sales_adjustment_1,0) + nvl(FY17_oct_ebook_sales_adjustment_1,0)) as Total_Net_sales_fy17,
             (nvl(FY18_core_digital_standalone_sales,0)+nvl(FY18_core_digital_bundle_sales,0)+nvl(FY18_LLF_bundle_sales,0)+nvl(FY18_cu_sales,0)+nvl(FY18_custom_print_core_sales,0)+nvl(FY18_print_core_sales,0)+nvl(FY18_print_other_sales,0)+nvl(FY18_custom_print_other_sales,0)+nvl(FY18_ebook_sales,0)+nvl(FY18_other_digital_standalone_sales,0)+nvl(FY18_other_digital_bundle_sales,0)+nvl(FY18_WA_cd_sales_adjustment_1,0)+nvl(FY18_quia_cd_sales_adjustment_1,0) + nvl(FY18_oct_ebook_sales_adjustment_1,0)) as Total_Net_sales_fy18,
             (nvl(FY19_core_digital_standalone_sales,0)+nvl(FY19_core_digital_bundle_sales,0)+nvl(FY19_LLF_bundle_sales,0)+nvl(FY19_cu_sales,0)+nvl(FY19_custom_print_core_sales,0)+nvl(FY19_print_core_sales,0)+nvl(FY19_print_other_sales,0)+nvl(FY19_custom_print_other_sales,0)+nvl(FY19_ebook_sales,0)+nvl(FY19_other_digital_standalone_sales,0)+nvl(FY19_other_digital_bundle_sales,0)+nvl(FY19_quia_cd_sales_adjustment_1,0) + nvl(FY19_oct_ebook_sales_adjustment_1,0) + nvl(FY19_api_cd_standalone_sales_adjustment_1,0) + nvl(FY19_notspec_CU_sales_allocation_1,0)) as Total_Net_sales_fy19,
             (nvl(FY20_core_digital_standalone_sales,0)+nvl(FY20_core_digital_bundle_sales,0)+nvl(FY20_LLF_bundle_sales,0)+nvl(FY20_cu_sales,0)+nvl(FY20_custom_print_core_sales,0)+nvl(FY20_print_core_sales,0)+nvl(FY20_print_other_sales,0)+nvl(FY20_custom_print_other_sales,0)+nvl(FY20_ebook_sales,0)+nvl(FY20_other_digital_standalone_sales,0)+nvl(FY20_other_digital_bundle_sales,0)+nvl(FY20_API_CU_sales_allocation_1,0)+nvl(FY20_api_cd_standalone_sales_adjustment_1,0) + nvl(FY20_oct_ebook_sales_adjustment_1,0) + nvl(FY20_notspec_CU_sales_allocation_1,0)) as Total_Net_sales_fy20,
             (nvl(FY17_custom_print_core_sales,0)+nvl(FY17_print_core_sales,0)+nvl(FY17_print_other_sales,0)+nvl(FY17_custom_print_other_sales,0)+nvl(FY17_ebook_sales,0)+nvl(FY17_other_digital_standalone_sales,0)+nvl(FY17_other_digital_bundle_sales,0)+nvl(FY17_WA_print_sales_adjustment_1,0) + nvl(FY17_oct_ebook_sales_adjustment_1,0)) as Total_print_net_sales_fy17,
             (nvl(FY18_custom_print_core_sales,0)+nvl(FY18_print_core_sales,0)+nvl(FY18_print_other_sales,0)+nvl(FY18_custom_print_other_sales,0)+nvl(FY18_ebook_sales,0)+nvl(FY18_other_digital_standalone_sales,0)+nvl(FY18_other_digital_bundle_sales,0) + nvl(FY18_oct_ebook_sales_adjustment_1,0)) as Total_print_net_sales_fy18,
             (nvl(FY19_custom_print_core_sales,0)+nvl(FY19_print_core_sales,0)+nvl(FY19_print_other_sales,0)+nvl(FY19_custom_print_other_sales,0)+nvl(FY19_ebook_sales,0)+nvl(FY19_other_digital_standalone_sales,0)+nvl(FY19_other_digital_bundle_sales,0) + nvl(FY19_oct_ebook_sales_adjustment_1,0)) as Total_print_net_sales_fy19,
             (nvl(FY20_custom_print_core_sales,0)+nvl(FY20_print_core_sales,0)+nvl(FY20_print_other_sales,0)+nvl(FY20_custom_print_other_sales,0)+nvl(FY20_ebook_sales,0)+nvl(FY20_other_digital_standalone_sales,0)+nvl(FY20_other_digital_bundle_sales,0) + nvl(FY20_oct_ebook_sales_adjustment_1,0)) as Total_print_net_sales_fy20,
             (nvl(FY17_custom_print_core_units,0)+nvl(FY17_print_core_units,0)+nvl(FY17_print_other_units,0)+nvl(FY17_custom_print_other_units,0)+nvl(FY17_ebook_units,0)+nvl(FY17_other_digital_standalone_units,0)+nvl(FY17_other_digital_bundle_units,0)+nvl(FY17_WA_print_units_adjustment_1,0) + nvl(FY17_oct_ebook_units_adjustment_1,0)) as Total_Print_net_units_fy17,
             (nvl(FY18_custom_print_core_units,0)+nvl(FY18_print_core_units,0)+nvl(FY18_print_other_units,0)+nvl(FY18_custom_print_other_units,0)+nvl(FY18_ebook_units,0)+nvl(FY18_other_digital_standalone_units,0)+nvl(FY18_other_digital_bundle_units,0) + nvl(FY18_oct_ebook_units_adjustment_1,0)) as Total_Print_net_units_fy18,
             (nvl(FY19_custom_print_core_units,0)+nvl(FY19_print_core_units,0)+nvl(FY19_print_other_units,0)+nvl(FY19_custom_print_other_units,0)+nvl(FY19_ebook_units,0)+nvl(FY19_other_digital_standalone_units,0)+nvl(FY19_other_digital_bundle_units,0) + nvl(FY19_oct_ebook_units_adjustment_1,0)) as Total_Print_net_units_fy19,
             (nvl(FY20_custom_print_core_units,0)+nvl(FY20_print_core_units,0)+nvl(FY20_print_other_units,0)+nvl(FY20_custom_print_other_units,0)+nvl(FY20_ebook_units,0)+nvl(FY20_other_digital_standalone_units,0)+nvl(FY20_other_digital_bundle_units,0) + nvl(FY20_oct_ebook_units_adjustment_1,0)) as Total_Print_net_units_fy20,
             (nvl(FY17_core_digital_standalone_units,0)+nvl(FY17_core_digital_bundle_units,0)+nvl(FY17_LLF_bundle_units,0)+nvl(FY17_WA_cd_units_adjustment_1,0)+nvl(FY17_quia_cd_units_adjustment_1,0)) as Total_core_digital_Ex_CU_Net_Units_fy17,
             (nvl(FY18_core_digital_standalone_units,0)+nvl(FY18_core_digital_bundle_units,0)+nvl(FY18_LLF_bundle_units,0)+nvl(FY18_WA_cd_units_adjustment_1,0)+nvl(FY18_quia_cd_units_adjustment_1,0)) as Total_core_digital_Ex_CU_Net_Units_fy18,
             (nvl(FY19_core_digital_standalone_units,0)+nvl(FY19_core_digital_bundle_units,0)+nvl(FY19_LLF_bundle_units,0)+nvl(FY19_quia_cd_units_adjustment_1,0)+nvl(FY19_unactivated_cu_units_adjustment_1,0) + nvl(FY19_api_cd_standalone_units_adjustment_1,0)) as Total_core_digital_Ex_CU_Net_Units_fy19,
             (nvl(FY20_core_digital_standalone_units,0)+nvl(FY20_core_digital_bundle_units,0)+nvl(FY20_LLF_bundle_units,0)+nvl(FY20_api_cd_standalone_units_adjustment_1,0)+nvl(FY20_unactivated_cu_units_adjustment_1,0)) as Total_core_digital_Ex_CU_Net_Units_fy20,
             (nvl(FY19_core_digital_standalone_units,0)+nvl(FY19_core_digital_bundle_units,0)+nvl(FY19_LLF_bundle_units,0)+nvl(FY19_quia_cd_units_adjustment_1,0) + nvl(FY19_api_cd_standalone_units_adjustment_1,0)) as Shipped_cd_ex_unactivated_CU_net_units_fy19,
             (nvl(FY20_core_digital_standalone_units,0)+nvl(FY20_core_digital_bundle_units,0)+nvl(FY20_LLF_bundle_units,0)+nvl(FY20_api_cd_standalone_units_adjustment_1,0)) as Shipped_cd_ex_unactivated_CU_net_units_fy20,
             (nvl(FY17_core_digital_standalone_units,0)+nvl(FY17_core_digital_bundle_units,0)+nvl(FY17_LLF_bundle_units,0)+nvl(FY17_cu_units,0)+nvl(FY17_WA_cd_units_adjustment_1,0)+nvl(FY17_quia_cd_units_adjustment_1,0)) as Total_Core_Digital_CU_Net_Units_fy17,
             (nvl(FY18_core_digital_standalone_units,0)+nvl(FY18_core_digital_bundle_units,0)+nvl(FY18_LLF_bundle_units,0)+nvl(FY18_cu_units,0)+nvl(FY18_WA_cd_units_adjustment_1,0)+nvl(FY18_quia_cd_units_adjustment_1,0)) as Total_Core_Digital_CU_Net_Units_fy18,
             (nvl(FY19_core_digital_standalone_units,0)+nvl(FY19_core_digital_bundle_units,0)+nvl(FY19_LLF_bundle_units,0)+nvl(FY19_cu_units,0)+nvl(FY19_quia_cd_units_adjustment_1,0)+nvl(FY19_unactivated_cu_units_adjustment_1,0) + nvl(FY19_api_cd_standalone_units_adjustment_1,0) + nvl(FY19_notspec_CU_units_allocation_1,0)) as Total_Core_Digital_CU_Net_Units_fy19,
             (nvl(FY20_core_digital_standalone_units,0)+nvl(FY20_core_digital_bundle_units,0)+nvl(FY20_LLF_bundle_units,0)+nvl(FY20_cu_units,0)+nvl(FY20_API_CU_units_allocation_1,0)+nvl(FY20_api_cd_standalone_units_adjustment_1,0)+nvl(FY20_unactivated_cu_units_adjustment_1,0) + nvl(FY20_notspec_CU_units_allocation_1,0)) as Total_Core_Digital_CU_Net_Units_fy20,
             coalesce(act_fy17_primary_platform,'No Activations') as FY17_primary_platform,
             coalesce(act_fy18_primary_platform,'No Activations') as FY18_primary_platform,
             coalesce(act_fy19_primary_platform,'No Activations') as FY19_primary_platform,
             coalesce(eb.FY17_ebook_units_byCU,0),
             coalesce(eb.FY18_ebook_units_byCU,0),
             coalesce(eb.FY19_ebook_units_byCU,0),
             coalesce(eb.FY20_ebook_units_byCU,0),
             coalesce(total_CD_actv_exCU_FY17,0) as total_CD_actv_exCU_FY17,
             coalesce(total_CD_actv_exCU_FY18,0) as total_CD_actv_exCU_FY18,
             coalesce(total_CD_actv_exCU_FY19,0) as total_CD_actv_exCU_FY19,
             coalesce(total_CD_actv_exCU_FY20,0) as total_CD_actv_exCU_FY20,
             coalesce(total_CD_actv_withCU_FY17,0) as total_CD_actv_withCU_FY17,
             coalesce(total_CD_actv_withCU_FY18,0) as total_CD_actv_withCU_FY18,
             coalesce(total_CD_actv_withCU_FY19,0) as total_CD_actv_withCU_FY19,
             coalesce(total_CD_actv_withCU_FY20,0) as total_CD_actv_withCU_FY20,
             coalesce(total_CD_actv_FY17,0) as total_CD_actv_FY17,
             coalesce(total_CD_actv_FY18,0) as total_CD_actv_FY18,
             coalesce(total_CD_actv_FY19,0) as total_CD_actv_FY19,
             coalesce(total_CD_actv_FY20,0) as total_CD_actv_FY20,
             coalesce(ia.FY_17_IA_ADOPTION_Y_N_,'N') AS FY_17_IA,
             coalesce(ia.FY_18_IA_ADOPTION_Y_N_,'N') AS FY_18_IA,
             coalesce(ia.FY_19_IA_ADOPTION_Y_N_,'N') AS FY_19_IA,
             coalesce(ia.FY_20_IA_ADOPTION_Y_N_,'N') AS FY_20_IA,
             coalesce(cui.FY_19_CU_I_INSTITUTION_Y_N_,'N') AS FY_19_CUI,
             coalesce(cui.FY_20_CU_I_INSTITUTION_Y_N_,'N') AS FY_20_CUI,

       CASE WHEN ia.FY_20_IA_ADOPTION_Y_N_ = 'Y' THEN
       CASE WHEN coalesce(total_CD_actv_FY20,0) > (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy20,0)) THEN coalesce(total_CD_actv_FY20,0)
            WHEN coalesce(total_CD_actv_FY20,0) <= (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy20,0)) THEN (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy20,0))
            END
        ELSE (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy20,0))
        END AS FY20_unadjusted_core_digital_consumed_units,
       CASE WHEN ia.FY_19_IA_ADOPTION_Y_N_ = 'Y' THEN
       CASE WHEN coalesce(total_CD_actv_FY19,0) > (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy19,0)) THEN coalesce(total_CD_actv_FY19,0)
            WHEN coalesce(total_CD_actv_FY19,0) <= (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy19,0)) THEN (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy19,0))
            END
        ELSE (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(Shipped_cd_ex_unactivated_CU_net_units_fy19,0))
        END AS FY19_unadjusted_core_digital_consumed_units,
        CASE WHEN ia.FY_20_IA_ADOPTION_Y_N_ = 'Y' THEN
        CASE WHEN coalesce(total_CD_actv_FY20,0) > (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(total_core_digital_ex_cu_net_units_fy20,0)) THEN coalesce(total_CD_actv_FY20,0)
             WHEN coalesce(total_CD_actv_FY20,0) <= (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(total_core_digital_ex_cu_net_units_fy20,0)) THEN (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(total_core_digital_ex_cu_net_units_fy20,0))
             END
         ELSE (coalesce(total_CD_actv_withCU_FY20,0) + coalesce(total_core_digital_ex_cu_net_units_fy20,0))
         END AS FY20_total_core_digital_consumed_units,
        CASE WHEN ia.FY_19_IA_ADOPTION_Y_N_ = 'Y' THEN
        CASE WHEN coalesce(total_CD_actv_FY19,0) > (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0)) THEN coalesce(total_CD_actv_FY19,0)
             WHEN coalesce(total_CD_actv_FY19,0) <= (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0)) THEN (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0))
             END
         ELSE (coalesce(total_CD_actv_withCU_FY19,0) + coalesce(total_core_digital_ex_cu_net_units_fy19,0))
         END AS FY19_total_core_digital_consumed_units,
        CASE WHEN ia.FY_18_IA_ADOPTION_Y_N_ = 'Y' THEN
        (CASE WHEN (coalesce(total_CD_actv_FY18,0) > (coalesce(total_core_digital_ex_cu_net_units_fy18,0))) THEN coalesce(total_CD_actv_FY18,0)
             WHEN (coalesce(total_CD_actv_FY18,0) <= (coalesce(total_core_digital_ex_cu_net_units_fy18,0))) THEN coalesce(total_core_digital_ex_cu_net_units_fy18,0)
             END)
         ELSE coalesce(total_core_digital_ex_cu_net_units_fy18,0)
         END AS FY18_total_core_digital_consumed_units,
        CASE WHEN ia.FY_17_IA_ADOPTION_Y_N_ = 'Y' THEN
        (CASE WHEN (coalesce(total_CD_actv_FY17,0) > (coalesce(Total_core_digital_Ex_CU_Net_Units_fy17,0))) THEN coalesce(total_CD_actv_FY17,0)
             WHEN (coalesce(total_CD_actv_FY17,0) <= (coalesce(Total_core_digital_Ex_CU_Net_Units_fy17,0))) THEN coalesce(Total_core_digital_Ex_CU_Net_Units_fy17,0)
             END)
         ELSE coalesce(Total_core_digital_Ex_CU_Net_Units_fy17,0)
         END AS FY17_total_core_digital_consumed_units,
      CASE WHEN ((coalesce(FY17_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY17,0) = 0)) THEN 0 ELSE (total_CD_actv_FY17/FY17_total_core_digital_consumed_units) END as actv_rate_fy17,
      CASE WHEN ((coalesce(FY18_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY18,0) = 0)) THEN 0 ELSE (total_CD_actv_FY18/FY18_total_core_digital_consumed_units) END as actv_rate_fy18,
      CASE WHEN ((coalesce(FY19_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY19,0) = 0)) THEN 0 ELSE (total_CD_actv_FY19/FY19_total_core_digital_consumed_units) END as actv_rate_fy19,
      CASE WHEN ((coalesce(FY20_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY20,0) = 0)) THEN 0 ELSE (total_CD_actv_FY20/FY20_total_core_digital_consumed_units) END as actv_rate_fy20,
      CASE WHEN (nvl(total_CD_actv_FY17,0) = 0 AND nvl(total_CD_actv_FY18,0) = 0) THEN 0
           WHEN (nvl(total_CD_actv_FY17,0) = 0 AND nvl(total_CD_actv_FY18,0) > 0) THEN 1
           WHEN (nvl(total_CD_actv_FY17,0) > 0 AND nvl(total_CD_actv_FY18,0) = 0) THEN -1
           ELSE nvl((nvl(total_CD_actv_FY18,0)-nvl(total_CD_actv_FY17,0))/total_cd_actv_fy17,0)
           END as actv_growth_rate_fy18,
      CASE WHEN (nvl(total_CD_actv_FY18,0) = 0 AND nvl(total_CD_actv_FY19,0) = 0) THEN 0
           WHEN (nvl(total_CD_actv_FY18,0) = 0 AND nvl(total_CD_actv_FY19,0) > 0) THEN 1
           WHEN (nvl(total_CD_actv_FY18,0) > 0 AND nvl(total_CD_actv_FY19,0) = 0) THEN -1
           ELSE nvl((nvl(total_CD_actv_FY19,0)-nvl(total_CD_actv_FY18,0))/total_cd_actv_fy18,0)
           END as actv_growth_rate_fy19,
      CASE WHEN (nvl(total_CD_actv_FY19,0) = 0 AND nvl(total_CD_actv_FY20,0) = 0) THEN 0
           WHEN (nvl(total_CD_actv_FY19,0) = 0 AND nvl(total_CD_actv_FY20,0) > 0) THEN 1
           WHEN (nvl(total_CD_actv_FY19,0) > 0 AND nvl(total_CD_actv_FY20,0) = 0) THEN -1
           ELSE nvl((nvl(total_CD_actv_FY20,0)-nvl(total_CD_actv_FY19,0))/total_cd_actv_fy19,0)
           END as actv_growth_rate_fy20,
      CASE WHEN to_number((coalesce(TOTAL_PRINT_NET_UNITS_FY20,0) + coalesce(FY20_total_core_digital_consumed_units,0))) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY20_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY20,0) + coalesce(FY20_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy20,
      CASE WHEN to_number((coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0))) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY19_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy19,
       CASE WHEN to_number((coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + coalesce(FY18_total_core_digital_consumed_units,0))) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY18_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + coalesce(FY18_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy18,
       CASE WHEN to_number((coalesce(TOTAL_PRINT_NET_UNITS_FY17,0) + coalesce(FY17_total_core_digital_consumed_units,0))) < 5 THEN 'Non Adoption'
            WHEN (coalesce(FY17_total_core_digital_consumed_units,0)/(coalesce(TOTAL_PRINT_NET_UNITS_FY17,0) + coalesce(FY17_total_core_digital_consumed_units,0))) > 0.5 THEN 'Digital'
          ELSE 'Print' END AS Adoption_type_Fy17,
        coalesce(TOTAL_PRINT_NET_UNITS_FY20,0) + coalesce(FY20_total_core_digital_consumed_units,0) AS total_net_units_fy20,
        coalesce(TOTAL_PRINT_NET_UNITS_FY19,0) + coalesce(FY19_total_core_digital_consumed_units,0) AS total_net_units_fy19,
        Coalesce(TOTAL_PRINT_NET_UNITS_FY18,0) + Coalesce(FY18_total_core_digital_consumed_units,0) AS total_net_units_fy18,
        Coalesce(TOTAL_PRINT_NET_UNITS_FY17,0) + Coalesce(FY17_total_core_digital_consumed_units,0) AS total_net_units_fy17,
        coalesce(total_net_units_fy18,0) - coalesce(total_net_units_fy17,0) as net_unit_change_fy18,
        coalesce(total_net_units_fy19,0) - coalesce(total_net_units_fy18,0) as net_unit_change_fy19,
        coalesce(total_net_units_fy20,0) - coalesce(total_net_units_fy19,0) as net_unit_change_fy20,
        CASE WHEN Coalesce(total_net_units_fy20,0) >= 0.5 AND Coalesce(total_net_units_fy19,0) >= 0.5
          THEN
            CASE WHEN total_net_units_fy20/total_net_units_fy19 >= 10 THEN '10x larger'
                WHEN total_net_units_fy20/total_net_units_fy19 > 1 THEN 'larger not 10x'
                WHEN total_net_units_fy20/total_net_units_fy19 = 1 THEN 'equal'
                WHEN total_net_units_fy20/total_net_units_fy19 <= 0.1 THEN '10x smaller'
                WHEN total_net_units_fy20/total_net_units_fy19 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy20,0) < 0.5 AND Coalesce(total_net_units_fy19,0) >= 0.5
          THEN
            CASE WHEN 0.5/Coalesce(total_net_units_fy19,0) >= 10 THEN '10x larger'
                WHEN 0.5/Coalesce(total_net_units_fy19,0) > 1 THEN 'larger not 10x'
                WHEN 0.5/Coalesce(total_net_units_fy19,0) = 1 THEN 'equal'
                WHEN 0.5/Coalesce(total_net_units_fy19,0) <= 0.1 THEN '10x smaller'
                WHEN 0.5/Coalesce(total_net_units_fy19,0) < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy20,0) >= 0.5 AND Coalesce(total_net_units_fy19,0) < 0.5
          THEN
            CASE WHEN Coalesce(total_net_units_fy20,0)/0.5 >= 10 THEN '10x larger'
                WHEN Coalesce(total_net_units_fy20,0)/0.5 > 1 THEN 'larger not 10x'
                WHEN Coalesce(total_net_units_fy20,0)/0.5 = 1 THEN 'equal'
                WHEN Coalesce(total_net_units_fy20,0)/0.5 <= 0.1 THEN '10x smaller'
                WHEN Coalesce(total_net_units_fy20,0)/0.5 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
       WHEN Coalesce(total_net_units_fy20,0) < 0.5 AND Coalesce(total_net_units_fy19,0) < 0.5
          THEN
          CASE WHEN 1 = 1 THEN 'equal'
        END
      ELSE 'error'
        END AS FY19_FY20_Adoption_Unit_Gain_Loss,
        CASE WHEN Coalesce(total_net_units_fy19,0) >= 0.5 AND Coalesce(total_net_units_fy18,0) >= 0.5
          THEN
            CASE WHEN total_net_units_fy19/total_net_units_fy18 >= 10 THEN '10x larger'
                WHEN total_net_units_fy19/total_net_units_fy18 > 1 THEN 'larger not 10x'
                WHEN total_net_units_fy19/total_net_units_fy18 = 1 THEN 'equal'
                WHEN total_net_units_fy19/total_net_units_fy18 <= 0.1 THEN '10x smaller'
                WHEN total_net_units_fy19/total_net_units_fy18 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy19,0) < 0.5 AND Coalesce(total_net_units_fy18,0) >= 0.5
          THEN
            CASE WHEN 0.5/Coalesce(total_net_units_fy18,0) >= 10 THEN '10x larger'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) > 1 THEN 'larger not 10x'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) = 1 THEN 'equal'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) <= 0.1 THEN '10x smaller'
                WHEN 0.5/Coalesce(total_net_units_fy18,0) < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy19,0) >= 0.5 AND Coalesce(total_net_units_fy18,0) < 0.5
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
        CASE WHEN Coalesce(total_net_units_fy18,0) >= 0.5 AND Coalesce(total_net_units_fy17,0) >= 0.5
          THEN
            CASE WHEN total_net_units_fy18/total_net_units_fy17 >= 10 THEN '10x larger'
                WHEN total_net_units_fy18/total_net_units_fy17 > 1 THEN 'larger not 10x'
                WHEN total_net_units_fy18/total_net_units_fy17 = 1 THEN 'equal'
                WHEN total_net_units_fy18/total_net_units_fy17 <= 0.1 THEN '10x smaller'
                WHEN total_net_units_fy18/total_net_units_fy17 < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy18,0) < 0.5 AND Coalesce(total_net_units_fy17,0) >= 0.5
          THEN
            CASE WHEN 0.5/Coalesce(total_net_units_fy17,0) >= 10 THEN '10x larger'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) > 1 THEN 'larger not 10x'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) = 1 THEN 'equal'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) <= 0.1 THEN '10x smaller'
                WHEN 0.5/Coalesce(total_net_units_fy17,0) < 1 THEN 'smaller not 10x'
              ELSE 'error'
          END
        WHEN Coalesce(total_net_units_fy18,0) >= 0.5 AND Coalesce(total_net_units_fy17,0) < 0.5
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
        Concat(Concat(concat(concat(Adoption_type_Fy18,'->'),Adoption_type_Fy19),' | '),FY18_FY19_Adoption_Unit_Gain_Loss) AS FY18_FY19_adoptions_transition_type_2,
        Concat(Concat(concat(concat(Adoption_type_Fy19,'->'),Adoption_type_Fy20),' | '),FY19_FY20_Adoption_Unit_Gain_Loss) AS FY19_FY20_adoptions_transition_type_2







      from    sales sal
              FULL OUTER JOIN ${af_activation_adoptions.SQL_TABLE_NAME} act
              ON act.act_adoption_key = sal.sales_adoption_key
              LEFT JOIN ${af_ebook_units_adoptions.SQL_TABLE_NAME} AS eb
              ON coalesce(sal.sales_adoption_key, act.act_adoption_key) = eb.adoption_key
              LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY17_20_IA_ADOPTIONS ia
              ON ia.adoption_key = coalesce(act.act_old_adoption_key,sal.sales_old_adoption_key)
              LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY19_20_CUI_INSTITUTIONS cui
              ON cui.institution_name = coalesce(sal.sales_institution_nm,act.act_institution_nm)
              --JOINED ON ACTIVATIONS BECAUSE THESE ALLOCATIONS ARE OFF OF ACTIVATIONS TO UNITS GAP
              LEFT JOIN wa_allocation wa
              ON wa.adoption_key = act.act_adoption_key
              LEFT JOIN quia_allocation quia
              on quia.adoption_key = act.act_adoption_key
              LEFT JOIN standalone_api_allocation_19 stand19
              on stand19.adoption_key = act.act_adoption_key
              LEFT JOIN standalone_api_allocation_20 stand20
              on stand20.adoption_key = act.act_adoption_key
              --JOINED ON ACTIVATIONS BECAUSE ALLOCATIONS ARE OFF OF ACTIVATIONS WITHIN CU
              LEFT JOIN cu_api_allocation cu
              on cu.act_adoption_key = sal.sales_adoption_key
              LEFT JOIN unactivated_cu_allocation cu2
              on cu2.adoption_key = act.act_adoption_key
              --JOINED ON SALES BECAUSE ALLOCATIONS ARE OFF OF SHIPPED EBOOK UNITS
              LEFT JOIN oct_ebook_allocation_1 ebook
              on ebook.adoption_key = sal.sales_adoption_key
              LEFT JOIN not_spec_allocation_1 notspec
              on notspec.not_spec_adoption_key = sal.sales_adoption_key
      ) SELECT s.*,
              adp_tr_20.adoption_transition as FY19_FY20_Adoption_Transition,
              adp_tr_19.adoption_transition as FY18_FY19_Adoption_Transition,
              adp_tr_18.adoption_transition as FY17_FY18_Adoption_Transition,
              concat(concat(FY17_FY18_Adoption_Transition,' | '), FY18_FY19_Adoption_Transition) as FY17_18_FY18_19_Transition,
              concat(concat(FY18_FY19_Adoption_Transition,' | '), FY19_FY20_Adoption_Transition) as FY18_19_FY19_20_Transition,
              coalesce(star.FY_19_star_rating,'1') as FY19_star_rating,
              coalesce(star.FY_20_star_rating,'1') as FY20_star_rating,
              coalesce(section.FY_17_sections_created,0) as FY17_sections_created_1,
              coalesce(section.FY_18_sections_created,0) as FY18_sections_created_1,
              coalesce(section.FY_19_sections_created,0) as FY19_sections_created_1,
              coalesce(section.FY_20_sections_created,0) as FY20_sections_created_1,
              coalesce(section.FY_18_sections_created_bucket,'Data Unavailable') as FY18_sections_created_bucket_1,
              coalesce(section.FY_19_sections_created_bucket,'Data Unavailable') as FY19_sections_created_bucket_1,
              coalesce(section.FY_20_sections_created_bucket,'Data Unavailable') as FY20_sections_created_bucket_1,
              coalesce(section.FY_17_total_enrollments,0) as FY17_total_enrollments_1,
              coalesce(section.FY_18_total_enrollments,0) as FY18_total_enrollments_1,
              coalesce(section.FY_19_total_enrollments,0) as FY19_total_enrollments_1,
              coalesce(section.FY_20_total_enrollments,0) as FY20_total_enrollments_1,
              coalesce(section.FY_18_units_per_section,0) as FY18_units_per_section_1,
              coalesce(section.FY_19_units_per_section,0) as FY19_units_per_section_1,
              coalesce(section.FY_20_units_per_section,0) as FY20_units_per_section_1,
              coalesce(FY_18_section_increase_bucket,'Non-Adoption') as FY18_section_increase_bucket_1,
              coalesce(FY_19_section_increase_bucket,'Non-Adoption') as FY19_section_increase_bucket_1,
              coalesce(FY_20_section_increase_bucket,'Non-Adoption') as FY20_section_increase_bucket_1,
              coalesce(FY_17_enrollments_per_section,0) as FY17_enrollments_per_section_1,
              coalesce(FY_18_enrollments_per_section,0) as FY18_enrollments_per_section_1,
              coalesce(FY_19_enrollments_per_section,0) as FY19_enrollments_per_section_1,
              coalesce(FY_20_enrollments_per_section,0) as FY20_enrollments_per_section_1,
              coalesce(FY_18_units_per_section_bucket,'0-5') as FY18_units_per_section_bucket_1,
              coalesce(FY_19_units_per_section_bucket,'0-5') as FY19_units_per_section_bucket_1,
              coalesce(FY_20_units_per_section_bucket,'0-5') as FY20_units_per_section_bucket_1,
              coalesce(FY_18_fall_forecast_digital_units,0) as FY18_fall_forecast_digital_units,
              coalesce(FY_19_fall_forecast_digital_units,0) as FY19_fall_forecast_digital_units,
              coalesce(FY_20_fall_forecast_digital_units,0) as FY20_fall_forecast_digital_units,
              coalesce(FY_20_fall_adjusted_forecast_digital_units,0) as FY20_fall_adjusted_forecast_digital_units,
              coalesce(channel.FY_20_channel_partner,'Unknown') AS FY20_channel_partner,
              case when (coalesce(FY18_fall_forecast_digital_units,0) - coalesce(FY18_total_core_digital_consumed_units,0)) < 0 then 0
                else (coalesce(FY18_fall_forecast_digital_units,0) - coalesce(FY18_total_core_digital_consumed_units,0)) end
                as FY18_forecast_actual_digital_gap,
              case when (coalesce(FY19_fall_forecast_digital_units,0) - coalesce(FY19_total_core_digital_consumed_units,0)) < 0 then 0
                else (coalesce(FY19_fall_forecast_digital_units,0) - coalesce(FY19_total_core_digital_consumed_units,0)) end
                as FY19_forecast_actual_digital_gap,
              case when (coalesce(FY20_fall_forecast_digital_units,0) - coalesce(FY20_total_core_digital_consumed_units,0)) < 0 then 0
                else (coalesce(FY20_fall_forecast_digital_units,0) - coalesce(FY20_total_core_digital_consumed_units,0)) end
                as FY20_forecast_actual_digital_gap,
              case when (coalesce(FY20_fall_adjusted_forecast_digital_units,0) - coalesce(FY20_total_core_digital_consumed_units,0)) < 0 then 0
                else (coalesce(FY20_fall_adjusted_forecast_digital_units,0) - coalesce(FY20_total_core_digital_consumed_units,0)) end
                as FY20_adjusted_forecast_actual_digital_gap,
              case when coalesce(course.core_course,'N') = 'No' THEN 'N'
                   when coalesce(course.core_course,'N') = 'Yes' THEN 'Y'
                  ELSE 'N'
              END as core_course_flag,
              case when coalesce(course.major_course,'N') = 'No' THEN 'N'
                   when coalesce(course.major_course,'N') = 'Yes' THEN 'Y'
                  ELSE 'N'
              END as major_course_flag,
              case when (coalesce(s.total_net_units_fy17,0) > 200 AND coalesce(core_course_flag,'N') = 'Y') THEN 'Y'
                  ELSE 'N'
              END as FY17_anchor_course_flag,
              case when (coalesce(s.total_net_units_fy18,0) > 200 AND coalesce(core_course_flag,'N') = 'Y') THEN 'Y'
                  ELSE 'N'
              END as FY18_anchor_course_flag,
              case when (coalesce(s.total_net_units_fy19,0) > 200 AND coalesce(core_course_flag,'N') = 'Y') THEN 'Y'
                  ELSE 'N'
              END as FY19_anchor_course_flag,
              case when (coalesce(s.total_net_units_fy20,0) > 200 AND coalesce(core_course_flag,'N') = 'Y') THEN 'Y'
                  ELSE 'N'
              END as FY20_anchor_course_flag
        FROM sales_adoption s
        LEFT JOIN UPLOADS.CU.ADOPTION_TRANSITIONS_SALESORDERS adp_tr_20
              ON lower(adp_tr_20.TYPE_2_ADOPTION_TRANSITION) = lower(s.FY19_FY20_adoptions_transition_type_2)
        LEFT JOIN UPLOADS.CU.ADOPTION_TRANSITIONS_SALESORDERS adp_tr_19
              ON lower(adp_tr_19.TYPE_2_ADOPTION_TRANSITION) = lower(s.FY18_FY19_adoptions_transition_type_2)
        LEFT JOIN UPLOADS.CU.ADOPTION_TRANSITIONS_SALESORDERS adp_tr_18
              ON lower(adp_tr_18.TYPE_2_ADOPTION_TRANSITION) = lower(s.FY17_FY18_adoptions_transition_type_2)
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.STAR_RATING_LOOKUP star
              ON upper(star.institution_name) = upper(s.institution_nm)
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.MAJOR_CORE_COURSES_LOOKUP course
              ON upper(course.course_code_description) = upper(s.course_code_description)
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.SECTION_LEVEL_DATA section
              on section.adoption_key = s.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.FY18_20_FORECAST_UNITS forecast
              on forecast.adoption_key = s.adoption_key
        LEFT JOIN STRATEGY.ADOPTION_PIVOT.CHANNEL_PARTNER_LOOKUP channel
              on channel.institution_name = s.sales_institution_nm

       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: FY_17_IA {
    label: "FY17 Inclusive Access Adoption (Y/N)"
  }
  dimension: FY_18_IA {
    label: "FY18 Inclusive Access Adoption (Y/N)"
  }
  dimension: FY_19_IA {
    label: "FY19 Inclusive Access Adoption (Y/N)"
  }

  dimension: FY_20_IA {
    label: "FY20 Inclusive Access Adoption (Y/N)"
  }

  dimension: FY_19_CUI {
    label: "FY19 CU-I Institution (Y/N)"
  }

  dimension: FY_20_CUI {
    label: "FY20 CU-I Institution (Y/N)"
  }

  dimension: old_adoption_key {}
  dimension: purchase_method {}
  dimension: institution_nm {
    label: "Institution Name"
  }
  dimension: state_cd {}
  dimension: course_code_description {}
  dimension: pub_series_de {}
  dimension: FY17_primary_platform {
    label: "FY17 Primary Platform"
  }
  dimension: FY18_primary_platform {
    label: "FY18 Primary Platform"
  }
  dimension: FY19_primary_platform {
    label: "FY19 Primary Platform"
  }

  dimension: FY20_primary_platform {
    label: "FY20 Primary Platform"
  }

  dimension: FY19_star_rating {
    label: "FY19 Star Rating"
  }

  dimension: fy20_star_rating {
    label: "FY20 Star Rating"
  }

  dimension: core_course_flag {
    label: "Core Course Flag"
  }

  dimension: major_course_flag {
    label: "Major Course Flag"
  }

  dimension: FY17_anchor_course_flag {
    label: "FY17 Anchor Course Flag"
  }

  dimension: FY18_anchor_course_flag {
    label: "FY18 Anchor Course Flag"
  }

  dimension: FY19_anchor_course_flag {
    label: "FY19 Anchor Course Flag"
  }

  dimension: FY20_anchor_course_flag {
    label: "FY20 Anchor Course Flag"
  }



 dimension: FY17_sections_created_1 {
   label: "FY17 Sections Created"
 }

  dimension: FY18_sections_created_1 {
    label: "FY18 Sections Created"
  }

  dimension: FY19_sections_created_1 {
    label: "FY19 Sections Created"
  }

  dimension: FY20_sections_created_1 {
    label: "FY20 Sections Created"
  }

  measure: sum_FY17_sections_created_1 {
    label: "FY17 Sections Created"
    type: sum
    sql: ${TABLE}."FY17_SECTIONS_CREATED_1";;
  }

  measure: sum_FY18_sections_created_1 {
    label: "FY18 Sections Created"
    type: sum
    sql: ${TABLE}."FY18_SECTIONS_CREATED_1";;
  }

  measure: sum_FY19_sections_created_1 {
    label: "FY19 Sections Created"
    type: sum
    sql: ${TABLE}."FY19_SECTIONS_CREATED_1";;
  }

  measure: sum_FY20_sections_created_1 {
    label: "FY20 Sections Created"
    type: sum
    sql: ${TABLE}."FY20_SECTIONS_CREATED_1";;
  }

  dimension: FY18_sections_created_bucket_1 {
    label: "FY18 Sections Created Bucket"
  }

  dimension: FY19_sections_created_bucket_1 {
    label: "FY19 Sections Created Bucket"
  }

  dimension: FY20_sections_created_bucket_1 {
    label: "FY20 Sections Created Bucket"
  }

  dimension: FY17_total_enrollments_1 {
    label: "FY17 Total Enrollments"
  }

  dimension: FY18_total_enrollments_1 {
    label: "FY18 Total Enrollments"
  }

  dimension: FY19_total_enrollments_1 {
    label: "FY19 Total Enrollments"
  }

  dimension: FY20_total_enrollments_1 {
    label: "FY20 Total Enrollments"
  }

  measure: sum_FY17_total_enrollments_1 {
    label: "FY17 Total Enrollments"
    type: sum
    sql: ${TABLE}."FY17_TOTAL_ENROLLMENTS_1";;
  }

  measure: sum_FY18_total_enrollments_1 {
    label: "FY18 Total Enrollments"
    type: sum
    sql: ${TABLE}."FY18_TOTAL_ENROLLMENTS_1";;
  }


  measure: sum_FY19_total_enrollments_1 {
    label: "FY19 Total Enrollments"
    type: sum
    sql: ${TABLE}."FY19_TOTAL_ENROLLMENTS_1";;
  }


  measure: sum_FY20_total_enrollments_1 {
    label: "FY20 Total Enrollments"
    type: sum
    sql: ${TABLE}."FY20_TOTAL_ENROLLMENTS_1";;
  }

  dimension: FY18_units_per_section_1 {
    label: "FY18 Units per Section"
  }

  dimension: FY19_units_per_section_1 {
    label: "FY19 Units per Section"
  }

  dimension: FY20_units_per_section_1 {
    label: "FY20 Units per Section"
  }

  dimension: FY18_section_increase_bucket_1 {
    label: "FY18 Section Increase Bucket"
  }

  dimension: FY19_section_increase_bucket_1 {
    label: "FY19 Section Increase Bucket"
  }

  dimension: FY20_section_increase_bucket_1 {
    label: "FY20 Section Increase Bucket"
  }

  dimension: FY17_enrollments_per_section_1 {
    label: "FY17 Enrollments per Section"
  }

  dimension: FY18_enrollments_per_section_1 {
    label: "FY18 Enrollments per Section"
  }

  dimension: FY19_enrollments_per_section_1 {
    label: "FY19 Enrollments per Section"
  }

  dimension: FY20_enrollments_per_section_1 {
    label: "FY20 Enrollments per Section"
  }

  dimension: FY18_units_per_section_bucket_1 {
    label: "FY18 Units per Section Bucket"
  }

  dimension: FY19_units_per_section_bucket_1 {
    label: "FY19 Units per Section Bucket"
  }

  dimension: FY20_units_per_section_bucket_1 {
    label: "FY20 Units per Section Bucket"
  }

  dimension: FY18_fall_forecast_digital_units {
    label: "FY18 Forecasted Digital Units"
  }

  dimension: FY19_fall_forecast_digital_units {
    label: "FY19 Forecasted Digital Units"
  }

  dimension: FY20_fall_forecast_digital_units {
    label: "FY20 Forecasted Digital Units"
  }

  dimension: FY20_fall_adjusted_forecast_digital_units {
    label: "FY20 Adjusted Forecasted Digital Units"
  }

  measure: sum_FY18_fall_forecast_digital_units {
    label: "FY18 Forecasted Digital Units"
    type: sum
    sql: ${TABLE}."FY18_FALL_FORECAST_DIGITAL_UNITS";;
  }

  measure: sum_FY19_fall_forecast_digital_units {
    label: "FY19 Forecasted Digital Units"
    type: sum
    sql: ${TABLE}."FY19_FALL_FORECAST_DIGITAL_UNITS";;
  }

  measure: sum_FY20_fall_forecast_digital_units {
    label: "FY20 Forecasted Digital Units"
    type: sum
    sql: ${TABLE}."FY20_FALL_FORECAST_DIGITAL_UNITS";;
  }

  measure: sum_FY20_fall_adjusted_forecast_digital_units {
    label: "FY20 Adjusted Forecasted Digital Units"
    type: sum
    sql: ${TABLE}."FY20_FALL_FORECAST_DIGITAL_UNITS";;
  }

  dimension: FY18_forecast_actual_digital_gap {
    label: "FY18 Digital Forecast to Actual Gap"
  }

  dimension: FY19_forecast_actual_digital_gap {
    label: "FY19 Digital Forecast to Actual Gap"
  }

  dimension: FY20_forecast_actual_digital_gap {
    label: "FY20 Digital Forecast to Actual Gap"
  }

  dimension: FY20_adjusted_forecast_actual_digital_gap {
    label: "FY20 Adjusted Digital Forecast to Actual Gap"
  }



  measure: sum_FY18_forecast_actual_digital_gap {
    label: "FY18 Digital Forecast to Actual Gap"
    type: sum
    sql: ${TABLE}."FY18_FORECAST_ACTUAL_DIGITAL_GAP";;
  }

  measure: sum_FY19_forecast_actual_digital_gap {
    label: "FY19 Digital Forecast to Actual Gap"
    type: sum
    sql: ${TABLE}."FY19_FORECAST_ACTUAL_DIGITAL_GAP";;
  }

  measure: sum_FY20_forecast_actual_digital_gap {
    label: "FY20 Digital Forecast to Actual Gap"
    type: sum
    sql: ${TABLE}."FY20_FORECAST_ACTUAL_DIGITAL_GAP";;
  }

  measure: sum_FY20_adjusted_forecast_actual_digital_gap {
    label: "FY20 Adjusted Digital Forecast to Actual Gap"
    type: sum
    sql: ${TABLE}."FY20_ADJUSTED_FORECAST_ACTUAL_DIGITAL_GAP";;
  }

  dimension: FY19_notspec_CU_units_allocation_1 {
    label: "FY19 Not Specified CU Units Allocation"
  }

  dimension: FY19_notspec_CU_sales_allocation_1 {
    label: "FY19 Not Specified CU Sales Allocation"
  }

  dimension: FY20_notspec_CU_units_allocation_1 {
    label: "FY20 Not Specified CU Units Allocation"
  }

  dimension: FY20_notspec_CU_sales_allocation_1 {
    label: "FY20 Not Specified CU Sales Allocation"
  }

  measure: sum_FY19_notspec_CU_units_allocation_1 {
    label: "FY19 Not Specified CU Units Allocation"
    type: sum
    sql: ${TABLE}."FY19_NOTSPEC_CU_UNITS_ALLOCATION_1";;
  }

  measure: sum_FY19_notspec_CU_sales_allocation_1 {
    label: "FY19 Not Specified CU Sales Allocation"
    type: sum
    sql: ${TABLE}."FY19_NOTSPEC_CU_SALES_ALLOCATION_1";;
  }

  measure: sum_FY20_notspec_CU_units_allocation_1 {
    label: "FY20 Not Specified CU Units Allocation"
    type: sum
    sql: ${TABLE}."FY20_NOTSPEC_CU_UNITS_ALLOCATION_1";;
  }

  measure: sum_FY20_notspec_CU_sales_allocation_1 {
    label: "FY20 Not Specified CU Sales Allocation"
    type: sum
    sql: ${TABLE}."FY20_NOTSPEC_CU_SALES_ALLOCATION_1";;
  }


  dimension: Adoption_type_Fy17 {
    label: "FY17 Adoption Type"
  }

  dimension: Adoption_type_Fy18 {
    label: "FY18 Adoption Type"
  }
  dimension: Adoption_type_Fy19 {
    label: "FY19 Adoption Type"
  }

  dimension: Adoption_type_Fy20 {
    label: "FY20 Adoption Type"
  }

  dimension: FY20_channel_partner {
    label: "FY20 Channel Partner"
  }

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }

  dimension: FY17_FY18_adoption_transition_type1 {
    label: "FY17->FY18 Adoption Transition Type 1"
    sql: concat(concat(Adoption_type_Fy17,' -> '),Adoption_type_Fy18) ;;
  }

  dimension: FY18_FY19_adoption_transition_type1 {
    label: "FY18->FY19 Adoption Transition Type 1"
    sql: concat(concat(Adoption_type_Fy18,' -> '),Adoption_type_Fy19) ;;
  }

  dimension: FY19_FY20_adoption_transition_type1 {
    label: "FY19->FY20 Adoption Transition Type 1"
    sql: concat(concat(Adoption_type_Fy19,' -> '),Adoption_type_Fy20) ;;
  }

  dimension:FY17_FY18_adoptions_transition_type_2  {
    label: "FY17 -> FY18 Adoption Transition Type 2"
    sql: ${TABLE}."FY17_FY18_ADOPTIONS_TRANSITION_TYPE_2" ;;
  }

  dimension:FY18_FY19_adoptions_transition_type_2  {
    label: "FY18 -> FY19 Adoption Transition Type 2"
    sql: ${TABLE}."FY18_FY19_ADOPTIONS_TRANSITION_TYPE_2" ;;
  }

  dimension:FY19_FY20_adoptions_transition_type_2  {
    label: "FY19 -> FY20 Adoption Transition Type 2"
    sql: ${TABLE}."FY19_FY20_ADOPTIONS_TRANSITION_TYPE_2" ;;
  }

  dimension: FY19_FY20_Adoption_Transition {
    label: "FY19 -> FY20 Adoption Transition"
  }



  dimension: FY18_FY19_Adoption_Transition {
    label: "FY18 -> FY19 Adoption Transition"
  }

  dimension: FY17_FY18_Adoption_Transition {
    label: "FY17 -> FY18 Adoption Transition"
  }

  dimension: FY17_18_FY18_19_Transition {
    label: "FY17 -> FY18 | FY18 -> FY19 Adoption Transition"
  }

  dimension: FY18_19_FY19_20_Transition {
    label: "FY18 -> FY19 | FY19 -> FY20 Adoption Transition"
  }

  dimension: FY17_FY18_Adoption_Unit_Gain_Loss {
    label: "FY17 -> FY18 Adoption Unit Gain/Loss"
  }

  dimension: FY18_FY19_Adoption_Unit_Gain_Loss {
    label: "FY18 -> FY19 Adoption Unit Gain/Loss"
  }

  dimension: FY19_FY20_Adoption_Unit_Gain_Loss {
    label: "FY19 -> FY20 Adoption Unit Gain/Loss"
  }


  dimension: FY17_WA_cd_units_adjustment_1 {
    label: "FY17 WebAssign Core Digital Units Adjustment"
  }

  dimension: FY18_WA_cd_units_adjustment_1 {
    label: "FY18 WebAssign Core Digital Units Adjustment"
  }

  dimension: FY17_WA_print_units_adjustment_1 {
    label: "FY17 WebAssign Print Units Adjustment"
  }

  measure: sum_FY17_WA_cd_units_adjustment_1 {
    label: "FY17 WebAssign Core Digital Units Adjustment"
    type: sum
    sql: ${TABLE}."FY17_WA_CD_UNITS_ADJUSTMENT_1";;
  }

  measure: sum_FY18_WA_cd_units_adjustment_1 {
    label: "FY18 WebAssign Core Digital Units Adjustment"
    type: sum
    sql: ${TABLE}."FY18_WA_CD_UNITS_ADJUSTMENT_1";;
  }

  measure: sum_FY17_WA_print_units_adjustment_1 {
    label: "FY17 WebAssign Print Units Adjustment"
    type: sum
    sql: ${TABLE}."FY17_WA_PRINT_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY17_WA_cd_sales_adjustment_1 {
    label: "FY17 WebAssign Core Digital Sales Adjustment"
  }

  dimension: FY18_WA_cd_sales_adjustment_1 {
    label: "FY18 WebAssign Core Digital Sales Adjustment"
  }

  dimension: FY17_WA_print_sales_adjustment_1 {
    label: "FY17 WebAssign Print Sales Adjustment"
  }

  measure: sum_FY17_WA_cd_sales_adjustment_1 {
    label: "FY17 WebAssign Core Digital Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY17_WA_CD_SALES_ADJUSTMENT_1";;
  }

  measure: sum_FY18_WA_cd_sales_adjustment_1 {
    label: "FY18 WebAssign Core Digital Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY18_WA_CD_SALES_ADJUSTMENT_1";;
  }

  measure: sum_FY17_WA_print_sales_adjustment_1 {
    label: "FY17 WebAssign Print Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY17_WA_PRINT_SALES_ADJUSTMENT_1";;
  }




  dimension: FY17_quia_cd_units_adjustment_1 {
    label: "FY17 Quia Core Digital Units Adjustment"
  }

  dimension: FY17_quia_cd_sales_adjustment_1 {
    label: "FY17 Quia Core Digital Sales Adjustment"
  }

  measure: sum_FY17_quia_cd_units_adjustment_1 {
    label: "FY17 Quia Core Digital Units Adjustment"
    type: sum
    sql: ${TABLE}."FY17_QUIA_CD_UNITS_ADJUSTMENT_1";;
  }

  measure: sum_FY17_quia_cd_sales_adjustment_1 {
    label: "FY17 Quia Core Digital Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY17_QUIA_CD_SALES_ADJUSTMENT_1";;
  }

  dimension: FY18_quia_cd_units_adjustment_1 {
    label: "FY18 Quia Core Digital Units Adjustment"
  }

  dimension: FY18_quia_cd_sales_adjustment_1 {
    label: "FY18 Quia Core Digital Sales Adjustment"
  }

  measure: sum_FY18_quia_cd_units_adjustment_1 {
    label: "FY18 Quia Core Digital Units Adjustment"
    type: sum
    sql: ${TABLE}."FY18_QUIA_CD_UNITS_ADJUSTMENT_1";;
  }

  measure: sum_FY18_quia_cd_sales_adjustment_1 {
    label: "FY18 Quia Core Digital Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY18_QUIA_CD_SALES_ADJUSTMENT_1";;
  }

  dimension: FY19_quia_cd_units_adjustment_1 {
    label: "FY19 Quia Core Digital Units Adjustment"
  }

  dimension: FY19_quia_cd_sales_adjustment_1 {
    label: "FY19 Quia Core Digital Sales Adjustment"
  }

  measure: sum_FY19_quia_cd_units_adjustment_1 {
    label: "FY19 Quia Core Digital Units Adjustment"
    type: sum
    sql: ${TABLE}."FY19_QUIA_CD_UNITS_ADJUSTMENT_1";;
  }

  measure: sum_FY19_quia_cd_sales_adjustment_1 {
    label: "FY19 Quia Core Digital Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY19_QUIA_CD_SALES_ADJUSTMENT_1";;
  }

  dimension: FY20_API_CU_units_allocation_1 {
    label: "FY20 API CU Units Adjustment"
  }

  measure: sum_FY20_API_CU_units_allocation_1 {
    label: "FY20 API CU Units Adjustment"
    type: sum
    sql: ${TABLE}."FY20_API_CU_UNITS_ALLOCATION_1";;
  }

  dimension: FY20_API_CU_sales_allocation_1 {
    label: "FY20 API CU Sales Adjustment"
  }

  measure: sum_FY20_API_CU_sales_allocation_1 {
    label: "FY20 API CU Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY20_API_CU_SALES_ALLOCATION_1";;
  }


  dimension: FY19_api_cd_standalone_units_adjustment_1 {
    label: "FY19 API CD Standalone Units Adjustment"
  }

  measure: sum_FY19_api_cd_standalone_units_adjustment_1 {
    label: "FY19 API CD Standalone Units Adjustment"
    type: sum
    sql: ${TABLE}."FY19_API_CD_STANDALONE_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY19_api_cd_standalone_sales_adjustment_1 {
    label: "FY19 API CD Standalone Sales Adjustment"
  }

  measure: sum_FY19_api_cd_standalone_sales_adjustment_1 {
    label: "FY19 API CD Standalone Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY19_API_CD_STANDALONE_SALES_ADJUSTMENT_1";;
  }

  dimension: FY20_api_cd_standalone_units_adjustment_1 {
    label: "FY20 API CD Standalone Units Adjustment"
  }

  measure: sum_FY20_api_cd_standalone_units_adjustment_1 {
    label: "FY20 API CD Standalone Units Adjustment"
    type: sum
    sql: ${TABLE}."FY20_API_CD_STANDALONE_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY20_api_cd_standalone_sales_adjustment_1 {
    label: "FY20 API CD Standalone Sales Adjustment"
  }

  measure: sum_FY20_api_cd_standalone_sales_adjustment_1 {
    label: "FY20 API CD Standalone Sales Adjustment"
    type: sum
    sql: ${TABLE}."FY20_API_CD_STANDALONE_SALES_ADJUSTMENT_1";;
  }



  dimension: FY19_unactivated_cu_units_adjustment_1 {
    label: "FY19 Unactivated CU Units Adjustment"
  }

  measure: sum_FY19_unactivated_cu_units_adjustment_1 {
    label: "FY19 Unactivated CU Units Adjustment"
    type: sum
    sql: ${TABLE}."FY19_UNACTIVATED_CU_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY20_unactivated_cu_units_adjustment_1 {
    label: "FY20 Unactivated CU Units Adjustment"
  }

  measure: sum_FY20_unactivated_cu_units_adjustment_1 {
    label: "FY20 Unactivated CU Units Adjustment"
    type: sum
    sql: ${TABLE}."FY20_UNACTIVATED_CU_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY17_oct_ebook_units_adjustment_1 {
    label: "FY17 eBook Units Billed in October"
  }

  measure: sum_FY17_oct_ebook_units_adjustment_1 {
    label: "FY17 eBook Units Billed in October"
    type: sum
    sql: ${TABLE}."FY17_OCT_EBOOK_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY17_oct_ebook_sales_adjustment_1 {
    label: "FY17 eBook Sales Billed in October"
  }

  measure: sum_FY17_oct_ebook_sales_adjustment_1 {
    label: "FY17 eBook Sales Billed in October"
    type: sum
    sql: ${TABLE}."FY17_OCT_EBOOK_SALES_ADJUSTMENT_1";;
  }

  dimension: FY18_oct_ebook_units_adjustment_1 {
    label: "FY18 eBook Units Billed in October"
  }

  measure: sum_FY18_oct_ebook_units_adjustment_1 {
    label: "FY18 eBook Units Billed in October"
    type: sum
    sql: ${TABLE}."FY18_OCT_EBOOK_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY18_oct_ebook_sales_adjustment_1 {
    label: "FY18 eBook Sales Billed in October"
  }

  measure: sum_FY18_oct_ebook_sales_adjustment_1 {
    label: "FY18 eBook Sales Billed in October"
    type: sum
    sql: ${TABLE}."FY18_OCT_EBOOK_SALES_ADJUSTMENT_1";;
  }

  dimension: FY19_oct_ebook_units_adjustment_1 {
    label: "FY19 eBook Units Billed in October"
  }

  measure: sum_FY19_oct_ebook_units_adjustment_1 {
    label: "FY19 eBook Units Billed in October"
    type: sum
    sql: ${TABLE}."FY19_OCT_EBOOK_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY19_oct_ebook_sales_adjustment_1 {
    label: "FY19 eBook Sales Billed in October"
  }

  measure: sum_FY19_oct_ebook_sales_adjustment_1 {
    label: "FY19 eBook Sales Billed in October"
    type: sum
    sql: ${TABLE}."FY19_OCT_EBOOK_SALES_ADJUSTMENT_1";;
  }

  dimension: FY20_oct_ebook_units_adjustment_1 {
    label: "FY20 eBook Units Billed in October"
  }

  measure: sum_FY20_oct_ebook_units_adjustment_1 {
    label: "FY20 eBook Units Billed in October"
    type: sum
    sql: ${TABLE}."FY20_OCT_EBOOK_UNITS_ADJUSTMENT_1";;
  }

  dimension: FY20_oct_ebook_sales_adjustment_1 {
    label: "FY20 eBook Sales Billed in October"
  }

  measure: sum_FY20_oct_ebook_sales_adjustment_1 {
    label: "FY20 eBook Sales Billed in October"
    type: sum
    sql: ${TABLE}."FY20_OCT_EBOOK_SALES_ADJUSTMENT_1";;
  }







  dimension: actv_rate_fy17  {
   label: "FY17 Activation Rate"
   value_format: "0.00%"
  }

  dimension: actv_rate_fy18  {
   label: "FY18 Activation Rate"
   value_format: "0.00%"
  }

  dimension: actv_rate_fy19  {
   label: "FY19 Activation Rate"
   value_format: "0.00%"
  }

  dimension: actv_rate_fy20  {
    label: "FY20 Activation Rate"
    value_format: "0.00%"
  }

  dimension: actv_rate_fy17_bucket {
    label: "FY17 Activation Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy17} ;;
  }

  dimension: actv_rate_fy18_bucket {
    label: "FY18 Activation Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy18} ;;
  }

  dimension: actv_rate_fy19_bucket {
    label: "FY19 Activation Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy19} ;;
  }

  dimension: actv_rate_fy20_bucket {
    label: "FY20 Activation Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${actv_rate_fy20} ;;
  }

  dimension: actv_growth_rate_fy18  {
    label: "FY17->FY18 Activation Growth Rate"
    value_format: "0.00%"
  }

  dimension: actv_growth_rate_fy19  {
    label: "FY18->FY19 Activation Growth Rate"
    value_format: "0.00%"
  }

  dimension: actv_growth_rate_fy20  {
    label: "FY19->FY20 Activation Growth Rate"
    value_format: "0.00%"
  }

  dimension: actv_growth_rate_fy18_bucket {
    label: "FY17->FY18 Activation Growth Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5]
    style: relational
    sql: ${actv_growth_rate_fy18} ;;
  }

  dimension: actv_growth_rate_fy19_bucket {
    label: "FY18->FY19 Activation Growth Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5]
    style: relational
    sql: ${actv_growth_rate_fy19} ;;
  }

  dimension: actv_growth_rate_fy20_bucket {
    label: "FY19->FY20 Activation Growth Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5]
    style: relational
    sql: ${actv_growth_rate_fy20} ;;
  }



  dimension: FY17_ebook_units {
    label: "FY17 eBook Units"
    value_format: "#,##0"
  }

  dimension: FY18_ebook_units {
    value_format: "#,##0"
    label: "FY18 eBook Units"
  }

  dimension: FY19_ebook_units {
    value_format: "#,##0"
    label: "FY19 eBook Units"
  }

  dimension: FY20_ebook_units {
    value_format: "#,##0"
    label: "FY20 eBook Units"
  }

  measure: sum_ebook_units_exCU_fy17 {
    value_format: "#,##0"
    label: "FY17 Ebook Units"
    type: sum
    sql: ${TABLE}."FY17_EBOOK_UNITS";;
  }

  measure: sum_ebook_units_exCU_fy18 {
    value_format: "#,##0"
    label: "FY18 Ebook Units"
    type: sum
    sql: ${TABLE}."FY18_EBOOK_UNITS";;
  }

  measure: sum_ebook_units_exCU_fy19 {
    value_format: "#,##0"
    label: "FY19 Ebook Units"
    type: sum
    sql: ${TABLE}."FY19_EBOOK_UNITS";;
  }

  measure: sum_ebook_units_exCU_fy20 {
    value_format: "#,##0"
    label: "FY20 Ebook Units"
    type: sum
    sql: ${TABLE}."FY20_EBOOK_UNITS";;
  }

  dimension: FY17_ebook_units_byCU {
    value_format: "#,##0"
    label: "FY17 eBook Activations within CU"
  }

  dimension: FY18_ebook_units_byCU {
    value_format: "#,##0"
    label: "FY18 eBook Activations within CU"
  }

  dimension: FY19_ebook_units_byCU {
    value_format: "#,##0"
    label: "FY19 eBook Activations within CU"
  }

  dimension: FY20_ebook_units_byCU {
    value_format: "#,##0"
    label: "FY20 eBook Activations within CU"
  }

  measure: sum_ebook_units_byCU_fy17 {
    value_format: "#,##0"
    label: "FY17 eBook Activations within CU"
    type: sum
    sql: ${TABLE}."FY17_EBOOK_UNITS_BYCU";;
  }

  measure: sum_ebook_units_byCU_fy18 {
    value_format: "#,##0"
    label: "FY18 eBook Activations within CU"
    type: sum
    sql: ${TABLE}."FY18_EBOOK_UNITS_BYCU";;
  }

  measure: sum_ebook_units_byCU_fy19 {
    value_format: "#,##0"
    label: "FY19 eBook Activations within CU"
    type: sum
    sql: ${TABLE}."FY19_EBOOK_UNITS_BYCU";;
  }

  measure: sum_ebook_units_byCU_fy20 {
    value_format: "#,##0"
    label: "FY20 eBook Activations within CU"
    type: sum
    sql: ${TABLE}."FY20_EBOOK_UNITS_BYCU";;
  }

  dimension: FY17_total_ebook_activations {
    value_format: "#,##0"
    label: "FY17 Total eBook Activations"
  }

  dimension: FY18_total_ebook_activations {
    value_format: "#,##0"
    label: "FY18 Total eBook Activations"
  }

  dimension: FY19_total_ebook_activations {
    value_format: "#,##0"
    label: "FY19 Total eBook Activations"
  }

  dimension: FY20_total_ebook_activations {
    value_format: "#,##0"
    label: "FY20 Total eBook Activations"
  }

  measure: sum_total_ebook_activations_fy17 {
    value_format: "#,##0"
    label: "FY17 Total eBook Activations"
    type: sum
    sql: ${TABLE}."FY17_TOTAL_EBOOK_ACTIVATIONS";;
  }

  measure: sum_total_ebook_activations_fy18 {
    value_format: "#,##0"
    label: "FY18 Total eBook Activations"
    type: sum
    sql: ${TABLE}."FY18_TOTAL_EBOOK_ACTIVATIONS";;
  }

  measure: sum_total_ebook_activations_fy19 {
    value_format: "#,##0"
    label: "FY19 Total eBook Activations"
    type: sum
    sql: ${TABLE}."FY19_TOTAL_EBOOK_ACTIVATIONS";;
  }

  measure: sum_total_ebook_activations_fy20 {
    value_format: "#,##0"
    label: "FY20 Total eBook Activations"
    type: sum
    sql: ${TABLE}."FY20_TOTAL_EBOOK_ACTIVATIONS";;
  }

  dimension: FY17_ebook_sales {
    label: "FY17 eBook Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_ebook_sales {
    label: "FY17 eBook Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_EBOOK_SALES";;
  }

  dimension: FY18_ebook_sales {
    label: "FY18 eBook Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_ebook_sales {
    label: "FY18 eBook Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_EBOOK_SALES";;
  }

  dimension: FY19_ebook_sales {
    label: "FY19 eBook Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_ebook_sales {
    label: "FY19 eBook Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_EBOOK_SALES";;
  }

  dimension: FY20_ebook_sales {
    label: "FY20 eBook Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_ebook_sales {
    label: "FY20 eBook Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_EBOOK_SALES";;
  }

  dimension: FY17_print_core_units {
    label: "FY17 Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_print_core_units {
    label: "FY17 Print Core Units"
    type: sum
    sql: ${TABLE}."FY17_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_print_core_units {
    label: "FY18 Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_print_core_units {
    label: "FY18 Print Core Units"
    type: sum
    sql: ${TABLE}."FY18_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_print_core_units {
    label: "FY19 Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_print_core_units {
    label: "FY19 Print Core Units"
    type: sum
    sql: ${TABLE}."FY19_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_print_core_units {
    label: "FY20 Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_print_core_units {
    label: "FY20 Print Core Units"
    type: sum
    sql: ${TABLE}."FY20_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_print_core_sales {
    label: "FY17 Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_print_core_sales {
    label: "FY17 Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_PRINT_CORE_SALES";;
  }

  dimension: FY18_print_core_sales {
    label: "FY18 Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_print_core_sales {
    label: "FY18 Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_PRINT_CORE_SALES";;
  }

  dimension: FY19_print_core_sales {
    label: "FY19 Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_print_core_sales {
    label: "FY19 Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_PRINT_CORE_SALES";;
  }

  dimension: FY20_print_core_sales {
    label: "FY20 Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_print_core_sales {
    label: "FY20 Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_PRINT_CORE_SALES";;
  }

  dimension: FY17_print_other_units {
    label: "FY17 Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_print_other_units {
    label: "FY17 Print Other Units"
    type: sum
    sql: ${TABLE}."FY17_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_print_other_units {
    label: "FY18 Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_print_other_units {
    label: "FY18 Print Other Units"
    type: sum
    sql: ${TABLE}."FY18_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_print_other_units {
    label: "FY19 Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_print_other_units {
    label: "FY19 Print Other Units"
    type: sum
    sql: ${TABLE}."FY19_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_print_other_units {
    label: "FY20 Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_print_other_units {
    label: "FY20 Print Other Units"
    type: sum
    sql: ${TABLE}."FY20_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_print_other_sales {
    label: "FY17 Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_print_other_sales {
    label: "FY17 Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_PRINT_OTHER_SALES";;
  }

  dimension: FY18_print_other_sales {
    label: "FY18 Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_print_other_sales {
    label: "FY18 Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_PRINT_OTHER_SALES";;
  }

  dimension: FY19_print_other_sales {
    label: "FY19 Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_print_other_sales {
    label: "FY19 Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_PRINT_OTHER_SALES";;
  }

  dimension: FY20_print_other_sales {
    label: "FY20 Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_print_other_sales {
    label: "FY20 Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_PRINT_OTHER_SALES";;
  }

  dimension: FY17_custom_print_other_units {
    label: "FY17 Custom Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_custom_print_other_units {
    label: "FY17 Custom Print Other Units"
    type: sum
    sql: ${TABLE}."FY17_CUSTOM_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_custom_print_other_units {
    label: "FY18 Custom Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_custom_print_other_units {
    label: "FY18 Custom Print Other Units"
    type: sum
    sql: ${TABLE}."FY18_CUSTOM_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_custom_print_other_units {
    label: "FY19 Custom Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_custom_print_other_units {
    label: "FY19 Custom Print Other Units"
    type: sum
    sql: ${TABLE}."FY19_CUSTOM_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_custom_print_other_units {
    label: "FY20 Custom Print Other Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_custom_print_other_units {
    label: "FY20 Custom Print Other Units"
    type: sum
    sql: ${TABLE}."FY20_CUSTOM_PRINT_OTHER_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_custom_print_other_sales {
    label: "FY17 Custom Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_custom_print_other_sales {
    label: "FY17 Custom Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_CUSTOM_PRINT_OTHER_SALES";;
  }

  dimension: FY18_custom_print_other_sales {
    label: "FY18 Custom Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_custom_print_other_sales {
    label: "FY18 Custom Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_CUSTOM_PRINT_OTHER_SALES";;
  }

  dimension: FY19_custom_print_other_sales {
    label: "FY19 Custom Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_custom_print_other_sales {
    label: "FY19 Custom Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_CUSTOM_PRINT_OTHER_SALES";;
  }

  dimension: FY20_custom_print_other_sales {
    label: "FY20 Custom Print Other Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_custom_print_other_sales {
    label: "FY20 Custom Print Other Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_CUSTOM_PRINT_OTHER_SALES";;
  }

  dimension: FY17_custom_print_core_units {
    label: "FY17 Custom Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_custom_print_core_units {
    label: "FY17 Custom Print Core Units"
    type: sum
    sql: ${TABLE}."FY17_CUSTOM_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_custom_print_core_units {
    label: "FY18 Custom Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_custom_print_core_units {
    label: "FY18 Custom Print Core Units"
    type: sum
    sql: ${TABLE}."FY18_CUSTOM_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_custom_print_core_units {
    label: "FY19 Custom Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_custom_print_core_units {
    label: "FY19 Custom Print Core Units"
    type: sum
    sql: ${TABLE}."FY19_CUSTOM_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_custom_print_core_units {
    label: "FY20 Custom Print Core Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_custom_print_core_units {
    label: "FY20 Custom Print Core Units"
    type: sum
    sql: ${TABLE}."FY20_CUSTOM_PRINT_CORE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_custom_print_core_sales {
    label: "FY17 Custom Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_custom_print_core_sales {
    label: "FY17 Custom Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_CUSTOM_PRINT_CORE_SALES";;
  }

  dimension: FY18_custom_print_core_sales {
    label: "FY18 Custom Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_custom_print_core_sales {
    label: "FY18 Custom Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_CUSTOM_PRINT_CORE_SALES";;
  }

  dimension: FY19_custom_print_core_sales {
    label: "FY19 Custom Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_custom_print_core_sales {
    label: "FY19 Custom Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_CUSTOM_PRINT_CORE_SALES";;
  }

  dimension: FY20_custom_print_core_sales {
    label: "FY20 Custom Print Core Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_custom_print_core_sales {
    label: "FY20 Custom Print Core Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_CUSTOM_PRINT_CORE_SALES";;
  }

  dimension: FY17_other_digital_standalone_units {
    label: "FY17 Other Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_other_digital_standalone_units {
    label: "FY17 Other Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY17_OTHER_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_other_digital_standalone_units {
    label: "FY18 Other Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_other_digital_standalone_units {
    label: "FY18 Other Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY18_OTHER_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_other_digital_standalone_units {
    label: "FY19 Other Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_other_digital_standalone_units {
    label: "FY19 Other Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY19_OTHER_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_other_digital_standalone_units {
    label: "FY20 Other Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_other_digital_standalone_units {
    label: "FY20 Other Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY20_OTHER_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_other_digital_standalone_sales {
    label: "FY17 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_other_digital_standalone_sales {
    label: "FY17 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_OTHER_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY18_other_digital_standalone_sales {
    label: "FY18 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_other_digital_standalone_sales {
    label: "FY18 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_OTHER_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY19_other_digital_standalone_sales {
    label: "FY19 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_other_digital_standalone_sales {
    label: "FY19 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_OTHER_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY20_other_digital_standalone_sales {
    label: "FY20 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_other_digital_standalone_sales {
    label: "FY20 Other Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_OTHER_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY17_other_digital_bundle_units {
    label: "FY17 Other Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_other_digital_bundle_units {
    label: "FY17 Other Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY17_OTHER_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_other_digital_bundle_units {
    label: "FY18 Other Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_other_digital_bundle_units {
    label: "FY18 Other Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY18_OTHER_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_other_digital_bundle_units {
    label: "FY19 Other Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_other_digital_bundle_units {
    label: "FY19 Other Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY19_OTHER_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_other_digital_bundle_units {
    label: "FY20 Other Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_other_digital_bundle_units {
    label: "FY20 Other Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY20_OTHER_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_other_digital_bundle_sales {
    label: "FY17 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_other_digital_bundle_sales {
    label: "FY17 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_OTHER_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY18_other_digital_bundle_sales {
    label: "FY18 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_other_digital_bundle_sales {
    label: "FY18 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_OTHER_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY19_other_digital_bundle_sales {
    label: "FY19 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_other_digital_bundle_sales {
    label: "FY19 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_OTHER_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY20_other_digital_bundle_sales {
    label: "FY20 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_other_digital_bundle_sales {
    label: "FY20 Other Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_OTHER_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY17_core_digital_standalone_units {
    label: "FY17 Core Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_core_digital_standalone_units {
    label: "FY17 Core Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY17_CORE_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_core_digital_standalone_units {
    label: "FY18 Core Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_core_digital_standalone_units {
    label: "FY18 Core Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY18_CORE_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_core_digital_standalone_units {
    label: "FY19 Core Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_core_digital_standalone_units {
    label: "FY19 Core Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY19_CORE_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_core_digital_standalone_units {
    label: "FY20 Core Digital Standalone Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_core_digital_standalone_units {
    label: "FY20 Core Digital Standalone Units"
    type: sum
    sql: ${TABLE}."FY20_CORE_DIGITAL_STANDALONE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_core_digital_standalone_sales {
    label: "FY17 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_core_digital_standalone_sales {
    label: "FY17 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_CORE_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY18_core_digital_standalone_sales {
    label: "FY18 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_core_digital_standalone_sales {
    label: "FY18 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_CORE_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY19_core_digital_standalone_sales {
    label: "FY19 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_core_digital_standalone_sales {
    label: "FY19 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_CORE_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY20_core_digital_standalone_sales {
    label: "FY20 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_core_digital_standalone_sales {
    label: "FY20 Core Digital Standalone Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_CORE_DIGITAL_STANDALONE_SALES";;
  }

  dimension: FY17_core_digital_bundle_units {
    label: "FY17 Core Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_core_digital_bundle_units {
    label: "FY17 Core Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY17_CORE_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_core_digital_bundle_units {
    label: "FY18 Core Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_core_digital_bundle_units {
    label: "FY18 Core Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY18_CORE_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_core_digital_bundle_units {
    label: "FY19 Core Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_core_digital_bundle_units {
    label: "FY19 Core Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY19_CORE_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_core_digital_bundle_units {
    label: "FY20 Core Digital Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_core_digital_bundle_units {
    label: "FY20 Core Digital Bundle Units"
    type: sum
    sql: ${TABLE}."FY20_CORE_DIGITAL_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_core_digital_bundle_sales {
    label: "FY17 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_core_digital_bundle_sales {
    label: "FY17 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_CORE_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY18_core_digital_bundle_sales {
    label: "FY18 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_core_digital_bundle_sales {
    label: "FY18 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_CORE_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY19_core_digital_bundle_sales {
    label: "FY19 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_core_digital_bundle_sales {
    label: "FY19 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_CORE_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY20_core_digital_bundle_sales {
    label: "FY20 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_core_digital_bundle_sales {
    label: "FY20 Core Digital Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_CORE_DIGITAL_BUNDLE_SALES";;
  }

  dimension: FY17_LLF_bundle_units {
    label: "FY17 LLF Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_LLF_bundle_units {
    label: "FY17 LLF Bundle Units"
    type: sum
    sql: ${TABLE}."FY17_LLF_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_LLF_bundle_units {
    label: "FY18 LLF Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_LLF_bundle_units {
    label: "FY18 LLF Bundle Units"
    type: sum
    sql: ${TABLE}."FY18_LLF_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_LLF_bundle_units {
    label: "FY19 LLF Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_LLF_bundle_units {
    label: "FY19 LLF Bundle Units"
    type: sum
    sql: ${TABLE}."FY19_LLF_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_LLF_bundle_units {
    label: "FY20 LLF Bundle Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_LLF_bundle_units {
    label: "FY20 LLF Bundle Units"
    type: sum
    sql: ${TABLE}."FY20_LLF_BUNDLE_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_LLF_bundle_sales {
    label: "FY17 LLF Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_LLF_bundle_sales {
    label: "FY17 LLF Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_LLF_BUNDLE_SALES";;
  }

  dimension: FY18_LLF_bundle_sales {
    label: "FY18 LLF Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_LLF_bundle_sales {
    label: "FY18 LLF Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_LLF_BUNDLE_SALES";;
  }

  dimension: FY19_LLF_bundle_sales {
    label: "FY19 LLF Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_LLF_bundle_sales {
    label: "FY19 LLF Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_LLF_BUNDLE_SALES";;
  }

  dimension: FY20_LLF_bundle_sales {
    label: "FY20 LLF Bundle Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_LLF_bundle_sales {
    label: "FY20 LLF Bundle Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_LLF_BUNDLE_SALES";;
  }

  dimension: FY17_CU_units {
    label: "FY17 CU Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_CU_units {
    label: "FY17 CU Units"
    type: sum
    sql: ${TABLE}."FY17_CU_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY18_CU_units {
    label: "FY18 CU Units"
    value_format: "#,##0"
  }

  measure: sum_FY18_CU_units {
    label: "FY18 CU Units"
    type: sum
    sql: ${TABLE}."FY18_CU_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY19_CU_units {
    label: "FY19 CU Units"
    value_format: "#,##0"
  }

  measure: sum_FY19_CU_units {
    label: "FY19 CU Units"
    type: sum
    sql: ${TABLE}."FY19_CU_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY20_CU_units {
    label: "FY20 CU Units"
    value_format: "#,##0"
  }

  measure: sum_FY20_CU_units {
    label: "FY20 CU Units"
    type: sum
    sql: ${TABLE}."FY20_CU_UNITS";;
    value_format: "#,##0"
  }

  dimension: FY17_CU_sales {
    label: "FY17 CU Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY17_CU_sales {
    label: "FY17 CU Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY17_CU_SALES";;
  }

  dimension: FY18_CU_sales {
    label: "FY18 CU Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY18_CU_sales {
    label: "FY18 CU Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY18_CU_SALES";;
  }

  dimension: FY19_CU_sales {
    label: "FY19 CU Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY19_CU_sales {
    label: "FY19 CU Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY19_CU_SALES";;
  }

  dimension: FY20_CU_sales {
    label: "FY20 CU Sales"
    value_format: "$#,##0.00"
  }

  measure: sum_FY20_CU_sales {
    label: "FY20 CU Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."FY20_CU_SALES";;
  }


  dimension: FY19_unadjusted_core_digital_consumed_units {
    value_format: "#,##0"
    label: "FY19 Unadjusted Consumed Units"
  }

  dimension: FY20_unadjusted_core_digital_consumed_units {
    value_format: "#,##0"
    label: "FY20 Unadjusted Consumed Units"
  }

  measure: sum_FY19_unadjusted_core_digital_consumed_units {
    value_format: "#,##0"
    label: "FY19 Unadjusted Consumed Units"
    type: sum
    sql: ${TABLE}."FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS" ;;
  }

  measure: sum_FY20_unadjusted_core_digital_consumed_units {
    value_format: "#,##0"
    label: "FY20 Unadjusted Consumed Units"
    type: sum
    sql: ${TABLE}."FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS" ;;
  }

  dimension: FY17_total_core_digital_consumed_units {
    value_format: "#,##0"
    label: "FY17 Total Core Digital Consumed Units"
  }

  dimension: FY18_total_core_digital_consumed_units {
    label: "FY18 Total Core Digital Consumed Units"
    value_format: "#,##0"
  }

  dimension: FY19_total_core_digital_consumed_units {
    label: "FY19 Total Core Digital Consumed Units"
    value_format: "#,##0"
  }

  dimension: FY20_total_core_digital_consumed_units {
    label: "FY20 Total Core Digital Consumed Units"
    value_format: "#,##0"
  }

  measure: sum_FY17_total_core_digital_consumed_units {
    value_format: "#,##0"
    label: "FY17 Total Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."FY17_TOTAL_CORE_DIGITAL_CONSUMED_UNITS" ;;
  }

  measure: sum_FY18_total_core_digital_consumed_units {
    label: "FY18 Total Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS" ;;
    value_format: "#,##0"
  }


  measure: sum_FY19_total_core_digital_consumed_units {
    label: "FY19 Total Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS" ;;
    value_format: "#,##0"
  }

  measure: sum_FY20_total_core_digital_consumed_units {
    label: "FY20 Total Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS" ;;
    value_format: "#,##0"
  }

  dimension: total_net_units_fy17 {
    label: "FY17 Total Net Units"
    value_format: "#,##0"
  }

  dimension: total_net_units_fy18 {
    label: "FY18 Total Net Units"
    value_format: "#,##0"
  }

  dimension: total_net_units_fy19 {
    label: "FY19 Total Net Units"
    value_format: "#,##0"
  }

  dimension: total_net_units_fy20 {
    label: "FY20 Total Net Units"
    value_format: "#,##0"
  }

  dimension: net_units_bucket_Fy17 {
    label: "FY17 Total Net Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${total_net_units_fy17} ;;
  }

  dimension: net_units_bucket_Fy18 {
    label: "FY18 Total Net Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${total_net_units_fy18} ;;
  }

  dimension: net_units_bucket_Fy19 {
    label: "FY19 Total Net Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${total_net_units_fy19} ;;
  }

  dimension: net_units_bucket_Fy20 {
    label: "FY20 Total Net Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${total_net_units_fy20} ;;
  }

  dimension: net_unit_change_fy18 {
    label: "FY18 Net Unit Change"
    value_format: "#,##0"
  }

  dimension: net_unit_change_fy19 {
    label: "FY19 Net Unit Change"
    value_format: "#,##0"
  }

  dimension: net_unit_change_fy20 {
    label: "FY20 Net Unit Change"
    value_format: "#,##0"
  }

  dimension: net_unit_change_bucket_fy18 {
    label: "FY18 Net Unit Change Bucket"
    type: tier
    tiers: [-500,-250,-100,-50,-25,-10,0,10,25,50,100,250,500]
    style: integer
    sql: ${net_unit_change_fy18} ;;
  }

  dimension: net_unit_change_bucket_fy19 {
    label: "FY19 Net Unit Change Bucket"
    type: tier
    tiers: [-500,-250,-100,-50,-25,-10,0,10,25,50,100,250,500]
    style: integer
    sql: ${net_unit_change_fy19} ;;
  }

  dimension: net_unit_change_bucket_fy20 {
    label: "FY20 Net Unit Change Bucket"
    type: tier
    tiers: [-500,-250,-100,-50,-25,-10,0,10,25,50,100,250,500]
    style: integer
    sql: ${net_unit_change_fy20} ;;
  }


  dimension: consumed_units_bucket_Fy17 {
    label: "FY17 Core Digital Consumed Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${FY17_total_core_digital_consumed_units} ;;
  }

  dimension: consumed_units_bucket_Fy18 {
    label: "FY18 Core Digital Consumed Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${FY18_total_core_digital_consumed_units} ;;
  }

  dimension: consumed_units_bucket_Fy19 {
    label: "FY19 Core Digital Consumed Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${FY19_total_core_digital_consumed_units} ;;
  }

  dimension: consumed_units_bucket_Fy20 {
    label: "FY20 Core Digital Consumed Units Bucket"
    type: tier
    tiers: [0,5,10,15,25,50,100,200,500,1000]
    style: integer
    sql: ${FY20_total_core_digital_consumed_units} ;;
  }

  measure: sum_total_net_units_fy17 {
    label: "FY17 Total Net Units"
    type: sum
    sql: ${total_net_units_fy17} ;;
    value_format: "#,##0"
  }

  measure: sum_total_net_units_fy18 {
    label: "FY18 Total Net Units"
    type: sum
    sql: ${total_net_units_fy18} ;;
    value_format: "#,##0"
  }

  measure: sum_total_net_units_fy19 {
    label: "FY19 Total Net Units"
    type: sum
    sql: ${total_net_units_fy19} ;;
    value_format: "#,##0"
  }

  measure: sum_total_net_units_fy20 {
    label: "FY20 Total Net Units"
    type: sum
    sql: ${total_net_units_fy20} ;;
    value_format: "#,##0"
  }

  dimension: Total_core_digital_NetSales_ex_CU_fy17 {
    label: "FY17 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY17" ;;
  }

  dimension: Total_core_digital_NetSales_ex_CU_fy18 {
    label: "FY18 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY18" ;;
  }

  dimension: Total_core_digital_NetSales_ex_CU_fy19 {
    label: "FY19 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY19" ;;
  }

  dimension: Total_core_digital_NetSales_ex_CU_fy20 {
    label: "FY20 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY20" ;;
  }


  measure: sum_total_core_digital_ex_cu_net_sales_fy17{
    label: "FY17 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY17" ;;
  }

  measure: sum_total_core_digital_ex_cu_net_sales_fy18{
    label: "FY18 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY18" ;;
  }

  measure: sum_total_core_digital_ex_cu_net_sales_fy19 {
    label: "FY19 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY19" ;;
  }

  measure: sum_total_core_digital_ex_cu_net_sales_fy20 {
    label: "FY20 Total Core Digital (ex CU) Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_EX_CU_FY20" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy17 {
    label: "FY17 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY17" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy18 {
    label: "FY18 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY18" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy19 {
    label: "FY19 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY19" ;;
  }

  dimension: total_core_digital_cu_net_sales_fy20 {
    label: "FY20 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY20" ;;
  }

  measure: sum_total_core_digital_cu_net_sales_fy17{
    label: "FY17 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY17" ;;
  }

  measure: sum_total_core_digital_cu_net_sales_fy18{
    label: "FY18 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY18" ;;
  }

  measure: sum_total_core_digital_cu_net_sales_fy19{
    label: "FY19 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY19" ;;
  }

  measure: sum_total_core_digital_cu_net_sales_fy20{
    label: "FY20 Total Core Digital + CU Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_NETSALES_FY20" ;;
  }

  dimension: total_core_digital_ex_cu_net_units_fy17 {
    label: "FY17 Total Core Digital (ex. CU) Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY17" ;;
    value_format: "#,##0"
  }

  dimension: total_core_digital_ex_cu_net_units_fy18 {
    label: "FY18 Total Core Digital (ex. CU) Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY18" ;;
    value_format: "#,##0"
  }

  dimension: total_core_digital_ex_cu_net_units_fy19 {
    label: "FY19 Total Core Digital (ex. CU) Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY19" ;;
    value_format: "#,##0"
  }

  dimension: total_core_digital_ex_cu_net_units_fy20 {
    label: "FY20 Total Core Digital (ex. CU) Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY20" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_ex_cu_net_units_fy17{
    label: "FY17 Total Core Digital (ex. CU) Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY17" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_ex_cu_net_units_fy18{
    label: "FY18 Total Core Digital (ex. CU) Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY18" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_ex_cu_net_units_fy19 {
    label: "FY19 Total Core Digital (ex. CU) Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY19" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_ex_cu_net_units_fy20 {
    label: "FY20 Total Core Digital (ex. CU) Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_EX_CU_NET_UNITS_FY20" ;;
    value_format: "#,##0"
  }

  dimension: total_core_digital_cu_net_units_fy17 {
    label: "FY17 Total Core Digital + CU Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY17" ;;
    value_format: "#,##0"
  }

  dimension: total_core_digital_cu_net_units_fy18 {
    label: "FY18 Total Core Digital + CU Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY18" ;;
    value_format: "#,##0"
  }

  dimension: total_core_digital_cu_net_units_fy19 {
    label: "FY19 Total Core Digital + CU Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY19" ;;
    value_format: "#,##0"
  }

  dimension: total_core_digital_cu_net_units_fy20 {
    label: "FY20 Total Core Digital + CU Net Units"
    type: number
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY20" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_cu_net_units_fy17{
    label: "FY17 Total Core Digital + CU Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY17" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_cu_net_units_fy18{
    label: "FY18 Total Core Digital + CU Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY18" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_cu_net_units_fy19{
    label: "FY19 Total Core Digital + CU Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY19" ;;
    value_format: "#,##0"
  }

  measure: sum_total_core_digital_cu_net_units_fy20{
    label: "FY20 Total Core Digital + CU Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_CU_NET_UNITS_FY20" ;;
    value_format: "#,##0"
  }

  dimension: total_net_sales_fy17 {
    label: "FY17 Total Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_NET_SALES_FY17" ;;
  }

  measure: sum_total_net_sales_fy17 {
    label: "FY17 Total Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY17" ;;
  }

  dimension: total_net_sales_fy18 {
    label: "FY18 Total Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_NET_SALES_FY18" ;;
  }

  measure: sum_total_net_sales_fy18 {
    label: "FY18 Total Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY18" ;;
  }

  measure: sum_total_net_sales_fy19 {
    label: "FY19 Total Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY19" ;;
  }

  dimension: total_net_sales_fy19 {
    label: "FY19 Total Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_NET_SALES_FY19" ;;
  }

  measure: sum_total_net_sales_fy20 {
    label: "FY20 Total Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_NET_SALES_FY20" ;;
  }

  dimension: total_net_sales_fy20 {
    label: "FY20 Total Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_NET_SALES_FY20" ;;
  }

  dimension: total_print_net_units_fy17 {
    label: "FY17 Total Print Net Units"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY17" ;;
    value_format: "#,##0"
  }

  dimension: total_print_net_units_fy18 {
    label: "FY18 Total Print Net Units"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY18" ;;
    value_format: "#,##0"
  }

  dimension: total_print_net_units_fy19 {
    label: "FY19 Total Print Net Units"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY19" ;;
    value_format: "#,##0"
  }

  dimension: total_print_net_units_fy20 {
    label: "FY20 Total Print Net Units"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY20" ;;
    value_format: "#,##0"
  }

  measure: sum_total_print_net_units_fy17{
    label: "FY17 Total Print Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY17" ;;
    value_format: "#,##0"
  }

  measure: sum_total_print_net_units_fy18{
    label: "FY18 Total Print Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY18" ;;
    value_format: "#,##0"
  }

  measure: sum_total_print_net_units_fy19 {
    label: "FY19 Total Print Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY19" ;;
    value_format: "#,##0"
  }

  measure: sum_total_print_net_units_fy20 {
    label: "FY20 Total Print Net Units"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_UNITS_FY20" ;;
    value_format: "#,##0"
  }

  dimension: total_print_net_sales_fy17 {
    label: "FY17 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY17" ;;
  }

  measure: sum_total_print_net_sales_fy17 {
    label: "FY17 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY17";;
  }

  dimension: total_print_net_sales_fy18 {
    label: "FY18 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY18" ;;
  }

  measure: sum_total_print_net_sales_fy18 {
    label: "FY18 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY18";;
  }

  dimension: total_print_net_sales_fy19 {
    label: "FY19 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY19" ;;
  }

  measure: sum_total_print_net_sales_fy19 {
    label: "FY19 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY19" ;;
  }

  dimension: total_print_net_sales_fy20 {
    label: "FY20 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY20" ;;
  }

  measure: sum_total_print_net_sales_fy20 {
    label: "FY20 Total Print Net Sales"
    value_format: "$#,##0.00"
    type: sum
    sql: ${TABLE}."TOTAL_PRINT_NET_SALES_FY20" ;;
  }

  dimension: total_cd_actv_excu_fy17 {
    label: "FY17 Total CD Activations (excluding CU)"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY17" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_excu_fy18 {
    label: "FY18 Total CD Activations (excluding CU)"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY18" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_excu_fy19 {
    label: "FY19 Total CD Activations (excluding CU)"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY19" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_excu_fy20 {
    label: "FY20 Total CD Activations (excluding CU)"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY20" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_excu_fy17{
    label: "FY17 Total CD Activations (excluding CU)"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY17" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_excu_fy18{
    label: "FY18 Total CD Activations (excluding CU)"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY18" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_excu_fy19 {
    label: "FY19 Total CD Activations (excluding CU)"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY19" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_excu_fy20 {
    label: "FY20 Total CD Activations (excluding CU)"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_EXCU_FY20" ;;
    value_format: "#,##0"
  }


  dimension: total_cd_actv_withcu_fy17 {
    label: "FY17 CD Activations within CU"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY17" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_withcu_fy18 {
    label: "FY18 CD Activations within CU"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY18" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_withcu_fy19 {
    label: "FY19 CD Activations within CU"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY19" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_withcu_fy20 {
    label: "FY20 CD Activations within CU"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY20" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_withcu_fy17{
    label: "FY17 CD Activations within CU"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY17" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_withcu_fy18{
    label: "FY18 CD Activations within CU"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY18" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_withcu_fy19 {
    label: "FY19 CD Activations within CU"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY19" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_withcu_fy20 {
    label: "FY20 CD Activations within CU"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY20" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_fy17 {
    label: "FY17 Total CD Activations"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY17" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_fy18 {
    label: "FY18 Total CD Activations"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY18" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_fy19 {
    label: "FY19 Total CD Activations"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY19" ;;
    value_format: "#,##0"
  }

  dimension: total_cd_actv_fy20 {
    label: "FY20 Total CD Activations"
    type: number
    sql: ${TABLE}."TOTAL_CD_ACTV_FY20" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_fy17 {
    label: "FY17 Total CD Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY17" ;;
    value_format: "#,##0"
  }

  measure: sum_total_cd_actv_fy18 {
    label: "FY18 Total CD Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY18" ;;
    value_format: "#,##0"
  }

 measure: sum_total_cd_actv_fy19 {
    label: "FY19 Total CD Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY19" ;;
  value_format: "#,##0"
  }

  measure: sum_total_cd_actv_fy20 {
    label: "FY20 Total CD Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY20" ;;
    value_format: "#,##0"
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
