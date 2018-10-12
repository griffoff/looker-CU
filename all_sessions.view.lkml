view: all_sessions {
  sql_table_name: ZPG.ALL_SESSIONS ;;

  dimension: age_in_days {
    type: number
    sql: ${TABLE}."AGE_IN_DAYS" ;;
  }

  dimension: age_in_weeks {
    type: number
    sql: ${TABLE}."AGE_IN_WEEKS" ;;
  }

  dimension: cities {
    type: string
    sql: ${TABLE}."CITIES" ;;
  }

  dimension: course_keys {
    type: string
    sql: ${TABLE}."COURSE_KEYS" ;;
  }

  dimension: cu_soft_value {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE" ;;
  }

  dimension: cu_soft_value_prank {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE_PRANK" ;;
  }

  dimension: culogins {
    type: number
    sql: ${TABLE}."CULOGINS" ;;
  }

  dimension: devices {
    type: string
    sql: ${TABLE}."DEVICES" ;;
  }

  dimension: first_event {
    type: string
    sql: ${TABLE}."FIRST_EVENT" ;;
  }

  dimension: first_session {
    type: yesno
    sql: ${TABLE}."FIRST_SESSION" ;;
  }

  dimension: ips {
    type: string
    sql: ${TABLE}."IPS" ;;
  }

  dimension: last_event {
    type: string
    sql: ${TABLE}."LAST_EVENT" ;;
  }

  dimension: locations {
    type: string
    sql: ${TABLE}."LOCATIONS" ;;
  }

  dimension: number_of_courseware_events {
    type: number
    sql: ${TABLE}."NUMBER_OF_COURSEWARE_EVENTS" ;;
  }

  dimension: number_of_dashboard_clicks {
    type: number
    sql: ${TABLE}."NUMBER_OF_DASHBOARD_CLICKS" ;;
  }

  dimension: number_of_ebook_events {
    type: number
    sql: ${TABLE}."NUMBER_OF_EBOOK_EVENTS" ;;
  }

  dimension: number_of_partner_clicks {
    type: number
    sql: ${TABLE}."NUMBER_OF_PARTNER_CLICKS" ;;
  }

  dimension: number_of_searches {
    type: number
    sql: ${TABLE}."NUMBER_OF_SEARCHES" ;;
  }

  dimension: other_events {
    type: number
    sql: ${TABLE}."OTHER_EVENTS" ;;
  }

  dimension: otherlogins {
    type: number
    sql: ${TABLE}."OTHERLOGINS" ;;
  }

  dimension: products {
    type: string
    sql: ${TABLE}."PRODUCTS" ;;
  }

  dimension: regions {
    type: string
    sql: ${TABLE}."REGIONS" ;;
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
  }

  dimension: session_gap_hours {
    type: number
    sql: ${TABLE}."SESSION_GAP_HOURS" ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
    primary_key: yes
  }

  dimension: session_length_mins {
    type: number
    sql: ${TABLE}."SESSION_LENGTH_MINS" ;;
  }

  dimension: session_length_tier {
    type: tier
    tiers: [ 30, 60, 120, 180, 240]
    style: integer
    sql: ${TABLE}."SESSION_LENGTH_MINS" ;;
  }


  dimension: session_no {
    type: number
    sql: ${TABLE}."SESSION_NO" ;;
  }

  dimension: session_no_tier {
    type: tier
    tiers: [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 20]
    style: integer
    sql: ${TABLE}."SESSION_NO" ;;
  }




  dimension_group: session_start {
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
    sql: ${TABLE}."SESSION_START" ;;
  }

  dimension: unique_event_types {
    type: number
    sql: ${TABLE}."UNIQUE_EVENT_TYPES" ;;
  }

  dimension: unique_events {
    type: string
    sql: ${TABLE}."UNIQUE_EVENTS" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }



  measure:  sum_courseware_events{
    type: sum
    sql:  ${number_of_courseware_events};;
  }

  measure:  sum_dashboard_clicks {
    type: sum
    sql:  ${number_of_dashboard_clicks};;
  }

  measure:  sum_ebook_events{
    type: sum
    sql:  ${number_of_ebook_events};;
  }

  measure:  sum_partner_clicks{
    type: sum
    sql:  ${number_of_partner_clicks};;
  }

  measure:  sum_searches{
    type: sum
    sql:  ${number_of_searches};;
  }

  measure:  sum_cu_soft_value {
    type: sum
    sql:  ${cu_soft_value} ;;
  }



  measure:  average_courseware_events{
    type: average
    sql:  ${number_of_courseware_events};;
  }

  measure:  average_dashboard_clicks {
    type: average
    sql:  ${number_of_dashboard_clicks};;
  }

  measure:  average_ebook_events{
    type: average
    sql:  ${number_of_ebook_events};;
  }

  measure:  average_partner_clicks{
    type: average
    sql:  ${number_of_partner_clicks};;
  }

  measure:  average_searches{
    type: average
    sql:  ${number_of_searches};;
  }

  measure:  average_session_duration{
    type: average
    sql:  ${session_length_mins};;
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
