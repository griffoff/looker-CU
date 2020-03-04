view: activations_sales_order_forecasting {
  derived_table: {
    sql: WITH activations as (
        Select COLUMN_HASH,PLATFORM, ACTV_TRIAL_PURCHASE,ACTV_DT, ACTV_CODE,entity_no,PRODUCT_SKEY,ACTV_USER_TYPE,ORGANIZATION,CU_FLG from  STG_CLTS.ACTIVATIONS_OLR activations_olr
        union all
     Select COLUMN_HASH,PLATFORM,ACTV_TRIAL_PURCHASE,ACTV_DT, ACTV_CODE,entity_no,PRODUCT_SKEY,ACTV_USER_TYPE,ORGANIZATION,CU_FLG from PROD.STG_CLTS.ACTIVATIONS_NON_OLR
             )
      Select
          ent."INSTITUTION_NM"  AS "institution_nm",
          prod."PROD_FAMILY_CD"  AS "prod_family_cd",
          prod."PUB_SERIES_DE"  AS "pub_series_de",
          activations.ENTITY_NO  AS "entity_no",
          prod."MEDIA_TYPE_CD"  AS "media_type_cd",
          prod."MEDIA_TYPE_DE"  AS "media_type_de",
          prod."DIVISION_CD"  AS "division_cd",
          activations.PLATFORM  AS "platform",
          activations.ACTV_TRIAL_PURCHASE  AS "actv_trial_purchase",
          TO_CHAR(TO_DATE(activations.ACTV_DT ), 'YYYY-MM-DD') AS "actv_dt_date",
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

 ;;
persist_for: "240 hours"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: COLUMN_HASH {
    primary_key: yes
    hidden: yes
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."institution_nm" ;;
  }

  dimension: prod_family_cd {
    type: string
    sql: ${TABLE}."prod_family_cd" ;;
  }

  dimension: pub_series_de {
    type: string
    sql: ${TABLE}."pub_series_de" ;;
  }

  dimension: entity_no {
    type: string
    sql: ${TABLE}."entity_no" ;;
  }

  dimension: media_type_cd {
    type: string
    sql: ${TABLE}."media_type_cd" ;;
  }

  dimension: media_type_de {
    type: string
    sql: ${TABLE}."media_type_de" ;;
  }

  dimension: division_cd {
    type: string
    sql: ${TABLE}."division_cd" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."platform" ;;
  }

  dimension: actv_trial_purchase {
    type: string
    sql: ${TABLE}."actv_trial_purchase" ;;
  }

  dimension: actv_dt_date {
    type: string
    sql: ${TABLE}."actv_dt_date" ;;
  }

  dimension: is_webassign_exclude {
    type: string
    sql: ${TABLE}."IS_WEBASSIGN_EXCLUDE" ;;
  }

  dimension: course_as_provided_by_prd_team {
    type: string
    sql: ${TABLE}."course_as_provided_by_prd_team" ;;
  }

  dimension: actv_code {
    type: string
    sql: ${TABLE}."ACTV_CODE" ;;
  }

  dimension: actv_user_type {
    type: string
    sql: ${TABLE}."ACTV_USER_TYPE" ;;
  }

  dimension: organization {
    type: string
    sql: ${TABLE}."ORGANIZATION" ;;
  }

  dimension: cu_flg {
    type: string
    sql: ${TABLE}."CU_FLG" ;;
  }

  dimension: fiscalyear {
    type: string
    sql: ${TABLE}."FISCALYEAR" ;;
  }

  dimension: ent_state_de {
    type: string
    sql: ${TABLE}."ENT_STATE_DE" ;;
  }

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }

  measure: count_actv_code {
    label: "Activations Count"
    type: count_distinct
    sql: ${TABLE}."ACTV_CODE" ;;
  }

  measure: total_CD_IAC_Activation_ex_CU {
    label: "Total CD Activations (excluding CU)"
    type: sum
    sql: CASE WHEN ${media_type_cd} IN ('IAC','PAC') AND ${cu_flg} = 'N' THEN actv_code ELSE 0 END;;
  }

  measure: total_core_Activation_within_CU {
    label: "Total Core Digital Activations within CU "
    type: sum
    sql: CASE WHEN ${media_type_cd} IN ('IAC','PAC') AND ${cu_flg} = 'Y' THEN actv_code ELSE 0 END;;
  }

  measure: Total_CD_Activations  {
    label: "Total CD Activations"
    type: count_distinct
    sql: CASE WHEN ${media_type_cd} IN ('IAC','PAC') AND ${cu_flg} IN ('Y','N') THEN ${COLUMN_HASH} END ;;
  }


  set: detail {
    fields: [
      institution_nm,
      prod_family_cd,
      pub_series_de,
      entity_no,
      media_type_cd,
      media_type_de,
      division_cd,
      platform,
      actv_trial_purchase,
      actv_dt_date,
      is_webassign_exclude,
      course_as_provided_by_prd_team,
      actv_code,
      actv_user_type,
      organization,
      fiscalyear,
      ent_state_de,
      adoption_key
    ]
  }
}
