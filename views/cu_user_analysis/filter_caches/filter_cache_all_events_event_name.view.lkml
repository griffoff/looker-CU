explore: filter_cache_all_events_event_name {hidden:yes}
view: filter_cache_all_events_event_name {
  derived_table: {
    sql: select distinct
    CASE WHEN UPPER(product_platform) = 'PERFORMANCE-REPORT-UI' THEN TRIM(INITCAP(LOWER(product_platform)) || ' ' || INITCAP(LOWER(event_type)) || ' ' || INITCAP(LOWER(event_action)))
          ELSE COALESCE(TRIM(event_name), '** ' || UPPER(event_type || ': ' || event_action) || ' **') END AS event_name
    from ${all_events.SQL_TABLE_NAME}  ;;
    datagroup_trigger: daily_refresh
  }
  dimension: event_name {}
  }
