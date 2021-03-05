include: "./ipm_browser_event.view"

explore: ipm_browser_event_and_outcome {hidden: yes}

view: ipm_browser_event_and_outcome {
  view_label: "IPM Events and Outcomes"
  extends: [ipm_browser_event]

  derived_table: {
    create_process: {
      sql_step:

      CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME}
      CLONE ${ipm_browser_event.SQL_TABLE_NAME}
      ;;

      sql_step:
            INSERT INTO ${SQL_TABLE_NAME} (message_id, event_action, event_category, user_platform, event_time, user_sso_guid)
            SELECT message_id, 'CONVERTED', COALESCE(event_name, 'UNKNOWN EVENT'), product_platform, first_event_time, user_sso_guid
            FROM ${ipm_campaign_to_outcome.SQL_TABLE_NAME}
            ;;

      }

      # sql:
      #   SELECT message_id, event_action, event_category, user_platform, event_time, user_sso_guid
      #   FROM IPM.PROD.IPM_BROWSER_EVENT
      #   UNION ALL
      #   SELECT message_id, 'CONVERTED', COALESCE(event_name, 'UNKNOWN EVENT'), product_platform, first_event_time, user_sso_guid
      #   FROM ${ipm_campaign_to_outcome.SQL_TABLE_NAME}
      #   ;;

    datagroup_trigger: daily_refresh
  }
}
