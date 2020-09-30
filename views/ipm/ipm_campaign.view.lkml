view: ipm_campaign {
  #sql_table_name: IPM.PROD.IPM_CAMPAIGN ;;
  derived_table: {
    sql:
    SELECT
        HASH(c.message_id, c.campaign_start_date) as pk
        ,c.*
        ,ROW_NUMBER() OVER (PARTITION BY c.message_id ORDER BY c.campaign_start_date) AS message_version_no
        ,COALESCE(LEAD(c.campaign_start_date) OVER (PARTITION BY c.message_id ORDER BY c.campaign_start_date), CURRENT_TIMESTAMP()) AS next_campaign_start_date
        ,outcome.event_outcome
        ,COALESCE(outcome.campaign_outcome, ARRAY_TO_STRING(outcome.event_outcome, ' OR ')) AS campaign_outcome
        ,COALESCE(outcome.real_campaign_title, c.campaign_title) AS real_campaign_title
        ,outcome.jira_link
        ,outcome.campaign_title IS NOT NULL AS has_outcome_mapping
    FROM IPM.PROD.IPM_CAMPAIGN c
    LEFT JOIN (
        SELECT
            campaign_title
            ,MIN(NULLIF(real_campaign_title, '')) AS real_campaign_title
            ,MIN(NULLIF(campaign_outcome, '')) AS campaign_outcome
            ,MIN(NULLIF(CASE WHEN jira_link like 'http%' THEN jira_link END, '')) AS jira_link
            ,ARRAY_AGG(DISTINCT UPPER(event_outcome)) AS event_outcome
        FROM uploads.ipm.campaign_to_outcome
        WHERE NOT _FIVETRAN_DELETED
        GROUP BY 1
        ) outcome ON c.campaign_title ilike outcome.campaign_title
    WHERE platform_environment = 'production'
    AND campaign_start_date > '2018-09-21'
    ;;

    datagroup_trigger: daily_refresh
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

  dimension: real_campaign_title {
    label: "Campaign Name"
    description: "Friendly (not internal) name of campaign"
    link: {label: "Link to the setup sheet" url: "{{ outcome_setup_link._value }}"}
    link: {label: "Link to JIRA: {{ jira_no._value }}" url: "{{ jira_link._value }}"}
  }

  dimension: jira_no {
    hidden: yes
    sql: SPLIT_PART(${jira_link}, '/', -1) ;;
  }
  dimension: jira_link {
    hidden: yes
  }

  dimension: outcome_setup_link {
    hidden: yes
    sql: 'https://docs.google.com/spreadsheets/d/1_XHPL3z2h7YEEQ3onZLvpcJ7Swi1pYWF95HAoaCxu58/edit#gid=0' ;;
  }

  dimension: has_outcome_mapping {
    type: yesno
    description: "Has a matching outcome row on the setup sheet"
    link: {label: "Link to the setup sheet" url: "{{ outcome_setup_link._value }}"}
  }

  dimension: event_outcome {
    label: "Campaign Expected Outcome"
    description: "What is this campaign trying to get people to do?"
    sql: ${TABLE}.campaign_outcome ;;
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
    type: date_raw
    sql:  ${TABLE}.next_campaign_start_date ;;
  }

  dimension: campaign_title {
    label: "Message Name"
    type: string
    description: "Title of campaign in IPM feed"
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
