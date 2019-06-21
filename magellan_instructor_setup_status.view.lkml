view: magellan_instructor_setup_status {
  derived_table: {
    sql: Select * from uploads.magellan_uploads.instructor_setup_status
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
    hidden: yes
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
    hidden: yes
  }

  dimension: user_guid {
    type: string
    sql: ${TABLE}."USER_GUID" ;;
  }

  dimension: mag_contact_id {
    type: string
    sql: ${TABLE}."MAG_CONTACT_ID" ;;
  }

  dimension: mag_contact_name {
    type: string
    sql: ${TABLE}."MAG_CONTACT_NAME" ;;
  }

  dimension: institution_course_name {
    type: string
    sql: ${TABLE}."INSTITUTION_COURSE_NAME" ;;
  }

  dimension: created_ {
    type: string
    sql: ${TABLE}."CREATED_" ;;
    hidden: yes
  }

  dimension: training_scheduled {
    type: string
    sql: ${TABLE}."TRAINING_SCHEDULED" ;;
  }

  dimension: training_completed {
    type: string
    sql: ${TABLE}."TRAINING_COMPLETED" ;;
  }

  dimension: start_strong_scheduled {
    type: string
    sql: ${TABLE}."START_STRONG_SCHEDULED" ;;
  }

  dimension: start_strong_completed {
    type: string
    sql: ${TABLE}."START_STRONG_COMPLETED" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      _file,
      _line,
      user_guid,
      mag_contact_id,
      mag_contact_name,
      institution_course_name,
      created_,
      training_scheduled,
      training_completed,
      start_strong_scheduled,
      start_strong_completed,
      _fivetran_synced_time
    ]
  }
}
