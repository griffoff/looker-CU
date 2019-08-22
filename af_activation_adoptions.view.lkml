view: af_activation_adoptions {
  derived_table: {
    sql: With activations as (
        Select COLUMN_HASH,PLATFORM, ACTV_TRIAL_PURCHASE,ACTV_DT, ACTV_CODE,entity_no,PRODUCT_SKEY,ACTV_USER_TYPE,ORGANIZATION,CU_FLG from  STG_CLTS.ACTIVATIONS_OLR activations_olr
        union all
        Select COLUMN_HASH,PLATFORM,ACTV_TRIAL_PURCHASE,ACTV_DT, ACTV_CODE,entity_no,PRODUCT_SKEY,ACTV_USER_TYPE,ORGANIZATION,CU_FLG from PROD.STG_CLTS.ACTIVATIONS_NON_OLR
      ),activations_1 as(
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
          CASE WHEN activations.PLATFORM  ilike 'webassign' AND (actv_trial_purchase ilike 'Continued Enrollment' OR actv_trial_purchase ilike 'Site License') then 'Y' else 'N' end as is_webassign_exclude,
          pf_master."COURSE_AS_PROVIDED_BY_PRD_TEAM"  AS "course_as_provided_by_prd_team",
      --  COUNT(DISTINCT activations.ACTV_CODE ) AS "activations_olr.actv_code_count"
          activations.ACTV_CODE as ACTV_CODE,
          activations.ACTV_USER_TYPE as ACTV_USER_TYPE,
          activations.ORGANIZATION as ORGANIZATION,
          activations.CU_FLG AS CU_FLG,
          activations.COLUMN_HASH AS COLUMN_HASH,
          dimdate.fiscalyearvalue as fiscalyear,
          ent.state_de as ent_state_de,
          concat(concat(concat(concat(institution_nm,'|'),course_as_provided_by_prd_team),'|'),prod.pub_series_de) as adoption_key
      FROM
          activations
      LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS prod
      ON activations.Product_Skey = prod.Product_Skey
      LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_ENTITIES ent
      ON activations.entity_no = ent.entity_no
      LEFT JOIN Uploads.CU.e1_product_family_master pf_master ON (pf_master."PF_CODE") = (prod."PROD_FAMILY_CD")
      LEFT JOIN prod.dw_ga.dim_date dimdate ON activations.actv_dt = dimdate.datevalue
      Where pf_master._file ilike 'E1 Product Family Master(12-20-18).csv'
      )

      select
        adoption_key,
        institution_nm,
        COUNT(CASE WHEN cu_flg = 'N' AND FISCALYEAR = 'FY18' THEN actv_code END) AS total_CD_actv_exCU_FY18,
        COUNT(CASE WHEN cu_flg = 'N' AND FISCALYEAR = 'FY19' THEN actv_code END) AS total_CD_actv_exCU_FY19,
        COUNT(CASE WHEN cu_flg = 'Y' AND FISCALYEAR = 'FY18' THEN actv_code END) AS total_CD_actv_withCU_FY18,
        COUNT(CASE WHEN cu_flg = 'Y' AND FISCALYEAR = 'FY19' THEN actv_code END) AS total_CD_actv_withCU_FY19,
        COUNT(CASE WHEN FISCALYEAR = 'FY18' THEN actv_code END) AS total_CD_actv_FY18,
        COUNT(CASE WHEN FISCALYEAR = 'FY19' THEN actv_code END) AS total_CD_actv_FY19
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

  set: detail {
    fields: [
      adoption_key,
      institution_nm,
      total_cd_actv_excu_fy18,
      total_cd_actv_excu_fy19,
      total_cd_actv_withcu_fy18,
      total_cd_actv_withcu_fy19,
      total_cd_actv_fy18,
      total_cd_actv_fy19
    ]
  }
}
