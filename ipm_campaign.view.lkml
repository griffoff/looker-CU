view: ipm_campaign {
  #sql_table_name: IPM.PROD.IPM_CAMPAIGN ;;
  derived_table: {
    sql:
    SELECT
        HASH(c.message_id, c.campaign_start_date) as pk
        ,c.*
        ,ROW_NUMBER() OVER (PARTITION BY c.message_id ORDER BY c.campaign_start_date) AS message_version_no
        ,LEAD(c.campaign_start_date) OVER (PARTITION BY c.message_id ORDER BY c.campaign_start_date) AS next_campaign_start_date
        ,outcome.event_outcome
    FROM IPM.PROD.IPM_CAMPAIGN c
    LEFT JOIN (
        SELECT DISTINCT campaign_title, event_outcome
        FROM uploads.ipm.campaign_to_outcome
        WHERE NOT _FIVETRAN_DELETED
        ) outcome ON c.campaign_title ilike outcome.campaign_title
    WHERE platform_environment = 'production'
    AND campaign_start_date > '2018-09-21'
    ;;
  }

  dimension:pk {
    hidden: yes
    primary_key: yes
  }

  dimension: message_id {
    type: string
    sql: ${TABLE}."MESSAGE_ID" ;;
  }

  dimension: message_version_no {
    hidden: yes
  }

  dimension: campaign_author {
    type: string
    sql: ${TABLE}."CAMPAIGN_AUTHOR" ;;
  }

  dimension: event_outcome {
    label: "Campaign target"
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

  dimension: next_campaign_start_time {
    hidden: yes
    type: date_time
    sql:  ${TABLE}.next_campaign_start_date ;;
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

  measure: count {
    type:  count
    label: "# Campaigns"
  }


}
