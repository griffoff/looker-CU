view: ipm_campaign {
  sql_table_name: PROD.IPM_CAMPAIGN ;;


  dimension: message_id {
    type: string
    sql: ${TABLE}."MESSAGE_ID" ;;
  }

  dimension: campaign_author {
    type: string
    sql: ${TABLE}."CAMPAIGN_AUTHOR" ;;
  }

  dimension_group: campaign_end {
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
    sql: ${TABLE}."CAMPAIGN_END_DATE" ;;
  }

  dimension: campaign_metadata {
    type: string
    sql: ${TABLE}."CAMPAIGN_METADATA" ;;
  }

  dimension: campaign_requestor {
    type: string
    sql: ${TABLE}."CAMPAIGN_REQUESTOR" ;;
  }

  dimension_group: campaign_start {
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
    sql: ${TABLE}."CAMPAIGN_START_DATE" ;;
  }

  dimension: campaign_title {
    type: string
    sql: ${TABLE}."CAMPAIGN_TITLE" ;;
  }

  dimension: campaign_type {
    type: string
    sql: ${TABLE}."CAMPAIGN_TYPE" ;;
  }

  dimension_group: event {
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
    sql: ${TABLE}."EVENT_TIME" ;;
  }


}
