view: as_user_journey {
  derived_table: {
    sql: With az_journey as (
      SELECT
          ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY event_time) AS event_number
          ,*
      FROM dev.zpg.all_events
      )
      , lead_fuc as (
      Select *
      ,LEAD (event_type, 1) over (partition by user_sso_guid order by event_time) as lead_event1
      ,LEAD (event_type, 2) over (partition by user_sso_guid order by event_time) as lead_event2
      ,LEAD (event_type, 3) over (partition by user_sso_guid order by event_time) as lead_event3
      ,LEAD (event_type, 4) over (partition by user_sso_guid order by event_time) as lead_event4
      ,LEAD (event_type, 5) over (partition by user_sso_guid order by event_time) as lead_event5
      from az_journey  where
      event_type NOT IN ('TIME-IN-MINDTAP','LOGIN','PAGE','ENGAGEMENT TIMER','FORMS','MARKETING','SAM%','PAGE EVENT','PAGE ERRORS','QUESTIA','EVENT','MINDAPP%','SCROLL%','STUDYHUB%','KALTURA','PDP%'
      ,'PROGRESS','READSPEAKER','GLOSSARY','NAVIGATION%','RSS%','DICTIONARY','DIET%')
      --user_sso_guid = '95096707cdeb01a5:-6f9b3e57:15e7a7678ef:-587d'
      )
      Select * from lead_fuc where event_number = 1 and event_type = 'CUSUBSCRIPTION';;
      persist_for: "12 hours"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: event_number {
    type: number
    sql: ${TABLE}."EVENT_NUMBER" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: load_metadata {
    type: string
    sql: ${TABLE}."LOAD_METADATA" ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
  }

  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: lead_event1 {
    type: string
    sql: ${TABLE}."LEAD_EVENT1" ;;
  }

  dimension: lead_event2 {
    type: string
    sql: ${TABLE}."LEAD_EVENT2" ;;
  }

  dimension: lead_event3 {
    type: string
    sql: ${TABLE}."LEAD_EVENT3" ;;
  }

  dimension: lead_event4 {
    type: string
    sql: ${TABLE}."LEAD_EVENT4" ;;
  }

  dimension: lead_event5 {
    type: string
    sql: ${TABLE}."LEAD_EVENT5" ;;
  }

  set: detail {
    fields: [
      event_number,
      platform_environment,
      product_platform,
      user_environment,
      user_sso_guid,
      load_metadata,
      event_action,
      event_time_time,
      event_type,
      local_time_time,
      event_data,
      session_id,
      lead_event1,
      lead_event2,
      lead_event3,
      lead_event4,
      lead_event5
    ]
  }
}
