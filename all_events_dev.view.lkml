include: "all_events.view"
include: "//core/common.lkml" # formats

view: event_name_lookup {
  derived_table: {
    sql:
        SELECT
          COALESCE(event_name
              ,'** ' || UPPER(event_type || ': ' || event_action) || ' **'
          ) as event_name
          ,COUNT(*) as event_count
        FROM ${all_events_dev.SQL_TABLE_NAME}
        GROUP BY 1
        HAVING COUNT(*) > 100
        ORDER BY 1
;;
    persist_for: "24 hours"
  }

  dimension: event_name {}
  dimension: event_count {}
}

explore: event_name_lookup {
  hidden: yes
}


view: all_events_dev {
  sql_table_name: dev.cu_user_analysis.all_events ;;
 extends: [all_events]


  dimension: iac_isbn {
    sql: ${event_data}:iac_isbn ;;
  }

  dimension: event_type {
    sql:${TABLE}."EVENT_TYPE" ;;
    hidden: no
    label: "Event Type"
    description: "Event category"
    group_label: "Event Classification"
  }

  dimension: event_name {
    suggest_explore: event_name_lookup
    suggest_dimension: event_name_lookup.event_name
  }

  dimension: event_name_temp {
    sql:  ${TABLE}."EVENT_TYPE" || ' ' || ${event_action} ;;
    group_label: "Event Classification"
    label: "event_classification concat with event_action"
  }

  dimension: has_shadow_guid {
    description: "Does a user have a shadow guid or not"
    type: yesno
    sql: ${TABLE}.original_user_sso_guid != ${TABLE}.user_sso_guid ;;
  }

  dimension: original_guid {
    type: string
    sql: ${TABLE}.original_user_sso_guid;;
    hidden: no
  }

  dimension: event_duration {
    type:  number
    sql: event_data:event_duration  / (60 * 60 * 24) ;;
    value_format: "[m] \m\i\n\s"
    label: "Event duration"
    description: "An event's duration calculated for events such as reading, viewing, and app usage, but not given to individual click events"
  }

  dimension: time_to_next_event {
    type:  number
    sql: event_data:time_until_next_event  / (60 * 60 * 24) ;;
    value_format: "[m] \m\i\n\s"
    label: "Event duration (time to next event)"
    description: "An event's duration calculated for all event types as the time until the next event is fired"
  }

  dimension: first_event_in_session {
    sql: ${TABLE}.event_no = 1 ;;
    type: yesno
    label: "First event in session"
    description: "TRUE if the event is the first in a session and FALSE otherwise"
  }

  dimension: event_0 {
    type: string
    sql: ${TABLE}."EVENT_0" ;;
    group_label: "Proceding five events"
    label: "Current event"
  }

  dimension: event_1 {
    type: string
    sql: ${TABLE}."EVENT_1" ;;
    group_label: "Proceding five events"
    label: "Event 1"
    description: "The event one prior to the current event"
  }

  dimension: event_2 {
    type: string
    sql: ${TABLE}."EVENT_2" ;;
    group_label: "Proceding five events"
    label: "Event 2"
    description: "The event two prior to the current event"
  }

  dimension: event_3 {
    type: string
    sql: ${TABLE}."EVENT_3" ;;
    group_label: "Proceding five events"
    label: "Event 3"
    description: "The event three prior to the current event"
  }

  dimension: event_4 {
    type: string
    sql: ${TABLE}."EVENT_4" ;;
    group_label: "Proceding five events"
    label: "Event 4"
    description: "The event four prior to the current event"
  }

  dimension: event_5 {
    type: string
    sql: ${TABLE}."EVENT_5" ;;
    group_label: "Proceding five events"
    label: "Event 5"
    description: "The event five prior to the current event"
  }

  dimension: event_0p {
    type: string
    sql: ${TABLE}."EVENT_0P" ;;
    group_label: "Succeeding five events"
    label: "Current event"
  }

  dimension: event_1p {
    type: string
    sql: ${TABLE}."EVENT_1P" ;;
    group_label: "Succeeding five events"
    label: "Event 1"
    description: "The event one after the current event"
  }

  dimension: event_2p {
    type: string
    sql: ${TABLE}."EVENT_2P" ;;
    group_label: "Succeeding five events"
    label: "Event 2"
    description: "The event two after the current event"
  }

  dimension: event_3p {
    type: string
    sql: ${TABLE}."EVENT_3P" ;;
    group_label: "Succeeding five events"
    label: "Event 3"
    description: "The event three after the current event"
  }

  dimension: event_4p {
    type: string
    sql: ${TABLE}."EVENT_4P" ;;
    group_label: "Succeeding five events"
    label: "Event 4"
    description: "The event four after the current event"
  }

  dimension: event_5p {
    type: string
    sql: ${TABLE}."EVENT_5P" ;;
    group_label: "Succeeding five events"
    label: "Event 5"
    description: "The event five after the current event"
  }

  dimension: has_coursekey {
    type: yesno
    sql: ${event_data}:course_key is not null ;;
  }

  dimension_group: event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year, day_of_week, hour_of_day]
    sql: ${TABLE}."EVENT_TIME" ;;
    label: "Event timestamp UTC"
    description: "Components of the events timestamp stored in TZ format"
  }


  dimension: load_metadata {
    type: string
    sql: ${TABLE}."LOAD_METADATA" ;;
    label: "Load metadata"
    description: "Data related to the underlying table refresh (_HASH, LDTS, _RSRC)"
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
    label: "Platform environment"
    description: "Development platofrm i.e. production, staging, development, etc."
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
    label: "User environment"
    description: "Development platofrm i.e. production, staging, development, etc."
  }

  dimension: relative_age {
    label: ""

  }

