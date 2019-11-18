explore:  af_fy19_transition_waterfall{}
view: af_fy19_transition_waterfall{
  derived_table: {
    sql:
    with pivot_1 as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           FY19_account_type as FY19_account_segment,
           FY20_account_type as FY20_account_segment,
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
                when FY18_FY19_adoption_transition = 'Digital Loss' then 'Digital Loss'
                when FY18_FY19_adoption_transition = 'Reinvent' then 'Reinvent'
                when FY18_FY19_adoption_transition = 'Regression' then 'Regression'
                else 'Installed Base'
                end as FY18_FY19_adoption_transition_aggregated
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
           'FY18 starting value' as Adoption_Transition,
           sum(FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units,
           sum(total_cd_actv_fy18)/1000 as Total_Core_Digital_Activations,
           sum(total_cd_actv_withcu_FY18)/1000 as Core_Digital_Activations_within_CU
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
           ((total_cd_actv_withcu_FY19) - (total_cd_actv_withcu_FY18))/1000 as Core_Digital_Activations_within_CU
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

  measure: sum_core_digital_consumed_units {
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
