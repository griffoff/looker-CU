view: wa_course_language {
  derived_table: {
    sql:  select * from uploads.course_section_metadata.wa_course_language;;
  }

  dimension: section_id {hidden:yes}
  dimension: textbook_id {hidden:yes}
  dimension: textbook_code {hidden:yes}
  dimension: context_id {hidden:yes}
  dimension: class_key {hidden:yes}
  dimension: language {}


  }
