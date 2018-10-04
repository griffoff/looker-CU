view: all_weeks_cu_value {
  sql_table_name: ZPG.ALL_WEEKS_CU_VALUE ;;

  dimension: age_in_weeks {
    type: number
    sql: ${TABLE}."AGE_IN_WEEKS" ;;
  }

  dimension: cu_soft_value {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE" ;;
  }

  dimension: cu_soft_value_prank {
    type: number
    sql: ${TABLE}."CU_SOFT_VALUE_PRANK" ;;
  }

  dimension_group: first_session {
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
    sql: ${TABLE}."FIRST_SESSION_DATE" ;;
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

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: guid_week {
    type: string
    sql: ${user_sso_guid} || ${age_in_weeks} ;;
    primary_key: yes
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
