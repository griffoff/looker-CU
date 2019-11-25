explore: af_adoption_level_data {}
view: af_adoption_level_data {
derived_table: {
  sql:  with relevant_adoptions as (
        select adoption_key,
               case when (FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS = 0 AND FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS = 0 AND FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS = 0
                          AND TOTAL_CD_ACTV_FY18 = 0 AND TOTAL_CD_ACTV_FY19 = 0 AND TOTAL_CD_ACTV_FY20 = 0) then 'Remove'
                   else 'Keep' end as relevant_adoption_flag
        from "STRATEGY"."ADOPTION_PIVOT"."MASTER_PIVOT_28OCT2019"
        where institution_nm <> 'Not Specified'
        and course_code_description <> '.')

        select pivot.adoption_key,
              institution_nm,
              pub_series_de,
              course_code_description,
              discipline_category,
              CASE WHEN FY19_account_type = 'Rest of Business' then 'Medium CU Penetration'
                ELSE FY19_account_type end as FY19_account_segment,
              CASE WHEN FY20_account_type = 'Rest of Business' then 'Medium CU Penetration'
                ELSE FY20_account_type end as FY20_account_segment,
              FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS,
              FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,
              FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS,
              TOTAL_CD_ACTV_FY18,
              TOTAL_CD_ACTV_FY19,
              TOTAL_CD_ACTV_FY20,
              TOTAL_CD_ACTV_WITHCU_FY19,
              TOTAL_CD_ACTV_WITHCU_FY20,
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
              CASE WHEN ((coalesce(TOTAL_CD_ACTV_FY19,0) = 0) OR (coalesce(TOTAL_CD_ACTV_WITHCU_FY19,0) = 0)) THEN 0
                   WHEN (TOTAL_CD_ACTV_WITHCU_FY19/TOTAL_CD_ACTV_FY19) <0 then 0
                   else (TOTAL_CD_ACTV_WITHCU_FY19/TOTAL_CD_ACTV_FY19) END as cu_pen_fy19,
              CASE WHEN ((coalesce(TOTAL_CD_ACTV_FY20,0) = 0) OR (coalesce(TOTAL_CD_ACTV_WITHCU_FY20,0) = 0)) THEN 0
                   WHEN (TOTAL_CD_ACTV_WITHCU_FY20/TOTAL_CD_ACTV_FY20) <0 then 0
                   else (TOTAL_CD_ACTV_WITHCU_FY20/TOTAL_CD_ACTV_FY20) END as cu_pen_fy20,
              FY18_FY19_adoption_transition,
              FY19_FY20_adoption_transition
        from "STRATEGY"."ADOPTION_PIVOT"."MASTER_PIVOT_28OCT2019" pivot
        left join relevant_adoptions adoptions on adoptions.adoption_key = pivot.adoption_key
        where institution_nm <> 'Not Specified'
        and course_code_description <> '.'
        and adoptions.relevant_adoption_flag = 'Keep'




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

  dimension: FY19_FY20_adoption_transition {
    label: "FY19->FY20 Adoption Transition"
  }

  dimension: FY18_FY19_adoption_transition {
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

  dimension: activation_rate_fy18 {
    type: number
    label: "FY18 Activation Rate"
    value_format: "0%"
  }

  dimension: activation_rate_fy19 {
    type: number
    label: "FY19 Activation Rate"
    value_format: "0%"
  }

  dimension: activation_rate_fy20 {
    type: number
    label: "FY20 Activation Rate"
    value_format: "0%"
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

  dimension: cu_pen_fy19 {
    type: number
    label: "FY19 CU Penetration"
    value_format: "0%"
  }

  dimension: cu_pen_fy20 {
    type: number
    label: "FY20 CU Penetration"
    value_format: "0%"
  }

  measure: sum_FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS {
    value_format: "#,##0"
    label: "FY18 Courseware Consumed Units"
    type: sum
    sql: ${TABLE}."FY18_TOTAL_CORE_DIGITAL_CONSUMED_UNITS";;
  }

  measure: sum_FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS {
    value_format: "#,##0"
    label: "FY19 Courseware Consumed Units"
    type: sum
    sql: ${TABLE}."FY19_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS";;
  }

  measure: sum_FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS {
    value_format: "#,##0"
    label: "FY20 Courseware Consumed Units"
    type: sum
    sql: ${TABLE}."FY20_UNADJUSTED_CORE_DIGITAL_CONSUMED_UNITS";;
  }

  measure: sum_TOTAL_CD_ACTV_FY18 {
    value_format: "#,##0"
    label: "FY18 Total Courseware Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY18";;
  }

  measure: sum_TOTAL_CD_ACTV_FY19 {
    value_format: "#,##0"
    label: "FY19 Total Courseware Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY19";;
  }

  measure: sum_TOTAL_CD_ACTV_FY20 {
    value_format: "#,##0"
    label: "FY20 Total Courseware Activations"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_FY20";;
  }

  measure: sum_TOTAL_CD_ACTV_WITHCU_FY19 {
    value_format: "#,##0"
    label: "FY19 Courseware Activations within CU"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY19";;
  }

  measure: sum_TOTAL_CD_ACTV_WITHCU_FY20 {
    value_format: "#,##0"
    label: "FY20 Courseware Activations within CU"
    type: sum
    sql: ${TABLE}."TOTAL_CD_ACTV_WITHCU_FY20";;
  }

}
