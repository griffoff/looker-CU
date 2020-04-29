explore: guid_date_course {}

view: guid_date_course {
  derived_table: {
    sql:
    WITH course_users AS (
    SELECT DISTINCT user_sso_guid, course_key, instructor_guid, LEAST(course_start_date::DATE, enrollment_date::date, activation_date::date) AS course_start
    ,least(course_end_date,DATEADD(w,20,course_start)) AS course_end, 'Student' AS user_type, activation_date
     FROM prod.cu_user_analysis.user_courses)

    ,course_instructors AS (
    SELECT instructor_guid as user_sso_guid, course_key, min(course_start) as course_start, max(course_end) as course_end, 'Instructor' AS user_type, NULL as activation_date
    FROM course_users
    GROUP BY 1,2)

    ,all_users AS (
    SELECT user_sso_guid, course_start, course_end, user_type, activation_date
    FROM course_users
    UNION
    SELECT user_sso_guid, course_start, course_end, user_type, activation_date
    FROM course_instructors)

SELECT dim_date.datevalue as date, user_sso_guid, 'Courseware' AS content_type, user_type, CASE WHEN dim_date.datevalue BETWEEN activation_date AND course_end THEN 'Paid' END AS paid_flag
FROM ${dim_date.SQL_TABLE_NAME} dim_date
         LEFT JOIN all_users ON dim_date.datevalue BETWEEN course_start AND course_end
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

  dimension: user_type {
    type: string
    sql: ${TABLE}.user_type ;;
  }

  dimension: paid_flag {
    type: string
    sql: ${TABLE}.paid_flag ;;
  }

}
