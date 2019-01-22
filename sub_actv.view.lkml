explore: sub_actv {label: "Active subscriptions"}

view: sub_actv {
  view_label: "Activations"
  derived_table: {
  sql:
 --- latest with activations -----------------

with sub as (SELECT
     COALESCE(shadow.PRIMARY_GUID, raw_data.USER_SSO_GUID) AS USER_SSO_GUID,
     LOCAL_TIME,
     CONTRACT_ID,
     SUBSCRIPTION_STATE,
     SUBSCRIPTION_START,
     SUBSCRIPTION_END
   FROM
     UNLIMITED.RAW_SUBSCRIPTION_EVENT AS raw_data
     LEFT OUTER JOIN UNLIMITED.SSO_MERGED_GUIDS as shadow
       ON raw_data.USER_SSO_GUID = shadow.SHADOW_GUID
   ),state as( SELECT
        RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time DESC) AS latest_record
        ,*
            FROM
               sub s
        where s.user_sso_guid NOT IN (Select user_sso_guid from unlimited.excluded_users)

   ), actv as ( Select COALESCE(shadow.PRIMARY_GUID, raw_data_act.USER_GUID) AS USER_SSO_GUID,
         actv_dt,
         context_id,
             platform,
             CU_flg
         FROM
            PROD.RAW_CLTS.ACTIVATIONS_OLR AS raw_data_act
            LEFT OUTER JOIN UNLIMITED.SSO_MERGED_GUIDS as shadow
                ON raw_data_act.USER_GUID = shadow.SHADOW_GUID

   ), sub_act as (

        select
        -- count(distinct state.user_sso_guid)
        -- ,count(distinct state.user_sso_guid)/550000
         state.user_sso_guid,state.subscription_start,state.subscription_end,actv_dt as local_date,platform,'act' as pp_name,context_id as course_key
         --*
            from state
         JOIN actv o
            on state.user_sso_guid = o.USER_SSO_GUID
         where latest_record = 1 and subscription_state like 'full_access'
         and (o.context_id is not null OR platform ilike 'cengage unlimited')
         and actv_dt >='2018-08-01'
 ), pp_prod as (
        select distinct COALESCE(shadow.PRIMARY_GUID, raw_data.USER_SSO_GUID) AS USER_SSO_GUID
        ,context_id
        ,'pp product' as platform
        ,iac.pp_name
    from PROD.UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT raw_data
    LEFT OUTER JOIN UNLIMITED.SSO_MERGED_GUIDS_NEW_20181218 as shadow
       ON raw_data.USER_SSO_GUID = shadow.SHADOW_GUID
   JOIN prod.unlimited.RAW_OLR_EXTENDED_IAC iac
                ON iac.pp_pid = raw_data.product_id
                  AND raw_data.user_type like 'student'
    -- WHERE raw_data.USER_SSO_GUID NOT IN (SELECT DISTINCT user_sso_guid from sub_act)
     where context_id is not null
 ),pp_final as ( select p.USER_SSO_GUID,state.subscription_start,state.subscription_end,local_time as local_date,'pp_prod' as platform,pp_name, context_id as course_key
                from pp_prod p
    join state
    on p.user_sso_guid = state.user_sso_guid
    and state.latest_record = 1 and subscription_state like 'full_access'
    where p.USER_SSO_GUID NOT IN (SELECT DISTINCT user_sso_guid from sub_act)
 ), enrol as(
        select distinct COALESCE(shadow.PRIMARY_GUID, raw_data.USER_SSO_GUID) AS USER_SSO_GUID
        ,course_key
        ,'enrol' as platform
    from PROD.UNLIMITED.RAW_OLR_ENROLLMENT raw_data
    LEFT OUTER JOIN UNLIMITED.SSO_MERGED_GUIDS as shadow
       ON raw_data.USER_SSO_GUID = shadow.SHADOW_GUID
 )  ,enrol_final as ( select e.USER_SSO_GUID,state.subscription_start,state.subscription_end,local_time as local_date,'enrol' as platform,'enrol' as pp_name, course_key
               from enrol e
    join state
    on e.user_sso_guid = state.user_sso_guid
    and state.latest_record = 1 and subscription_state like 'full_access'
    where e.USER_SSO_GUID NOT IN (SELECT DISTINCT user_sso_guid from sub_act)
         and e.USER_SSO_GUID NOT IN (Select Distinct user_sso_guid from pp_final)
  ), final as (
    Select * from sub_act
    UNION ALL
    Select * from pp_final
    UNION ALL
    Select * from enrol_final
    )
    select f.*,Case when sam.user_guid is NULL then 'N' ELSE 'Y' END AS SAM_USER,sam.user_guid
        from final f
        left join  uploads.zas.active_users_sam sam
        ON f.user_sso_guid = sam.user_guid ;;

  }
  dimension: subscription_start{}
  dimension: subscription_end {}
  dimension: user_sso_guid {
    primary_key: yes
  }
  dimension: local_date {}
  dimension: platform {}
  dimension: course_key {}
  dimension: pp_name{}
  dimension: SAM_USER {}
  dimension: user_guid {}
  measure: count {
    label: "# users"
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }
}
