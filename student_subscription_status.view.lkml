view: student_subscription_status {
derived_table: {
  sql:
    with get_latest as (
      select
            *
         ,row_number() over (partition by user_sso_guid order by local_time desc) as reverse_order
         ,MAX(case when subscription_state = 'trial_access' then 1 end) over (partition by user_sso_guid) = 1 as has_trial
         ,MAX(CASE WHEN subscription_state = 'trial_access' THEN subscription_start END) OVER (PARTITION BY user_sso_guid) AS trial_start_date
         ,MAX(case when subscription_state = 'full_access' then 1 end) over (partition by user_sso_guid) = 1 as has_subscription
         ,MAX(CASE WHEN subscription_state = 'full_access' THEN subscription_start END) OVER (PARTITION BY user_sso_guid) AS subscription_start_date
         ,MAX(case when subscription_state = 'trial_access' and subscription_end < current_timestamp() then 1 end) over (partition by user_sso_guid) = 1 as trial_expired
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
  dimension: user_sso_guid{
    primary_key:yes
    label: "User SSO GUID"
    }

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
    description: "TRUE if user has or ever had a subscription and FALSE otherwise"
    type: yesno
    }

  dimension: trial_expired {
    label: "Trial expired"
    description: "TRUE if user has ever had a trial expire and FALSE otherwise"
    type: yesno
    }

  dimension_group: trial_start_date {
    sql: ${TABLE}.trial_start_date ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
    }


  dimension_group: subscription_start_date {
    sql: ${TABLE}.subscription_start_date ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
    description: "The time components of the timestamp when the user began their subscription"
  }


}
