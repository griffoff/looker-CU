  explore: filter_cache_all_events_event_group {hidden:yes}
  view: filter_cache_all_events_event_group {
    derived_table: {
      sql:
      with event_names as (
        select distinct event_name, upper(product_platform) as product_platform
        from ${all_events.SQL_TABLE_NAME}
      )
      select distinct
      case
          when e.event_name like 'Subscription:%'
          then e.event_name
          else COALESCE("EVENT_GROUP", '** ' || e.product_platform || ' **', '** Uncategorized **')
      end as event_group
      from event_names e
      left join UPLOADS.CU.EVENT_GROUPS g on upper(e.event_name) like upper(g.event_name) and not _fivetran_deleted

     ;;
      datagroup_trigger: daily_refresh
    }
    dimension: event_group {}
  }
