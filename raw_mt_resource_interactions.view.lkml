view: raw_mt_resource_interactions {
  sql_table_name: PROD.RAW_MT_RESOURCE_INTERACTIONS ;;

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
  }

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
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: activity_uri {
    type: string
    sql: ${TABLE}."ACTIVITY_URI" ;;
  }

  dimension: component_isbn {
    type: string
    sql: ${TABLE}."COMPONENT_ISBN" ;;
  }

  dimension: core_text_isbn {
    type: string
    sql: ${TABLE}."CORE_TEXT_ISBN" ;;
  }

  dimension: course_uri {
    type: string
    sql: ${TABLE}."COURSE_URI" ;;
  }

  dimension: environment {
    type: string
    sql: ${TABLE}."ENVIRONMENT" ;;
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}."EVENT_CATEGORY" ;;
  }

  dimension: event_source {
    type: string
    sql: ${TABLE}."EVENT_SOURCE" ;;
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

  dimension: event_value {
    type: number
    sql: ${TABLE}."EVENT_VALUE" ;;
  }

  dimension: mt_session_id {
    type: string
    sql: ${TABLE}."MT_SESSION_ID" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: reading_cendoc_id {
    type: string
    sql: ${TABLE}."READING_CENDOC_ID" ;;
  }

  dimension: reading_page_count {
    type: number
    sql: ${TABLE}."READING_PAGE_COUNT" ;;
  }

  dimension: reading_page_view {
    type: number
    sql: ${TABLE}."READING_PAGE_VIEW" ;;
  }

  dimension: timezone_offset {
    type: string
    sql: ${TABLE}."TIMEZONE_OFFSET" ;;
  }

  dimension: user_identifier {
    type: string
    sql: ${TABLE}."USER_IDENTIFIER" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
