# view: ipm_conversion {

#     derived_table: {
#       sql: with ipms as(
#         Select ips.*,CASE WHEN (al."EVENT_NAME") ilike 'IPM%'
#                 THEN (al."EVENT_DATA"):message_id::STRING
#                 ELSE NULL
#                 END as mess_id,
#                 user_sso_guid,
#                 event_time
#         from zpg.all_events_diff_ipmsubscription ips
#         INNER JOIN  zpg.all_events al
#           ON al.event_id = ips.event_id
#         )
#         , camps as (
#         Select Distinct message_id,campaign_title
#           from IPM.PROD.IPM_CAMPAIGN
#           )
#           ,diff_events as (
#               Select *
#               from ipms i
#               join camps c
#               on i.mess_id = c.message_id
#             ) Select * from diff_events where diff_event_0 like 'IPM Displayed'
# ;;
#     }

#     measure: count {
#       type: count
#       drill_fields: [detail*]
#     }

#     dimension: event_id {
#       type: number
#       primary_key: yes
#       sql: ${TABLE}."EVENT_ID" ;;
#     }

#     dimension: diff_event_0 {
#       type: string
#       sql: ${TABLE}."DIFF_EVENT_0" ;;
#     }

#     dimension: diff_event_1 {
#       type: string
#       sql: ${TABLE}."DIFF_EVENT_1" ;;
#     }

#     dimension: diff_event_2 {
#       type: string
#       sql: ${TABLE}."DIFF_EVENT_2" ;;
#     }

#     dimension: diff_event_3 {
#       type: string
#       sql: ${TABLE}."DIFF_EVENT_3" ;;
#     }

#     dimension: diff_event_4 {
#       type: string
#       sql: ${TABLE}."DIFF_EVENT_4" ;;
#     }

#     dimension: diff_event_5 {
#       type: string
#       sql: ${TABLE}."DIFF_EVENT_5" ;;
#     }

#     dimension: event_no {
#       type: number
#       sql: ${TABLE}."EVENT_NO" ;;
#     }

#     dimension: mess_id {
#       type: string
#       sql: ${TABLE}."MESS_ID" ;;
#     }

#     dimension: user_sso_guid {
#       type: string
#       sql: ${TABLE}."USER_SSO_GUID" ;;
#     }

#     dimension_group: event_time {
#       type: time
#       sql: ${TABLE}."EVENT_TIME" ;;
#     }

#     dimension: message_id {
#       type: string
#       sql: ${TABLE}."MESSAGE_ID" ;;
#     }

#     dimension: campaign_title {
#       type: string
#       sql: ${TABLE}."CAMPAIGN_TITLE" ;;
#     }

#     measure: total_displayed {
#       type: count_distinct
#       sql: ${user_sso_guid} ;;
#     }

#   measure: total_clicked {
#     type: count_distinct
#     sql: CASE WHEN diff_event_1 like 'IPM Clicked' THEN ${user_sso_guid} END ;;
#   }

#   measure: total_converted {
#     type: count_distinct
#     sql: CASE WHEN diff_event_2 ilike 'Subscription: %Converted%' OR diff_event_2 ilike 'Subscription: %Reinstated%' OR
#     diff_event_2 ilike 'Subscription: %Full Access%' OR diff_event_2 ilike '%Subscription Without Trial%' THEN ${user_sso_guid} end ;;
#   }

#     set: detail {
#       fields: [
#         event_id,
#         diff_event_0,
#         diff_event_1,
#         diff_event_2,
#         diff_event_3,
#         diff_event_4,
#         diff_event_5,
#         event_no,
#         mess_id,
#         user_sso_guid,
#         event_time_time,
#         message_id,
#         campaign_title
#       ]
#     }
#   }
