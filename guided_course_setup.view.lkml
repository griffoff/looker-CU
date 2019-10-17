# explore: guided_course_setup {}

view: guided_course_setup {
  derived_table: {
    sql:
    /*
    WITH
      cdp AS
        (
        SELECT
            parse_json(REPLACE(HIT_CUSTOM_DIMENSIONS[0]['value'],'\\', '')::string) AS cdp
            ,cdp:"courseKey"::string AS course_key
            ,cdp:"eventAction"::string AS eventAction
            ,cdp:"eventCategory"::string AS eventCategory
            ,cdp:"eISBN"::string AS eISBN
            ,cdp:"localTime"::string AS "localTime"
            ,cdp:"snapshotId"::string AS snapshotId
            ,cdp:"userSSOGUID"::string AS userSSOGUID
            ,cdp:"userRole"::string AS userRole
            ,cdp:"environment"::string AS "environment"
            ,cdp:"productPlatform"::string AS productPlatform
            ,cdp:"lmsInstructionType"::string AS lmsInstructionType
            ,cdp:"pageName"::string AS pageName
            ,cdp:"activityDates"::string AS activityDates
            ,cdp:"activitySettings"::string AS activitySettings
            ,cdp:"basics"::string AS "basics"
            ,cdp:"lms"::string AS lms
            ,LENGTH(hit_custom_dimensions[0]) AS len
            ,*
        FROM ANALYTICS360.PROD.GUIDEDCOURSE
        )
        */
        WITH
          cdp AS
          (SELECT * FROM dev.zkc.cdp)
      SELECT
        *
        ,eventcategory || ' ' ||  eventaction AS event_name
        ,LEAD(event_name, 1) OVER (PARTITION BY userssoguid ORDER BY localtime) AS event_1
        ,LEAD(event_name, 2) OVER (PARTITION BY userssoguid ORDER BY localtime) AS event_2
        ,LEAD(event_name, 3) OVER (PARTITION BY userssoguid ORDER BY localtime) AS event_3
        ,LEAD(event_name, 4) OVER (PARTITION BY userssoguid ORDER BY localtime) AS event_4
        ,LEAD(event_name, 5) OVER (PARTITION BY userssoguid ORDER BY localtime) AS event_5
      FROM cdp
    ;;

    sql_trigger_value: SELECT CURRENT_DATE() ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: user_count {
    type: count_distinct
    sql: ${userssoguid};;
    drill_fields: [detail*]
  }


  dimension: cdp {
    type: string
    sql: ${TABLE}."CDP" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: eventaction {
    type: string
    sql: ${TABLE}."EVENTACTION" ;;
  }

  dimension: eventcategory {
    type: string
    sql: ${TABLE}."EVENTCATEGORY" ;;
  }


  dimension: event_name {
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
    label: "Event Name"
    description: "Event Name and event category wtih space in between"
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."EVENT_1" ;;
    group_label: "Five succeding events"
  }

  dimension: event_2 {
    type: string
    sql: ${TABLE}."EVENT_2" ;;
    group_label: "Five succeding events"
  }
  dimension: event_3 {
    type: string
    sql: ${TABLE}."EVENT_3" ;;
    group_label: "Five succeding events"
  }  dimension: event_4 {
    type: string
    sql: ${TABLE}."EVENT_4" ;;
    group_label: "Five succeding events"
  }
  dimension: event_5 {
    type: string
    sql: ${TABLE}."EVENT_5" ;;
    group_label: "Five succeding events"
  }

  dimension: eisbn {
    type: string
    sql: ${TABLE}."EISBN" ;;
  }

  dimension: local_time {
    type: string
    sql: ${TABLE}."localTime" ;;
  }

  dimension: snapshotid {
    type: string
    sql: ${TABLE}."SNAPSHOTID" ;;
  }

  dimension: userssoguid {
    type: string
    sql: ${TABLE}."USERSSOGUID" ;;
  }

  dimension: userrole {
    type: string
    sql: ${TABLE}."USERROLE" ;;
  }

  dimension: environment {
    type: string
    sql: ${TABLE}."environment" ;;
  }

  dimension: productplatform {
    type: string
    sql: ${TABLE}."PRODUCTPLATFORM" ;;
  }

  dimension: lmsinstructiontype {
    type: string
    sql: ${TABLE}."LMSINSTRUCTIONTYPE" ;;
  }

  dimension: pagename {
    type: string
    sql: ${TABLE}."PAGENAME" ;;
  }

  dimension: activitydates {
    type: string
    sql: ${TABLE}."ACTIVITYDATES" ;;
  }

  dimension: activitysettings {
    type: string
    sql: ${TABLE}."ACTIVITYSETTINGS" ;;
  }

  dimension: basics {
    type: string
    sql: ${TABLE}."basics" ;;
  }

  dimension: lms {
    type: string
    sql: ${TABLE}."LMS" ;;
  }

  dimension: len {
    type: number
    sql: ${TABLE}."LEN" ;;
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: _id {
    type: string
    sql: ${TABLE}."_ID" ;;
  }

  dimension: client_id {
    type: string
    sql: ${TABLE}."CLIENT_ID" ;;
  }

  dimension: full_visitor_id {
    type: string
    sql: ${TABLE}."FULL_VISITOR_ID" ;;
  }

  dimension: visitor_id {
    type: string
    sql: ${TABLE}."VISITOR_ID" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: visit_number {
    type: number
    sql: ${TABLE}."VISIT_NUMBER" ;;
  }

  dimension: visit_id {
    type: number
    sql: ${TABLE}."VISIT_ID" ;;
  }

  dimension: visit_start_time {
    type: number
    sql: ${TABLE}."VISIT_START_TIME" ;;
  }

  dimension: session_date {
    type: string
    sql: ${TABLE}."SESSION_DATE" ;;
  }

  dimension: totals {
    type: string
    sql: ${TABLE}."TOTALS" ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}."TRAFFIC_SOURCE" ;;
  }

  dimension: social_engagement_type {
    type: string
    sql: ${TABLE}."SOCIAL_ENGAGEMENT_TYPE" ;;
  }

  dimension: channel_grouping {
    type: string
    sql: ${TABLE}."CHANNEL_GROUPING" ;;
  }

  dimension: device {
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  dimension: geo_network {
    type: string
    sql: ${TABLE}."GEO_NETWORK" ;;
  }

#   dimension: geo_network {
#     type: string
#     sql: ${TABLE}."GEO_NETWORK":"longitude" || ',' || ${TABLE}."GEO_NETWORK":"latitude";;
#   }

  dimension: lat_lon {
    type: location
    sql_latitude: ${TABLE}."GEO_NETWORK":latitude ;;
    sql_longitude: ${TABLE}."GEO_NETWORK":longitude ;;
    label: "Longitute and latitude coordinates"
    description: "The longitude and latitude coordinates from the first event in the session based on an IP lookup via extreme-ip-lookup.com which can be used for geo mapping"
    drill_fields: [user_id]
  }

  dimension: lat {
    type: string
    sql: ${TABLE}."GEO_NETWORK":latitude::string ;;
    label: "Latitude coordinates"
  }

  dimension: lon {
    type: string
    sql: ${TABLE}."GEO_NETWORK":longitude::string ;;
    label: "Longitude coordinates"
  }

  dimension: network_location {
    type: string
    sql: ${TABLE}."GEO_NETWORK":networkLocation::string ;;
    label: "Network Location"
  }

  dimension: region {
    type: string
    sql: ${TABLE}."GEO_NETWORK":region::string ;;
    label: "Region"
  }

  dimension: metro {
    type: string
    sql: ${TABLE}."GEO_NETWORK":metro::string ;;
    label: "Metro"
  }

  dimension: hit_data_source {
    type: string
    sql: ${TABLE}."HIT_DATA_SOURCE" ;;
  }

  dimension: hit_source_property_info {
    type: string
    sql: ${TABLE}."HIT_SOURCE_PROPERTY_INFO" ;;
  }

  dimension: hit_ecommerce_action {
    type: string
    sql: ${TABLE}."HIT_ECOMMERCE_ACTION" ;;
  }

  dimension: hit_experiment {
    type: string
    sql: ${TABLE}."HIT_EXPERIMENT" ;;
  }

  dimension: hit_number {
    type: number
    sql: ${TABLE}."HIT_NUMBER" ;;
  }

  dimension: hit_hour {
    type: number
    sql: ${TABLE}."HIT_HOUR" ;;
  }

  dimension: hit_is_entrance {
    type: string
    sql: ${TABLE}."HIT_IS_ENTRANCE" ;;
  }

  dimension: hit_is_exit {
    type: string
    sql: ${TABLE}."HIT_IS_EXIT" ;;
  }

  dimension: hit_is_interaction {
    type: string
    sql: ${TABLE}."HIT_IS_INTERACTION" ;;
  }

  dimension: hit_latency_tracking {
    type: string
    sql: ${TABLE}."HIT_LATENCY_TRACKING" ;;
  }

  dimension: hit_minute {
    type: number
    sql: ${TABLE}."HIT_MINUTE" ;;
  }

  dimension: hit_product {
    type: string
    sql: ${TABLE}."HIT_PRODUCT" ;;
  }

  dimension: hit_publisher {
    type: string
    sql: ${TABLE}."HIT_PUBLISHER" ;;
  }

  dimension: hit_time {
    type: number
    sql: ${TABLE}."HIT_TIME" ;;
  }

  dimension: hit_transaction {
    type: string
    sql: ${TABLE}."HIT_TRANSACTION" ;;
  }

  dimension: hit_referer {
    type: string
    sql: ${TABLE}."HIT_REFERER" ;;
  }

  dimension: hit_refund {
    type: string
    sql: ${TABLE}."HIT_REFUND" ;;
  }

  dimension: hit_social {
    type: string
    sql: ${TABLE}."HIT_SOCIAL" ;;
  }

  dimension: hit_type {
    type: string
    sql: ${TABLE}."HIT_TYPE" ;;
  }

  dimension: hit_page {
    type: string
    sql: ${TABLE}."HIT_PAGE" ;;
  }

  dimension: hit_promotion {
    type: string
    sql: ${TABLE}."HIT_PROMOTION" ;;
  }

  dimension: hit_item {
    type: string
    sql: ${TABLE}."HIT_ITEM" ;;
  }

  dimension: hit_content_group {
    type: string
    sql: ${TABLE}."HIT_CONTENT_GROUP" ;;
  }

  dimension: hit_content_info {
    type: string
    sql: ${TABLE}."HIT_CONTENT_INFO" ;;
  }

  dimension: hit_app_info {
    type: string
    sql: ${TABLE}."HIT_APP_INFO" ;;
  }

  dimension: hit_exception_info {
    type: string
    sql: ${TABLE}."HIT_EXCEPTION_INFO" ;;
  }

  dimension: hit_event_info {
    type: string
    sql: ${TABLE}."HIT_EVENT_INFO" ;;
  }

  dimension: hit_custom_variables {
    type: string
    sql: ${TABLE}."HIT_CUSTOM_VARIABLES" ;;
  }

  dimension: hit_custom_metrics {
    type: string
    sql: ${TABLE}."HIT_CUSTOM_METRICS" ;;
  }

  dimension: hit_custom_dimensions {
    type: string
    sql: ${TABLE}."HIT_CUSTOM_DIMENSIONS" ;;
  }

  dimension: custom_dimensions {
    type: string
    sql: ${TABLE}."CUSTOM_DIMENSIONS" ;;
  }

  set: detail {
    fields: [
      cdp,
      course_key,
      eventaction,
      eventcategory,
      eisbn,
      local_time,
      snapshotid,
      userssoguid,
      userrole,
      environment,
      productplatform,
      lmsinstructiontype,
      pagename,
      activitydates,
      activitysettings,
      basics,
      lms,
      len,
      _ldts_time,
      _rsrc,
      _id,
      client_id,
      full_visitor_id,
      visitor_id,
      user_id,
      visit_number,
      visit_id,
      visit_start_time,
      session_date,
      totals,
      traffic_source,
      social_engagement_type,
      channel_grouping,
      device,
      geo_network,
      hit_data_source,
      hit_source_property_info,
      hit_ecommerce_action,
      hit_experiment,
      hit_number,
      hit_hour,
      hit_is_entrance,
      hit_is_exit,
      hit_is_interaction,
      hit_latency_tracking,
      hit_minute,
      hit_product,
      hit_publisher,
      hit_time,
      hit_transaction,
      hit_referer,
      hit_refund,
      hit_social,
      hit_type,
      hit_page,
      hit_promotion,
      hit_item,
      hit_content_group,
      hit_content_info,
      hit_app_info,
      hit_exception_info,
      hit_event_info,
      hit_custom_variables,
      hit_custom_metrics,
      hit_custom_dimensions,
      custom_dimensions
    ]
  }
}
