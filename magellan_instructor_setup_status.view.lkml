view: magellan_instructor_setup_status {
  #sql_table_name: uploads.magellan_uploads.instructor_setup_status ;;
   derived_table: {
    # must switch this code out so it uses institution_course_id
     sql:
      with upload as (
        select *, lead(_fivetran_synced) over(partition by array_construct(institution_course_name, mag_contact_id) order by _fivetran_synced) is null as latest
        from uploads.magellan_uploads.instructor_setup_status
      )
      select *
      from upload
      where latest
       ;;

      persist_for: "24 hours"
   }

  set: marketing_fields {
    fields: [
      user_guid,
      mag_contact_id,
      mag_contact_name,
      institution_course_name,
      course_created,
      training_scheduled,
      training_completed,
      start_strong_scheduled,
      start_strong_completed,
      courses_expected,
      course_created_count,
      training_scheduled_count,
      training_completed_count,
      start_strong_scheduled_count,
      start_strong_completed_count,
      freshness_score
      ]
    }

  measure: courses_expected {
    label: "# Courses Expected"
    type: count
    drill_fields: [detail*]
  }

  dimension: freshness_score {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.FRESHNESS_SCORE / 100 ;;
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

  dimension: pk {
    hidden: yes
    sql: hash(${institution_course_name}, ${mag_contact_id}) ;;
    primary_key: yes
  }

  dimension: mag_contact_id {
    type: string
    sql: ${TABLE}."MAG_CONTACT_ID" ;;
    link: {
      label: "View Account in Magellan"
      url: "http://magellan.cengage.com/Magellan2/#/Dashboard/{{ dim_course.mag_acct_id._value }}/{{ mag_contact_id._value }}"
    }

  }

  dimension: mag_contact_name {
    type: string
    sql: ${TABLE}."MAG_CONTACT_NAME" ;;
    link: {
      label: "View Contact in Magellan"
      url: "http://magellan.cengage.com/Magellan2/#/Dashboard/{{ dim_course.mag_acct_id._value }}/{{ mag_contact_id._value }}"
    }
    link: {
      label: "View Account Activities in Magellan"
      url: "http://magellan.cengage.com/Magellan2/#/Activities/{{ dim_course.mag_acct_id._value }}"
    }

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

  dimension: start_strong_completed {
    type: yesno
    sql: ${TABLE}."START_STRONG_COMPLETED" = 'Yes';;
  }

  measure: start_strong_completed_count {
    label: "# Start Strong Completed"
    type: sum
    sql: case when ${start_strong_completed} then 1 end;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      user_guid,
      mag_contact_id,
      mag_contact_name,
      institution_course_name,
      course_created,
      training_scheduled,
      training_completed,
      start_strong_scheduled,
      start_strong_completed,
    ]
  }
}
