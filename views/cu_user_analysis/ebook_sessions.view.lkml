explore: ebook_sessions {}
view: ebook_sessions {
  sql_table_name: ZANDBOX.PGRIFFITHS.EBOOK_SESSIONS;;

  dimension: ebook_session_id {}
  dimension: merged_guid {}

  dimension_group: session_start_time {
    label: "Session Start Time"
    type:time
    timeframes: [raw,date,week,month,year]
  }

  dimension: session_end_time {}

  dimension: page_read_event_count  {}
  dimension: session_duration_seconds {}

  dimension:  session_length_bucket {
    sql: CASE WHEN session_duration_seconds < 300 THEN '(1) 0-5 min'
              WHEN session_duration_seconds < 600 THEN '(2) 5-10 min'
              WHEN session_duration_seconds < 1200 THEN '(3) 10-20 min'
              WHEN session_duration_seconds < 1800 THEN '(4) 20-30 min'
              ELSE '(5) >30 min'
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
  }

  }
