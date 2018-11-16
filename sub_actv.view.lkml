explore: sub_actv {label: "Active subscriptions"}

view: sub_actv {
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
         state.user_sso_guid,state.subscription_start,state.subscription_end,actv_dt,platform,context_id,cu_flg
         --*
            from state
         JOIN actv o
            on state.user_sso_guid = o.USER_SSO_GUID
         where latest_record = 1 and subscription_state like 'full_access'
         and (o.context_id is not null OR platform ilike 'cengage unlimited')
         and actv_dt >='2018-08-01'
        ) select * from sub_act;;

  }
  dimension: subscription_start{}
  dimension: subscription_end {}
  dimension: user_sso_guid {}
  dimension: actv_dt {}
  dimension: platform {}

}
