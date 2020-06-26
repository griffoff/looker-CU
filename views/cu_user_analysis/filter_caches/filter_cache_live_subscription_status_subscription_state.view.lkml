  explore: filter_cache_live_subscription_status_subscription_state {hidden:yes}
  view: filter_cache_live_subscription_status_subscription_state {
    derived_table: {
      sql: select distinct subscription_state
            FROM ${raw_subscription_event_sap.SQL_TABLE_NAME}  ;;
      datagroup_trigger: daily_refresh
    }
    dimension: subscription_state {}
  }
