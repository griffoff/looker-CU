view: event_groups {
  sql_table_name: UPLOADS.CU.EVENT_GROUPS ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: event_group {
    type: string
    sql: ${TABLE}."EVENT_GROUP" ;;
  }

  dimension: event_name {
    type: string
    primary_key: yes
    sql: ${TABLE}."EVENT_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [event_name]
  }
}
