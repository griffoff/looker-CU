include: "/views/cu_user_analysis/all_sessions.view"
include: "/views/cu_user_analysis/cohorts/cohorts.mobile_usage.view"

view: course_section_usage_facts {

  view_label: "Course / Section Details"

  derived_table: {
    sql:
    SELECT uc.*
      ,COALESCE(s.total_sessions, 0) as total_sessions_for_course
      ,COALESCE(m.mobile_users, 0) as mobile_users
      ,COALESCE(m.mobile_time, 0) as mobile_time
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
      ) s ON uc.course_key = s.course_key
    LEFT JOIN (
      SELECT course_key, COUNT(DISTINCT user_sso_guid) as mobile_users, SUM(duration) as mobile_time
      FROM ${mobile_usage.SQL_TABLE_NAME}
      GROUP BY 1
      ) m ON uc.course_key = m.course_key
      ;;
    persist_for: "24 hours"
  }

  dimension: course_key {
    primary_key: yes
    hidden: yes
  }

  dimension: total_users_on_course {type: number}
  dimension: total_sessions_for_course {type:number}
  dimension: mobile_users {type:number group_label: "Mobile Usage" label:"# Mobile Users" description: "Number of people using the mobile app on this course"}
  dimension: mobile_users_tier {
    group_label: "Mobile Usage" label:"# Mobile Users (buckets)" description: "Number of people using the mobile app on this course"
    type:tier
    style: relational
    tiers: [0.05, 0.1, 0.25, 0.5, 0.75]
    sql:${mobile_users} / ${total_users_on_course} ;;
    value_format_name: percent_0
    }

}
