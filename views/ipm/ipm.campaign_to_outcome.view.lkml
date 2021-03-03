include: "/views/cu_user_analysis/all_events.view"
explore: ipm_campaign_to_outcome {hidden:yes}

view: ipm_campaign_to_outcome {
  #sql_table_name: uploads.ipm.campaign_to_outcome;;
  derived_table: {
    create_process: {
      sql_step:
        CREATE TRANSIENT TABLE IF NOT EXISTS looker_scratch.ipm_campaign_to_outcome
        CLUSTER BY (message_id)
        (
          campaign_title STRING
          ,message_id STRING
          ,message_version_no INT
          ,user_sso_guid STRING
          ,event_category STRING
          ,event_name STRING
          ,product_platform STRING
          ,first_event_time TIMESTAMP_TZ
          ,occurence INT
        )
        ;;

      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.new_outcomes
        AS
        WITH campaigns AS (
          SELECT *
          FROM ${ipm_campaign.SQL_TABLE_NAME} campaign
          WHERE (campaign.campaign_end_date > CURRENT_DATE() - 14 AND campaign.campaign_start_date <= CURRENT_DATE())
          OR campaign.message_id NOT IN (SELECT message_id FROM looker_scratch.ipm_campaign_to_outcome)
        )
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
        FROM campaigns campaign
        INNER JOIN (
            SELECT
              c.message_id
              ,c.message_version_no
              ,e.user_sso_guid
              ,min(e.event_time) AS first_event_time
              ,MAX(e.event_time) AS last_event_time
              ,MIN(CASE WHEN e.event_action IN ('CLICKED', 'DISMISSED') THEN e.event_time END) AS clicked_time
            FROM campaigns c
            INNER JOIN ${ipm_browser_event.SQL_TABLE_NAME} e ON c.message_id = e.message_id
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
                                                              events.event_name
                                                            )::VARIANT
                                                            ,campaign.event_outcome
                                                          )
                                                        AND response.user_sso_guid = events.user_sso_guid
                                                        AND response.clicked_time <= events.local_time
                                                        AND campaign.next_campaign_start_date > events.local_time
        WHERE TO_TIMESTAMP(events.session_id) >= (SELECT MIN(campaign_start_date) FROM campaigns)
        GROUP BY 1, 2, 3, 4, 5, 6, 7
       ;;

      sql_step:
        MERGE INTO looker_scratch.ipm_campaign_to_outcome old
        USING looker_scratch.new_outcomes new ON old.message_id = new.message_id AND old.message_version_no = new.message_version_no AND old.user_sso_guid = new.user_sso_guid
        WHEN MATCHED THEN UPDATE
            SET
              old.campaign_title = new.campaign_title
              ,old.event_category = new.event_category
              ,old.event_name = new.event_name
              ,old.product_platform = new.product_platform
              ,old.first_event_time = new.first_event_time
              ,old.occurence = new.occurence
        WHEN NOT MATCHED THEN INSERT (campaign_title,message_id,message_version_no,user_sso_guid,event_category,event_name,product_platform,first_event_time,occurence)
        VALUES(new.campaign_title,new.message_id,new.message_version_no,new.user_sso_guid,new.event_category,new.event_name,new.product_platform,new.first_event_time,new.occurence)
        ;;

      sql_step: CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME} CLONE looker_scratch.ipm_campaign_to_outcome ;;
    }

      datagroup_trigger: daily_refresh
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
