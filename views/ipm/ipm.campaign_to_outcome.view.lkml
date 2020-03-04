include: "/views/cu_user_analysis/all_events.view"

view: ipm_campaign_to_outcome {
  #sql_table_name: uploads.ipm.campaign_to_outcome;;
  derived_table: {
    sql:
     SELECT
        campaign.campaign_title
        ,campaign.message_id
        ,campaign.message_version_no
        ,response.user_sso_guid
        ,events.event_type AS event_category
        ,events.event_name AS event_name
        ,events.product_platform AS product_platform
        ,MIN(events.local_time) as first_event_time
        ,COUNT(*) as occurence
     FROM ${ipm_campaign.SQL_TABLE_NAME} campaign
     INNER JOIN (
          SELECT
            c.message_id
            ,c.message_version_no
            ,e.user_sso_guid
            ,min(e.event_time) AS first_event_time
            ,MAX(e.event_time) AS last_event_time
            ,MIN(CASE WHEN e.event_action IN ('CLICKED', 'DISMISSED') THEN e.event_time END) AS clicked_time
          FROM ${ipm_campaign.SQL_TABLE_NAME} c
          INNER JOIN ipm.prod.ipm_browser_event e ON c.message_id = e.message_id
                                                  AND e.event_time >= c.campaign_start_date
                                                  AND e.event_time < c.next_campaign_start_date
                                                  AND c.platform_environment = e.platform_environment
          GROUP BY 1, 2, 3
        ) response ON campaign.message_id = response.message_id
                                        AND campaign.message_version_no = response.message_version_no
      -- TO DO: check to see whether we need to only collect events after a "click" action from the user on the IPM notification
     INNER JOIN ${all_events.SQL_TABLE_NAME} events ON
                                                        ARRAY_CONTAINS(
                                                          UPPER(
                                                            REPLACE(REPLACE(REPLACE(REPLACE(events.event_name
                                                              ,'Sapsubscription Subscription', 'Subscription:')
                                                              ,'Subscriptionservice Subscription', 'Subscription:')
                                                              ,'Sapsubscription Subscriptiontransfer', 'Subscription:')
                                                              ,'Subscriptionservice Cusubscription', 'Subscription:')
                                                          )::VARIANT
                                                          ,campaign.event_outcome
                                                        )
                                                      AND response.user_sso_guid = events.user_sso_guid
                                                      AND response.clicked_time <= events.local_time
                                                      AND campaign.next_campaign_start_date > events.local_time
     GROUP BY 1, 2, 3, 4, 5, 6, 7
     ;;

      persist_for: "24 hours"
  }

  dimension: campaign_title { hidden:yes}
  dimension: message_id { hidden:yes}
  dimension: message_version_no { hidden:yes}
  dimension: user_sso_guid { hidden:yes}
  dimension: event_name {}
  dimension: event_category {}
  dimension: product_platform {}
  dimension: first_event_time { type:date_time}
  measure: conversion { type: count}

}
