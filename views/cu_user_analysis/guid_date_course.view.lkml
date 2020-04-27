explore: guid_date_course {}

view: guid_date_course {
  derived_table: {
    sql:
    WITH course_users AS (
    SELECT DISTINCT user_sso_guid, course_start_date::DATE AS course_start, course_end_date::DATE AS course_end
     FROM prod.cu_user_analysis.user_courses)

SELECT dim_date.datevalue as date, user_sso_guid, 'Courseware' AS content_type
FROM ${dim_date.SQL_TABLE_NAME} dim_date
         LEFT JOIN course_users ON dim_date.datevalue BETWEEN course_start AND course_end
WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
    ;;
    persist_for: "24 hours"
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}.USER_SSO_GUID ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: content_type {
    type: string
    sql: ${TABLE}.content_type ;;
  }

}
