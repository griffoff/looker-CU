view: magellan_instructor_setup_status {
  sql_table_name: uploads.magellan_uploads.instructor_setup_status ;;
#    derived_table: {
#     # must switch this code out so it uses institution_course_id
#      sql:
#       with upload as (
#         select *, lead(_fivetran_synced) over(partition by array_construct(institution_course_name, mag_contact_id, user_guid) order by _fivetran_synced) is null as latest
#         from uploads.magellan_uploads.instructor_setup_status
#       )
#       select *
#       from upload
#       where latest
#        ;;
#
#       #sql_trigger_value: select max(_fivetran_synced) from uploads.magellan_uploads.instructor_setup_status;;
#    }

  set: marketing_fields {
    fields: [
      user_guid,
      mag_contact_id,
      mag_contact_name,
      mag_acct_id,
      institution_course_name,
      course_created,
      training_scheduled,
      training_completed,
      start_strong_scheduled,
      start_strong_completed,
      courses_expected,
      course_created_count,
      courses_not_created,
      training_scheduled_count,
      training_completed_count,
      start_strong_scheduled_count,
      start_strong_completed_count,
      freshness_score,
      estimated_start_week,
      instructor_count,
      closed_units
      ]
    }

  measure: instructor_count {
    label: "# instructors"
    type: count_distinct
    sql: ${user_guid} ;;
  }

  measure: courses_expected {
    label: "# Courses Expected"
    type: count
    drill_fields: [detail*]
  }

  measure: courses_not_created {
    label: "# Courses Not Created"
    type: number
    drill_fields: [detail*]
    sql: Greatest(0, ${courses_expected} - ${course_created_count}) ;;
  }

  dimension: freshness_score {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.FRESHNESS ;;
    #sql: TRY_CAST(NULLIF(REPLACE(${TABLE}.FRESHNESS, '%', ''), '0') AS NUMERIC) / 100 ;;
  }

  dimension: estimated_start_week {
    type: date
    sql: ${TABLE}.estimated_start_date;;
  }

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#     hidden: yes
#   }
#
#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#     hidden: yes
#   }

  dimension: user_guid {
    type: string
    sql: ${TABLE}."USER_GUID" ;;
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}.entity ;;
    value_format: "0000"

  }

  dimension: pk {
    hidden: yes
    sql: hash(${institution_course_name}, ${mag_contact_id}, ${user_guid}) ;;
    primary_key: yes
  }

  dimension: mag_acct_id {
    link: {
      label: "View Account Activities in Magellan"
      url: "http://magellan.cengage.com/Magellan2/#/Activities/{{ mag_acct_id._value }}"
    }
  }

  dimension: mag_contact_id {
    type: string
    sql: ${TABLE}."MAG_CONTACT_ID" ;;
    link: {
      label: "View Contact in Magellan"
      url: "http://magellan.cengage.com/Magellan2/#/Dashboard/{{ mag_acct_id._value }}/{{ mag_contact_id._value }}"
    }

  }

  dimension: mag_contact_name {
    type: string
    sql: ${TABLE}."MAG_CONTACT_NAME" ;;
    link: {
      label: "View Contact in Magellan"
      url: "http://magellan.cengage.com/Magellan2/#/Dashboard/{{ mag_acct_id._value }}/{{ mag_contact_id._value }}"
    }
    link: {
      label: "View Account Activities in Magellan"
      url: "http://magellan.cengage.com/Magellan2/#/Activities/{{ mag_acct_id._value }}"
    }
    label: "Contact Name"

  }

  dimension: institution_course_name {
    type: string
    sql: ${TABLE}."INSTITUTION_COURSE_NAME" ;;
  }

  dimension: course_created {
    type: yesno
    sql: ${TABLE}."CREATED_" = 'Yes';;
  }

  measure: course_created_count {
    label: "# Courses Created"
    type: sum
    sql: case when ${course_created} then 1 end;;
  }

  dimension: training_scheduled {
    type: yesno
    sql: ${TABLE}."TRAINING_SCHEDULED" = 'Yes' ;;
  }

  measure: training_scheduled_count {
    label: "# Training Scheduled"
    type: sum
    sql: case when ${training_scheduled} then 1 end;;
  }

  measure: training_was_scheduled_count {
    label: "# Training Was or Is Scheduled"
    type: sum
    sql: case when ${training_scheduled} or ${training_completed} then 1 end;;
  }

  dimension: training_completed {
    type: yesno
    sql: ${TABLE}."TRAINING_COMPLETED" = 'Yes';;
  }

  measure: training_completed_count {
    label: "# Training Completed"
    type: sum
    sql: case when ${training_completed} then 1 end;;
  }

  dimension: start_strong_scheduled {
    type: yesno
    sql: ${TABLE}."START_STRONG_SCHEDULED" = 'Yes';;
  }

  measure: start_strong_scheduled_count {
    label: "# Start Strong Scheduled"
    type: sum
    sql: case when ${start_strong_scheduled} then 1 end;;
  }

  measure: start_strong_was_scheduled_count {
    label: "# Start Strong Was or Is Scheduled"
    type: sum
    sql: case when ${start_strong_scheduled} or ${start_strong_completed} then 1 end;;
  }

  dimension: start_strong_completed {
    type: yesno
    sql: ${TABLE}."START_STRONG_COMPLETED" = 'Yes';;
  }

  measure: start_strong_completed_count {
    label: "# Start Strong Completed"
    type: sum
    sql: case when ${start_strong_completed} then 1 end;;
  }

  dimension: marked_proficient {
    type: yesno
    sql: ${TABLE}."MARKED_PROFICIENT" = 'Yes';;
  }

  measure: marked_proficient_count {
    label: "# Marked Proficient"
    type: sum
    sql: case when ${marked_proficient} then 1 end;;
  }

  measure: start_strong_complete_percent {
    label: "% Start Strong Complete"
    type: number
    sql:  ${magellan_instructor_setup_status.start_strong_completed_count} / NULLIF(${magellan_instructor_setup_status.start_strong_was_scheduled_count}, 0) ;;
    value_format_name: percent_0
  }

  measure: training_complete_percent {
    label: "% Training Complete"
    type: number
    sql:  ${magellan_instructor_setup_status.training_completed_count} / NULLIF(${magellan_instructor_setup_status.training_was_scheduled_count}, 0) ;;
    value_format_name: percent_0
  }

  measure: courses_created_percent {
    label: "% Courses Created"
    type: number
    sql: IFF(${user_courses.current_course_sections} > ${magellan_instructor_setup_status.courses_expected}, 1, ${user_courses.current_course_sections} /  NULLIF(${magellan_instructor_setup_status.courses_expected}, 0)) ;;
    value_format_name: percent_0
  }

  measure: closed_units {
    label: "# Closed Units"
    description: "Expected numbr of enrollments"
    type: sum
  }




  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      user_guid,
      entity_no,
      mag_contact_id,
      mag_contact_name,
      institution_course_name,
      course_created,
      training_scheduled,
      training_completed,
      start_strong_scheduled,
      start_strong_completed,
      freshness_score,
      estimated_start_week,
      closed_units
    ]
  }
}
