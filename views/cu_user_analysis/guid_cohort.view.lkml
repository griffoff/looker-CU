explore: guid_cohort {}
view: guid_cohort {
  label: "X Cohort Analysis X"
  derived_table: {
    sql: Select * from uploads.cu.guid_cohort where NOT _fivetran_deleted
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: cohort_group {
    label: "Custom cohort"
    description: "Upload custom list of guids via Fivetran. Please reach out to Looker admin if interested in using"
  }

  dimension: _fivetran_deleted {
    hidden: yes
    type: string
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

  dimension: guid {
    label: "Custom Cohort GUID"
    type: string
    sql: ${TABLE}."GUID" ;;
  }

  dimension_group: _fivetran_synced {
    hidden: yes
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [_row, _fivetran_deleted, guid, _fivetran_synced_time]
  }
}
