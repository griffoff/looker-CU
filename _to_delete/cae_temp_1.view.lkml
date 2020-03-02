explore: cae_temp_1 {}
view: cae_temp_1 {
  derived_table: {
    sql: WITH
          cae AS
          (
            SELECT
                COALESCE(user_environment, product_environment) AS platform_environment
                ,_ldts
                ,_rsrc
                ,message_format_version
                ,message_type
                ,event_time
                ,event_category
                ,event_action
                ,product_platform
                ,session_id
                ,user_sso_guid
                ,event_uri
                ,host_platform
                ,MAX(CASE WHEN s.value:key::string = 'courseKey' THEN s.value:value::string END) AS courseKey
                ,MAX(CASE WHEN s.value:key::string = 'carouselName' THEN s.value:value::string END) AS carouselName
                ,MAX(CASE WHEN s.value:key::string = 'carouselSessionId' THEN s.value:value::string END) AS carouselSessionId
                ,MAX(CASE WHEN s.value:key::string = 'activityId' THEN s.value:value::string END) AS activityId
                ,MAX(CASE WHEN s.value:key::string = 'checkpointId' THEN s.value:value::string END) AS checkpointId
                ,MAX(CASE WHEN s.value:key::string = 'contentType' THEN s.value:value::string END) AS contentType
                ,MAX(CASE WHEN s.value:key::string = 'appName' THEN s.value:value::string END) AS appName
                ,MAX(CASE WHEN s.value:key::string = 'externalTakeUri' THEN s.value:value::string END) AS externalTakeUri
                ,MAX(CASE WHEN s.value:key::string = 'itemUri' THEN s.value:value::string END) AS itemUri
                ,MAX(CASE WHEN s.value:key::string = 'showGradeIndicators' THEN s.value:value::string END) AS showGradeIndicators
                ,MAX(CASE WHEN s.value:key::string = 'courseUri' THEN s.value:value::string END) AS courseUri
                ,MAX(CASE WHEN s.value:key::string = 'attemptId' THEN s.value:value::string END) AS attemptId
                ,MAX(CASE WHEN s.value:key::string = 'activityUri' THEN s.value:value::string END) AS activityUri
                ,MAX(CASE WHEN s.value:key::string = 'claPageNumber' THEN s.value:value::string END) AS claPageNumber
                ,MAX(CASE WHEN s.value:key::string = 'numberOfPages' THEN s.value:value::string END) AS numberOfPages
                ,MAX(CASE WHEN s.value:key::string = 'studyToolCgi' THEN s.value:value::string END) AS studyToolCgi
                ,MAX(CASE WHEN s.value:key::string = 'sequenceUuid' THEN s.value:value::string END) AS sequenceUuid
                ,MAX(CASE WHEN s.value:key::string = 'pointInSemester' THEN s.value:value::string END) AS pointInSemester
                ,MAX(CASE WHEN s.value:key::string = 'discipline' THEN s.value:value::string END) AS discipline
                ,MAX(CASE WHEN s.value:key::string = 'ISBN' THEN s.value:value::string END) AS ISBN
            FROM cap_eventing.prod.client_activity_event wa
            CROSS JOIN LATERAL FLATTEN(WA.tags,outer=>true) s
            WHERE event_time >= '2018-08-01'  AND product_platform NOT IN ('performance-report-ui', 'performance-reports-widgets', 'industry-links-mindapp')
            GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
           )
      SELECT
          UPPER(platform_environment) AS platform_environment
          ,product_platform AS product_platform
          ,UPPER(platform_environment) AS user_environment
          ,user_sso_guid AS original_user_sso_guid
          ,user_sso_guid AS user_sso_guid
          ,object_construct('_hash', NULL, '_ldts', _LDTS, '_rsrc', _rsrc) load_metadata
          ,event_action
          ,CONVERT_TIMEZONE('UTC', event_time)::TIMESTAMP_TZ AS event_time
          ,event_category AS event_type
          ,event_time AS local_time
          ,OBJECT_CONSTRUCT('courseKey', courseKey, 'carouselName', carouselName, 'carouselSessionId', carouselSessionId, 'activityId', activityId
                      ,'checkpointId', checkpointId,'contentType', contentType, 'appName', appName, 'externalTakeUri', externalTakeUri
                       ,'showGradeIndicators', showGradeIndicators, 'product_platform', product_platform, 'host_platform', host_platform
                       ,'courseUri', courseUri, 'attemptId', attemptId, 'activityUri', activityUri, 'claPageNumber', claPageNumber, 'numberOfPages', numberOfPages
                       ,'itemUri', itemUri, 'studyToolCgi', studyToolCgi, 'sequenceUuid', sequenceUuid, 'pointInSemester', pointInSemester
                       ,'discipline', discipline, 'ISBN', ISBN, 'event_source', 'Client Activity Events') AS event_data
      FROM cae
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
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

  dimension: original_user_sso_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_USER_SSO_GUID" ;;
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
    label: "Event Category"
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}."EVENT_TYPE" || ' ' ||  ${event_action};;
    label: "Event name"
  }


  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
  }

  set: detail {
    fields: [
      platform_environment,
      product_platform,
      user_environment,
      original_user_sso_guid,
      user_sso_guid,
      load_metadata,
      event_action,
      event_time_time,
      event_type,
      local_time_time,
      event_data
    ]
  }
}
