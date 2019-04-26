explore: guid_cohort {}
view: guid_cohort {
  derived_table: {
    sql: Select * from uploads.cu.guid_cohort where _fivetran_deleted
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: _fivetran_deleted {
    type: string
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

  dimension: guid {
    label: "Cohort GUID"
    type: string
    sql: ${TABLE}."GUID" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [_row, _fivetran_deleted, guid, _fivetran_synced_time]
  }
}
