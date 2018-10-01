view: student_subscription_status {
derived_table: {
  sql:
    with get_latest as (
      select
            *
            ,row_number() over (partition by user_sso_guid order by local_time desc) as reverse_order
            ,max(case when subscription_state = 'trial_access' then 1 end) over (partition by user_sso_guid) = 1 as has_trial
            ,max(case when subscription_state = 'full_access' then 1 end) over (partition by user_sso_guid) = 1 as has_subscription
            ,max(case when subscription_state = 'trial_access' and subscription_end < current_timestamp() then 1 end) over (partition by user_sso_guid) = 1 as trial_expired
      from UNLIMITED.raw_subscription_event
    )
    select
      *
      ,case
        when subscription_state = 'trial_access' and trial_expired then 'Trial Expired'
        else InitCap(replace(subscription_state, '_', ' '))
        end as subscription_status
    from get_latest
    where reverse_order = 1
    ;;
}
  dimension: user_sso_guid{primary_key:yes}
  dimension: subscription_status {}
  dimension: has_trial {type:yesno}
  dimension: has_subscription {type: yesno}
  dimension: trial_expired {type: yesno}
}
