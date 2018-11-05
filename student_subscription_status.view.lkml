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
    persist_for: "6 hours"
}
  dimension: user_sso_guid{primary_key:yes
    label: "User SSO GUID"}

  dimension: subscription_status {
    label: "Subscription status"
    description: "Current subscription status"
  }
  dimension: has_trial {
    type:yesno
    label: "Has or had trial"
    description: "TRUE if user has or ever had a trial and FALSE otherwise"
    }
  dimension: has_subscription {
    label: "Has or had subscription"
    description: "TURE if user has or ever had a subscription and FALSE otherwise"
    type: yesno}

  dimension: trial_expired {
    label: "Trial expired"
    description: "TRUE if user has ever had a trial expire and FALSE otherwise"
    type: yesno}
}
