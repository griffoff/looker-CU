explore: simple_flow_analysis{
  always_filter: {filters: [simple_flow_analysis.date_range_filter: "after 7 days ago", simple_flow_analysis.flow_events_filter: ""]}
}

view: simple_flow_analysis {
  filter: date_range_filter {
    label: "Choose a starting date range"
    description: "Select a date range for the starting event(s)"
    type: date
    datatype: date
  }

  filter: flow_events_filter {
    label: "Events to include / exclude in the flow"
    description: "Select the things that you want to include or exclude in your flow"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  derived_table: {
    sql:
    WITH event_sequence AS (
      SELECT
        user_sso_guid
        ,event_id
        --,zandbox.delderfield.event_name_from_source(load_metadata:source, TRIM(event_data:host_platform), event_type, event_action, event_data) AS event_name
        ,event_name
        ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY event_time) AS sequence
        --,event_time
        --,LEAD(event_time) OVER (PARTITION BY user_sso_guid ORDER BY event_time) AS next_event_time
        --,DATEDIFF(second, event_time, next_event_time) / (3600 * 24) AS duration
      FROM ${all_events.SQL_TABLE_NAME}
      WHERE {% condition date_range_filter %} TO_TIMESTAMP(session_id::INT) {% endcondition%}
      AND {% condition flow_events_filter %} event_name {% endcondition %}
    )
    SELECT
      user_sso_guid
      ,MAX(CASE WHEN sequence = 1 THEN event_name END) as event_1
      ,MAX(CASE WHEN sequence = 2 THEN event_name END) as event_2
      ,MAX(CASE WHEN sequence = 3 THEN event_name END) as event_3
      ,MAX(CASE WHEN sequence = 4 THEN event_name END) as event_4
      ,MAX(CASE WHEN sequence = 5 THEN event_name END) as event_5
      ,MAX(CASE WHEN sequence = 6 THEN event_name END) as event_6
      ,MAX(CASE WHEN sequence = 7 THEN event_name END) as event_7
      ,MAX(CASE WHEN sequence = 8 THEN event_name END) as event_8
      ,MAX(CASE WHEN sequence = 9 THEN event_name END) as event_9
    FROM event_sequence
    WHERE sequence <= 9
    GROUP BY 1

      ;;
  }

  dimension: user_sso_guid {primary_key:yes hidden:yes}

  measure: count {type:count}

  dimension: event_1 {}
  dimension: event_2 {}
  dimension: event_3 {}
  dimension: event_4 {}
  dimension: event_5 {}
  dimension: event_6 {}
  dimension: event_7 {}
  dimension: event_8 {}
  dimension: event_9 {}



}
