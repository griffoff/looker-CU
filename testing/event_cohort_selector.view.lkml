include: "/views/cu_user_analysis/filter_caches/*.view"
include: "/views/cu_user_analysis/all_events.view"
include: "/views/cu_user_analysis/all_sessions.view"
include: "/models/shared_explores.lkml"



explore: event_cohort_selector {
  hidden: yes
  always_filter: {
    filters: [
      event_cohort_selector.cohort_events_filter: ""
      ,event_cohort_selector.cohort_exclude_events_filter: "-UNLOAD UNLOAD"
      ,event_cohort_selector.cohort_date_range_filter: "after 21 days ago"
      ,event_cohort_selector.time_bucket_size_mins: "5"
      ]
  }

  join: all_sessions {
    sql: right join ${all_sessions.SQL_TABLE_NAME} all_sessions ON ${event_cohort_selector.user_sso_guid} = ${all_sessions.user_sso_guid} ;;
  }

  join: all_events {
    sql_on: ${all_sessions.session_id} = ${all_events.session_id} ;;
    relationship: one_to_many
  }

  join: user_courses {
    # required for validation but not needed for testing this view
    fields: []
    sql_on: 1=0 ;;
    relationship: one_to_one
  }

  join: dim_course {
    fields: []
    # required for validation but not needed for testing this view
    sql_on: 1=0 ;;
    relationship: one_to_one
  }
}

