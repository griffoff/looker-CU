explore: guid_date_ebook {}

view: guid_date_ebook {
  derived_table: {
    sql:
    WITH activations_olr AS (
    SELECT PRODUCT.PRINT_DIGITAL_CONFIG_CD as content_code
      , product.PRINT_DIGITAL_CONFIG_DE as content_descr
      , product.DIVISION_CD
      , coalesce(m.PRIMARY_GUID,a.USER_GUID) AS merged_guid
      , a.*
    FROM prod.STG_CLTS.ACTIVATIONS_OLR a
    LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m on a.USER_GUID = m.PARTNER_GUID
    LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON a.actv_isbn = PRODUCT.isbn13
    )
    ,activations_olr_no_context_id AS (
    SELECT DISTINCT merged_guid AS user_sso_guid
      , actv_dt AS course_start
      , DATEADD(W,16,actv_dt) AS course_end
      , actv_dt AS activation_date
      , actv_region AS region
      , platform
      , organization
    FROM activations_olr
    WHERE CONTEXT_ID IS NULL
    AND ACTV_DT > '2017-07-01'
    AND lower(actv_user_type) = 'student'
    AND (PLATFORM = 'MindTap Reader' OR content_code = '000')
    AND ACTV_TRIAL_PURCHASE NOT IN ('Trial','Duplicate')
    AND code_source <> 'Locker'
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
    SELECT ss.user_sso_guid, ss.registration_date AS ebook_start, DATEADD(d,ss.subscription_length_in_days,ss.registration_date) as ebook_end
      , ebook_start AS subscription_start
      , ebook_end AS subscription_end
      , 'Full Access' AS subscription_type
      , 'Serial Number Consumed' AS source
      , CASE WHEN ss.region = 'UNITED STATES' THEN 'USA' ELSE ss.region END AS region
      , CASE WHEN p.platform IS NOT NULL THEN p.platform ELSE 'Other' END AS platform
      , CASE WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
        WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
        ELSE 'Other' END AS organization
    FROM prod.datavault.hub_product hp
    INNER JOIN prod.datavault.sat_serialnumber_consumed ss ON hp.pid = ss.product_id
    INNER JOIN prod.datavault.sat_product_olr sp ON hp.HUB_PRODUCT_KEY = sp.hub_product_key
    INNER JOIN prod.datavault.hub_user hu on ss.user_sso_guid = hu.uid
    LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal
    LEFT JOIN prod.STG_CLTS.ENTITIES e ON ss.institution_id = e.ENTITY_NO
    LEFT JOIN prod.stg_clts.products p on ss.referring_isbn = p.isbn13
    WHERE sp.type IN ('MTR','SMEB')
      AND ss.user_type = 'student'
      AND ui.hub_user_key IS NULL
    )
    UNION
    (
    SELECT pp.USER_SSO_GUID, pp.date_added AS ebook_start, pp.expiration_date AS ebook_end
      , COALESCE(ss.subscription_start, bp._effective_from) AS subscription_start
      , COALESCE(COALESCE(ss.cancelled_time, ss.subscription_end), COALESCE(bp._effective_to, CURRENT_DATE())) AS subscription_end
      , CASE WHEN ss.subscription_start IS NOT NULL THEN ss.subscription_plan_id WHEN bp.subscription_start IS NOT NULL THEN bp.subscription_state END AS subscription_type
      , 'Provisioned Product' AS source
      , CASE WHEN COUNTRY_CD = 'US' THEN 'USA' WHEN COUNTRY_CD IS NOT NULL THEN COUNTRY_CD ELSE 'Other' END AS region
      , CASE WHEN p.platform IS NOT NULL THEN p.platform ELSE 'Other' END AS platform
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
    LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal
    LEFT JOIN prod.stg_clts.products p ON pp.IAC_ISBN = p.ISBN13
    LEFT JOIN prod.STG_CLTS.ENTITIES e ON pp.institution_id = e.ENTITY_NO
    WHERE sp.type IN ('MTR', 'SMEB')
      AND pp.user_type = 'student'
      AND subscription_type IS NOT NULL
      AND ui.hub_user_key IS NULL
    )
    )
    SELECT DISTINCT dim_date.datevalue as date, user_sso_guid, 'eBook' AS content_type, source, region, platform, organization
      , CASE WHEN (subscription_type ILIKE 'Full%' OR subscription_type ILIKE 'Limited%') THEN TRUE ELSE FALSE END AS paid_flag
    FROM ${dim_date.SQL_TABLE_NAME} dim_date
    LEFT JOIN ebook_users ON dim_date.datevalue BETWEEN ebook_start AND ebook_end
      AND dim_date.datevalue BETWEEN subscription_start AND subscription_end
    WHERE dim_date.datevalue BETWEEN '2017-07-01' AND CURRENT_DATE()
    ;;
    persist_for: "12 hours"
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

  dimension: source {
    type: string
  }

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
  }

}
