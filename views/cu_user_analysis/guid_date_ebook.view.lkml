explore: guid_date_ebook {}

view: guid_date_ebook {
  derived_table: {
    sql:
    WITH activations AS (
    SELECT a.*
         , coalesce(m.PRIMARY_GUID,a.USER_GUID) AS merged_guid
    FROM prod.STG_CLTS.ACTIVATIONS_OLR a
    LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m on a.USER_GUID = m.PARTNER_GUID
    )
    ,activations_no_context_id AS (
    SELECT DISTINCT merged_guid AS user_sso_guid
      , actv_dt AS course_start
      , DATEADD(W,20,actv_dt) AS course_end
      , actv_dt AS activation_date
    FROM activations
    WHERE CONTEXT_ID IS NULL
    and in_actv_flg = 1
    and lower(actv_user_type) = 'student'
    and actv_trial_purchase not in ('Duplicate','Trial')
    and platform = 'MindTap Reader'
    )
    ,ebook_users AS (
    (
    SELECT user_sso_guid
    , course_start AS ebook_start
    , course_end AS ebook_end
    , course_start AS subscription_start
    , course_end AS subscription_end
    , 'Full Access' AS subscription_type
    FROM activations_no_context_id
    )
    UNION
    (
    SELECT ss.user_sso_guid, ss.registration_date AS ebook_start, DATEADD(d,ss.subscription_length_in_days,ss.registration_date) as ebook_end
    , ebook_start AS subscription_start
    , ebook_end AS subscription_end
    , 'Full Access' AS subscription_type
    FROM prod.datavault.hub_product hp
    INNER JOIN prod.datavault.sat_serialnumber_consumed ss ON hp.pid = ss.product_id
    INNER JOIN prod.datavault.sat_product_olr sp ON hp.HUB_PRODUCT_KEY = sp.hub_product_key
    INNER JOIN prod.datavault.hub_user hu on ss.user_sso_guid = hu.uid
    LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal
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
    FROM prod.datavault.hub_product hp
    INNER JOIN prod.datavault.sat_provisioned_product_v2 pp ON hp.pid = pp.product_id
      AND pp._latest
    INNER JOIN prod.datavault.sat_product_olr sp ON hp.hub_product_key = sp.hub_product_key
      AND sp._latest
    LEFT JOIN prod.datavault.hub_subscription hs ON pp.source_id = hs.subscription_id
    LEFT JOIN prod.datavault.sat_subscription_sap ss ON hs.hub_subscription_key = ss.hub_subscription_key
      AND ss._LATEST
    LEFT JOIN prod.datavault.sat_subscription_bp bp ON hs.hub_subscription_key = bp.hub_subscription_key
      AND pp.USER_SSO_GUID = bp.USER_SSO_GUID
      AND bp.SUBSCRIPTION_STATE NOT IN ('no_access','banned','cancelled')
    INNER JOIN prod.datavault.hub_user hu on pp.user_sso_guid = hu.uid
    LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal
    WHERE sp.type IN ('MTR', 'SMEB')
      AND pp.user_type = 'student'
      AND subscription_type IS NOT NULL
      AND ui.hub_user_key IS NULL
    )
    )
SELECT DISTINCT dim_date.datevalue as date, user_sso_guid, 'eBook' AS content_type
  , CASE WHEN (subscription_type ILIKE 'Full%' OR subscription_type ILIKE 'Limited%') THEN TRUE ELSE FALSE END AS paid_flag
FROM ${dim_date.SQL_TABLE_NAME} dim_date
LEFT JOIN ebook_users ON dim_date.datevalue BETWEEN ebook_start AND ebook_end
  AND dim_date.datevalue BETWEEN subscription_start AND subscription_end
WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
    ;;
    persist_for: "24 hours"
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}.USER_SSO_GUID ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: content_type {
    type: string
    sql: ${TABLE}.content_type ;;
  }

  dimension: paid_flag {
    type: string
    sql: ${TABLE}.paid_flag ;;
  }

  measure: num_users {
    type: count_distinct
    sql: ${TABLE}.user_sso_guid ;;
  }

}
