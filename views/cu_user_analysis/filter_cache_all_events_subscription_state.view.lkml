explore: filter_cache_all_events_subscription_state {hidden:no}
view: filter_cache_all_events_subscription_state {
  derived_table: {
    sql: select distinct COALESCE(subscription_state, INITCAP(REPLACE(event_data:subscription_state, '_', ' '))) as event_subscription_state from ${all_events.SQL_TABLE_NAME}  ;;
    datagroup_trigger: daily_refresh
  }
  dimension: event_subscription_state {}
}
