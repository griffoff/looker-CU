view: all_sessions {
  sql_table_name: prod.cu_user_analysis.all_sessions ;;
  view_label: "Sessions"

#   parameter: session_sampling {
#     view_label: "** RECOMMENDED FILTERS **"
#     group_label: "Sampling"
#     label: "Session sample size"
#     description: "Only use a sample of the full dataset (speeds up queries and gives good overall results, but will not return every datapoint if you are looking at detailed records)"
#     type: unquoted
#     default_value: "10"
#     allowed_value: {label:"10% sampling" value:"10"}
#     allowed_value: {label:"25% sampling" value:"25"}
#     allowed_value: {label:"50% sampling" value:"50"}
#     allowed_value: {label:"All records" value:"100"}
#   }

  dimension: session_id {
    hidden:  yes
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
    primary_key: yes
    label: "Session ID"
    description: "Unique session identifier"
  }

  dimension: age_in_days {
    hidden: yes
    type: number
    sql: ${TABLE}."AGE_IN_DAYS" ;;
    label: "Session age in days"
    description: "Number of days since the first login in this session occurred"
  }


  dimension: course_keys {
    type: string
    sql: ${TABLE}."COURSE_KEYS" ;;
    label: "Course keys"
    description: "Unique course keys related to an event that occurred in the given session i.e. registration, provisioned product, etc."
    hidden: yes
  }

  dimension: ips {
    group_label: "IPs used"
    type: string
    sql: ${TABLE}."IPS"[0];;
    label: "IP address"
    description: "IP address from the first event in this session per Google Analytics"
    hidden: yes
  }

  dimension: ip1 {
    group_label: "Internal IP"
    type: string
    sql: CASE WHEN SPLIT_PART(${TABLE}."IPS"[0], '.', 1) IN ('10', '172', '192', '127') THEN 'internal' ELSE 'external' END  ;;
    label: "IP address internal 1"
    description: "IP address from the first event in this session per Google Analytics was internal/external"
    hidden: yes
  }

  dimension: ip2 {
    group_label: "Internal IP"
    type: string
    sql: CASE WHEN SPLIT_PART(${TABLE}."IPS"[1], '.', 1) IN ('10', '172', '192', '127') THEN 'internal' ELSE 'external' END  ;;
    label: "IP address internal 2"
    description: "IP address from the first event in this session per Google Analytics was internal/external"
    hidden: yes
  }

  dimension: ip3 {
    group_label: "Internal IP"
    type: string
    sql: CASE WHEN SPLIT_PART(${TABLE}."IPS"[2], '.', 1) IN ('10', '172', '192', '127') THEN 'internal' ELSE 'external' END  ;;
    label: "IP address internal 3"
    description: "IP address from the first event in this session per Google Analytics was internal/external"
    hidden: yes
  }

  dimension: ip4 {
    group_label: "Internal IP"
    type: string
    sql: CASE WHEN SPLIT_PART(${TABLE}."IPS"[3], '.', 1) IN ('10', '172', '192', '127') THEN 'internal' ELSE 'external' END  ;;
    label: "IP address internal 4"
    description: "IP address from the first event in this session per Google Analytics was internal/external"
    hidden: yes
  }

  dimension: number_of_courseware_events {
    #potential hide for clean up
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_COURSEWARE_EVENTS" ;;
    label: "Number of courseware events"
    description: "Number of courseware related events in the given session"
  }

  dimension: number_of_dashboard_clicks {
    #potential hide for clean up
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_DASHBOARD_CLICKS" ;;
    label: "Number of dashboard events"
    description: "Number of dashboard related events in the given session"
  }

  dimension: number_of_ebook_events {
    #potential hide for clean up
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_EBOOK_EVENTS" ;;
    label: "Number of ebook events"
    description: "Number of ebook related events in the given session"
  }

  dimension: number_of_partner_clicks {
    #potential hide for clean up
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_PARTNER_CLICKS" ;;
    label: "Number of partner click events"
    description: "Number of partner related events (Chegg, Kaplan, etc.) in the given session"
  }

  dimension: number_of_searches {
    #potential hide for clean up
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_SEARCHES" ;;
    label: "Number of search events"
    description: "Number of search events in the given session"
  }

  dimension: session_length_mins {
    group_label: "Session Length"
    type: number
    sql: ${TABLE}."SESSION_LENGTH_MINS" ;;
    label: "Session length (minutes)"
    description: "Length of the given session in minutes"
    value_format: "0 \m\i\n\u\t\e\s"
  }

  dimension: session_length_mins_tier {
    group_label: "Session Length"
    type: tier
    tiers: [ 30, 60, 120, 180, 240]
    style: integer
    sql: ${session_length_mins} ;;
    label: "Session length (minutes) tiers"
    description: "Tiers for bucketing session lengths in minutes"
    value_format: "0 \m\i\n\u\t\e\s"
  }

  dimension: session_length_tier {
    group_label: "Session Length"
    type: tier
    tiers: [ 0.0208333333, 0.04166666666, 0.08333333333, 0.125, 0.16666666666, 0.20833333333, 0.25]
    style: relational
    sql: ${session_length} ;;
    label: "Session length tiers"
    description: "Tiers for bucketing session lengths (formatted as HH:mm:ss)"
    value_format:  "[m] \m\i\n\s"
  }

  dimension: session_length {
    group_label: "Session Length"
    type: number
    sql: ${TABLE}."SESSION_LENGTH_MINS" / 60 / 24 ;;
    label: "Session length"
    description: "Length of the given session (formatted as HH:mm:ss)"
    value_format: "[m] \m\i\n\s"
  }

  dimension_group: session_start {
    label: "Session"
    description: "Start time of session converted to EST - captured from systems, so does not represent users local time
    ** Filtering on this can speed up queries significantly **"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year, day_of_year, week_of_year, day_of_week]
    sql: CONVERT_TIMEZONE('EST', ${TABLE}."SESSION_START");;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    label: "User SSO GUID"
    description: "User SSO GUID"
    hidden: yes
  }

  measure:  average_courseware_events{
    #potential hide for clean up
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_courseware_events};;
    label: "# Courseware events (avg)"
    description: "Average number of courseware events"
  }

  measure:  average_dashboard_clicks {
    #potential hide for clean up
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_dashboard_clicks};;
    label: "# Dashboard click events (avg)"
    description: "Average number of dashboard click events"
  }

  measure:  average_ebook_events{
    #potential hide for clean up
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_ebook_events};;
    label: "# Ebook events (avg)"
    description: "Average number of ebook events"
  }

  measure:  average_partner_clicks{
    #potential hide for clean up
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_partner_clicks};;
    label: "# Partner click events (avg)"
    description: "Average number of partner click events"
  }

  measure:  average_searches{
    #potential hide for clean up
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_searches};;
    label: "# Search events (avg)"
    description: "Average number of search events"
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
    hidden: yes
  }


  measure: user_day_count {
    type: count_distinct
    sql: ${user_sso_guid}, ${session_start_raw}::DATE ;;
    hidden: yes
  }

  measure: user_week_count {
    type: count_distinct
    sql: ${user_sso_guid}, DATE_TRUNC('week', ${session_start_raw}) ;;
    hidden: yes
  }

  measure: user_month_count {
    type: count_distinct
    sql: ${user_sso_guid}, DATE_TRUNC('month', ${session_start_raw}) ;;
    hidden: yes
  }

  measure: sessions_per_user_per_week {
    group_label: "Time in product"
    label: "Average sessions per user per week"
    type: number
    sql: ${count} / ${user_week_count};;
    value_format_name: decimal_1
    description: "Total number of sessions divided by distinct user weekly sessions"
  }

  measure: session_length_mins_avg {
    group_label: "Time in product"
    label: "Average session length in minutes"
    type: average
    sql: ${session_length_mins} / 60 / 24;;
    value_format: "[m] \m\i\n\s s \s\e\c\s"
    description: "Average of all session lengths in minutes"
  }

  measure: session_length_total {
    group_label: "Time in product"
    description: "Total of all session lengths in minutes"
    label: "Total time in product"
    hidden: no
    type: sum
    sql: ${session_length} ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: session_length_average_per_student_per_week {
    group_label: "Time in product"
    description: "Average total session time per user per week in minutes"
    label: "Average time in product per user per week"
    type: number
    sql: ${session_length_total} / ${user_week_count}  ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: session_length_average_per_student_per_day {
    group_label: "Time in product"
    description: "Average total session time per user per active day in minutes"
    label: "Average time in product per user per day"
    type: number
    sql: ${session_length_total} / ${user_day_count}  ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: session_length_average_per_student_per_month {
    group_label: "Time in product"
    description: "Average total session time per user per active month in minutes"
    label: "Average time in product per user per month"
    type: number
    sql: ${session_length_total} / ${user_month_count}  ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: session_length_average_per_student {
    group_label: "Time in product"
    label: "Average time in product per user in minutes"
    type: number
    sql: ${session_length_total} / ${user_count}  ;;
    value_format: "[m] \m\i\n\s"
    description: "Total session length in minutes divided by number of distinct user"
  }


  measure: count {
    label: "# Sessions"
    type: count
    description: "Number of sessions
    - A session is defined as all activities and events by a single user with no more than 30 minutes between one event and the next"
  }

}
