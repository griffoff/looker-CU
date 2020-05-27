explore: daily_coursesection_instructors  {hidden:yes}
view: daily_coursesection_instructors {
  derived_table: {
    sql:
      SELECT dim_date.datevalue as date
        ,COUNT(DISTINCT course.course_key, course.instructor_guid) as course_instructor_count
        ,COUNT(DISTINCT course.course_key) as coursesection_count
        ,COUNT(DISTINCT course.instructor_guid) as instructor_count
      FROM ${dim_date.SQL_TABLE_NAME} dim_date
      LEFT JOIN PROD.STG_CLTS.OLR_COURSES course ON dim_date.datevalue BETWEEN course.begin_date and course.end_date
      WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
      GROUP BY 1
      ;;

      persist_for: "24 hours"
  }

  dimension: date {
    hidden:  yes
    type: date
    primary_key: yes
    }

  measure: instructor_count {
    label: "# Instructors on active courses"
    type: number
    sql: AVG(${TABLE}.instructor_count) ;;
    value_format_name: decimal_0
    hidden: yes
  }

}
