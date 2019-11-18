explore:  af_fy20_transition_waterfall{}
view: af_fy20_transition_waterfall{
  derived_table: {
    sql:
    with pivot_1 as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           CASE WHEN FY19_account_type = 'Rest of Business' then 'Medium CU Penetration'
                ELSE FY19_account_type end as FY19_account_segment,
           CASE WHEN FY20_account_type = 'Rest of Business' then 'Medium CU Penetration'
                ELSE FY20_account_type end as FY20_account_segment,
           CASE WHEN ((coalesce(FY18_total_core_digital_consumed_units,0) = 0) OR (coalesce(total_CD_actv_FY18,0) = 0)) THEN 0
                WHEN (total_CD_actv_FY18/FY18_total_core_digital_consumed_units) <0 then 0
                else (total_CD_actv_FY18/FY18_total_core_digital_consumed_units) END as activation_rate_fy18,
           CASE WHEN ((coalesce(FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,0) = 0) OR (coalesce(total_CD_actv_FY19,0) = 0)) THEN 0
                WHEN (total_CD_actv_FY19/FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS) <0 then 0
                else (total_CD_actv_FY19/FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS) END as activation_rate_fy19,
           CASE WHEN ((coalesce(FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,0) = 0) OR (coalesce(total_CD_actv_FY20,0) = 0)) THEN 0
                WHEN (total_CD_actv_FY20/FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS) <0 then 0
                else (total_CD_actv_FY20/FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS) END as activation_rate_fy20,
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
           FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,
           FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,
           FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,
           TOTAL_CD_ACTV_FY18,
           TOTAL_CD_ACTV_FY19,
           TOTAL_CD_ACTV_FY20,
           TOTAL_CD_ACTV_WITHCU_FY18,
           TOTAL_CD_ACTV_WITHCU_FY19,
           TOTAL_CD_ACTV_WITHCU_FY20,
           case when FY18_FY19_adoption_transition = 'Digital Takeaway' then 'Digital Takeaway'
                when FY18_FY19_adoption_transition = 'Reinvent' then 'Reinvent'
                else 'Installed Base'
                end as FY18_FY19_adoption_transition_aggregated,
           case when FY19_FY20_adoption_transition = 'Digital Takeaway' then 'Digital Takeaway'
                when FY19_FY20_adoption_transition = 'Digital Loss' then 'Digital Loss'
                when FY19_FY20_adoption_transition = 'Reinvent' then 'Reinvent'
                when FY19_FY20_adoption_transition = 'Regression' then 'Regression'
                else 'Installed Base'
                end as FY19_FY20_adoption_transition_aggregated,
           case when discipline_category = 'Hardside' then FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as hardside_consumed_units,
           case when discipline_category = 'Softside' then FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as softside_consumed_units,
           case when discipline_category = 'B&E' then FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as be_consumed_units,
           case when discipline_category = 'Computing' then FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as computing_consumed_units,
           case when discipline_category = 'Career Ed' then FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as careered_consumed_units,
           case when discipline_category = 'Other' then FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as other_consumed_units
    from "STRATEGY"."ADOPTION_PIVOT"."MASTER_PIVOT_28OCT2019"
    where institution_nm <> 'Not Specified'
    and course_code_description <> '.'),

    fy19_unit_total as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           fy19_account_segment,
           fy20_account_segment,
           activation_rate_bucket_fy18,
           activation_rate_bucket_fy19,
           activation_rate_bucket_fy20,
           'FY19 starting value' as Adoption_Transition,
           FY18_FY19_adoption_transition_aggregated as PY_Adoption_Transition,
           sum(FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units_Growth,
           sum(FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units,
           sum(total_cd_actv_fy19)/1000 as Total_Core_Digital_Activations,
           sum(total_cd_actv_withcu_FY19)/1000 as Core_Digital_Activations_within_CU,
           0 as Hardside_Consumed_Units_Total,
           0 as Softside_Consumed_Units_Total,
           0 as BE_Consumed_Units_Total,
           0 as Computing_Consumed_Units_Total,
           0 as Careered_Consumed_Units_Total,
           0 as Other_Consumed_Units_Total
    from pivot_1
    group by 1,2,3,4,5,6,7,8,9,10,11),

    fy19_20_pivot as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           fy19_account_segment,
           fy20_account_segment,
           activation_rate_bucket_fy18,
           activation_rate_bucket_fy19,
           activation_rate_bucket_fy20,
           FY19_FY20_adoption_transition_aggregated as Adoption_Transition,
           FY18_FY19_adoption_transition_aggregated as PY_Adoption_Transition,
           ((FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS) - (FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS))/1000 as Core_Digital_Consumed_Units_Growth,
           (FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units,
           ((total_cd_actv_fy20) - (total_cd_actv_fy19))/1000 as Total_Core_Digital_Activations,
           ((total_cd_actv_withcu_FY20) - (total_cd_actv_withcu_FY19))/1000 as Core_Digital_Activations_within_CU,
           hardside_consumed_units/1000 as Hardside_Consumed_Units_Total,
           softside_consumed_units/1000 as Softside_Consumed_Units_Total,
           be_consumed_units/1000 as BE_Consumed_Units_Total,
           computing_consumed_units/1000 as Computing_Consumed_Units_Total,
           careered_consumed_units/1000 as Career_Ed_Consumed_Units_Total,
           other_consumed_units/1000 as Other_Consumed_Units_Total
    from pivot_1)

    select * from fy19_20_pivot
    UNION
    select * from fy19_unit_total

    ;;
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

  measure: sum_core_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Core Digital Consumed Units Growth"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_CONSUMED_UNITS_GROWTH";;
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

  measure: sum_other_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Other Disciplines"
    type: sum
    sql: ${TABLE}."OTHER_CONSUMED_UNITS_TOTAL";;
  }

  measure: sum_career_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Career Ed"
    type: sum
    sql: ${TABLE}."CAREER_ED_CONSUMED_UNITS_TOTAL";;
  }





  measure: sum_fy20_core_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Core Digital Consumed Units"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_CONSUMED_UNITS";;
  }

  measure: sum_core_digital_activations {
    value_format: "#,##0.0"
    label: "Total Core Digital Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_ACTIVATIONS";;
  }

  measure: sum_core_digital_activations_within_CU {
    value_format: "#,##0.0"
    label: "Core Digital Activations within CU"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_ACTIVATIONS_WITHIN_CU";;
  }

  }
