# explore: ipm_conversion_rent_chegg {}

# view: ipm_conversion_rent_chegg {
#   derived_table: {
#     sql: With ipm_dis as (
#         Select to_timestamp(b.event_time) as ipm_event_time,user_sso_guid, campaign_title from IPM.PROD.IPM_Browser_event b
#                 JOIN IPM.PROD.IPM_CAMPAIGN c
#                 ON c.message_id = b.message_id
#                 where c.campaign_title IN ('CU Textbook Rental AB Campaign: A','CU Textbook Rental AB Campaign: B')
#                 and event_action ilike 'clicked'
#     ),peps_converted as
#         (
#     --select count(*),campaign_title from ipm_dis group by 2; --3171
#     select
#     campaign_title,event_name, ev.user_sso_guid
#     from prod.zpg.all_events ev
#     --select ipm_event_time,event_time,ev.user_sso_guid,event_name from prod.zpg.all_events ev
#         INNER JOIN ipm_dis i
#         on i.user_sso_guid = ev.user_sso_guid
#         AND ipm_event_time <= to_timestamp(ev.event_time)
#         where event_name ilike 'Rent From Chegg Clicked'
#     ),all_ipm as (
#     SELECT
#       ipm_campaign."CAMPAIGN_TITLE"  AS campaign_title,
#       ipm_browser_event."EVENT_ACTION"  AS event_action,
#       ipm_browser_event.USER_SSO_GUID
#         FROM IPM.PROD.IPM_BROWSER_EVENT  AS ipm_browser_event
#         LEFT JOIN IPM.PROD.IPM_CAMPAIGN  AS ipm_campaign ON (ipm_browser_event."MESSAGE_ID") = (ipm_campaign."MESSAGE_ID")
#         WHERE
#       (UPPER(ipm_campaign."CAMPAIGN_TITLE" ) = UPPER('CU Textbook Rental AB Campaign: A') OR UPPER(ipm_campaign."CAMPAIGN_TITLE" ) = UPPER('CU Textbook Rental AB Campaign: B'))

#     ), union_tab as(
#         Select * from all_ipm
#       UNION ALL
#         Select * from peps_converted
#     )select * from union_tab
# ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: campaign_title {
#     type: string
#     sql: ${TABLE}."CAMPAIGN_TITLE" ;;
#   }

#   dimension: event_action {
#     type: string
#     sql: ${TABLE}."EVENT_ACTION" ;;
#   }

#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#   }

#   measure: user_sso_guid_count {
#     label: "# users"
#     type: count_distinct
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#   }

#   set: detail {
#     fields: [campaign_title, event_action, user_sso_guid]
#   }
# }
