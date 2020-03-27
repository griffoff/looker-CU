connection: "snowflake_prod"

include: "/views/cu_user_analysis/all_events.view"
include: "/views/cu_user_analysis/learner_profile.view"

explore: events {
  from: all_events
  hidden: yes
}

view: next_events {

  dimension: primary_key {sql:HASH(${session_id}, ${event_number});; primary_key: yes hidden: yes}

  dimension: session_id {type:number hidden:yes}
  dimension: event_number {type: number}
  dimension: event_name { type: string}
  measure: count {type: count}
}

view: cohort_selection {
  extends: [all_events]

  parameter: cohort_events_filter {
    label: "Choose cohort behavior"
    description: "Select the things that you want your cohort to have done "
    type: string
    default_value: ""
    suggest_explore: events
    suggest_dimension: events.event_name
    suggest_persist_for: "24 hours"
  }

  filter: cohort_date_range_filter {
    label: "Choose a cohort date range"
    description: "Select a date range for the taret cohort behavior"
    type: date
    datatype: date

  }

  parameter: time_period {
    label: "Include events (n) minutes after the initial behavior"
    description: "How long after the initial behavior (within the same session) do you want to look for subsequent actions"
    type: number
  }

  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER(PARTITION BY all_events.session_id ORDER BY event_time, event_id) AS event_sequence
            ,all_events.*
      FROM (
        SELECT user_sso_guid, session_id, min(event_time) as start_event_time, min(event_id) as first_event_id
          ,CASE WHEN {{ time_period._parameter_value }} IS NULL THEN NULL ELSE DATEADD(minute,  {{ time_period._parameter_value }}, start_event_time) END as end_event_time
        FROM ${all_events.SQL_TABLE_NAME}
        WHERE UPPER(event_name) IN ( {{ cohort_events_filter._parameter_value | replace: ", ", "," | replace: ",", "', '" | upcase }})
        AND (event_time >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
        AND (event_time < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
        GROUP BY 1, 2
      ) cohort_selection
      INNER JOIN ${all_events.SQL_TABLE_NAME} all_events ON cohort_selection.session_id = all_events.session_id
         and all_events.event_id > cohort_selection.first_event_id
         --and ${cohort_selection.start_event_time} <= ${all_events.event_date_raw}
         and (
            cohort_selection.end_event_time > all_events.event_time
           or cohort_selection.end_event_time IS NULL
          )
      ;;
  }

  dimension: event_sequence {type: number}
}


# view: cohort_selection_old {
#
#   parameter: cohort_events_filter {
#     label: "Choose cohort behavior"
#     description: "Select the things that you want your cohort to have done "
#     type: string
#     default_value: ""
#     suggest_explore: events
#     suggest_dimension: events.event_name
#     suggest_persist_for: "24 hours"
#   }
#
#   filter: cohort_date_range_filter {
#     label: "Choose a cohort date range"
#     description: "Select a date range for the taret cohort behavior"
#     type: date
#     datatype: date
#
#   }
#
#   parameter: time_period {
#     label: "Include events (n) hours after the initial behavior"
#     description: "How long after the initial behavior (within the same session) do you want to look for subsequent actions"
#     type: number
#   }
#
#   derived_table: {
#     sql:
#       SELECT user_sso_guid, session_id, min(event_time) as start_event_time, min(event_id) as first_event_id
#         ,CASE WHEN {{ time_period._parameter_value }} IS NULL THEN NULL ELSE DATEADD(hour,  {{ time_period._parameter_value }}, start_event_time) END as end_event_time
#       FROM ${all_events.SQL_TABLE_NAME}
#       WHERE UPPER(event_name) IN ( {{ cohort_events_filter._parameter_value | replace: ", ", "," | replace: ",", "', '" | upcase }})
#       AND (event_time >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
#       AND (event_time < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
#       GROUP BY 1, 2
#       ;;
#   }
#
#   dimension: user_sso_guid {type:string hidden: yes}
#   dimension: session_id {type:number hidden: yes}
#   dimension: start_event_time {type: date hidden: yes}
#   dimension: end_event_time {type: date hidden: yes}
#   dimension: first_event_id { type: number hidden: yes}
# }

explore: cohort_analysis {
  from: cohort_selection
  view_name: cohort_selection

#   join: next_events {
#     sql: inner join TABLE(prod.cu_user_analysis.next_events(${cohort_selection.session_id}, ${cohort_selection.first_event_id}, 10 )) ON 1=1;;
#   }
#   join: all_events {
#     sql_on: ${cohort_selection.session_id} = ${all_events.session_id}
#         and ${all_events.event_id} > ${cohort_selection.first_event_id}
#         --and ${cohort_selection.start_event_time} <= ${all_events.event_date_raw}
#         and (
#            ${cohort_selection.end_event_time} > ${all_events.event_date_raw}
#           or  ${cohort_selection.end_event_time} IS NULL
#           );;
#   }
  join: learner_profile {
    sql_on: ${cohort_selection.user_sso_guid} = ${learner_profile.user_sso_guid} ;;
    relationship: many_to_one
  }
}
