explore: af_fy19_transition_waterfall {}
view: af_fy19_transition_waterfall{
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
           case when FY18_FY19_adoption_transition = 'Digital Takeaway' then 'Courseware Takeaway'
                when FY18_FY19_adoption_transition = 'Digital Loss' then 'Courseware Loss'
                when FY18_FY19_adoption_transition = 'Reinvent' then 'Reinvent'
                when FY18_FY19_adoption_transition = 'Regression' then 'Regression'
                else 'Installed Base'
                end as FY18_FY19_adoption_transition_aggregated,
           case when discipline_category = 'Hardside' then FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as hardside_consumed_units,
           case when discipline_category = 'Softside' then FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as softside_consumed_units,
           case when discipline_category = 'B&E' then FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as be_consumed_units,
           case when discipline_category = 'Computing' then FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as computing_consumed_units,
           case when discipline_category = 'Career Ed' then FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS else '0' end as careered_consumed_units
    from "STRATEGY"."ADOPTION_PIVOT"."MASTER_PIVOT_28OCT2019"
    where institution_nm <> 'Not Specified'
    and course_code_description <> '.'),

    fy18_unit_total as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           fy19_account_segment,
           fy20_account_segment,
           activation_rate_bucket_fy18,
           activation_rate_bucket_fy19,
           activation_rate_bucket_fy20,
           'FY18 ending value' as Adoption_Transition,
           sum(FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units,
           sum(total_cd_actv_fy18)/1000 as Total_Core_Digital_Activations,
           sum(total_cd_actv_withcu_FY18)/1000 as Core_Digital_Activations_within_CU,
           0 as Hardside_Consumed_Units_Total,
           0 as Softside_Consumed_Units_Total,
           0 as BE_Consumed_Units_Total,
           0 as Computing_Consumed_Units_Total,
           0 as Career_Ed_Consumed_Units_Total,
           case when FY19_account_segment = 'CU-I Institution' then 1
                when FY19_account_segment = 'High IA Penetration' then 2
                when FY19_account_segment = 'High CU Penetration' then 3
                when FY19_account_segment = 'Medium CU Penetration' then 4
                else 5 end as account_segment_order
    from pivot_1
    group by 1,2,3,4,5,6,7,8,9),

    fy18_19_pivot as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           fy19_account_segment,
           fy20_account_segment,
           activation_rate_bucket_fy18,
           activation_rate_bucket_fy19,
           activation_rate_bucket_fy20,
           FY18_FY19_adoption_transition_aggregated as Adoption_Transition,
           ((FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS) - (FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS))/1000 as Core_Digital_Consumed_Units,
           ((total_cd_actv_fy19) - (total_cd_actv_fy18))/1000 as Total_Core_Digital_Activations,
           ((total_cd_actv_withcu_FY19) - (total_cd_actv_withcu_FY18))/1000 as Core_Digital_Activations_within_CU,
           hardside_consumed_units/1000 as Hardside_Consumed_Units_Total,
           softside_consumed_units/1000 as Softside_Consumed_Units_Total,
           be_consumed_units/1000 as BE_Consumed_Units_Total,
           computing_consumed_units/1000 as Computing_Consumed_Units_Total,
           nvl(careered_consumed_units,0)/1000 as Career_Ed_Consumed_Units_Total,
           case when FY19_account_segment = 'CU-I Institution' then 1
                when FY19_account_segment = 'High IA Penetration' then 2
                when FY19_account_segment = 'High CU Penetration' then 3
                when FY19_account_segment = 'Medium CU Penetration' then 4
                else 5 end as account_segment_order
    from pivot_1)

    select * from fy18_unit_total
    UNION
    select * from fy18_19_pivot

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

  dimension: account_segment_order {
    label: "Account Segment Order"
  }

  measure: sum_core_digital_consumed_units {
    value_format: "#,##0.0"
    label: "Courseware Consumed Units"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_CONSUMED_UNITS";;
  }

  measure: sum_core_digital_activations {
    value_format: "#,##0.0"
    label: "Total Courseware Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CORE_DIGITAL_ACTIVATIONS";;
  }

  measure: sum_core_digital_activations_within_CU {
    value_format: "#,##0.0"
    label: "Courseware Activations within CU"
    type: sum
    sql: ${TABLE}."CORE_DIGITAL_ACTIVATIONS_WITHIN_CU";;
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

}
