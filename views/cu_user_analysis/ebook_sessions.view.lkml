explore: ebook_sessions {
  join: ebook_sessions_weekly {
    sql_on: ${ebook_sessions.merged_guid} = ${ebook_sessions_weekly.merged_guid}
    and ${ebook_sessions.session_start_time_week} = ${ebook_sessions_weekly.session_start_time_week} ;;
    type: inner
    relationship: many_to_one
  }
}

explore: ebook_sessions_only {
  from: ebook_sessions
  hidden: yes
}

view: ebook_sessions_weekly {
  label: "E-Book Sessions (Weekly)"
  derived_table: {
    explore_source: ebook_sessions_only {
      column: session_start_time_week {}
      column: merged_guid {}
      column: total_session_length {}
      derived_column: session_duration_seconds {sql: total_session_length  * (60 * 60 * 24);;}
      column: total_pages_read {}
      column: avg_page_read_time {}
      column: session_count {}
    }

    persist_for: "24 hours"
  }

  dimension: total_session_time {
    value_format: "[m] \m\i\n\s"
    type: number
  }

  dimension: session_duration_seconds {
    type:number
    hidden:yes
  }

  dimension:  session_length_bucket_75 {
    label: "Weekly Total Session Time (up to 75 minutes)"
    case: {
      when: {label:"0-5 min" sql: ${session_duration_seconds} < 300 ;;}
      when: {label:"5-10 min" sql: ${session_duration_seconds} < 600 ;;}
      when: {label:"10-15 min" sql: ${session_duration_seconds} < 900 ;;}
      when: {label:"15-30 min" sql: ${session_duration_seconds} < 1800 ;;}
      when: {label:"30-45 min" sql: ${session_duration_seconds} < 2700 ;;}
      when: {label:"45-60 min" sql: ${session_duration_seconds} < 3600 ;;}
      when: {label:"60-75 min" sql: ${session_duration_seconds} < 4500 ;;}
      else: ">75 min"
    }
    description: "Sum Total of Session Lengths in a given week per individual student, bucketed into groups"
  }

  dimension:  total_sessions_in_week_bucket_tiers {
    label: "Total Sessions in Week (buckets)"
    case: {
      when: {label: "1 session" sql: ${total_sessions_count} = 1;;}
      when: {label: "2 sessions" sql: ${total_sessions_count} = 2;;}
      when: {label: "3-4 sessions" sql: ${total_sessions_count} < 5;;}
      when: {label: "5 or more sessions" sql: ${total_sessions_count} >= 5;;}
      else: "no sessions?"
    }
  }

  dimension_group: session_start_time {
    label: "Ebook Sessions Session Start"
    type: time
    timeframes: [raw, week, month, year]
    sql: ${TABLE}.session_start_time_week ;;
    hidden: yes
  }

  dimension: merged_guid {hidden: yes}

  dimension: total_sessions_count {
    label: "Total Sessions in Week"
    value_format_name: decimal_0
    sql: ${TABLE}.session_count ;;
  }

  dimension: total_pages_read {
    label: "Total Pages Read Per Week"
    hidden: yes
    value_format: "#,##0"
    type: number
  }
  dimension: avg_page_read_time {
    hidden: yes
    label: "Average Weekly Page Read Time"
    value_format: "[m]:ss \m\i\n\s"
    type: number
  }
}



view: ebook_sessions {
  label: "E-Book Sessions"
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


  dimension: page_read_count  {
    type:number
    label: "Pages viewed in Session"
    }

  dimension: page_read_count_mt  {type:number}
  dimension: page_read_count_gt  {type:number}
  dimension: page_read_count_vs  {type:number}
  dimension: page_read_count_mobile  {type:number}

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
    case: {
      when: {label:"0-5 min" sql: ${session_duration_seconds} < 300 ;;}
      when: {label:"5-10 min" sql: ${session_duration_seconds} < 600 ;;}
      when: {label:"10-20 min" sql: ${session_duration_seconds} < 1200 ;;}
      when: {label:"20-30 min" sql: ${session_duration_seconds} < 1800 ;;}
      else: ">30 min"
    }
    label: "Session Length Buckets (up to 30 minutes)"
    description: "Length of each individual session, bucketed into groups"
  }

  dimension: time_between_pages {
    type: number
    sql: (${seconds_session_duration} / ${page_read_count}) / (60 * 60 * 24) ;;
    hidden: yes
  }

  measure: time_between_pages_avg {
    label: "Time between pages per session Average"
    group_label: "Time between pages"
    type: average
    sql: ${time_between_pages} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: time_between_pages_min {
    label: "Time between pages Minimum"
    group_label: "Time between pages"
    type: min
    sql: ${time_between_pages} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: time_between_pages_1q {
    label: "Time between pages 1st quartile"
    group_label: "Time between pages"
    type: percentile
    percentile: 25
    sql: ${time_between_pages} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: time_between_pages_median {
    label: "Time between pages Median"
    group_label: "Time between pages"
    type: median
    sql: ${time_between_pages} ;;
    value_format: "[m]:ss \m\i\n\s"
  }


  measure: time_between_pages_3q {
    label: "Time between pages 3rd quartile"
    group_label: "Time between pages"
    type: percentile
    percentile: 75
    sql: ${time_between_pages} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: time_between_pages_max {
    label: "Time between pages Maximum"
    group_label: "Time between pages"
    type: max
    sql: ${time_between_pages} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_session_length {
    label: "Total Session Time"
    type: sum
    sql: ${seconds_session_duration} / (60 * 60 * 24) ;;
    value_format: "[m] \m\i\n\s"
    description: "Total of all session durations"
  }

  measure: average_session_length {
    label: "Average Session Length"
    type: average
    sql: ${seconds_session_duration} / (60 * 60 * 24) ;;
    value_format: "[m] \m\i\n\s"
    description: "Average session duration"
  }

  measure: total_pages_read {
    label: "Total Pages Viewed"
    type: sum
    sql: ${page_read_count} ;;
    value_format_name: decimal_0
  }

  measure: avg_pages_read {
    label: "Average Pages per session"
    type: average
    sql: ${page_read_count} ;;
    value_format_name: decimal_0
  }

  measure: avg_page_read_time {
    label: "Avg. time between pages in session"
    type: number
    sql: ${total_session_length} / ${total_pages_read} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: merged_guid_count {
    label: "# Students"
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
