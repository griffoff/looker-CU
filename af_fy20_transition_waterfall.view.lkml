explore:  af_fy20_transition_waterfall{}
view: af_fy20_transition_waterfall{
  derived_table: {
    sql:
    with pivot_1 as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           FY19_account_type as FY19_account_segment,
           FY20_account_type as FY20_account_segment,
           ACTV_RATE_FY18,
           ACTV_RATE_FY19,
           ACTV_RATE_FY20,
           FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,
           FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,
           FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,
           TOTAL_CD_ACTV_FY18,
           TOTAL_CD_ACTV_FY19,
           TOTAL_CD_ACTV_FY20,
           TOTAL_CD_ACTV_WITHCU_FY18,
           TOTAL_CD_ACTV_WITHCU_FY19,
           TOTAL_CD_ACTV_WITHCU_FY20,
           case when FY19_FY20_adoption_transition = 'Digital Takeaway' then 'Digital Takeaway'
                when FY19_FY20_adoption_transition = 'Digital Loss' then 'Digital Loss'
                when FY19_FY20_adoption_transition = 'Reinvent' then 'Reinvent'
                when FY19_FY20_adoption_transition = 'Regression' then 'Regression'
                else 'Installed Base Same Adoption Growth'
                end as FY19_FY20_adoption_transition_aggregated
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
           actv_rate_fy18,
           actv_rate_fy19,
           actv_rate_fy20,
           'FY19 starting value' as Adoption_Transition,
           sum(FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS)/1000 as Core_Digital_Consumed_Units,
           sum(total_cd_actv_fy19)/1000 as Total_Core_Digital_Activations,
           sum(total_cd_actv_withcu_FY19)/1000 as Core_Digital_Activations_within_CU
    from pivot_1
    group by 1,2,3,4,5,6,7,8,9),

    fy19_20_pivot as (
    select institution_nm,
           pub_series_de,
           course_code_description,
           discipline_category,
           fy19_account_segment,
           fy20_account_segment,
           actv_rate_fy18,
           actv_rate_fy19,
           actv_rate_fy20,
           FY19_FY20_adoption_transition_aggregated as Adoption_Transition,
           ((FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS) - (FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS))/1000 as Core_Digital_Consumed_Units,
           ((total_cd_actv_fy20) - (total_cd_actv_fy19))/1000 as Total_Core_Digital_Activations,
           ((total_cd_actv_withcu_FY20) - (total_cd_actv_withcu_FY19))/1000 as Core_Digital_Activations_within_CU
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

  dimension: discipline_category {
    label: "Discipline Category"
  }

  dimension: actv_rate_fy18_bucket {
    label: "FY18 Activation Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [0,0.25,0.5,0.75]
    style: relational
    sql: ${TABLE}."ACTV_RATE_FY18"} ;;
  }

  dimension: actv_rate_fy19_bucket {
    label: "FY19 Activation Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [0,0.25,0.5,0.75]
    style: relational
    sql: ${TABLE}."ACTV_RATE_FY19"} ;;
  }

  dimension: actv_rate_fy20_bucket {
    label: "FY20 Activation Rate Bucket"
    value_format: "0.0%"
    type: tier
    tiers: [0,0.1,0.25,0.5,0.75]
    style: relational
    sql: ${TABLE}."ACTV_RATE_FY20"} ;;
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