#     dimension_group: time_since_first_login_test {
#       label: "Time since first login test"
#       sql: DATEDIFF(d,  ${learner_profile_2.first_interaction_raw}, ${event_time}) ;;
#       type: duration
#       intervals: [hour, day, week, month]
#     }

  dimension: event_action {
    hidden: no
  }

  measure: user_count {
    label: "# people"
    type: count_distinct
    sql: ${user_sso_guid} ;;
    drill_fields: [event_time, system_category, event_action, event_data, count]
    description: "Measure for counting unique users (drill fields)"
  }

  measure: user_count_before_mapping {
    label: "# guids (unmerged)"
    type: count_distinct
    sql: ${original_guid} ;;
    drill_fields: [event_time, system_category, event_action, event_data, count]
    description: "Measure for counting unique user ids before shadow guid mapping was applied"
  }

  measure: user_count_after_mapping {
    label: "# guids (merged)"
    type: count_distinct
    sql: ${user_sso_guid} ;;
    drill_fields: [event_time, system_category, event_action, event_data, count]
    description: "Measure for counting unique user ids after shadow guid mapping"
  }

  measure: example_event_data {
    type: string
    sql: any_value(${event_data}) ;;
    label: "Example event data"
    description: "Randomly selects some event data from the event data json as an example of the type of data tracked with the given event type"
  }

  measure: latest_event_time {
    type: date_time
    sql: max(${event_raw}) ;;
    label: "Latest event time"
    description: "Latest event time for the currently querried subset of population (i.e. filterable)"
  }

  measure: first_event_time {
    type: date_time
    sql:min(${event_raw}) ;;
    label: "First event time"
    description: "First event time for the currently querried subset of population (i.e. filterable)"
  }

  measure: days_total {
    type: number
    sql: CEIL(datediff(hour, ${first_event_time}, ${latest_event_time})/24, 0) ;;
    label: "Total number of days"
    description: "Total number of days between the first event time and latest event time over the currently querried subset of population (i.e. filterable)"
  }

  measure: days_active {
    type: count_distinct
    sql: ${event_date} ;;
    label: "Days active"
    description: "Count of the unique dates"
  }

  measure: days_active_per_week {
    sql: LEAST(${days_active}, ${days_total}) / GREATEST(nullif((${days_total}/7), 0), 1) ;;
    label: "Days active per week"
    description: "Average days active per week"
  }

  measure: days_since_last_login {
    type: number
    sql: datediff(hour, ${latest_event_time}, current_timestamp()) / 24 ;;
    label: "Days since last login"
    description: "Calculated as number of days since last login"
  }

  measure: session_count {
    type: count_distinct
    sql: ${session_id} ;;
  }

  measure: events_per_session {
    sql: ${count} / nullif(${session_count}, 0) ;;
    label: "Events per session"
    description: "Calculated as the number of events per session"
  }

  measure: recency {
    sql: CASE WHEN ROUND(${days_since_last_login}, 0) < 0 THEN 0 ELSE ROUND(${days_since_last_login}, 0) END ;;
    type:  number
    label: "Recency"
    description: "Calculated as the number of days since the last login"
  }
  measure: frequency {
    sql: COALESCE(ROUND(${days_active_per_week}, 1),0) ;;
    label: "Frequency"
    type:  number
    description: "Calculated as the average number of days active per week"
  }
  measure: intensity {
    sql: ROUND(${events_per_session}, 1) ;;
    label: "Intensity"
    type:  number
    description: "Calculated as the average number of events per session"
  }

  measure: usage_score {
    sql: (${recency} * -2) + (${intensity} * 2 ) + (${frequency} * 10) ;;
    type: number
    label: "Usage score"
  }

  measure: usage_score_prank {
    sql: PERCENT_RANK() OVER (PARTITION BY ${event_week} ORDER BY ${usage_score}) ;;
    type: number
  }

  measure: usage_classification {

  }

  measure: net_trials {
    label: "Net New Trials"
    type: sum
    sql: case
            when event_action = 'TRIAL EXPIRED'
            then -1
            when event_data:subscription_state = 'trial_access'
            then
              iff(event_data:prev_subscription_state = event_data:subscription_state, 0, 1)
            when event_data:prev_subscription_state = 'trial_access'
            then
              iff(event_data:prev_subscription_state = event_data:subscription_state, 0, -1)
            end;;
  }

  measure: net_subscriptions {
    label: "Net New Subscriptions"
    type: sum
    sql: case
            when event_action = 'TRIAL EXPIRED'
            then 0
            when event_data:subscription_state = 'full_access'
            then
              iff(event_data:prev_subscription_state = event_data:subscription_state, 0, 1)
            when event_data:prev_subscription_state = 'full_access'
            then iff(event_data:prev_subscription_state = event_data:subscription_state, 0, -1)
            when event_data:subscription_state is not null
            then 0
          end;;
  }

  measure: sum_of_event_duration{
    type: sum
    sql:event_data:event_duration / (60 * 60 * 24);;
    value_format: "[m] \m\i\n\s"
    label: "Sum of event durations"
    description: "Calcualted as the sum of event durations grouped by selected dimensions"
  }

  measure: sum_of_time_to_next_event{
    type: sum
    sql: event_data:time_to_next_event  / (60 * 60 * 24) ;;
    value_format: "[m] \m\i\n\s"
    label: "Sum of event durations (time to next event)"
    description: "Calcualted as the sum of event durations (time to next event) grouped by selected dimensions"
  }

  dimension: search_event_duration_dim {
    type:  number
    sql: CASE WHEN (${event_name} ILIKE '%search%' AND event_data:time_to_next_event > 10) THEN 10
         WHEN (${event_name} ILIKE '%search%' AND event_data:time_to_next_event < 10) THEN event_data:time_to_next_event
         ELSE NULL END;;

    value_format: "[m] \m\i\n\s"
      label: "Search durations (time to next event)"
      description: "Calcualted as the sum of search durations (time to next event) grouped by selected dimensions"
    }

    measure: search_event_duration{
      type: sum
      sql: CASE WHEN (CASE WHEN (event_name ILIKE '%search%') THEN event_data:time_to_next_event END) > 10 THEN 10 ELSE event_data:time_to_next_event END;;

      value_format: "[m] \m\i\n\s"
      label: "Sum of search durations (time to next event)"
      description: "Calcualted as the sum of search durations (time to next event) grouped by selected dimensions"
    }

    measure: avg_search_event_duration{
      type: average
      sql: ${search_event_duration_dim}  / (60 * 60 * 24);;
      value_format: "[m] \m\i\n\s"
      label: "Average search durations"
      description: "Calcualted as the sum of search durations (time to next event) grouped by selected dimensions"
    }

    measure: course_ware_duration {
      type: sum
      sql: CASE WHEN event_data:course_key IS NOT NULL THEN event_data:event_duration / (60 * 60 * 24) END   ;;
      value_format: "[m] \m\i\n\s"
    }

    measure: non_courseware_duration {
      type: sum
      sql: CASE WHEN event_data:course_key IS NULL THEN event_data:event_duration / (60 * 60 * 24) END  ;;
      value_format: "[m] \m\i\n\s"
    }

  measure:  no_cu_users_searched{
    label: "CU users that Searched"
    type: count_distinct
    sql: CASE WHEN ${event_name} ilike 'dashboard%search%result%' THEN ${user_sso_guid} ELSE null end ;;
  }

#   measure:  no_of_searches_trial{
#     label: "No Of Searches for Trial"
#     type: count_distinct
#     sql:  CASE WHEN ${event_name} ilike 'dashboard%search%result%' and ${event_subscription_state} ilike 'trial access' THEN ${event_id} ELSE null end ;;
#   }

#   measure:  no_success_searched_trial{
#     label: "No Of Successful Searches Trial"
#     type: count_distinct
#     sql: CASE WHEN ${event_data}:search_outcome ilike 'Y' and ${event_subscription_state} ilike 'trial access' THEN ${event_id} ELSE null end;;
#   }

  measure:  no_of_searches{
    label: "No Of Searches"
    type: count_distinct
    sql:  CASE WHEN ${event_name} ilike 'dashboard%search%result%'  THEN ${event_id} ELSE null end ;;
  }

  measure:  no_success_searched{
    label: "No Of Successful Searches"
    type: count_distinct
    sql: CASE WHEN ${event_data}:search_outcome ilike 'Y' THEN ${event_id} ELSE null end;;
  }
  }
