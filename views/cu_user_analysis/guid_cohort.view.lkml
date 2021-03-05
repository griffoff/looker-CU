explore: guid_cohort {hidden:yes}
view: guid_cohort {
  view_label: "User Details"

  derived_table: {
    sql: Select * from uploads.cu.guid_cohort where NOT _fivetran_deleted
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: cohort_group {
    label: "Custom Upload Cohort"
    description: "Upload custom list of guids via Fivetran. Please reach out to Looker admin if interested in using"
    group_label: "Custom Upload Cohort"
  }

  dimension: _fivetran_deleted {
    hidden: yes
    type: string
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

  dimension: guid {
    label: "Custom Upload Cohort GUID"
    description: "List of GUIDs uploaded via Fivetran to conduct cohort analysis"
    type: string
    sql: ${TABLE}."GUID" ;;
    group_label: "Custom Upload Cohort"
    hidden: yes
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
