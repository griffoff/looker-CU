explore: ebook_sessions {}
view: ebook_sessions {
  sql_table_name: ZANDBOX.PGRIFFITHS.EBOOK_SESSIONS;;

  dimension: ebook_session_id {}
  dimension: merged_guid {}

  dimension: session_no {type:number}
  dimension: session_no_reverse {type:number}
  dimension: week_session_no {type:number}
  dimension: week_session_no_reverse {type:number}


  dimension_group: session_start_time {
    group_label: "Session Start Date"
    label: "Session Start"
    type:time
    timeframes: [raw,date,week,month,year]
  }

  dimension_group: session_end_time {
    hidden:  yes
    label: "Session End Time"
    type:time
    timeframes: [raw]
  }


  dimension: page_read_count  {type:number}

  dimension: page_read_count_mt  {type:number}
  dimension: page_read_count_gt  {type:number}
  dimension: page_read_count_vs  {type:number}

  dimension: session_duration_seconds {}

  dimension_group: session_duration {
    group_label: "Session Length"
    label: "in Session"
    type: duration
    sql_start: ${session_start_time_raw};;
    sql_end: ${session_end_time_raw};;
    intervals: [second, minute, hour]
  }


  dimension:  session_length_bucket_30 {
    sql: CASE WHEN session_duration_seconds < 300 THEN '(1) 0-5 min'
              WHEN session_duration_seconds < 600 THEN '(2) 5-10 min'
              WHEN session_duration_seconds < 1200 THEN '(3) 10-20 min'
              WHEN session_duration_seconds < 1800 THEN '(4) 20-30 min'
              ELSE '(5) >30 min'
          END ;;
  }



  dimension:  session_length_bucket_75 {
    sql: CASE WHEN session_duration_seconds < 300 THEN '(1) 0-5 min'
              WHEN session_duration_seconds < 600 THEN '(2) 5-10 min'
              WHEN session_duration_seconds < 900 THEN '(3) 10-15 min'
              WHEN session_duration_seconds < 1800 THEN '(4) 15-30 min'
              WHEN session_duration_seconds < 2700 THEN '(5) 30-45 min'
              WHEN session_duration_seconds < 3600 THEN '(6) 45-60 min'
              WHEN session_duration_seconds < 4500 THEN '(7) 60-75 min'
              ELSE '(8) >75 min'
          END ;;
  }

  measure: merged_guid_count {
    label: "# Users"
    sql: ${merged_guid} ;;
    type:  count_distinct
  }

  measure: session_count {
    label: "# Sessions"
    sql: ${ebook_session_id} ;;
    type:  count_distinct
    value_format_name: decimal_0
  }

  }