view: event_cohort_selector {
  label: "** COHORT SELECTION **"

  filter: cohort_events_filter {
    label: "Choose event(s) to include"
    description: "Select the events that you want your users to have done"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: cohort_exclude_events_filter {
    label: "Choose event(s) to exclude"
    description: "Select the events that you want your users to have NOT done (be sure to chose exclusion operators like 'Not equal to')"
    type: string
    default_value: "~UNLOAD UNLOAD"
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  parameter: time_bucket_size_mins {
    type: number
    default_value: "5"
  }

  filter: cohort_date_range_filter {
    label: "Choose a date range for selected behavior"
    description: "Select a date range for user behavior(s)"
    type: date
    datatype: date
  }

  derived_table: {

    sql:

    SELECT
      all_events.user_sso_guid
      ,SUM(all_events.event_data:event_duration) as total_duration_seconds
      ,COUNT(DISTINCT all_sessions.session_start::DATE) as days_with_events
    FROM ${all_sessions.SQL_TABLE_NAME} all_sessions
    JOIN ${all_events.SQL_TABLE_NAME} all_events USING(session_id)
    WHERE {% condition cohort_date_range_filter %} all_sessions.session_start {% endcondition %}
    AND {% condition cohort_events_filter %} all_events.event_name {% endcondition %}
    AND {% condition cohort_exclude_events_filter %} all_events.event_name {% endcondition %}
    GROUP BY 1;;
  }

  dimension: user_sso_guid {primary_key:yes hidden:yes}

  dimension: time_bucket {
    case: {
      when: {sql: ${total_duration_seconds} IS NULL ;; label: "No Usage" }
      when: {sql: ${total_duration_seconds} < (1 * 60 * {{ time_bucket_size_mins._parameter_value }}) ;; label: "< {{ time_bucket_size_mins._parameter_value }} mins" }
      when: {sql: ${total_duration_seconds} < (2 * 60 * {{ time_bucket_size_mins._parameter_value }}) ;; label: "between {{ time_bucket_size_mins._parameter_value | times: 1 }} and {{ time_bucket_size_mins._parameter_value | times: 2 }} mins" }
      when: {sql: ${total_duration_seconds} < (3 * 60 * {{ time_bucket_size_mins._parameter_value }}) ;; label: "between {{ time_bucket_size_mins._parameter_value | times: 2 }} and {{ time_bucket_size_mins._parameter_value | times: 3 }} mins" }
      when: {sql: ${total_duration_seconds} < (4 * 60 * {{ time_bucket_size_mins._parameter_value }}) ;; label: "between {{ time_bucket_size_mins._parameter_value | times: 3 }} and {{ time_bucket_size_mins._parameter_value | times: 4 }} mins"}
      else: ">= {{ time_bucket_size_mins._parameter_value | times: 4 }} mins"
    }
  }

  dimension: days_with_events {type:number hidden:yes}

  measure: user_in_cohort_count {
    label: "# Users in selected cohort"
    type: count
    value_format_name: decimal_0
    alias: [count]
  }

  measure: user_not_in_cohort_count {
    label: "# Users NOT in selected cohort"
    type: count_distinct
    sql: IFF(${user_sso_guid} IS NULL, ${all_events.user_sso_guid}, NULL) ;;
    value_format_name: decimal_0
  }

  measure: user_in_cohort_percent {
    label: "% Users in selected cohort"
    type: number
    sql: ${user_in_cohort_count} / ${all_events.user_count} ;;
    required_fields: [all_events.user_count]
    value_format_name: percent_1
  }

  ## TOTAL DURATION

  dimension: total_duration_seconds {
    type: number
    hidden:yes
  }

  dimension: total_duration {
    type: number
    sql: ${TABLE}.total_duration_seconds / 3600 / 24 ;;
    value_format: "[m]:ss \m\i\n\s"
    hidden: yes
  }

  measure: total_duration_per_student_per_day {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Average Duration for events in cohort (per User per Day)"
    type: average
    sql: (${total_duration} / ${days_with_events}) ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_sum {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (Sum)"
    type: sum
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_min {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (Min)"
    type: min
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_avg {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (per User)"
    type: average
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_max {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (Max)"
    type: max
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_p05 {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (05th percentile)"
    type: number
    sql:  PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY (${total_duration}) ) ;;
#     type: percentile
#     percentile: 5
#     sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_p10 {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (10th percentile)"
    type: percentile
    percentile: 10
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_p25 {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (25th percentile)"
    type: percentile
    percentile: 25
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_p50 {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (50th percentile)"
    type: percentile
    percentile: 50
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_p75 {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (75th percentile)"
    type: percentile
    percentile: 75
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_p90 {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (90th percentile)"
    type: percentile
    percentile: 90
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_p95 {
    group_label: "Time spent on SELECTED events (for selected cohort)"
    label: "Total Duration for events in cohort (95th percentile)"
    type: percentile
    percentile: 95
    sql: ${total_duration} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  ## END TOTAL DURATION

  ## TOTAL DURATION IN COHORT

  dimension: total_duration_in_cohort {
    type: number
    sql: IFF(${user_sso_guid} IS NOT NULL, ${all_events.event_data}:event_duration::int / 3600 / 24, NULL);;
    #sql: ${TABLE}.total_duration_seconds / 3600 / 24 ;;
    value_format: "[m]:ss \m\i\n\s"
    hidden: yes
  }

  measure: total_duration_in_cohort_per_user {
    group_label: "Total Active Time (for selected cohort)"
    label: "Total Active time for users in cohort (avg per user)"
    type: number
    sql: SUM(${total_duration_in_cohort}) / ${user_in_cohort_count};;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_in_cohort_sum {
    group_label: "Total Active Time (for selected cohort)"
    label: "Total active time for users in cohort (Sum)"
    type: number
    sql: SUM(${total_duration_in_cohort}) ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_in_cohort_min {
    group_label: "Total Active Time (for selected cohort)"
    label: "Total active time for users in cohort (Min)"
    type: min
    sql: ${total_duration_in_cohort} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_in_cohort_avg {
    group_label: "Total Active Time (for selected cohort)"
    label: "Total active time for users in cohort (Avg)"
    type: number
    sql: AVG(${total_duration_in_cohort}) ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_in_cohort_max {
    group_label: "Total Active Time (for selected cohort)"
    label: "Total active time for users in cohort (Max)"
    type: max
    sql: ${total_duration_in_cohort} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_in_cohort_p05 {
    group_label: "Total Active Time (for selected cohort)"
    label: "Total active time for users in cohort (05th percentile)"
    type: number
    sql:  PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY (${total_duration_in_cohort}) ) ;;
#     type: percentile
#     percentile: 5
#     sql: ${total_duration_in_cohort} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  ## END TOTAL DURATION IN COHORT

  ## TOTAL DURATION NOT IN COHORT

  dimension: total_duration_not_in_cohort {
    type: number
    sql: IFF(${user_sso_guid} IS NULL, ${all_events.event_data}:event_duration::int / 3600 / 24, NULL);;
    #sql: ${TABLE}.total_duration_seconds / 3600 / 24 ;;
    value_format: "[m]:ss \m\i\n\s"
    hidden: yes
  }

  measure: total_duration_not_in_cohort_per_user {
   group_label: "Total Active Time (for those NOT in selected cohort)"
    label: "Total Active time for users NOT in cohort (avg per user)"
    type: number
    sql: SUM(${total_duration_not_in_cohort}) / ${user_not_in_cohort_count};;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_not_in_cohort_sum {
    group_label: "Total Active Time (for those NOT in selected cohort)"
    label: "Total active time for users NOT in cohort (Sum)"
    type: number
    sql: SUM(${total_duration_not_in_cohort}) ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_not_in_cohort_min {
    group_label: "Total Active Time (for those NOT in selected cohort)"
    label: "Total active time for users NOT in cohort (Min)"
    type: min
    sql: ${total_duration_not_in_cohort} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_not_in_cohort_avg {
    group_label: "Total Active Time (for those NOT in selected cohort)"
    label: "Total active time for users NOT in cohort (Avg)"
    type: number
    sql: AVG(${total_duration_not_in_cohort}) ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: total_duration_not_in_cohort_max {
    group_label: "Total Active Time (for those NOT in selected cohort)"
    label: "Total active time for users NOT in cohort (Max)"
    type: max
    sql: ${total_duration_not_in_cohort} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  ## END TOTAL DURATION NOT IN COHORT



}
