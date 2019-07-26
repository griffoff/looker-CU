explore: activations_for_salesorder_adoptions {}
view: activations_for_salesorder_adoptions {
    derived_table: {
      sql: WITH activations as (
        Select PLATFORM, ACTV_TRIAL_PURCHASE,ACTV_DT, ACTV_CODE,entity_no,PRODUCT_SKEY from  STG_CLTS.ACTIVATIONS_OLR activations_olr
        union all
     Select PLATFORM,ACTV_TRIAL_PURCHASE,ACTV_DT, ACTV_CODE,entity_no,PRODUCT_SKEY from PROD.STG_CLTS.ACTIVATIONS_NON_OLR
             )
Select dm_entities."INSTITUTION_NM"  AS "dm_entities.institution_nm",
  dm_products."PROD_FAMILY_CD"  AS "dm_products.prod_family_cd",
  dm_products."PUB_SERIES_DE"  AS "dm_products.pub_series_de",
  activations.ENTITY_NO  AS "activations_olr.entity_no",
  dm_products."MEDIA_TYPE_CD"  AS "dm_products.media_type_cd",
  dm_products."MEDIA_TYPE_DE"  AS "dm_products.media_type_de",
  dm_products."DIVISION_CD"  AS "dm_products.division_cd",
  activations.PLATFORM  AS "activations_olr.platform",
  activations.ACTV_TRIAL_PURCHASE  AS "activations_olr.actv_trial_purchase",
  TO_CHAR(TO_DATE(activations.ACTV_DT ), 'YYYY-MM-DD') AS "activations_olr.actv_dt_date",
    CASE WHEN activations.PLATFORM  ilike 'webassign' AND (actv_trial_purchase ilike 'Continued Enrollment' OR actv_trial_purchase ilike 'Site License') then 'Y' else 'N' end as is_webassign_exclude,
  e1_product_family_master."COURSE_AS_PROVIDED_BY_PRD_TEAM"  AS "e1_product_family_master.course_as_provided_by_prd_team",
--  COUNT(DISTINCT activations.ACTV_CODE ) AS "activations_olr.actv_code_count"
 activations.ACTV_CODE as ACTV_CODE
from
    activations
Left Join DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS dm_products
ON activations.Product_Skey = dm_products.Product_Skey
LEFT JOIN DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_ENTITIES dm_entities
ON activations.entity_no = dm_entities.entity_no
LEFT JOIN Uploads.CU.e1_product_family_master ON (e1_product_family_master."PF_CODE") = (dm_products."PROD_FAMILY_CD")

 ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: dm_entities_institution_nm {
      type: string
      sql: ${TABLE}."dm_entities.institution_nm" ;;
    }

    dimension: dm_products_prod_family_cd {
      type: string
      sql: ${TABLE}."dm_products.prod_family_cd" ;;
    }

    dimension: dm_products_pub_series_de {
      type: string
      sql: ${TABLE}."dm_products.pub_series_de" ;;
    }

    dimension: activations_olr_entity_no {
      type: string
      sql: ${TABLE}."activations_olr.entity_no" ;;
    }

    dimension: dm_products_media_type_cd {
      type: string
      sql: ${TABLE}."dm_products.media_type_cd" ;;
    }

    dimension: dm_products_media_type_de {
      type: string
      sql: ${TABLE}."dm_products.media_type_de" ;;
    }

    dimension: dm_products_division_cd {
      type: string
      sql: ${TABLE}."dm_products.division_cd" ;;
    }

    dimension: activations_olr_platform {
      type: string
      sql: ${TABLE}."activations_olr.platform" ;;
    }

    dimension: activations_olr_actv_trial_purchase {
      type: string
      sql: ${TABLE}."activations_olr.actv_trial_purchase" ;;
    }

    dimension: activations_olr_actv_dt_date {
      type: string
      sql: ${TABLE}."activations_olr.actv_dt_date" ;;
    }

    dimension: is_webassign_exclude {
      type: string
      sql: ${TABLE}."IS_WEBASSIGN_EXCLUDE" ;;
    }

    dimension: e1_product_family_master_course_as_provided_by_prd_team {
      type: string
      sql: ${TABLE}."e1_product_family_master.course_as_provided_by_prd_team" ;;
    }

    dimension: actv_code {
      type: string
      sql: ${TABLE}."ACTV_CODE" ;;
      primary_key: yes
    }

    measure: count_actv_code {
      type: count_distinct
      sql: ${TABLE}."ACTV_CODE" ;;
    }

    set: detail {
      fields: [
        dm_entities_institution_nm,
        dm_products_prod_family_cd,
        dm_products_pub_series_de,
        activations_olr_entity_no,
        dm_products_media_type_cd,
        dm_products_media_type_de,
        dm_products_division_cd,
        activations_olr_platform,
        activations_olr_actv_trial_purchase,
        activations_olr_actv_dt_date,
        is_webassign_exclude,
        e1_product_family_master_course_as_provided_by_prd_team,
        actv_code
      ]
    }
  }

