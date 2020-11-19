explore: custom_cohort_filter_summary {}
view: custom_cohort_filter_summary {
  sql_table_name: prod.looker_scratch.looker_cohort_summary ;;

  dimension: filename {}
  dimension: cohort_name {}

  dimension_group: refresh {
    type:time
    sql: ${TABLE}.refresh_time ;;
    timeframes: [raw,date,time]
  }

  dimension: latest {type:yesno}
  dimension: cohort_size {type:number}

  measure: average_cohort_size {
    type: average
    sql: ${cohort_size} ;;
    value_format_name: decimal_0
  }
 }
