view: as_user_journey {
  derived_table: {
    sql: With az_journey as (
      SELECT
          ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY event_time) AS event_number
          ,*
      FROM dev.zpg.all_events
      )
      ,eve as (
      Select *, case when event_type LIKE 'DASHBOARD' THEN event_action ELSE event_type END as event_type_updated from az_journey
      )
      , lead_fuc as (
      Select *
      ,LEAD (event_type_updated, 1) over (partition by user_sso_guid order by event_time) as lead_event1
      ,LEAD (event_type_updated, 2) over (partition by user_sso_guid order by event_time) as lead_event2
      ,LEAD (event_type_updated, 3) over (partition by user_sso_guid order by event_time) as lead_event3
      ,LEAD (event_type_updated, 4) over (partition by user_sso_guid order by event_time) as lead_event4
      ,LEAD (event_type_updated, 5) over (partition by user_sso_guid order by event_time) as lead_event5
      from eve  where
      event_type_updated NOT IN ('TIME-IN-MINDTAP','LOGIN','PAGE','ENGAGEMENT TIMER','FORMS','MARKETING','SAM.APPIFICATION.PROD','PAGE EVENT','PAGE ERRORS','QUESTIA','EVENT','MINDAPP-EPORTFOLIO','SCROLL TRACKING - CENGAGE UNLIMITED','STUDYHUB.MINDAPP','KALTURA','ECOMMERCE'
      ,'PDP ELEMENTS CLICKED','GOOGLE.DOC','ATP','ONENOTE','YOUSEEU','NETTUTORS','BOOKMARKS','EVERNOTE'
      ,'PROGRESS','READSPEAKER','GLOSSARY','NAVIGATION MENUS','RSSFEED','DICTIONARY','DIET.WELLNESS.PLUS','CONNECTYARD.LEARNER','OUTBOUND LINKS','MINDAPP-OFFICE-365','DLMT.IQ.STUDENTTESTCREATOR')
      --user_sso_guid = '95096707cdeb01a5:-6f9b3e57:15e7a7678ef:-587d'
      )

      Select * from lead_fuc where event_number = 1 and event_type = 'CUSUBSCRIPTION'
       ;;
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
