view: total_users {

  derived_table: {
    sql: with enrol_pp as(
    SelecT DISTINCT user_sso_guid,course_key as context_id
    from prod.UNLIMITED.RAW_OLR_ENROLLMENT
    where access_role = 'STUDENT'
    AND local_time::date BETWEEN '2018-08-01' AND CURRENT_DATE()
    and user_environment='production'
    and platform_environment = 'production'
  UNION
  SELECT DISTINCT pp.user_sso_guid, context_id
    from prod.unlimited.raw_olr_provisioned_product pp
    Where context_id IS NOT NULL
    AND date_added::date BETWEEN '2018-08-01' AND '2018-09-06'
  )
  , activations as (
   select distinct
    a.user_guid,
    a.context_id,
    a.platform,
    a.code_type,
    b.net_price,
    b.list_price,
    a.actv_code,
    case
        when a.code_type = 'PAC' or a.code_type = 'PAC-ML' then 0.75*b.list_price
        else b.list_price end as credited_price
     from prod.stg_clts.activations_olr_v a left join prod.stg_clts.products_v b
        on a.actv_isbn=b.isbn13
    where
    a.actv_user_type ='student' and
    a.actv_region = 'USA' and
    actv_dt between '2018-08-01' and CURRENT_DATE() and
    a.actv_trial_purchase not in ('Excluded','Duplicate','Trial') and
    not exists (SELECT 1 FROM prod.unlimited.vw_user_blacklist where user_sso_guid = a.user_guid)
)
,recent_record AS (
-- Selects most recent subscription start for a user_sso_guid from raw subscription events
  SELECT
    user_sso_guid
    ,MAX(SUBSCRIPTION_START) as current_record
  FROM prod.unlimited.raw_subscription_event
  GROUP BY user_sso_guid
)
,recent_record_full as (
    SELECT
        rse.*
    FROM prod.unlimited.raw_subscription_event rse
    JOIN recent_record rr
        ON rse.user_sso_guid = rr.user_sso_guid
    AND rse.subscription_start = rr.current_record
    LEFT JOIN UNLIMITED.CLTS_EXCLUDED_USERS eu
    ON rse.user_sso_guid = eu.user_sso_guid
    WHERE eu.user_sso_guid IS NULL
)
, non_cu_with_enroll AS (
    Select
        rse.user_sso_guid
        ,CASE WHEN (DATEDIFF(day, rse.subscription_end, CURRENT_DATE())) > 0 THEN 'Expired' ELSE 'In trial' END AS trial_status
        ,CASE WHEN (a.actv_code IS NOT NULL) THEN 'Paid' ELSE 'Unpaid' END AS paid
        ,a.code_type
        ,coalesce (credited_price,0) AS credited_price
        ,list_price
        ,en.context_id
        from recent_record_full rse
        JOIN enrol_pp en
            ON en.user_sso_guid = rse.user_sso_guid

        LEFT JOIN activations a
            ON en.context_id  = a.context_id
            AND en.user_sso_guid = a.user_guid

        WHERE rse.subscription_state = 'trial_access'
    )
  Select * from non_cu_with_enroll ;;


    }
    dimension: user_sso_guid {}
    dimension: trial_status {}
    dimension: paid {}
    dimension: credited_price {}
    dimension: list_price{}
    dimension: context_id {}

}
