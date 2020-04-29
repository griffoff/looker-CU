explore: unused_accounts {}
view: unused_accounts {

  derived_table: {
    sql:
        WITH all_events_merged AS (
          SELECT DISTINCT e.user_sso_guid , e.date
          FROM ${guid_platform_date_active.SQL_TABLE_NAME} e
        )
        SELECT DISTINCT COALESCE(m.primary_guid, e.linked_guid) AS merged_guid, e.rsrc_timestamp::date AS event_time
          FROM prod.datavault.sat_user e
                  LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m ON e.linked_guid = m.partner_guid
                  LEFT JOIN all_events_merged a ON a.user_sso_guid = COALESCE(m.primary_guid, e.linked_guid)
          WHERE merged_guid IS NOT NULL
          AND a.user_sso_guid IS NULL

          ;;
    persist_for: "24 hours"
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}.merged_guid ;;
  }

  dimension: event_time {
    type: date
    sql: ${TABLE}.event_time ;;
  }




}
