explore: guid_date_course {hidden:no}

view: guid_date_course {
  derived_table: {
    sql:
    WITH course_users AS (
    SELECT DISTINCT user_sso_guid, course_key, instructor_guid, context_id
    ,LEAST(COALESCE(course_start_date, enrollment_date, activation_date)
          ,COALESCE(activation_date, enrollment_date, course_start_date)
          ,COALESCE(enrollment_date, course_start_date, activation_date))::date AS course_start
    ,LEAST(COALESCE(datediff(w,course_start_date,course_end_date),20),52) AS course_length
    ,LEAST(COALESCE(course_end_date,'2100-12-31'),DATEADD(w,course_length,course_start))::date AS course_end
    , COALESCE(LEAST(activation_date, DATEADD(D, 1 / 2 * course_length, course_start), DATEADD(D, 60, course_start)),DATEADD(D, 14, course_start)) AS unpaid_access_end
    , activation_date
     FROM prod.cu_user_analysis.user_courses
    )
    ,course_instructors AS (
    SELECT coalesce(hu.uid, s.linked_guid, course.instructor_guid) as user_sso_guid
    , course_key, min(course_start) as course_start, max(course_end) as course_end
    FROM course_users course
    left join prod.datavault.hub_coursesection h on course.context_id = h.context_id
    left join prod.datavault.link_user_coursesection l on h.hub_coursesection_key = l.hub_coursesection_key
    inner join prod.datavault.sat_user s on l.hub_user_key = s.hub_user_key and s.active and s.instructor
    inner join prod.datavault.hub_user hu on s.HUB_USER_KEY = hu.HUB_USER_KEY
    GROUP BY 1,2
    )
    ,all_users AS (
    SELECT user_sso_guid, course_start, course_end,'Student' AS user_type, activation_date, unpaid_access_end
    FROM course_users
    UNION
    SELECT user_sso_guid, course_start, course_end, 'Instructor' AS user_type, NULL AS activation_date, NULL AS unpaid_access_end
    FROM course_instructors
    )
    SELECT dim_date.datevalue as date, user_sso_guid, 'Courseware' AS content_type, user_type
      , CASE WHEN dim_date.datevalue >= activation_date THEN TRUE ELSE FALSE END AS paid_flag
      , CASE WHEN activation_date IS NULL AND dim_date.datevalue > unpaid_access_end THEN TRUE ELSE FALSE END AS expired_access_flag
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
    type: yesno
    sql: ${TABLE}.paid_flag ;;
  }

  dimension: expired_access_flag {
    type: yesno
    sql: ${TABLE}.expired_access_flag ;;
  }

}
