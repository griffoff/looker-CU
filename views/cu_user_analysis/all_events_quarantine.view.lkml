explore: all_events_quarantine {hidden:yes}

explore: event_counts_per_day {
  hidden: yes
  join: event_quarantined_counts_per_day {
    sql_on: (${event_counts_per_day.event_raw}, ${event_counts_per_day.load_source}, ${event_counts_per_day.event_type}, ${event_counts_per_day.event_action})
                            = (${event_quarantined_counts_per_day.event_raw}, ${event_quarantined_counts_per_day.load_source}, ${event_quarantined_counts_per_day.event_type}, ${event_quarantined_counts_per_day.event_action}) ;;
    relationship: one_to_many
  }

}

view: event_counts_per_day {
  derived_table: {
    sql:
    with events as (
      select event_time::DATE as event_date
            ,load_metadata:source::STRING as load_source
            ,event_type
            ,event_action
            ,hash(event_date, load_source, event_type, event_action) as pk
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
            ,hash(event_date, load_source, event_type, event_action) as pk
            ,count(*) as event_count
      from ${all_events_quarantine.SQL_TABLE_NAME}
      where event_time::DATE >= CURRENT_DATE() - 120
      group by 1, 2, 3, 4
    )
    select e.*, e.event_count + coalesce(q.event_count, 0) as event_count_received
    from events e
    left join quarantine q on e.pk = q.pk
    ;;

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
  dimension: pk {primary_key: yes hidden:yes}
  dimension: load_source {}
  dimension: event_type {}
  dimension: event_action {}
  measure: event_count {type:sum label: "Events Persisted"}
  measure: event_count_received {type:sum label: "Events Received"}
  measure: percent_kept {type:number sql: ${event_count} / ${event_count_received};;
    value_format_name:percent_1}

}

view: event_quarantined_counts_per_day {
  extends: [event_counts_per_day]

  derived_table: {
    sql:
    select event_time::DATE as event_date
          ,load_metadata:source::STRING as load_source
          ,event_type
          ,event_action
          ,reason
          ,hash(event_date, load_source, event_type, event_action, reason) as pk
          ,count(*) as event_count
    from ${all_events_quarantine.SQL_TABLE_NAME}
    where event_time::DATE >= CURRENT_DATE() - 120
    group by 1, 2, 3, 4, 5
    ;;

    persist_for: "24 hours"
  }

  dimension: reason {}
  measure: event_count_received {hidden:yes}
  measure: event_count {label: "Events Quarantined"}
  measure: percent_quarantined {type:number sql: ${event_count} / ${event_counts_per_day.event_count_received};;
    required_fields: [event_counts_per_day.event_count_received] value_format_name:percent_1}

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
