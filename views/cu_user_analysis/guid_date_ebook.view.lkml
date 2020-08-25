explore: guid_date_ebook {}

view: guid_date_ebook {
  derived_table: {
    create_process: {
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      AS
      WITH activations_olr_no_context_id AS (
      SELECT DISTINCT coalesce(su.LINKED_GUID,a.USER_GUID) AS user_sso_guid
        , actv_dt AS course_start
        , DATEADD(W,16,actv_dt) AS course_end
        , actv_dt AS activation_date
        , a.platform
        , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
        , CASE WHEN e.mkt_seg_maj_cd = 'PSE' AND e.mkt_seg_min_cd in ('056','060') THEN 'Career'
                WHEN e.mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
                ELSE 'Other' END AS organization
      FROM prod.STG_CLTS.ACTIVATIONS_OLR a
      LEFT JOIN prod.datavault.hub_user hu ON a.USER_GUID = hu.UID
      LEFT JOIN prod.datavault.SAT_USER_V2 su ON hu.hub_user_key = su.hub_user_key AND su._LATEST
      LEFT JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
      LEFT JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key and sui.active
      LEFT JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
      LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
      LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
      LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON a.actv_isbn = PRODUCT.isbn13
      WHERE CONTEXT_ID IS NULL
        AND ACTV_DT > '2017-07-01'
        AND lower(actv_user_type) = 'student'
        AND (a.PLATFORM = 'MindTap Reader' OR PRINT_DIGITAL_CONFIG_CD = '000')
        AND ACTV_TRIAL_PURCHASE NOT IN ('Trial','Duplicate')
        AND code_source <> 'Locker'
        AND ui.hub_user_key IS NULL
      )
      ,ebook_users AS (
      (
      SELECT user_sso_guid
        , course_start AS ebook_start
        , course_end AS ebook_end
        , course_start AS subscription_start
        , course_end AS subscription_end
        , 'Full Access' AS subscription_type
        , 'Activations OLR' AS source
        , region
        , platform
        , organization
      FROM activations_olr_no_context_id
      )
      UNION
      (
      SELECT ss.user_sso_guid
        , ss.registration_date AS ebook_start
        , DATEADD(week,LEAST(16,ss.subscription_length_in_days),ss.registration_date) as ebook_end
        , ebook_start AS subscription_start
        , ebook_end AS subscription_end
        , 'Full Access' AS subscription_type
        , 'Serial Number Consumed' AS source
        , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
        , CASE WHEN p.platform IS NOT NULL THEN p.platform ELSE 'Other eBook' END AS platform
        , CASE WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
                WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
                ELSE 'Other' END AS organization
      FROM prod.datavault.hub_product hp
      INNER JOIN prod.datavault.SAT_SERIAL_NUMBER_CONSUMED ss ON hp.pid = ss.product_id and ss._LATEST
      INNER JOIN prod.datavault.sat_product_olr sp ON hp.HUB_PRODUCT_KEY = sp.hub_product_key and sp._LATEST
      INNER JOIN prod.datavault.hub_user hu on ss.user_sso_guid = hu.uid
      LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
      LEFT JOIN prod.STG_CLTS.ENTITIES e ON ss.institution_id = e.ENTITY_NO
      LEFT JOIN prod.stg_clts.products p on ss.referring_isbn = p.isbn13
      WHERE sp.type IN ('MTR','SMEB')
        AND ss.user_type = 'student'
        AND ui.hub_user_key IS NULL
      )
      UNION
      (
      SELECT pp.USER_SSO_GUID
        , pp.date_added AS ebook_start
        , case when pp.expiration_date < pp.date_added then dateadd(week,16,ebook_start)
          else least(dateadd(week,16,ebook_start),pp.expiration_date)
          end as ebook_end
        , COALESCE(ss.subscription_start, bp._effective_from) AS subscription_start
        , COALESCE(COALESCE(ss.cancelled_time, ss.subscription_end), COALESCE(bp._effective_to, CURRENT_DATE())) AS subscription_end
        , CASE WHEN ss.subscription_start IS NOT NULL THEN ss.subscription_plan_id WHEN bp.subscription_start IS NOT NULL THEN bp.subscription_state END AS subscription_type
        , 'Provisioned Product' AS source
        , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
        , CASE WHEN p.platform IS NOT NULL THEN p.platform ELSE 'Other eBook' END AS platform
        , CASE WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
                WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
                ELSE 'Other' END AS organization
      FROM prod.datavault.hub_product hp
      INNER JOIN prod.datavault.sat_provisioned_product_v2 pp ON hp.pid = pp.product_id AND pp._latest
      INNER JOIN prod.datavault.sat_product_olr sp ON hp.hub_product_key = sp.hub_product_key AND sp._latest
      LEFT JOIN prod.datavault.hub_subscription hs ON pp.source_id = hs.subscription_id
      LEFT JOIN prod.datavault.sat_subscription_sap ss ON hs.hub_subscription_key = ss.hub_subscription_key AND ss._LATEST
      LEFT JOIN prod.datavault.sat_subscription_bp bp ON hs.hub_subscription_key = bp.hub_subscription_key AND pp.USER_SSO_GUID = bp.USER_SSO_GUID AND bp.SUBSCRIPTION_STATE NOT IN ('no_access','banned','cancelled')
      INNER JOIN prod.datavault.hub_user hu on pp.user_sso_guid = hu.uid
      LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
      LEFT JOIN prod.stg_clts.products p ON pp.IAC_ISBN = p.ISBN13
      LEFT JOIN prod.STG_CLTS.ENTITIES e ON pp.institution_id = e.ENTITY_NO
      WHERE sp.type IN ('MTR', 'SMEB')
        AND pp.user_type = 'student'
        AND subscription_type IS NOT NULL
        AND ui.hub_user_key IS NULL
      )
      )
      SELECT DISTINCT dim_date.datevalue as date, user_sso_guid, 'eBook' AS content_type, region, platform, organization
        , CASE WHEN (subscription_type ILIKE 'Full%' OR subscription_type ILIKE 'Limited%' OR (subscription_type ILIKE 'CU-ETextBook%' AND subscription_type NOT ILIKE 'CU-ETextBook-Trial%')) THEN TRUE ELSE FALSE END AS paid_flag
      FROM  ${dim_date.SQL_TABLE_NAME} dim_date
      LEFT JOIN ebook_users ON dim_date.datevalue BETWEEN ebook_start AND ebook_end
        AND dim_date.datevalue BETWEEN subscription_start AND subscription_end
      WHERE dim_date.datevalue BETWEEN '2017-07-01' AND CURRENT_DATE()
      ORDER BY 1

      ;;

      sql_step: ALTER TABLE ${SQL_TABLE_NAME} CLUSTER BY (date) ;;
      sql_step: ALTER TABLE ${SQL_TABLE_NAME} RECLUSTER ;;

    }

    datagroup_trigger: daily_refresh
  }

  dimension: user_sso_guid {
    type: string
  }

  dimension: date {
    type: date
  }

  dimension: content_type {
    type: string
  }

  dimension: paid_flag {
    type: string
  }

#   dimension: source {
#     type: string
#   }

  dimension: region {
    type: string
  }

  dimension: platform {
    type: string
  }

  dimension: organization {
    type: string
  }

  measure: num_users {
    type: count_distinct
    sql: ${TABLE}.user_sso_guid ;;
    label: "# Users "
  }

}
