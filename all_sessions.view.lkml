view: all_sessions {
  sql_table_name: CU_USER_ANALYSIS.ALL_SESSIONS ;;
  view_label: "Sessions"

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
    primary_key: yes
    label: "Session ID"
    description: "Unique session identifier"
  }

  dimension: age_in_days {
    type: number
    sql: ${TABLE}."AGE_IN_DAYS" ;;
    label: "Session age in days"
    description: "Number of days since the first login and this session occurred"
  }


  dimension: course_keys {
    type: string
    sql: ${TABLE}."COURSE_KEYS" ;;
    label: "Course keys"
    description: "Unique course keys related to an event that occurred in the given session i.e. registration, provisioned product, etc."
    hidden: yes
  }

  dimension: ips {
    type: string
    sql: ${TABLE}."IPS"[0];;
    label: "IP address"
    description: "IP address from the first event in this session per Google Analytics"
    hidden: yes
  }

  dimension: number_of_courseware_events {
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_COURSEWARE_EVENTS" ;;
    label: "Number of courseware events"
    description: "Number of courseware related events in the given session"
  }

  dimension: number_of_dashboard_clicks {
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_DASHBOARD_CLICKS" ;;
    label: "Number of dashboard events"
    description: "Number of dashboard related events in the given session"
  }

  dimension: number_of_ebook_events {
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_EBOOK_EVENTS" ;;
    label: "Number of ebook events"
    description: "Number of ebook related events in the given session"
  }

  dimension: number_of_partner_clicks {
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_PARTNER_CLICKS" ;;
    label: "Number of partner click events"
    description: "Number of partner related events (Chegg, Kaplan, etc.) in the given session"
  }

  dimension: number_of_searches {
    type: number
    group_label: "Event Counts"
    sql: ${TABLE}."NUMBER_OF_SEARCHES" ;;
    label: "Number of search events"
    description: "Number of search events in the given session"
  }

  dimension: session_length_mins {
    group_label: "Session Info"
    type: number
    sql: ${TABLE}."SESSION_LENGTH_MINS" ;;
    label: "Session length (minutes)"
    description: "Length of the given session in minutes"
    value_format: "0 \m\i\n\u\t\e\s"
  }

  dimension: session_length_mins_tier {
    group_label: "Session Info"
    type: tier
    tiers: [ 30, 60, 120, 180, 240]
    style: integer
    sql: ${session_length_mins} ;;
    label: "Session length (minutes) tiers"
    description: "Tiers for bucketing session lengths in minutes"
    value_format: "0 \m\i\n\u\t\e\s"
  }

  dimension: session_length_tier {
    group_label: "Session Info"
    type: tier
    tiers: [ 0.0208333333, 0.04166666666, 0.08333333333, 0.125, 0.16666666666]
    style: relational
    sql: ${session_length} ;;
    label: "Session length tiers"
    description: "Tiers for bucketing session lengths (formated as HH:mm:ss)"
    value_format_name:  duration_hms
  }

  dimension: session_length {
    group_label: "Session Info"
    type: number
    sql: ${TABLE}."SESSION_LENGTH_MINS" / 60 / 24 ;;
    label: "Session length"
    description: "Length of the given session (formated as HH:mm:ss)"
    value_format_name: duration_hms
  }

  dimension_group: session_start {
    label: "Session"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."SESSION_START" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    label: "User SSO GUID"
    description: "User SSO GUID"
    hidden: yes
  }

  measure:  average_courseware_events{
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_courseware_events};;
    label: "# Courseware events (avg)"
    description: "Average number of courseware events"
  }

  measure:  average_dashboard_clicks {
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_dashboard_clicks};;
    label: "# Dashboard click events (avg)"
    description: "Average number of dashboard click events"
  }

  measure:  average_ebook_events{
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_ebook_events};;
    label: "# Ebook events (avg)"
    description: "Average number of ebook events"
  }

  measure:  average_partner_clicks{
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_partner_clicks};;
    label: "# Partner click events (avg)"
    description: "Average number of partner click events"
  }

  measure:  average_searches{
    group_label: "Event Counts"
    type: average
    sql:  ${number_of_searches};;
    label: "# Search events (avg)"
    description: "Average number of search events"
  }

  measure: count {
    label: "# Sessions"
    type: count
    description: "Number of sessions
    - A session is defined as all activities and events by a single user with no more than 30 minutes between one event and the next"
  }

}
