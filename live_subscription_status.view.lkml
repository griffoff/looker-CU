include: "raw_subscription_event.view"

view: live_subscription_status {
  derived_table: {
    sql:
      WITH
distinct_primary AS
(
SELECT DISTINCT primary_guid
FROM prod.unlimited.vw_partner_to_primary_user_guid
WHERE partner_guid IS NOT NULL
)
,sap_subscriptions_ranked AS
(
SELECT
ROW_NUMBER() OVER (PARTITION BY subscription_id ORDER BY event_time DESC) AS record_rank
,current_guid AS user_sso_guid
,event_time AS local_time
,CASE
WHEN subscription_status ILIKE '%cancel%' OR contract_status ILIKE '%cancel%' THEN  'Cancelled'
-- pending read_only = provisional locker
WHEN contract_status ILIKE '%Banned%' THEN  'Banned'
WHEN subscription_plan_id ILIKE '%full%' THEN 'Full Access'
WHEN subscription_plan_id ILIKE '%trial%' THEN 'Trial Access'
ELSE subscription_plan_id
END AS subscription_state
,subscription_status
,contract_status
,user_environment
,product_platform
,platform_environment
,subscription_end
,subscription_start
,contract_id
,NULL AS transferred_contract
,NULL AS access_code
,_ldts
FROM subscription.prod.sap_subscription_event
--WHERE local_time >= $cut_over_date
)
,sap_subscription_events_merged_clean AS
  (
      SELECT
          COALESCE(m.primary_guid, r.user_sso_guid) AS merged_guid
          ,CASE WHEN m.primary_guid IS NOT NULL OR m2.primary_guid IS NOT NULL THEN 1 ELSE 0 END AS lms_user_status
          ,LOCAL_TIME
          ,USER_SSO_GUID as original_guid
          ,USER_SSO_GUID
          ,USER_ENVIRONMENT
          ,PRODUCT_PLATFORM
          ,PLATFORM_ENVIRONMENT
          ,CASE WHEN SUBSCRIPTION_STATE = 'provisional_locker' THEN SUBSCRIPTION_END ELSE greatest(local_time, subscription_start) END AS MOD_SUBSCRIPTION_START
--          ,MOD_SUBSCRIPTION_START AS SUBSCRIPTION_START
            ,subscription_start
          ,CASE SUBSCRIPTION_STATE WHEN 'cancelled' THEN CURRENT_DATE() WHEN 'provisional_locker' THEN DATEADD(YEAR, 1, SUBSCRIPTION_END) ELSE SUBSCRIPTION_END END AS SUBSCRIPTION_END
          ,LEAD(mod_subscription_start) OVER (PARTITION BY merged_guid ORDER BY local_time) as next_subscription_start
          ,SUBSCRIPTION_STATE
          ,CONTRACT_ID
          ,TRANSFERRED_CONTRACT
          ,ACCESS_CODE
      FROM sap_subscriptions_ranked r
      LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
          ON r.user_sso_guid = m.partner_guid
      LEFT JOIN distinct_primary m2
          ON  r.user_sso_guid = m2.primary_guid
      WHERE r.user_environment = 'production'
      AND r.platform_environment = 'production'
      AND r.local_time >= to_date('01-Aug-2018')
      AND record_rank = 1
      --AND subscription_status = 'Active'
      --AND contract_status = 'Active'
       AND NOT
            (
              EXISTS(
                SELECT 1 FROM PROD.UNLIMITED.EXCLUDED_USERS excluded LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids_forexcl ON excluded.user_sso_guid = guids_forexcl.partner_guid
                     WHERE COALESCE(guids_forexcl.primary_guid, excluded.user_sso_guid) = COALESCE(m.primary_guid, r.user_sso_guid)
              )
            )
    )
     SELECT
          e.*
          --,REPLACE(INITCAP(subscription_state), '_', ' ') AS subscription_status
          ,REPLACE(INITCAP(subscription_state), '_', ' ') || CASE WHEN subscription_state not in ('cancelled', 'banned','read_only', 'no_access', 'provisional_locker') AND subscription_end < CURRENT_TIMESTAMP() THEN ' (Expired)' ELSE '' END as subscription_status
          ,subscription_state not in ('cancelled', 'banned', 'no_access') AND subscription_end < CURRENT_TIMESTAMP() AS expired
          ,FIRST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as first_status
          ,FIRST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as first_start
          ,LAST_VALUE(subscription_status) over(partition by merged_guid order by local_time) as current_status
          ,LAST_VALUE(subscription_start) over(partition by merged_guid order by local_time) as current_start
          ,LAST_VALUE(subscription_end) over(partition by merged_guid order by local_time) as current_end
          ,LAG(subscription_status) over(partition by merged_guid order by local_time) as prior_status
          ,LAG(subscription_start) over(partition by merged_guid order by local_time) as prior_start
          ,LAG(subscription_end) over(partition by merged_guid order by local_time) as prior_end
          ,LEAD(local_time) over(partition by merged_guid order by local_time, subscription_start) as next_event_time
          ,MAX(CASE
                WHEN subscription_state = 'full_access'
                /*    AND NOT cancelled  */
                THEN subscription_start
                END) over(partition by merged_guid order by local_time rows between unbounded preceding and 1 preceding) as previous_full_access_start
          ,MAX(CASE
                WHEN subscription_state = 'full_access'
                /*    AND NOT cancelled  */
                THEN subscription_end
                END) over(partition by merged_guid order by local_time rows between unbounded preceding and 1 preceding) as previous_full_access_end
          ,LEAD(subscription_status) over(partition by merged_guid order by local_time) as next_status
          ,LEAD(subscription_start) over(partition by merged_guid order by local_time) as next_start
          ,subscription_start < current_timestamp() AND subscription_end > current_timestamp() as active
          ,MAX(local_time) over(partition by merged_guid) as latest_update
          ,next_status IS NULL as latest
          ,prior_status IS NULL as earliest
          ,subscription_start AS effective_from
          ,COALESCE(LEAST(next_subscription_start, subscription_end), subscription_end) AS effective_to
      FROM sap_subscription_events_merged_clean e
    ;;
  }


# view: live_subscription_status_old {
#   derived_table: {
#     sql:
#       SELECT *
#       FROM ${raw_subscription_event.SQL_TABLE_NAME}
#       WHERE latest = 1;;
#   }
  set: marketing_fields {
    fields: [live_subscription_status.student_count, live_subscription_status.days_time_left_in_current_status, live_subscription_status.subscription_status,live_subscription_status.subscriber_count,
        live_subscription_status.days_time_in_current_status, live_subscription_status.lms_user, live_subscription_status.effective_from, live_subscription_status.effective_to
        ,live_subscription_status.local_time_date, live_subscription_status.subscription_end_date]
  }

  dimension: effective_to {
    type: date
    label: "Effective to date"
    description: "The day this status ended. e.g. different from subscription end date when a subscription gets cancelled or when a trial state upgrades to ful access early"
    hidden: no
    sql: ${TABLE}."EFFECTIVE_TO" ;;
  }

  dimension: effective_from {
    type: date
    label: "Subscription effective from date"
    description: "Start date of this status"
    hidden: no
    sql: ${TABLE}."EFFECTIVE_FROM" ;;
  }

  dimension_group: time_in_current_status {
    view_label: "Learner Profile - Live Subscription Status"
    type: duration
    intervals: [day, week, month]
    sql_start: ${effective_from} ;;
    sql_end:  CURRENT_DATE();;
    label: "Time in current status"
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    description: "Parimary user sso guid, after shadonw guid lookup and merge"
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: no
 }
  dimension: original_guid {
    description: "Origiual guid captured in raw event"
    alias: [partner_guid]
  }
  dimension: lms_user {
    type: yesno
    sql: ${TABLE}.lms_user_status = 1;;
    description: "This flag is yes if a user has ever done a subscription event from a gateway account (from a shadow or gateway guid)"
  }


  dimension: prior_status {}
  dimension: subscription_status {}
  dimension_group: subscription_start {

    type: time
    timeframes: [raw, date, week, month, year]
  }
  dimension_group: subscription_end {
    type: time
    timeframes: [raw, date, week, month, year]
  }
  dimension_group: local_time {
    label: "Last Updated"
    type: time
    timeframes: [raw, date, week, month, year]
  }
  dimension: contract_id {}

  dimension: is_trial {
    sql: ${subscription_status} = 'Trial Access' ;;
    hidden: yes
  }

  dimension_group: time_since_last_subscription {
#     group_label: "Time at this status"
    type: duration
    intervals: [day, week, month]
    sql_start: CASE WHEN ${subscription_end_raw} < current_timestamp() THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
    sql_end: current_date() ;;
  }




#   dimension_group: time_since_last_trial {
# #     group_label: "Time at this status"
#     type: duration
#     intervals: [day, week, month]
#     sql_start: CASE (WHEN ${subscription_end_raw} < current_timestamp() AND ${prior_status} = 'Trial_Access') THEN ${subscription_end_raw}::date ELSE  ${subscription_start_raw}::date END ;;
#     sql_end: current_date() ;;
#   }

#
#   dimension_group: time_in_current_status {
#     group_label: "Time at this status"
#     type: duration
#     intervals: [day, week, month]
#     sql_start: ${subscription_start_raw}::date ;;
#     sql_end: current_date() ;;
#   }


#
#   dimension: time_in_curr {
#     label: "Testing time in current state"
#     sql: TIMEDIFF('d', ${subscription_end_raw}, CURRENT_TIMESTAMP()) ;;
#   }


  dimension_group: time_left_in_current_status {
    type: duration
    intervals: [day, week, month]
    sql_start: current_timestamp() ;;
    sql_end: ${subscription_end_date} ;;

}

#   dimension_group: time_in_current_status {
#     type: duration
#     intervals: [day, week, month]
#     sql_start: ${subscription_start_date};;
#     sql_end: current_timestamp()  ;;
#
#   }

  measure: latest_data_date {
    description: "The latest time at which any subscription event has been received"
    type: date_time
    sql: max(${local_time_raw}) ;;
  }

  measure: student_count {
    hidden: yes
    label: "# Students"
    type: number
    sql: COUNT(DISTINCT ${user_sso_guid}) ;;
    drill_fields: [user_sso_guid]
  }

  measure: subscriber_count {
    label: "# Subscribers"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${subscription_status} = 'Full Access' THEN ${user_sso_guid} END) ;;
  }

  measure: non_subscriber_count {
    label: "# Non-subscribers"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${subscription_status} = 'Full Access' THEN NULL ELSE ${user_sso_guid} END) ;;
  }


}
