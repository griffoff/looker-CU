explore: cas_cafe_student_activity_duration_aggregate {hidden:yes}
view: cas_cafe_student_activity_duration_aggregate {
  parameter: group_by_activity_name {
    label: "Group By Activity Name"
    type: yesno
    default_value: "No"
    description: ""
  }

  parameter: group_by_group_name {
    label: "Group By Group Name"
    type: yesno
    default_value: "No"
    description: ""
  }

  parameter: group_by_learning_unit_name {
    label: "Group By Learning Unit Name"
    type: yesno
    default_value: "No"
    description: ""
  }

  parameter: group_by_learning_path_name {
    label: "Group By Learning Path Name"
    type: yesno
    default_value: "No"
    description: ""
  }

  parameter: group_by_due_date {
    label: "Group By Due Date"
    type: unquoted
    allowed_value: {
      label: "Day"
      value: "day"
    }
    allowed_value: {
      label: "Week"
      value: "week"
    }
    allowed_value: {
      label: "Month"
      value: "month"
    }
    allowed_value: {
      label: "No group on due date"
      value: "none"
    }
    default_value: "none"
    description: ""
  }

  filter: group_by_due_date_range {
    label: "Due Date Range"
    description: ""
    type: date
    datatype: date
  }

  derived_table: {
    sql:
      select
        merged_guid
        , course_key
        {% if group_by_due_date._parameter_value == 'day' or group_by_due_date._parameter_value == 'week' or group_by_due_date._parameter_value == 'month' %}
              , date_trunc({{ group_by_due_date._parameter_value }}, due_date) as due_date
        {% endif %}
        {% if group_by_activity_name._parameter_value == 'true' %}
              , activity_name
        {% endif %}
        {% if group_by_group_name._parameter_value == 'true' %}
              , group_name
        {% endif %}
        {% if group_by_learning_unit_name._parameter_value == 'true' %}
              , learning_unit_name
        {% endif %}
        {% if group_by_learning_path_name._parameter_value == 'true' %}
              , learning_path_name
        {% endif %}
        , hash(merged_guid, course_key
              {% if group_by_due_date._parameter_value == 'day' or group_by_due_date._parameter_value == 'week' or group_by_due_date._parameter_value == 'month' %}
              , due_date
              {% endif %}
              {% if group_by_activity_name._parameter_value == 'true' %}
                  , activity_name
              {% endif %}
              {% if group_by_group_name._parameter_value == 'true' %}
                  , group_name
              {% endif %}
              {% if group_by_learning_unit_name._parameter_value == 'true' %}
                  , learning_unit_name
              {% endif %}
              {% if group_by_learning_path_name._parameter_value == 'true' %}
                  , learning_path_name
              {% endif %}
          ) as pk
        , sum(activity_session_duration) as user_duration

      from ${cas_cafe_student_activity_duration.SQL_TABLE_NAME} d
      where (due_date >= {% date_start group_by_due_date_range %} OR {% date_start group_by_due_date_range %} IS NULL)
        AND (due_date <= {% date_end group_by_due_date_range %} OR {% date_end group_by_due_date_range %} IS NULL)
      group by merged_guid, course_key
        {% if group_by_due_date._parameter_value == 'day' or group_by_due_date._parameter_value == 'week' or group_by_due_date._parameter_value == 'month' %}
              , due_date
        {% endif %}
        {% if group_by_activity_name._parameter_value == 'true' %}
              , activity_name
        {% endif %}
        {% if group_by_group_name._parameter_value == 'true' %}
              , group_name
        {% endif %}
        {% if group_by_learning_unit_name._parameter_value == 'true' %}
              , learning_unit_name
        {% endif %}
        {% if group_by_learning_path_name._parameter_value == 'true' %}
              , learning_path_name
        {% endif %}
        , pk
      ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
  }

  dimension: merged_guid {}
  dimension: course_key {}

  dimension: due_date {
    type:date
    sql:{% if group_by_due_date._parameter_value == 'day' or group_by_due_date._parameter_value == 'week' or group_by_due_date._parameter_value == 'month' %} ${TABLE}.due_date
      {% else %} null {% endif %};;
    }


  dimension: activity_name {
    sql: {% if group_by_activity_name._parameter_value == 'true' %} ${TABLE}.activity_name {% else %} 'All Activities' {% endif %};;
  }

  dimension: learning_unit_name {
    sql: {% if group_by_learning_unit_name._parameter_value == 'true' %} ${TABLE}.learning_unit_name {% else %} 'All Learning Units' {% endif %};;
  }

  dimension: group_name {
    sql: {% if group_by_group_name._parameter_value == 'true' %} ${TABLE}.group_name {% else %} 'All Groups' {% endif %};;
  }

  dimension: learning_path_name {
    sql: {% if group_by_learning_path_name._parameter_value == 'true' %} ${TABLE}.learning_path_name {% else %} 'All Learning Paths' {% endif %};;
  }

  dimension: user_duration {
    type: number
    sql: ${TABLE}.user_duration / 60 / 60 / 24 ;;
    value_format_name: duration_minutes
  }

  measure: number_users {
    type: count_distinct
    sql: ${merged_guid};;
    label: "# Users"
  }

  measure: average_duration {
    type: number
    sql: avg(${user_duration});;
    value_format_name: duration_minutes
  }

  measure: total_duration  {
    type: sum
    sql: ${user_duration}  ;;
    value_format_name: duration_minutes
  }

  measure: duration_p10 {
    group_label: "Duration Percentiles"
    type: number
    sql: PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY ${user_duration}) ;;
    value_format_name: duration_minutes
  }

  measure: duration_p25 {
    group_label: "Duration Percentiles"
    type: number
    sql: PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ${user_duration}) ;;
    value_format_name: duration_minutes
  }

  measure: duration_p50 {
    group_label: "Duration Percentiles"
    type: number
    sql: PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ${user_duration}) ;;
    value_format_name: duration_minutes
  }

  measure: duration_p75 {
    group_label: "Duration Percentiles"
    type: number
    sql: PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ${user_duration}) ;;
    value_format_name: duration_minutes
  }

  measure: duration_p90 {
    group_label: "Duration Percentiles"
    type: number
    sql: PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY ${user_duration}) ;;
    value_format_name: duration_minutes
  }

  measure: count {
    type: count
  }


}
