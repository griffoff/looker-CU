explore: all_events_quarantine {}

explore: event_counts_per_source_per_day {}

view: event_counts_per_source_per_day {
  derived_table: {
    sql:
    with events as (
    select event_time::DATE as event_date
          ,load_metadata:source::STRING as load_source
          ,event_type
          ,event_action
          ,count(*) as event_count
    from ${all_events.SQL_TABLE_NAME}
    where to_timestamp(session_id)::DATE >= CURRENT_DATE() - 120
    group by 1, 2, 3, 4
    )
    ,quarantine as (
    select event_time::DATE as event_date
          ,load_metadata:source::STRING as load_source
          ,event_type
          ,event_action
          ,count(*) as event_count
    from ${all_events_quarantine.SQL_TABLE_NAME}
    where event_time::DATE >= CURRENT_DATE() - 120
    group by 1, 2, 3, 4
    )
    select e.*, e.event_count + coalesce(q.event_count, 0) as total_event_count, q.event_count as quarantined_event_count
    from events e
    left join quarantine q on (e.event_date, e.load_source, e.event_type, e.event_action)
                            = (q.event_date, q.load_source, q.event_type, q.event_action)  ;;

    persist_for: "24 hours"
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
    sql: ${TABLE}.event_date;;
  }
  dimension: load_source {}
  dimension: event_type {}
  dimension: event_action {}
  measure: event_count {type:sum}
  measure: total_event_count {type:sum}
  measure: quarantined_event_count {type:sum}
  measure: percent_quarantined {type:number sql: ${quarantined_event_count} / ${total_event_count};; value_format_name:percent_1}
  measure: percent_kept {type:number sql: ${event_count} / ${total_event_count};; value_format_name:percent_1}
}

view: all_events_quarantine {
  sql_table_name: prod.CU_USER_ANALYSIS.ALL_EVENTS_QUARANTINE
    ;;

  dimension: event_action {
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
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
    sql: CAST(${TABLE}."EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
  }

  dimension: load_metadata {
    group_label: "Load metadata"
    type: string
    sql: ${TABLE}."LOAD_METADATA" ;;
  }

  dimension: load_metadata_source {
    label: "Source"
    group_label: "Load metadata"
    sql: ${load_metadata}:source ;;
  }

  dimension: load_time {
    type: string
    sql: ${TABLE}."LOAD_TIME" ;;
  }

  dimension_group: local {
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
    sql: CAST(${TABLE}."LOCAL_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension: original_user_sso_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_USER_SSO_GUID" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: reason {
    type: string
    sql: ${TABLE}."REASON" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
