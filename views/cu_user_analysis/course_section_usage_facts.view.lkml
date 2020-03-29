view: course_section_usage_facts {

  view_label: "Course / Section Details"

  derived_table: {
    sql:
    SELECT uc.*, COALESCE(s.total_sessions, 0) as total_sessions_for_course
    FROM (
      SELECT course_key, COUNT(*) as total_users_on_course
      FROM ${user_courses.SQL_TABLE_NAME}
      GROUP BY 1
    ) uc
    LEFT JOIN (
      SELECT course_keys[0] as course_key, COUNT(*) as total_sessions
      FROM ${all_sessions.SQL_TABLE_NAME}
      WHERE course_keys IS NOT NULL
      GROUP BY 1
      ) s ON uc.course_key = s.course_key;;
    persist_for: "24 hours"
  }

  dimension: course_key {
    primary_key: yes
    hidden: yes
  }

  dimension: total_users_on_course {type: number}
  dimension: total_sessions_for_course {type:number}

}
