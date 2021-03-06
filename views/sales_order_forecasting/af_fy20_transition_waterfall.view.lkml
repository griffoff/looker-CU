explore: af_fy20_transition_waterfall {hidden:yes}
view: af_fy20_transition_waterfall{
  derived_table: {
    sql:
    with relevant_courses as (
    select course_code_description,
          sum(FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY18_core_digital_units,
          sum(FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY19_core_digital_units,
          sum(FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY20_core_digital_units,
          sum(FY_TOTAL_PRINT_NET_UNITS_FY19) as FY19_print_net_units,
          case when (fy18_core_digital_units = 0 AND fy19_core_digital_units = 0 AND fy20_core_digital_units = 0 AND FY19_print_net_units = 0) then 'Remove'
                else 'Keep' end as relevant_course_flag
    from "STRATEGY"."ADOPTION_PIVOT"."FY20_YTD_ADOPTION_PIVOT_FLAT"
    where institution_nm <> 'Not Specified'
    and course_code_description <> '.'
    group by 1),

    relevant_disc as (
    select pub_series_de,
          sum(FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY18_core_digital_units,
          sum(FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY19_core_digital_units,
          sum(FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY20_core_digital_units,
          sum(FY_TOTAL_PRINT_NET_UNITS_FY19) as FY19_print_net_units,
          case when (fy18_core_digital_units = 0 AND fy19_core_digital_units = 0 AND fy20_core_digital_units = 0 AND FY19_print_net_units = 0) then 'Remove'
                else 'Keep' end as relevant_disc_flag
    from "STRATEGY"."ADOPTION_PIVOT"."FY20_YTD_ADOPTION_PIVOT_FLAT"
    where institution_nm <> 'Not Specified'
    and course_code_description <> '.'
    group by 1),

    relevant_inst as (
    select institution_nm,
          sum(FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY18_core_digital_units,
          sum(FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY19_core_digital_units,
          sum(FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) as FY20_core_digital_units,
          case when (fy18_core_digital_units = 0 AND fy19_core_digital_units = 0 AND fy20_core_digital_units = 0) then 'Remove'
                else 'Keep' end as relevant_inst_flag
    from "STRATEGY"."ADOPTION_PIVOT"."FY20_YTD_ADOPTION_PIVOT_FLAT"
    where institution_nm <> 'Not Specified'
    and course_code_description <> '.'
    group by 1),

    pivot_1 as (
    select adoption_key,
          pivot.institution_nm,
          pivot.pub_series_de,
          pivot.course_code_description,
          discipline_category,
          coalesce(FY19_account_segment,'Low CU Penetration') as FY19_account_segment,
          coalesce(FY20_account_segment,'Low CU Penetration') as FY20_account_segment,
          CASE WHEN ((coalesce(FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,0) = 0) OR (coalesce(fy_total_CD_actv_FY18,0) = 0)) THEN 0
                WHEN (fy_total_CD_actv_FY18/FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) <0 then 0
                else (fy_total_CD_actv_FY18/FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) END as activation_rate_fy18,
          CASE WHEN ((coalesce(FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,0) = 0) OR (coalesce(fy_total_CD_actv_FY19,0) = 0)) THEN 0
                WHEN (fy_total_CD_actv_FY19/FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) <0 then 0
                else (fy_total_CD_actv_FY19/FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) END as activation_rate_fy19,
          CASE WHEN ((coalesce(FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,0) = 0) OR (coalesce(fy_total_CD_actv_FY20,0) = 0)) THEN 0
                WHEN (fy_total_CD_actv_FY20/FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) <0 then 0
                else (fy_total_CD_actv_FY20/FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) END as activation_rate_fy20,
          CASE WHEN activation_rate_fy18 <= .25 then '0 - 25%'
                WHEN activation_rate_fy18 <= .5 then '25 - 50%'
                WHEN activation_rate_fy18 <= .75 then '50 - 75%'
                else '75 - 100%' END as activation_rate_bucket_fy18,
          CASE WHEN activation_rate_fy19 <= .25 then '0 - 25%'
                WHEN activation_rate_fy19 <= .5 then '25 - 50%'
                WHEN activation_rate_fy19 <= .75 then '50 - 75%'
                else '75 - 100%' END as activation_rate_bucket_fy19,
          CASE WHEN activation_rate_fy20 <= .25 then '0 - 25%'
                WHEN activation_rate_fy20 <= .5 then '25 - 50%'
                WHEN activation_rate_fy20 <= .75 then '50 - 75%'
                else '75 - 100%' END as activation_rate_bucket_fy20,
          FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,
          FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,
          FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,
          FY_TOTAL_CD_ACTV_FY18,
          FY_TOTAL_CD_ACTV_FY19,
          FY_TOTAL_CD_ACTV_FY20,
          FY_TOTAL_CD_ACTV_WITHCU_FY18,
          FY_TOTAL_CD_ACTV_WITHCU_FY19,
          FY_TOTAL_CD_ACTV_WITHCU_FY20,
          case when FY_FY18_FY19_adoption_transition = 'Digital Takeaway' then 'FY18->FY19 Courseware Takeaway'
                when FY_FY18_FY19_adoption_transition = 'Reinvent' then 'FY18->FY19 Reinvent'
                else 'FY18->FY19 Installed Base'
                end as FY18_FY19_adoption_transition_aggregated,
          case when FY_FY19_FY20_adoption_transition = 'Digital Takeaway' then 'Courseware Takeaway'
                when FY_FY19_FY20_adoption_transition = 'Digital Loss' then 'Courseware Loss'
                when FY_FY19_FY20_adoption_transition = 'Reinvent' then 'Reinvent'
                when FY_FY19_FY20_adoption_transition = 'Regression' then 'Regression'
                else 'Installed Base'
                end as FY19_FY20_adoption_transition_aggregated,
          case when FY19_FY20_adoption_transition_aggregated = 'Courseware Takeaway' then 1
                when FY19_FY20_adoption_transition_aggregated = 'Courseware Loss' then 2
                when FY19_FY20_adoption_transition_aggregated = 'Reinvent' then 3
                when FY19_FY20_adoption_transition_aggregated = 'Regression' then 4
                else 5
                end as FY19_FY20_transition_order,
          case when discipline_category = 'Hardside' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as hardside_consumed_units,
          case when discipline_category = 'Softside' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as softside_consumed_units,
          case when discipline_category = 'B&E' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as be_consumed_units,
          case when discipline_category = 'Computing' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as computing_consumed_units,
          case when discipline_category = 'Career Ed' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as careered_consumed_units,
          case when FY19_FY20_adoption_transition_aggregated = 'Courseware Loss' then (FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS-FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) else '0' end as fy20_lost_units,
          case when FY19_FY20_adoption_transition_aggregated = 'Courseware Takeaway' then (FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS-FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) else '0' end as fy20_takeaway_units,
          case when FY18_FY19_adoption_transition_aggregated = 'FY18->FY19 Courseware Takeaway' then (FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS-FY_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) else '0' end as fy19_takeaway_units,
          case when FY_FY19_FY20_adoption_transition = 'Digital Installed Base' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as fy20_base_units,
          case when FY_FY19_FY20_adoption_transition = 'Digital Installed Base' then FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as fy19_base_units,
          case when FY_FY19_FY20_adoption_transition <> 'Digital Takeaway' AND FY_FY19_FY20_adoption_transition <> 'Digital Loss' AND FY_FY19_FY20_adoption_transition <> 'Reinvent' AND FY_FY19_FY20_adoption_transition <> 'Regression' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else 0 end as fy20_base_units_aggregated,
          case when FY_FY19_FY20_adoption_transition <> 'Digital Takeaway' AND FY_FY19_FY20_adoption_transition <> 'Digital Loss' AND FY_FY19_FY20_adoption_transition <> 'Reinvent' AND FY_FY19_FY20_adoption_transition <> 'Regression' then FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else 0 end as fy19_base_units_aggregated,
          case when FY_FY19_FY20_adoption_transition = 'Reinvent' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as fy20_reinvent_units,
          case when FY_FY19_FY20_adoption_transition = 'Reinvent' then FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as fy19_reinvent_units,
          case when FY_FY19_FY20_adoption_transition = 'Regression' then FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as fy20_regression_units,
          case when FY_FY19_FY20_adoption_transition = 'Regression' then FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS else '0' end as fy19_regression_units,
          FY_TOTAL_PRINT_NET_UNITS_FY19 as FY19_print_net_units
    from "STRATEGY"."ADOPTION_PIVOT"."FY20_YTD_ADOPTION_PIVOT_FLAT" pivot
    left join relevant_courses course on course.course_code_description = pivot.course_code_description
    left join relevant_disc disc on disc.pub_series_de = pivot.pub_series_de
    left join relevant_inst inst on inst.institution_nm = pivot.institution_nm
    where pivot.institution_nm <> 'Not Specified'
    and pivot.course_code_description <> '.'
    and relevant_course_flag = 'Keep'
    and relevant_disc_flag = 'Keep'
    and relevant_inst_flag = 'Keep'),

    fy19_unit_total as (
    select adoption_key,
          institution_nm,
          pub_series_de,
          course_code_description,
          discipline_category,
          fy19_account_segment,
          fy20_account_segment,
          activation_rate_bucket_fy18,
          activation_rate_bucket_fy19,
          activation_rate_bucket_fy20,
          'FY19 ending value' as Adoption_Transition,
          concat(adoption_key, adoption_transition) as Adoption_Key_Transition,
          FY18_FY19_adoption_transition_aggregated as PY_Adoption_Transition,
          0 as FY19_FY20_transition_order,
          sum(FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units_Growth,
          0 as Core_Digital_Consumed_Units,
          0 as PY_Core_Digital_Consumed_Units,
          sum(fy_total_cd_actv_fy19)/1000 as PY_Core_Digital_Activations,
          0 as FY20_Core_Digital_Activations,
          sum(fy_total_cd_actv_withcu_FY19)/1000 as Core_Digital_Activations_within_CU,
          0 as Hardside_Consumed_Units_Total,
          0 as Softside_Consumed_Units_Total,
          0 as BE_Consumed_Units_Total,
          0 as Computing_Consumed_Units_Total,
          0 as Career_Ed_Consumed_Units_Total,
          0 as FY20_lost_units_total,
          0 as FY20_takeaway_units_total,
          0 as FY19_takeaway_units_total,
          0 as FY20_base_units_total,
          0 as FY19_base_units_total,
          0 as FY20_base_units_aggregated_total,
          0 as FY19_base_units_aggregated_total,
          0 as FY20_reinvent_units_total,
          0 as FY19_reinvent_units_total,
          0 as FY20_regression_units_total,
          0 as FY19_regression_units_total,
          0 as FY19_print_net_units_total,
          case when FY20_account_segment = 'High CU Penetration' then 1
                when FY20_account_segment = 'Medium CU Penetration' then 2
                when FY20_account_segment = 'Low CU Penetration' then 3
                when FY20_account_segment = 'CU-I Institution' then 4
                else 5 end as account_segment_order
    from pivot_1
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13),

    segment_total as (
    select 'Total' as adoption_key,
          'Total' as institution_nm,
          'Total' as pub_series_de,
          'Total' as course_code_description,
          'Total' as discipline_category,
          'Total' as fy19_account_segment,
          'Total' as fy20_account_segment,
          'Total' as activation_rate_bucket_fy18,
          'Total' as activation_rate_bucket_fy19,
          'Total' as activation_rate_bucket_fy20,
          'Total' as Adoption_Transition,
          'Total' as Adoption_Key_Transition,
          'Total' as PY_Adoption_Transition,
          6 as FY19_FY20_transition_order,
          0 as Core_Digital_Consumed_Units_Growth,
          sum(FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units,
          sum(FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS)/1000 as PY_Core_Digital_Consumed_Units,
          0 as PY_Core_Digital_Activations,
          0 as Total_Core_Digital_Activations,
          0 as Core_Digital_Activations_within_CU,
          sum(hardside_consumed_units)/1000 as Hardside_Consumed_Units_Total,
          sum(softside_consumed_units)/1000 as Softside_Consumed_Units_Total,
          sum(be_consumed_units)/1000 as BE_Consumed_Units_Total,
          sum(computing_consumed_units)/1000 as Computing_Consumed_Units_Total,
          sum(careered_consumed_units)/1000 as Career_Ed_Consumed_Units_Total,
          sum(fy20_lost_units)/1000 as FY20_lost_units_total,
          sum(fy20_takeaway_units)/1000 as FY20_takeaway_units_total,
          sum(fy19_takeaway_units)/1000 as FY19_takeaway_units_total,
          sum(fy20_base_units)/1000 as FY20_base_units_total,
          sum(fy19_base_units)/1000 as FY19_base_units_total,
          sum(fy20_base_units_aggregated)/1000 as FY20_base_units_aggregated_total,
          sum(fy19_base_units_aggregated)/1000 as FY19_base_units_aggregated_total,
          sum(fy20_reinvent_units)/1000 as FY20_reinvent_units_total,
          sum(fy19_reinvent_units)/1000 as FY19_reinvent_units_total,
          sum(fy20_regression_units)/1000 as FY20_regression_units_total,
          sum(fy19_regression_units)/1000 as FY19_regression_units_total,
          sum(fy19_print_net_units)/1000 as FY19_print_net_units_total,
          6 as account_segment_order
    from pivot_1
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13),


    fy19_20_pivot as (
    select adoption_key,
          institution_nm,
          pub_series_de,
          course_code_description,
          discipline_category,
          fy19_account_segment,
          fy20_account_segment,
          activation_rate_bucket_fy18,
          activation_rate_bucket_fy19,
          activation_rate_bucket_fy20,
          FY19_FY20_adoption_transition_aggregated as Adoption_Transition,
          concat(adoption_key, adoption_transition) as Adoption_Key_Transition,
          FY18_FY19_adoption_transition_aggregated as PY_Adoption_Transition,
          FY19_FY20_transition_order,
          ((FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS) - (FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS))/1000 as Core_Digital_Consumed_Units_Growth,
          (FY_FY20_TOTAL_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units,
          (FY_FY19_TOTAL_CORE_DIGITAL_CONSUMED_UNITS)/1000 as PY_Core_Digital_Consumed_Units,
          (fy_total_cd_actv_fy19)/1000 as PY_Core_Digital_Activations,
          (fy_total_cd_actv_fy20)/1000 as Total_Core_Digital_Activations,
          ((fy_total_cd_actv_withcu_FY20) - (fy_total_cd_actv_withcu_FY19))/1000 as Core_Digital_Activations_within_CU,
          hardside_consumed_units/1000 as Hardside_Consumed_Units_Total,
          softside_consumed_units/1000 as Softside_Consumed_Units_Total,
          be_consumed_units/1000 as BE_Consumed_Units_Total,
          computing_consumed_units/1000 as Computing_Consumed_Units_Total,
          careered_consumed_units/1000 as Career_Ed_Consumed_Units_Total,
          fy20_lost_units/1000 as FY20_lost_units_total,
          fy20_takeaway_units/1000 as FY20_takeaway_units_total,
          fy19_takeaway_units/1000 as FY19_takeaway_units_total,
          fy20_base_units/1000 as FY20_base_units_total,
          fy19_base_units/1000 as FY19_base_units_total,
          fy20_base_units_aggregated/1000 as FY20_base_units_aggregated_total,
          fy19_base_units_aggregated/1000 as FY19_base_units_aggregated_total,
          fy20_reinvent_units/1000 as FY20_reinvent_units_total,
          fy19_reinvent_units/1000 as FY19_reinvent_units_total,
          fy20_regression_units/1000 as FY20_regression_units_total,
          fy19_regression_units/1000 as FY19_regression_units_total,
          fy19_print_net_units/1000 as FY19_print_net_units_total,
          case when FY20_account_segment = 'High CU Penetration' then 1
                when FY20_account_segment = 'Medium CU Penetration' then 2
                when FY20_account_segment = 'Low CU Penetration' then 3
                when FY20_account_segment = 'CU-I Institution' then 4
                else 5 end as account_segment_order
    from pivot_1)



    select * from fy19_20_pivot
    UNION
    select * from fy19_unit_total
    UNION
    select * from segment_total

    ;;
  }

  dimension: adoption_key {
    label: "Adoption Key"
  }

  dimension: pub_series_de {
    label: "Discipline"
  }

  dimension: course_code_description {
    label: "Course"
  }

  dimension: institution_nm {
    label: "Institution"
  }

  dimension: Adoption_Transition {
    label: "FY19->FY20 Adoption Transition"
  }

  dimension: PY_Adoption_Transition {
    label: "FY18->FY19 Adoption Transition"
  }

  dimension: FY19_FY20_transition_order {
    label: "Transition Order"
  }

  dimension: discipline_category {
    label: "Discipline Category"
  }

  dimension: fy19_account_segment {
    label: "FY19 Account Segment"
  }

  dimension: fy20_account_segment {
    label: "FY20 Account Segment"
  }

  dimension: activation_rate_bucket_fy18 {
    label: "FY18 Activation Rate Bucket"
  }

  dimension: activation_rate_bucket_fy19 {
    label: "FY19 Activation Rate Bucket"
  }

  dimension: activation_rate_bucket_fy20 {
    label: "FY20 Activation Rate Bucket"
  }

  dimension: account_segment_order {
    label: "Account Segment Order"
  }

  measure: sum_core_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Courseware Consumed Units"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_CONSUMED_UNITS_GROWTH";;
  }

  measure: sum_py_core_digital_consumed_units {
    value_format: "#,##0.0"
    label: "FY19 Courseware Consumed Units"
    type: sum
    sql: ${TABLE}."PY_CORE_DIGITAL_CONSUMED_UNITS";;
  }

  measure: sum_hardside_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Hardside"
    type: sum
    sql: ${TABLE}."HARDSIDE_CONSUMED_UNITS_TOTAL";;
  }

  measure: sum_softside_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Softside"
    type: sum
    sql: ${TABLE}."SOFTSIDE_CONSUMED_UNITS_TOTAL";;
  }

  measure: sum_be_digital_consumed_units {
    value_format: "#,##0.0"
    label: "B&E"
    type: sum
    sql: ${TABLE}."BE_CONSUMED_UNITS_TOTAL";;
  }

  measure: sum_computing_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Computing"
    type: sum
    sql: ${TABLE}."COMPUTING_CONSUMED_UNITS_TOTAL";;
  }


  measure: sum_career_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Career Ed"
    type: sum
    sql: ${TABLE}."CAREER_ED_CONSUMED_UNITS_TOTAL";;
  }

  measure: sum_lost_units {
    value_format: "#,##0.0"
    label: "FY20 Lost Units"
    type: sum
    sql: ${TABLE}."FY20_LOST_UNITS_TOTAL";;
  }

  measure: sum_fy20_takeaway_units {
    value_format: "#,##0.0"
    label: "FY20 Takeaway Units"
    type: sum
    sql: ${TABLE}."FY20_TAKEAWAY_UNITS_TOTAL";;
  }

  measure: sum_fy19_takeaway_units {
    value_format: "#,##0.0"
    label: "FY19 Takeaway Units"
    type: sum
    sql: ${TABLE}."FY19_TAKEAWAY_UNITS_TOTAL";;
  }

  measure: sum_fy19_base_units {
    value_format: "#,##0.0"
    label: "FY19 Installed Base Units"
    type: sum
    sql: ${TABLE}."FY19_BASE_UNITS_TOTAL";;
  }

  measure: sum_fy20_base_units {
    value_format: "#,##0.0"
    label: "FY20 Installed Base Units"
    type: sum
    sql: ${TABLE}."FY20_BASE_UNITS_TOTAL";;
  }

  measure: sum_fy19_base_aggregated_units {
    value_format: "#,##0.0"
    label: "FY19 Installed Base Units"
    type: sum
    sql: ${TABLE}."FY19_BASE_UNITS_AGGREGATED_TOTAL";;
  }

  measure: sum_fy20_base_aggregated_units {
    value_format: "#,##0.0"
    label: "FY20 Installed Base Units"
    type: sum
    sql: ${TABLE}."FY20_BASE_UNITS_AGGREGATED_TOTAL";;
  }

  measure: sum_fy20_reinvent_units {
    value_format: "#,##0.0"
    label: "FY20 Reinvent Units"
    type: sum
    sql: ${TABLE}."FY20_REINVENT_UNITS_TOTAL";;
  }

  measure: sum_fy19_reinvent_units {
    value_format: "#,##0.0"
    label: "FY19 Reinvent Units"
    type: sum
    sql: ${TABLE}."FY19_REINVENT_UNITS_TOTAL";;
  }

  measure: sum_fy20_regression_units {
    value_format: "#,##0.0"
    label: "FY20 Regression Units"
    type: sum
    sql: ${TABLE}."FY20_REGRESSION_UNITS_TOTAL";;
  }

  measure: sum_fy19_regression_units {
    value_format: "#,##0.0"
    label: "FY19 Regression Units"
    type: sum
    sql: ${TABLE}."FY19_REGRESSION_UNITS_TOTAL";;
  }

  measure: sum_fy19_print_units {
    value_format: "#,##0.0"
    label: "FY19 Total Print Units"
    type: sum
    sql: ${TABLE}."FY19_PRINT_NET_UNITS_TOTAL";;
  }





  measure: sum_fy20_core_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Courseware Consumed Units"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_CONSUMED_UNITS";;

  }

  measure: sum_core_digital_activations {
    value_format: "#,##0.0"
    label: "FY20 Courseware Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_ACTIVATIONS";;
  }

  measure: sum_fy19_core_digital_activations {
    value_format: "#,##0.0"
    label: "FY19 Courseware Activations"
    type: sum
    sql: ${TABLE}."PY_CORE_DIGITAL_ACTIVATIONS";;
  }


  measure: sum_core_digital_activations_within_CU {
    value_format: "#,##0.0"
    label: "Courseware Activations within CU"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_ACTIVATIONS_WITHIN_CU";;
  }

  }
