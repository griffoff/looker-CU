explore: cas_cafe_student_activity_duration {}
view: cas_cafe_student_activity_duration {
  derived_table: {
    sql:
    select
      merged_guid
      , activity_id::string as activity_id
      , is_gradable
      , due_date
      , course_key
      , hash(merged_guid,activity_id,is_gradable,due_date,course_key) as pk
      , min(event_time) as activity_start
      , max(event_time) as activity_complete
      , sum(duration) as activity_duration
    from ZANDBOX.DELDERFIELD.SESSION_EVENT_DURATIONS
    group by 1,2,3,4,5,6
    ;;
    persist_for: "8 hours"
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
  }

  dimension: activity_counts_toward_grade {
    sql: case when ${TABLE}.due_date is not null and ${TABLE}.is_gradable then true else false end  ;;
    type: yesno
    description: "Activity has 'is gradable' flag and due date is not null"
  }

  dimension: merged_guid {}
  dimension: activity_id {}
  dimension: is_gradable {}

  dimension_group: due_date  {
    type: time
    label: "Due"
    timeframes: [raw,date,week,month,year]
  }

  dimension: course_key {}

  dimension: activity_duration {
    type: number
    sql: ${TABLE}.activity_duration / 60 / 60 / 24 ;;
    value_format_name: duration_minutes
  }

  measure: number_users {
    type: count_distinct
    sql: ${merged_guid};;
    label: "# Users"
  }

  measure: average_activity_duration {
    type: average
    sql: ${activity_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p10 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 10
    sql: ${activity_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p25 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 25
    sql: ${activity_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p50 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 50
    sql: ${activity_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p75 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 75
    sql: ${activity_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p90 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 90
    sql: ${activity_duration};;
    value_format_name: duration_minutes
  }

  measure: count {
    type: count
  }


  }
