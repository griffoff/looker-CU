include: "all_sessions.view"


view: all_sessions_dev {
  extends: [all_sessions]
  label: "all sessions dev"
  sql_table_name: zpg.all_sessions ;;



  dimension: age_in_weeks {
    type: number
    sql: ${TABLE}."AGE_IN_WEEKS" ;;
    label: "Session age in weeks"
    description: "Number of weeks since the first login and this session occurred"

  }

  dimension: cities {
    type: string
    sql: ${TABLE}."CITIES" ;;
    label: "Cities"
    description: "The cities where the events in this session occurred from according to Google Analytics"
  }

  dimension: first_city {
    type: string
    sql: ${TABLE}."CITIES"[0] ;;
    label: "First city"
    description: "The city where the first event in this session occurred from according to Google Analytics"
  }

  dimension: no_course_keys {
    type: tier
    tiers: [1, 2, 3]
    style: integer
    sql: array_size(${course_keys}) ;;
    label: "Tiers of number of unique course keys"
    description: "Tiers of number of unique course keys that occurred in the given session"
  }

  dimension: cu_soft_value {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE" ;;
    label: "CU soft value"
    description: "A value representing the value a user recieves from non-courseware related events (searches + ebook events + partner clicks + dashboard clicks)"
  }

  dimension: cu_soft_value_prank {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE_PRANK" ;;
    label: "Percentile ranking of CU soft value"
    description: "Percentile ranking of CU soft value"
  }

  dimension: culogins {
    type: number
    sql: ${TABLE}."CULOGINS" ;;
    label: "Number of CU Logings"
    description: "Number of times a user logged in during the given session"
  }

  dimension: devices {
    type: string
    sql: ${TABLE}."DEVICES" ;;
    label: "Devices"
    description: "Number of unique device IDs in a given session"
  }

  dimension: first_event {
    type: string
    sql: ${TABLE}."FIRST_EVENT" ;;
    label: "First event"
    description: "First event that occurred in the given session"
  }

  dimension: first_session {
    type: yesno
    sql: ${TABLE}."FIRST_SESSION" ;;
    label: "First session"
    description: "TRUE if this is the first session for a given user otherwise FALSE"
  }

  dimension: last_event {
    type: string
    sql: ${TABLE}."LAST_EVENT" ;;
    label: "Last event"
    description: "Last event that occurred in the given session"
  }

  dimension: locations {
    type: string
    sql: ${TABLE}."LOCATIONS" ;;
    label: "Locations"
    description: "List of location details from all unique locations from all events in the given session per IP lookup via extreme-ip-lookup.com"
  }

  dimension: lat {
    type: string
    sql:  ${TABLE}."LOCATIONS"[0]:lat ;;
    label: "Latitude coordinate"
    description: "The latitude coordinate from the first event in the session based on an IP lookup via extreme-ip-lookup.com"
  }

  dimension: lon {
    type: string
    sql:  ${TABLE}."LOCATIONS"[0]:lon ;;
    label: "Longitute coordinate"
    description: "The longitude coordinate from the first event in the session based on an IP lookup via extreme-ip-lookup.com"
  }

  dimension: lat_lon {
    type: location
    sql_latitude: ${TABLE}."LOCATIONS"[0]:lat ;;
    sql_longitude: ${TABLE}."LOCATIONS"[0]:lon ;;
    label: "Longitute and latitude coordinates"
    description: "The longitude and latitude coordinates from the first event in the session based on an IP lookup via extreme-ip-lookup.com which can be used for geo mapping"
  }

  dimension: other_events {
    type: number
    sql: ${TABLE}."OTHER_EVENTS" ;;
    label: "Number of other events"
    description: "Number of other events in the given session"
  }

  dimension: otherlogins {
    type: number
    sql: ${TABLE}."OTHERLOGINS" ;;
    label: "Number of other login type events"
    description: "Number of other login type events not in the given session"
  }

  dimension: products {
    type: string
    sql: ${TABLE}."PRODUCTS" ;;
    label: "Products"
    description: "Number of unique ISBNs related to events in the given session"
  }


  dimension: country {
    type: string
    sql: ${TABLE}."LOCATIONS"[0]:country;;
    label: "Country"
    description: "Country from which the session occurred"
  }

  dimension: regions {
    type: string
    sql: ${TABLE}."REGIONS" ;;
    label: "Regions (states)"
    description: "Unique regions (States in the US) from which the events in the given session occurred"
  }

  dimension: first_state {
    type: string
    sql: REPLACE(${TABLE}."REGIONS"[1], '""', '');;
    map_layer_name: us_states
    label: "First region (state)"
    description: "The region (state) from the first event in the session"

  }

  dimension_group: session_end {
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
    sql: ${TABLE}."SESSION_END" ;;
    label: "Session end"
  }

  dimension: relative_day_number {
    type: number
    label: "Relative day number"
    description: "This users number of unique login dates including the given session"
  }

  dimension: session_gap_hours {
    type: number
    sql: ${TABLE}."SESSION_GAP_HOURS" ;;
    label: "Hours since last session"
    description: "Hours since last session"
  }

  dimension: session_no {
    type: number
    sql: ${TABLE}."SESSION_NO" ;;
    label: "Session number (user)"
    description: "Session number for a given user"
  }

  dimension: session_no_tier {
    type: tier
    tiers: [ 2, 3, 6, 11, 16, 21]
    style: integer
    sql: ${TABLE}."SESSION_NO" ;;
    label: "Session number tiers"
    description: "Tiers for bucketing session numbers"
  }

  dimension: success_searches {}

  dimension: success_tier {
    type: tier
    tiers: [1,2,5,10,20,100]
    style: integer
    sql: ${success_searches} ;;
  }
  dimension: non_success_searches {}

  dimension: non_success_tier {
    type: tier
    tiers: [1,2,5,10,20,100]
    style: integer
    sql: ${non_success_searches} ;;
  }

  measure: sum_success_searches {
    type: sum
    sql:  success_searches;;
  }
  measure: no_sessions {
    label: "# sessions"
    type: count_distinct
    sql: ${session_id} ;;
  }

  measure: sum_non_success_searches {
    type: sum
    sql:  non_success_searches;;
  }

  dimension: unique_event_types {
    type: number
    sql: ${TABLE}."UNIQUE_EVENT_TYPES" ;;
    label: "Number of unique event types"
    description: "Number of unique event types"
  }

  dimension: unique_events {
    type: string
    sql: ${TABLE}."UNIQUE_EVENTS" ;;
    label: "List of unique event types"
    description: "List of unique event types"
  }

  measure:  distinct_users{
    type: count_distinct
    sql:  ${user_sso_guid};;
    label: "Unique user count"
    description: "Unique user count"
  }

  measure: distinct_users_courseware {
    type: count_distinct
    sql: CASE WHEN ${number_of_courseware_events} > 0 THEN ${user_sso_guid} END ;;
    label: "Unique courseware users"
    description: "Unique number of users that have done a courseware event"
  }

  measure: distinct_users_dashboard_clicks {
    type: count_distinct
    sql: CASE WHEN ${number_of_dashboard_clicks} > 0 THEN ${user_sso_guid} END ;;
    label: "Unique courseware users"
    description: "Unique number of users that have done a courseware event"
  }

  measure: distinct_users_ebook_events {
    type: count_distinct
    sql: CASE WHEN ${number_of_ebook_events} > 0 THEN ${user_sso_guid} END ;;
    label: "Unique ebook users"
    description: "Unique number of users that have done an ebook event"
  }

  measure: distinct_users_partner_clicks {
    type: count_distinct
    sql: CASE WHEN ${number_of_partner_clicks} > 0 THEN ${user_sso_guid} END ;;
    label: "Unique users that clicked partner button"
    description: "Unique number of users that clicked a partner button (Chegg, Kaplan, etc.)"
  }

  measure: distinct_users_searches {
    type: count_distinct
    sql: CASE WHEN ${number_of_searches} > 0 THEN ${user_sso_guid} END ;;
    label: "Unique search users"
    description: "Unique number of users that have completed a search event"
  }

  measure: distinct_users_other_events {
    type: count_distinct
    sql: CASE WHEN ${other_events} > 0 THEN ${user_sso_guid} END ;;
    label: "Unique other event users"
    description: "Unique number of users that have done an other event"
  }


  measure:  sum_courseware_events{
    type: sum
    sql:  ${number_of_courseware_events};;
    label: "Sum of courseware events"
    description: "Sum of courseware events"
  }

  measure:  sum_dashboard_clicks {
    type: sum
    sql:  ${number_of_dashboard_clicks};;
    label: "Sum of dashboard click events"
    description: "Sum of dashboard click events"
  }

  measure:  sum_ebook_events{
    type: sum
    sql:  ${number_of_ebook_events};;
    label: "Sum of ebook events"
    description: "Sum of ebook events"
  }

  measure:  sum_partner_clicks{
    type: sum
    sql:  ${number_of_partner_clicks};;
    label: "Sum of partner click events"
    description: "Sum of partner click events"
  }

  measure:  sum_searches{
    type: sum
    sql:  ${number_of_searches};;
    label: "Sum of search events"
    description: "Sum of search events"
  }

  measure:  sum_cu_soft_value {
    type: sum
    sql:  ${cu_soft_value} ;;
    label: "Sum of cu soft value"
    description: "Sum of cu soft value"
  }

  measure:  average_session_duration{
    type: average
    sql:  ${session_length_mins} / (24 * 60);;
    value_format_name: duration_hms
    label: "Average session duration (minutes)"

  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
    label: "Count of unique users"
    description: "Count of unique users"
  }

  measure: count {
    type: count
    drill_fields: []
    label: "Count"
  }


}
