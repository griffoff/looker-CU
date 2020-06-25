explore: filter_cache_all_events_event_name {hidden:no}
view: filter_cache_all_events_event_name {
  derived_table: {
    sql: select distinct event_name from ${all_events.SQL_TABLE_NAME}  ;;
    datagroup_trigger: daily_refresh
  }
  dimension: event_name {}
  }
