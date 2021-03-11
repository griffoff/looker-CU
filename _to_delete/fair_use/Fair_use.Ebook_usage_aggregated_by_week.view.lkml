# view: ebook_usage_aggregated_by_week {
#     derived_table: {
#               sql:WITH combined_ebook_data AS
#                         (SELECT
#                         event_time
#                         ,user_sso_guid
#                         ,vbid AS ebook_id
#                         ,event_action
#                         ,'vital source' AS source
#                         FROM unlimited.raw_vitalsource_event
#                         WHERE event_action = 'Searched'
#                         OR event_action = 'Viewed'

#                         UNION

#                         SELECT
#                         event_time
#                         ,user_identifier AS user_sso_guid
#                         ,core_text_isbn AS ebook_id
#                         ,event_action
#                         ,'mind tap reader' AS source
#                         FROM cap_er.prod.raw_mt_resource_interactions
#                         WHERE event_category = 'READING'
#                         AND event_action = 'VIEW'

#                         UNION

#                         SELECT
#                         TO_TIMESTAMP_LTZ(visitstarttime) AS event_time
#                         ,userssoguid AS user_sso_guid
#                         ,ssoisbn AS ebook_id
#                         ,eventaction AS event_action
#                         ,'mind tap mobile' AS source
#                         FROM prod.raw_ga.ga_mobiledata
#                         WHERE eventcategory = 'Reader'
#                         AND ssoisbn IS NOT NULL)

#                         ,cengage_unlimited_users AS
#                         (SELECT
#                         ced.event_time AS event_time
#                         ,ced.user_sso_guid AS user_sso_guid
#                         ,ced.ebook_id AS ebook_id
#                         ,ced.event_action AS event_action
#                         ,ced.source AS source
#                         ,CASE WHEN (rse.message_type = 'CUSubscription') THEN 1 ELSE 0 END AS unlimited_user
#                         FROM combined_ebook_data ced
#                         INNER JOIN unlimited.raw_subscription_event rse
#                         ON ced.user_sso_guid = rse.user_sso_guid)


#                         SELECT
#                           user_sso_guid
#                           ,DATE_TRUNC('week', event_time) AS week
#                           ,COUNT(DISTINCT ebook_id) AS unique_ebooks
#                         FROM cengage_unlimited_users
#                         WHERE user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users)
#                         GROUP BY 1, 2 ;;
#                 }



#   dimension: user_sso_guid {}
#   dimension: unique_ebooks {
#     type: number
#     }

#   dimension: week {
#     type: date_week
#   }


#   dimension: unique_product_bucket {
#     type:  tier
#     tiers: [2, 4, 6, 8]
#     style:  integer
#     sql: ${TABLE}.unique_ebooks;;
#   }

#   measure: count_users {
#     type:  count_distinct
#     sql: ${TABLE}.USER_SSO_GUID ;;

#   }
# }
