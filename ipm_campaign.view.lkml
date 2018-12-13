view: ipm_campaign {
  sql_table_name: PROD.IPM_CAMPAIGN ;;

  dimension_group: _ldts {
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
    sql: ${TABLE}."_LDTS" ;;
    hidden: yes
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden: yes
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

  dimension: message_body {
    type: string
    sql: ${TABLE}."MESSAGE_BODY" ;;
  }

  dimension: message_format_version {
    type: string
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_id {
    type: string
    sql: ${TABLE}."MESSAGE_ID" ;;
  }

  dimension: message_title {
    type: string
    sql: ${TABLE}."MESSAGE_TITLE" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
