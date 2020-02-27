view: aj_survey {
  sql_table_name: UPLOADS.CU.AJ_SURVEY ;;

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

  dimension: ga_dashboarddata_userssoguid {
    type: string
    sql: ${TABLE}."GA_DASHBOARDDATA_USERSSOGUID" ;;
  }

  dimension: response_id {
    type: string
    sql: ${TABLE}."RESPONSE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
