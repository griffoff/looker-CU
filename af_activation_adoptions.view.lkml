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
          coalesce(pfmt.COURSE_CODE_DESCRIPTION,'.') as course_code_description,
          activations.ACTV_USER_TYPE as ACTV_USER_TYPE,
          activations.ORGANIZATION as ORGANIZATION,
          activations.CU_FLG AS CU_FLG,
          dimdate.fiscalyearvalue as fiscalyear,
          ent.state_cd as state_cd,
          concat(concat(concat(concat(concat(concat(institution_nm,'|'),state_cd),'|'),coalesce(pfmt.COURSE_CODE_DESCRIPTION,'.')),'|'),prod.pub_series_de) as adoption_key,
          concat(concat(concat(concat(institution_nm,'|'),coalesce(pfmt.COURSE_CODE_DESCRIPTION,'.')),'|'),prod.pub_series_de) as old_adoption_key,
          sum(case when activations.platform = 'WebAssign' then activations.ACTV_COUNT_WO_SITELIC else activations.ACTV_COUNT_W_SITELIC end) AS actv_count
      FROM raw_actv activations
      LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS prod
      ON activations.Product_Skey = prod.Product_Skey
      LEFT JOIN STRATEGY.ADOPTION_PIVOT.ENTITIES_ADOPTIONPIVOT ent
      ON activations.entity_no = ent.entity_no
      LEFT JOIN STRATEGY.ADOPTION_PIVOT.PFMT_ADOPTIONPIVOT pfmt on pfmt.product_family_code = prod.prod_family_cd
      JOIN prod.dw_ga.dim_date dimdate ON to_date(activations.actv_dt) = dimdate.datevalue
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
      ),

      primary_platform as (
      select adoption_key,
             platform,
             fiscalyear,
             sum(actv_count) as actv_count
      from activations_1
      where ORGANIZATION = 'Higher Ed'
      AND actv_trial_purchase IN ('Site License','Purchase')
      AND ACTV_USER_TYPE = 'student'
      AND platform IN ('4LTR Online','Aplia', 'CNOW', 'Diet Analysis Plus', 'Insite', 'MindTap', 'OWL V2', 'Quia', 'SAM', 'Speech Studio', 'WebAssign', 'Write Experience')
      group by 1,2,3),

      primary_platform2 as (
             select adoption_key,
             platform,
             actv_count,
             fiscalyear,
             row_number() over (partition by adoption_key,fiscalyear order by actv_count desc) as primary_platform_flag
      from primary_platform),

      primary_platform3 as (
             select plat.adoption_key,
             case when fiscalyear = 'FY17' then plat.platform else null end as fy17_primary_platform,
             case when fiscalyear = 'FY18' then plat.platform else null end as fy18_primary_platform,
             case when fiscalyear = 'FY19' then plat.platform else null end as fy19_primary_platform
      from primary_platform2 plat
      where primary_platform_flag = '1'
      order by 1),


      primary_platform4 as (
      select adoption_key,
             coalesce(max(fy17_primary_platform), 'No Activations') as act_fy17_primary_platform,
             coalesce(max(fy18_primary_platform), 'No Activations') as act_fy18_primary_platform,
             coalesce(max(fy19_primary_platform), 'No Activations') as act_fy19_primary_platform
      from primary_platform3
      group by 1)

      select
        act.adoption_key as act_adoption_key,
        act.old_adoption_key as act_old_adoption_key,
        act.institution_nm as act_institution_nm,
        act.state_cd as act_state_cd,
        act.course_code_description as act_course_code_description,
        act.pub_series_de as act_pub_series_de,
        plat.act_fy17_primary_platform,
        plat.act_fy18_primary_platform,
        plat.act_fy19_primary_platform,
        sum(CASE WHEN act.cu_flg = 'N' AND act.FISCALYEAR = 'FY17' THEN act.actv_count END) AS total_CD_actv_exCU_FY17,
        sum(CASE WHEN act.cu_flg = 'N' AND act.FISCALYEAR = 'FY18' THEN act.actv_count END) AS total_CD_actv_exCU_FY18,
        sum(CASE WHEN act.cu_flg = 'N' AND act.FISCALYEAR = 'FY19' THEN act.actv_count END) AS total_CD_actv_exCU_FY19,
        sum(CASE WHEN act.cu_flg = 'Y' AND act.FISCALYEAR = 'FY17' THEN act.actv_count END) AS total_CD_actv_withCU_FY17,
        sum(CASE WHEN act.cu_flg = 'Y' AND act.FISCALYEAR = 'FY18' THEN act.actv_count END) AS total_CD_actv_withCU_FY18,
        sum(CASE WHEN act.cu_flg = 'Y' AND act.FISCALYEAR = 'FY19' THEN act.actv_count END) AS total_CD_actv_withCU_FY19,
        sum(CASE WHEN act.FISCALYEAR = 'FY17' THEN act.actv_count END) AS total_CD_actv_FY17,
        sum(CASE WHEN act.FISCALYEAR = 'FY18' THEN act.actv_count END) AS total_CD_actv_FY18,
        sum(CASE WHEN act.FISCALYEAR = 'FY19' THEN act.actv_count END) AS total_CD_actv_FY19
      from activations_1 act
      left join primary_platform4 plat on plat.adoption_key = act.adoption_key
      where act.ORGANIZATION = 'Higher Ed'
      AND act.actv_trial_purchase IN ('Site License','Purchase')
      AND act.ACTV_USER_TYPE = 'student'
      AND act.platform IN ('4LTR Online','Aplia', 'CNOW', 'Diet Analysis Plus', 'Insite', 'MindTap', 'OWL V2', 'Quia', 'SAM', 'Speech Studio', 'WebAssign', 'Write Experience')
      group by 1,2,3,4,5,6,7,8,9

 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: act_adoption_key {
    type: string
    sql: ${TABLE}."ACT_ADOPTION_KEY" ;;
  }

  dimension: act_old_adoption_key {
    type: string
    sql: ${TABLE}."ACT_OLD_ADOPTION_KEY" ;;
  }

  dimension: act_institution_nm {
    type: string
    sql: ${TABLE}."ACT_INSTITUTION_NM" ;;
  }

  dimension: act_state_cd {
    type: string
    sql: ${TABLE}."ACT_STATE_CD" ;;
  }

  dimension: act_course_code_description {
    type: string
    sql: ${TABLE}."ACT_COURSE_CODE_DESCRIPTION" ;;
  }

  dimension: act_pub_series_de {
    type: string
    sql: ${TABLE}."ACT_PUB_SERIES_DE" ;;
  }

  dimension: act_fy17_primary_platform {
    type: string
    sql: ${TABLE}."act_FY17_PRIMARY_PLATFORM" ;;
  }

  dimension: act_fy18_primary_platform {
    type: string
    sql: ${TABLE}."act_FY18_PRIMARY_PLATFORM" ;;
  }

  dimension: act_fy19_primary_platform {
    type: string
    sql: ${TABLE}."act_FY19_PRIMARY_PLATFORM" ;;
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
      act_adoption_key,
      act_old_adoption_key,
      act_institution_nm,
      act_state_cd,
      act_course_code_description,
      act_pub_series_de,
      act_fy17_primary_platform,
      act_fy18_primary_platform,
      act_fy19_primary_platform,
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
