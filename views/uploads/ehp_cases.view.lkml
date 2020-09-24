view: ehp_cases {
  sql_table_name: UPLOADS.EHP.CASES
    ;;

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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: date_time_opened {
    type: string
    sql: ${TABLE}."DATE_TIME_OPENED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}."ISSUE_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
