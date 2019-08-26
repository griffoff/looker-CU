explore: cafe_getenrolled {}
view: cafe_getenrolled {

derived_table: {
  #sql: Select * from ${client_activity_event_prod.SQL_TABLE_NAME} where product_platform ilike 'get-enrolled' ;;
  sql:
      SELECT
          event_id AS event_id_cafe
          ,COALESCE(user_environment, product_environment) AS platform_environment
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
      FROM ${client_activity_event_prod.SQL_TABLE_NAME} cafe
      CROSS JOIN LATERAL FLATTEN(cafe.tags,outer=>true) s
      WHERE product_platform = 'get-enrolled'
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
;;
}

  dimension: courseKey {}
  dimension: carouselName {}
  dimension: carouselSessionId {}
  dimension: activityId {}
  dimension: checkpointId {}
  dimension: contentType {}
  dimension: appName {}
  dimension: externalTakeUri {}
  dimension: itemUri {}
  dimension: showGradeIndicators {}
  dimension: courseUri {}
  dimension: attemptId {}
  dimension: activityUri {}
  dimension: claPageNumber {}
  dimension: numberOfPages {}
  dimension: studyToolCgi {}
  dimension: sequenceUuid {}
  dimension: pointInSemester {}
  dimension: discipline {}
  dimension: ISBN {}


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
    hidden: yes
  }
  dimension: merged_guid {}

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden: yes
  }

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: event_duration {
    type: number
    sql: ${TABLE}."EVENT_DURATION" ;;
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: product_environment {
    type: string
    sql: ${TABLE}."PRODUCT_ENVIRONMENT" ;;
  }

  dimension: user_platform {
    type: string
    sql: ${TABLE}."USER_PLATFORM" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: host_platform {
    type: string
    sql: ${TABLE}."HOST_PLATFORM" ;;
  }

  dimension: host_environment {
    type: string
    sql: ${TABLE}."HOST_ENVIRONMENT" ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: event_id {
    type: string
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: event_uri {
    type: string
    sql: ${TABLE}."EVENT_URI" ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }

  set: detail {
    fields: [
      _ldts_time,
      _rsrc,
      message_format_version,
      message_type,
      event_time_time,
      event_duration,
      event_category,
      event_action,
      product_platform,
      product_environment,
      user_platform,
      user_environment,
      host_platform,
      host_environment,
      session_id,
      event_id,
      user_sso_guid,
      event_uri,
      tags
    ]
  }

}
