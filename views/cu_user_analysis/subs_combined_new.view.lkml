explore: subs_combined_new {hidden:yes}
view: subs_combined_new {
  derived_table: {
    sql:
      with subs as (
        select distinct
          coalesce(su.LINKED_GUID, bp.USER_SSO_GUID) as merged_guid
          , bp.SUBSCRIPTION_START
          , bp.SUBSCRIPTION_END
          , case bp.SUBSCRIPTION_STATE
            when 'trial_access' then 'Active'
            when 'full_access' then 'Active'
            when 'cancelled' then 'Cancelled'
          end as subscription_state_n
          , case bp.SUBSCRIPTION_STATE
            when 'trial_access' then 'Trial'
            when 'full_access' then 'Full-Access'
            when 'cancelled' then 'Full-Access'
          end as subscription_plan_id
          , bp.RSRC_TIMESTAMP
        from prod.DATAVAULT.SAT_SUBSCRIPTION_BP bp
        left join prod.DATAVAULT.HUB_USER hu on hu.uid = bp.USER_SSO_GUID
        left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._latest
        left join prod.DATAVAULT.SAT_USER_INTERNAL sui on sui.HUB_USER_KEY = hu.HUB_USER_KEY and sui.INTERNAL
        where bp.SUBSCRIPTION_STATE in ('cancelled', 'full_access', 'trial_access')
          and bp.SUBSCRIPTION_START is not null
          and bp.SUBSCRIPTION_END is not null
      )
      , subs_expired as (
        select *
          , case SUBSCRIPTION_STATE_n
            when 'Expired' then SUBSCRIPTION_END
            when 'Cancelled' then RSRC_TIMESTAMP
            when 'Active' then RSRC_TIMESTAMP
          end as _effective_from_date
          , lead(_effective_from_date) over (partition by merged_guid order by _effective_from_date, SUBSCRIPTION_STATE_n desc)
          as _effective_to_date
          , SUBSCRIPTION_END < coalesce(_effective_to_date, current_date) as expired
        from subs
        qualify expired
          and subscription_state_n <> 'Cancelled'
      )
      , bp as (
        select *
        , concat(subscription_plan_id, subscription_state) as plan
        , case
          when coalesce(lag(plan) over (partition by merged_guid order by rsrc_timestamp,subscription_state) <> plan, true) then 1
          else 0
        end as new_plan
        from (
          select
            merged_guid
            , SUBSCRIPTION_START
            , SUBSCRIPTION_END
            , 'Expired' as subscription_state
            , subscription_plan_id
            , RSRC_TIMESTAMP
          from subs_expired
          union all
          select *
          from subs
        )
      )
      , bp_all as (
        select
          merged_guid
          , subscription_plan_id
          , subscription_state
          , partition_number
          , min(SUBSCRIPTION_START) as subscription_start
          , max(SUBSCRIPTION_END) as subscription_end
          , min(RSRC_TIMESTAMP) as rsrc_timestamp
        from (
          select *
          , sum(new_plan)
            over (partition by merged_guid order by rsrc_timestamp, subscription_state rows between unbounded preceding and 0 preceding)
          as partition_number
          from bp
          order by RSRC_TIMESTAMP desc, subscription_state desc
        )
        group by 1, 2, 3, 4
      )
      , sap_subs as (
        select distinct
          coalesce(su.LINKED_GUID, ss.CURRENT_GUID) as merged_guid
          , SUBSCRIPTION_PLAN_ID
          , ss.SUBSCRIPTION_STATE
          , ss.SUBSCRIPTION_START
          , ss.SUBSCRIPTION_END
          , case when ss.SUBSCRIPTION_STATE = 'Cancelled' then coalesce(CANCELLED_TIME, ss.RSRC_TIMESTAMP) end as cancelled_time
          , ss.PLACED_TIME
          , ss.RSRC_TIMESTAMP
          , lead(ss.RSRC_TIMESTAMP)
            over (partition by ss.HUB_SUBSCRIPTION_KEY, ss.SUBSCRIPTION_STATE, SUBSCRIPTION_PLAN_ID order by ss.RSRC_TIMESTAMP) is null
          as _latest_n
          , min(ss.RSRC_TIMESTAMP) over (partition by ss.HUB_SUBSCRIPTION_KEY, ss.SUBSCRIPTION_STATE, SUBSCRIPTION_PLAN_ID)
          as first_rsrc_timestamp
        from prod.DATAVAULT.SAT_SUBSCRIPTION_SAP ss
        left join prod.DATAVAULT.HUB_USER hu on hu.uid = ss.CURRENT_GUID
        left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._latest
        left join prod.DATAVAULT.SAT_SUBSCRIPTION_BP bp on bp.HUB_SUBSCRIPTION_KEY = ss.HUB_SUBSCRIPTION_KEY
        where SUBSCRIPTION_PLAN_ID <> 'Read-Only'
          and ss.SUBSCRIPTION_STATE <> 'Pending'
          and ss.SUBSCRIPTION_START is not null
          and ss.SUBSCRIPTION_END is not null
          and bp.HUB_SUBSCRIPTION_KEY is null
        qualify _latest_n
      )
      , all_subs as (
        select distinct
          merged_guid
          , subscription_plan_id
          , subscription_state
          , subscription_start
          , subscription_end
          , cancelled_time
          , rsrc_timestamp
          , _effective_from_date
          , subscription_source
          , max(subscription_source)
            over (partition by merged_guid order by _effective_from_date, rsrc_timestamp, SUBSCRIPTION_STATE desc rows between unbounded preceding and 0 preceding)
          as latest_subscription_source
          , lag(subscription_plan_id) over (partition by merged_guid order by _effective_from_date, rsrc_timestamp, SUBSCRIPTION_STATE)
          as previous_plan
          , lag(subscription_state)
          over (partition by merged_guid, subscription_plan_id order by _effective_from_date, rsrc_timestamp, SUBSCRIPTION_STATE)
          as previous_state
          , (subscription_source = 'BP' and latest_subscription_source = 'SAP')
            or (subscription_state in ('Cancelled', 'Expired') and previous_state <> 'Active') as exclude
        from (
          select
            merged_guid
            , subscription_plan_id
            , subscription_state
            , subscription_start
            , subscription_end
            , case when subscription_state = 'Cancelled' then rsrc_timestamp end as cancelled_time
            , rsrc_timestamp
            , case SUBSCRIPTION_STATE
              when 'Expired' then SUBSCRIPTION_END
              when 'Cancelled' then CANCELLED_TIME
              when 'Active' then RSRC_TIMESTAMP
            end as _effective_from_date
            , 'BP' as subscription_source
          from bp_all
          union
          select
            merged_guid
            , SUBSCRIPTION_PLAN_ID
            , SUBSCRIPTION_STATE
            , SUBSCRIPTION_START
            , SUBSCRIPTION_END
            , CANCELLED_TIME
            , RSRC_TIMESTAMP
            , case SUBSCRIPTION_STATE
              when 'Expired' then SUBSCRIPTION_END
              when 'Cancelled' then CANCELLED_TIME
              when 'Active' then case when subscription_plan_id = 'CU-Full-Restricted-30' then subscription_start else rsrc_timestamp end
            end as _effective_from_date
            , 'SAP' as subscription_source
          from sap_subs
        )
        qualify not exclude
      )
      select distinct
        hash(subscription_source, merged_guid, subscription_plan_id, subscription_state, subscription_start, subscription_end, cancelled_time, _effective_from_date)
        as pk
        , subscription_source
        , merged_guid
        , subscription_plan_id
        , subscription_state
        , subscription_start
        , subscription_end
        , cancelled_time
        , _effective_from_date
        , lead(_effective_from_date)
          over (partition by merged_guid order by _effective_from_date, SUBSCRIPTION_start, subscription_state desc) as _effective_to_date
        , lead(_effective_from_date)
          over (partition by merged_guid order by _effective_from_date, SUBSCRIPTION_start, subscription_state desc) is null as _latest
      from all_subs
      group by 1, 2, 3, 4, 5, 6, 7, 8, 9
    ;;
    persist_for: "8 hours"
  }

  dimension: pk {primary_key:yes hidden:yes}

  dimension: subscription_source {}

  dimension: merged_guid {hidden:yes}

  dimension: subscription_plan_id {}

  dimension: subscription_state {}

  dimension_group: subscription_start {
    type:time
    timeframes: [time,raw,date,week,month,year]
  }

  dimension_group: subscription_end {
    type:time
    timeframes: [time,raw,date,week,month,year]
  }

  dimension_group: cancelled {
    sql: ${TABLE}.cancelled_time ;;
    type:time
    timeframes: [time,raw,date,week,month,year]
  }

  dimension_group: _effective_from {
    sql: ${TABLE}._effective_from_date ;;
    type:time
    timeframes: [time,raw]
  }

  dimension_group: _effective_to {
    sql: ${TABLE}._effective_to_date ;;
    type:time
    timeframes: [time,raw]
  }

  dimension: _latest {type:yesno}

  measure: count {
    type: count
    label: "# Subscription Records"
  }

  measure: count_subscriptions {
    type: count_distinct
    sql: hash(${merged_guid},${subscription_plan_id},${subscription_start_time})  ;;
    label: "# Subscriptions"
    description: "Number of distinct user / plan / start date combinations"
  }








}
