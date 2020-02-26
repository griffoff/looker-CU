view: event_groups {
  view_label: "Events"
#   sql_table_name: UPLOADS.CU.EVENT_GROUPS ;;

  derived_table: {
    sql: select * from UPLOADS.CU.EVENT_GROUPS where not _fivetran_deleted ;;
  }
  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
    label: "Fivetran deleted"
    description: "TRUE if this recorded was deleted via Fivetran and FALSE if record still exists"
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    label: "Fivetran synced"
    description: "Timestamp of the last time fivetran synced the table"
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    label: "Row number"
    description: "Row number of the record in the table"
  }

  dimension: event_group {
    group_label: "Event Classification"
    type: string
#    sql: COALESCE(${TABLE}."EVENT_GROUP", '** Uncategorized **') ;;
    sql: case
          when ${all_events.event_name} like 'Subscription:%'
          then ${all_events.event_name}
          else COALESCE(${TABLE}."EVENT_GROUP", '** ' || ${all_events.product_platform} || ' **', '** Uncategorized **')
          end;;
    label: "Event group"
    description: "Classification hard coded in for grouping events according to different business purposes"
  }

  dimension: event_names {
    type: string
    primary_key: yes
    sql: ${TABLE}."EVENT_NAME" ;;
    label: "Event name"
    description: "Lowest level of classification hierarchy and meant to represent a user action in plain english i.e. 'Clicked Upgrade Button'"
  }

  measure: count {
    type: count
    drill_fields: [event_names]
    label: "Count"
  }
}
