view: ipm_260_email_list {
  derived_table: {
    sql: SELECT * FROM  uploads.cu.ipm_260_email_list
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [_file, _line, email, _fivetran_synced_time]
  }

  set: marketing_fields {
    fields: [ipm_260_email_list.email]
  }

}
