#explore: all_sessions_cu_value {}

view: all_sessions_cu_value {
  sql_table_name: ZPG.ALL_SESSIONS_CU_VALUE ;;

  dimension: cu_soft_value {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE" ;;
  }

  dimension: cu_soft_value_prank {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE_PRANK" ;;
  }

  dimension: first_session_date {
    type: date
    sql: ${TABLE}."FIRST_SESSION_DATE" ;;
  }

  dimension: age_in_days {
    type: number
    sql: ${TABLE}."AGE_IN_DAYS" ;;
  }

  dimension: age_in_weeks {
    type: number
    sql: ${TABLE}."AGE_IN_WEEKS" ;;
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

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
    primary_key: yes
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


  dimension: cu_soft_value_tiers{
    type: string
    sql: CASE WHEN ${cu_soft_value_prank} < .34 THEN 'LOW'
              WHEN ${cu_soft_value_prank} < .67 THEN 'MEDIUM'
              ELSE 'HIGH' END ;;
  }


  measure: count {
    type: count
    drill_fields: []
  }
}
