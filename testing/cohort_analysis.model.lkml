connection: "snowflake_prod"

include: "//core/common.lkml"
include: "/views/cu_user_analysis/all_events.view"
include: "/views/cu_user_analysis/learner_profile.view"
include: "/views/cu_user_analysis/filter_caches/filter_cache_all_events_event_name.view"
include: "/datagroups.lkml"

# explore: all_events_base {
#   hidden: no
#   sql_always_where: ${event_date_raw} >= DATEADD(month, -12, CURRENT_DATE()) ;;
#   sql_always_having: ${count} > 1000 ;;
#   persist_for: "24 hours"
# }

# view: next_events {
#
#   dimension: primary_key {sql:HASH(${session_id}, ${event_number});; primary_key: yes hidden: yes}
#
#   dimension: session_id {type:number hidden:yes}
#   dimension: event_number {type: number}
#   dimension: event_name { type: string}
#   measure: count {type: count}
# }

view: cohort_selection {
  #extends: [all_events]

  filter: cohort_events_filter {
    view_label: "** COHORT ANALYSIS **"
    label: "Choose cohort behavior"
    description: "Select the things that you want your cohort to have done "
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
    #suggest_persist_for: "24 hours"
  }

  filter: flow_events_filter {
    view_label: "** COHORT ANALYSIS **"
    label: "Events to include / exclude in the flow"
    description: "Select the things that you want to include or exclude in your flow"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
    #suggest_persist_for: "24 hours"
  }

  filter: cohort_date_range_filter {
    view_label: "** COHORT ANALYSIS **"
    label: "Choose a cohort date range"
    description: "Select a date range for the target cohort behavior"
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

  parameter: sample_size {
    view_label: "** COHORT ANALYSIS **"
    label: "Sample size"
    description: "How much of the data do you want to use in this analysis?  Reduce sample size to speed up the query"
    type: unquoted
    default_value: "50"
    allowed_value: {label: "25%" value: "25"}
    allowed_value: {label: "50%" value: "50"}
    allowed_value: {label: "75%" value: "75"}
    allowed_value: {label: "No sampling" value: "100"}
  }

  parameter: ignore_duplicates {
    view_label: "** COHORT ANALYSIS **"
    label: "Ignore duplicate events?"
    description: "Do you want to ignore consecutive events that are the same (e.g. only count the first page view in an ebook session)?"
    type: unquoted
    default_value: "ignore"
    allowed_value: {label:"Exclude duplicates" value:"exclude"}
    allowed_value: {label:"Include all events" value:"include"}
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
      FROM ${all_events.SQL_TABLE_NAME} SAMPLE({{ sample_size._parameter_value }}) REPEATABLE(0)
      WHERE (DATEADD(day, 1, event_time::DATE) >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
      AND (DATEADD(day, -1, event_time::DATE) < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
      AND {% condition cohort_events_filter %} event_name {% endcondition %}
      GROUP BY 1, 2
      ) cohort_selection
      LEFT JOIN (
          SELECT *
          {% if ignore_duplicates._parameter_value == 'include' %}
              ,FALSE
          {% elsif before_or_after._parameter_value == 'before' %}
              ,LEAD(event_name) OVER(PARTITION BY user_sso_guid ORDER BY event_time) = event_name
          {% else %}
              ,LAG(event_name) OVER(PARTITION BY user_sso_guid ORDER BY event_time) = event_name
          {% endif %}
              AS is_duplicate
          FROM ${all_events.SQL_TABLE_NAME} SAMPLE({{ sample_size._parameter_value }}) REPEATABLE(0)
          WHERE (DATEADD(day, 1, event_time::DATE) >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
          AND (DATEADD(day, -1, event_time::DATE) < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
          AND ({% condition flow_events_filter %} event_name {% endcondition %})
      ) all_events ON cohort_selection.session_id = all_events.session_id
        AND NOT all_events.is_duplicate
        {% if before_or_after._parameter_value == 'before' %}
          --PRECEDING EVENT ANALYSIS
         AND all_events.event_time < cohort_selection.start_event_time
         AND (
            all_events.event_time > cohort_selection.boundary_event_time
           OR cohort_selection.boundary_event_time IS NULL
          )
        {% else %}
        --SUBSEQUENT EVENT ANALYSIS
         AND all_events.event_time > cohort_selection.start_event_time
         AND (
            all_events.event_time < cohort_selection.boundary_event_time
           OR cohort_selection.boundary_event_time IS NULL
          )
        {% endif %}
      )
    WHERE event_sequence <= 5
    GROUP BY 1, 2
      ;;
   }

  dimension: user_sso_guid {hidden:yes}
  dimension: cohort_events {view_label: "** COHORT ANALYSIS **" type: string primary_key:yes}
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

  always_filter: {filters:[cohort_events_filter: "", flow_events_filter: "-UNLOAD UNLOAD", cohort_date_range_filter: "after 21 days ago", time_period: "30", ignore_duplicates: "exclude", before_or_after: "before"]}

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
