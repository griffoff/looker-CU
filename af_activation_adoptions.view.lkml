explore: af_activation_adoptions {}

view: af_activation_adoptions {
  derived_table: {
    sql:with raw_actv as (select * from STRATEGY.ADOPTION_PIVOT.FY17_ACTIVATIONS_ADOPTIONPIVOT UNION select * from STRATEGY.ADOPTION_PIVOT.FY18_ACTIVATIONS_ADOPTIONPIVOT UNION select * from STRATEGY.ADOPTION_PIVOT.FY19_ACTIVATIONS_ADOPTIONPIVOT),
        activations_1 as(
        Select
          ent."INSTITUTION_NM"  AS institution_nm,
          prod."PROD_FAMILY_CD"  AS prod_family_cd,
          prod."PUB_SERIES_DE"  AS pub_series_de,
          activations.ENTITY_NO  AS entity_no,
          prod."MEDIA_TYPE_CD"  AS media_type_cd,
          prod."MEDIA_TYPE_DE"  AS media_type_de,
          prod."DIVISION_CD"  AS division_cd,
          activations.PLATFORM  AS platform,
          activations.ACTV_TRIAL_PURCHASE  AS actv_trial_purchase,
          TO_CHAR(TO_DATE(activations.ACTV_DT ), 'YYYY-MM-DD') AS actv_dt_date,
          pfmt.COURSE_CODE_DESCRIPTION,
          activations.ACTV_USER_TYPE as ACTV_USER_TYPE,
          activations.ORGANIZATION as ORGANIZATION,
          activations.CU_FLG AS CU_FLG,
          dimdate.fiscalyearvalue as fiscalyear,
          ent.state_cd as ent_state_cd,
          concat(concat(concat(concat(institution_nm,'|'),pfmt.COURSE_CODE_DESCRIPTION),'|'),prod.pub_series_de) as adoption_key,
          sum(case when activations.platform = 'WebAssign' then activations.ACTV_COUNT_WO_SITELIC else activations.ACTV_COUNT_W_SITELIC end) AS actv_count
      FROM raw_actv activations
      LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS prod
      ON activations.Product_Skey = prod.Product_Skey
      LEFT JOIN STRATEGY.DW.DM_ENTITIES ent
      ON activations.entity_no = ent.entity_no
      LEFT JOIN STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd
      JOIN prod.dw_ga.dim_date dimdate ON to_date(activations.actv_dt) = dimdate.datevalue
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
      )

      select
        adoption_key,
        institution_nm,
        sum(CASE WHEN cu_flg = 'N' AND FISCALYEAR = 'FY17' THEN actv_count END) AS total_CD_actv_exCU_FY17,
        sum(CASE WHEN cu_flg = 'N' AND FISCALYEAR = 'FY18' THEN actv_count END) AS total_CD_actv_exCU_FY18,
        sum(CASE WHEN cu_flg = 'N' AND FISCALYEAR = 'FY19' THEN actv_count END) AS total_CD_actv_exCU_FY19,
        sum(CASE WHEN cu_flg = 'Y' AND FISCALYEAR = 'FY17' THEN actv_count END) AS total_CD_actv_withCU_FY17,
        sum(CASE WHEN cu_flg = 'Y' AND FISCALYEAR = 'FY18' THEN actv_count END) AS total_CD_actv_withCU_FY18,
        sum(CASE WHEN cu_flg = 'Y' AND FISCALYEAR = 'FY19' THEN actv_count END) AS total_CD_actv_withCU_FY19,
        sum(CASE WHEN FISCALYEAR = 'FY17' THEN actv_count END) AS total_CD_actv_FY17,
        sum(CASE WHEN FISCALYEAR = 'FY18' THEN actv_count END) AS total_CD_actv_FY18,
        sum(CASE WHEN FISCALYEAR = 'FY19' THEN actv_count END) AS total_CD_actv_FY19
      from activations_1
      where
        ORGANIZATION = 'Higher Ed' AND actv_trial_purchase IN ('Site License','Purchase')
      AND ACTV_USER_TYPE = 'student' and
        platform IN
        ('4LTR Online','Aplia', 'CNOW', 'Diet Analysis Plus', 'Insite', 'MindTap', 'OWL V2', 'Quia', 'SAM', 'Speech Studio', 'WebAssign', 'Write Experience')
      group by 1,2

 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
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

  set: detail {
    fields: [
      adoption_key,
      institution_nm,
      total_cd_actv_excu_fy17,
      total_cd_actv_excu_fy18,
      total_cd_actv_excu_fy19,
      total_cd_actv_withcu_fy17,
      total_cd_actv_withcu_fy18,
      total_cd_actv_withcu_fy19,
      total_cd_actv_fy18,
      total_cd_actv_fy19
    ]
  }
}
