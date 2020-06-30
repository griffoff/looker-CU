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
  #extends: [all_events]

  parameter: cohort_events_filter {
    view_label: "** COHORT ANALYSIS **"
    label: "Choose cohort behavior"
    description: "Select the things that you want your cohort to have done "
    type: string
    default_value: ""
    suggest_explore: events
    suggest_dimension: events.event_name
    suggest_persist_for: "24 hours"
  }

  filter: cohort_date_range_filter {
    view_label: "** COHORT ANALYSIS **"
    label: "Choose a cohort date range"
    description: "Select a date range for the taret cohort behavior"
    type: date
    datatype: date

  }

  parameter: before_or_after {
    view_label: "** COHORT ANALYSIS **"
    label: "Before or after analysis?"
    description: "Do you want to find behaviors before (leading up to) or after (happened after) the chosen cohort behavior?"
    type: unquoted
    default_value: "before"
    allowed_value: {label: "Before" value: "before"}
    allowed_value: {label: "After" value: "after"}
  }

  parameter: time_period {
    view_label: "** COHORT ANALYSIS **"
    label: "Include events (n) minutes before/after the initial behavior"
    description: "How long after the initial behavior (within the same session) do you want to look for subsequent actions"
    type: number
  }

  derived_table: {
    sql:
     SELECT
        user_sso_guid
        ,cohort_events
        ,MAX(CASE WHEN event_sequence = 1 THEN event_name END) as event_1
        ,MAX(CASE WHEN event_sequence = 2 THEN event_name END) as event_2
        ,MAX(CASE WHEN event_sequence = 3 THEN event_name END) as event_3
        ,MAX(CASE WHEN event_sequence = 4 THEN event_name END) as event_4
        ,MAX(CASE WHEN event_sequence = 5 THEN event_name END) as event_5
     FROM (
      SELECT
          {% if before_or_after._parameter_value == 'before' %}
          ROW_NUMBER() OVER(PARTITION BY all_events.session_id ORDER BY event_time DESC, event_id DESC) AS event_sequence
          {% else %}
          ROW_NUMBER() OVER(PARTITION BY all_events.session_id ORDER BY event_time, event_id) AS event_sequence
          {% endif %}
          ,cohort_selection.cohort_events
          ,COALESCE(all_events.USER_SSO_GUID,cohort_selection.USER_SSO_GUID) AS USER_SSO_GUID
          ,all_events.EVENT_NAME
      FROM (
        SELECT user_sso_guid, session_id, LISTAGG(distinct event_name) as cohort_events, min(event_time) as start_event_time, min(event_id) as first_event_id
        ,CASE
          WHEN {{ time_period._parameter_value }} IS NULL THEN NULL
          ELSE
            DATEADD(minute,  IFF('{% parameter before_or_after %}' = 'before', -1, 1) * {{ time_period._parameter_value }}, start_event_time)
          END as boundary_event_time
      FROM ${all_events.SQL_TABLE_NAME} all_events
      WHERE (DATEADD(day, 1, event_time::DATE) >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
      AND (DATEADD(day, -1, event_time::DATE) < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
      AND UPPER(event_name) IN ( {{ cohort_events_filter._parameter_value | replace: ", ", "," | replace: ",", "', '" | upcase }})
      GROUP BY 1, 2
      ) cohort_selection
      LEFT JOIN (
          SELECT *
          FROM ${all_events.SQL_TABLE_NAME}
          WHERE (DATEADD(day, 1, event_time::DATE) >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
          AND (DATEADD(day, -1, event_time::DATE) < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
      ) all_events ON cohort_selection.session_id = all_events.session_id
        {% if before_or_after._parameter_value == 'before' %}
          --PRECEDING EVENT ANALYSIS
         and all_events.event_time < cohort_selection.start_event_time
         and (
            all_events.event_time > cohort_selection.boundary_event_time
           or cohort_selection.boundary_event_time IS NULL
          )
        {% else %}
        --SUBSEQUENT EVENT ANALYSIS
         and all_events.event_time > cohort_selection.start_event_time
         and (
            all_events.event_time < cohort_selection.boundary_event_time
           or cohort_selection.boundary_event_time IS NULL
          )
        {% endif %}
      )
    WHERE event_sequence <= 5
    GROUP BY 1, 2
      ;;
   }

  dimension: user_sso_guid {hidden:yes}
  dimension: cohort_events {view_label: "** COHORT ANALYSIS **" type: string}
#   dimension: event_sequence {view_label: "** COHORT ANALYSIS **" type: number}
#   dimension: event_sequence_description {view_label: "** COHORT ANALYSIS **" type: string sql: ${event_sequence} || ' event' || IFF(${event_sequence} > 1, 's ', ' ') || '{% parameter before_or_after %}';; order_by_field: event_sequence}
  dimension: event_1 {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events after" label: "1 event after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_1 {% else %} NULL {% endif%} ;;}
  dimension: event_2 {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events after" label: "2 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_2 {% else %} NULL {% endif%} ;;}
  dimension: event_3 {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events after" label: "3 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_3 {% else %} NULL {% endif%} ;;}
  dimension: event_4 {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events after" label: "4 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_4 {% else %} NULL {% endif%} ;;}
  dimension: event_5 {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events after" label: "5 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_5 {% else %} NULL {% endif%} ;;}
  dimension: event_1_p {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events before" label: "1 event before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_1 {% else %} NULL {% endif%} ;;}
  dimension: event_2_p {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events before" label: "2 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_2 {% else %} NULL {% endif%} ;;}
  dimension: event_3_p {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events before" label: "3 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_3 {% else %} NULL {% endif%} ;;}
  dimension: event_4_p {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events before" label: "4 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_4 {% else %} NULL {% endif%} ;;}
  dimension: event_5_p {view_label: "** COHORT ANALYSIS **" type: string  group_label: "Events before" label: "5 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_5 {% else %} NULL {% endif%} ;;}

}


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
