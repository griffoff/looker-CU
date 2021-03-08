include: "/views/cu_user_analysis/all_events.view"
include: "/views/cu_user_analysis/user_profile.view"

view: course_section_usage_facts {

  view_label: "Course Section Details"

  derived_table: {
    create_process: {
      sql_step:
      CREATE TRANSIENT TABLE IF NOT EXISTS cu_user_analysis.course_section_facts
      (
          course_key                     STRING NOT NULL PRIMARY KEY,
          users_with_activity_count      INT,
          instructors_with_activity_count INT,
          students_with_activity_count INT,
          mobile_user_count              INT,
          mobile_session_count           INT,
          total_session_count            INT,
          total_session_count_instructor INT,
          total_session_count_student    INT,
          days_with_activity_count       INT,
          user_days_with_activity_count  INT,
          total_active_time              FLOAT,
          total_active_time_instructor   FLOAT,
          total_active_time_student      FLOAT,
          latest_event_time              TIMESTAMP_TZ
      )
      ;;

      sql_step:
      SET latest = (SELECT MAX(latest_event_time)
                    FROM cu_user_analysis.course_section_facts)
      ;;

      sql_step: USE WAREHOUSE HEAVYDUTY ;;
      sql_step:
      MERGE INTO cu_user_analysis.course_section_facts
          USING (
              SELECT course_key
                   , COUNT(DISTINCT e.user_sso_guid)                                                       AS users_with_activity_count
                   , COUNT(DISTINCT CASE WHEN up.instructor THEN e.user_sso_guid END)                      AS instructors_with_activity_count
                   , COUNT(DISTINCT CASE WHEN NOT up.instructor THEN e.user_sso_guid END)                  AS students_with_activity_count
                   , COUNT(DISTINCT
                           CASE WHEN UPPER(product_platform) = 'MOBILE' THEN e.user_sso_guid END)          AS mobile_user_count
                   , COUNT(DISTINCT
                           CASE WHEN UPPER(product_platform) = 'MOBILE' THEN e.session_id END)             AS mobile_session_count
                   , COUNT(DISTINCT session_id)                                                            AS total_session_count
                   , COUNT(DISTINCT CASE WHEN up.instructor THEN session_id END)                           AS total_session_count_instructor
                   , COUNT(DISTINCT CASE WHEN NOT up.instructor THEN session_id END)                       AS total_session_count_student
                   , COUNT(DISTINCT event_time::DATE)                                                      AS days_with_activity_count
                   , COUNT(DISTINCT HASH(event_time::DATE, e.user_sso_guid))                               AS user_days_with_activity_count
                   , SUM(event_data:event_duration)                                                        AS total_active_time
                   , SUM(CASE WHEN up.instructor THEN event_data:event_duration END)                       AS total_active_time_instructor
                   , SUM(CASE WHEN NOT up.instructor THEN event_data:event_duration END)                   AS total_active_time_student
                   , MAX(event_time)                                                                       AS latest_event_time
              FROM ${all_events.SQL_TABLE_NAME} e
                   INNER JOIN ${user_profile.SQL_TABLE_NAME} up ON e.user_sso_guid = up.user_sso_guid
              WHERE (
                      TO_TIMESTAMP(e.session_id) > $latest
                      OR $latest IS NULL
                  )
                AND e.course_key IS NOT NULL
              GROUP BY 1
          ) new ON course_section_facts.course_key = new.course_key
          WHEN MATCHED THEN
              UPDATE
                  SET users_with_activity_count = new.users_with_activity_count
                      ,instructors_with_activity_count = new.instructors_with_activity_count
                      ,students_with_activity_count = new.students_with_activity_count
                      ,mobile_user_count = new.mobile_user_count
                      ,mobile_session_count = new.mobile_session_count
                      ,total_session_count = new.total_session_count
                      ,total_session_count_instructor = new.total_session_count_instructor
                      ,total_session_count_student = new.total_session_count_student
                      ,days_with_activity_count = new.days_with_activity_count
                      ,user_days_with_activity_count = new.user_days_with_activity_count
                      ,total_active_time = new.total_active_time
                      ,total_active_time_instructor = new.total_active_time_instructor
                      ,total_active_time_student = new.total_active_time_student
                      ,latest_event_time = new.latest_event_time
          WHEN NOT MATCHED THEN
              INSERT (course_key, users_with_activity_count, instructors_with_activity_count, students_with_activity_count,
                      mobile_user_count, mobile_session_count, total_session_count,
                      total_session_count_instructor, total_session_count_student, days_with_activity_count,
                      user_days_with_activity_count, total_active_time, total_active_time_instructor,
                      total_active_time_student, latest_event_time)
                  VALUES ( new.course_key, new.users_with_activity_count, new.instructors_with_activity_count, new.students_with_activity_count
                         , new.mobile_user_count, new.mobile_session_count, new.total_session_count
                         , new.total_session_count_instructor
                         , new.total_session_count_student, new.days_with_activity_count, new.user_days_with_activity_count
                         , new.total_active_time
                         , new.total_active_time_instructor, new.total_active_time_student, new.latest_event_time)
      ;;

      sql_step: USE WAREHOUSE LOOKER ;;

      sql_step:
      UNSET latest
      ;;

      sql_step:
      CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME} CLONE cu_user_analysis.course_section_facts
      ;;
    }

    datagroup_trigger: daily_refresh
  }

  dimension: course_key {
    primary_key: yes
    hidden: yes
  }

  dimension: users_with_activity_count {
    label: "# Users with Activity"
    type: number
    group_label: "Course User Counts"
    alias: [total_users_on_course]
    hidden: yes
  }
  dimension: students_with_activity_count {
    label: "# Students with Activity"
    type: number
    group_label: "Course User Counts"
  }
  dimension: instructors_with_activity_count {
    label: "# Instructors with Activity"
    type: number
    group_label: "Course User Counts"
  }
  dimension: total_session_count {
    label: "Total Sessions"
    type:number
    group_label: "Course User Counts"
    alias:[total_sessions_for_course]
  }
  dimension: total_sessions_for_course_per_user_tier {
    label: "Total Sessions For Course Per User (buckets)"
    type:tier
    group_label: "Course User Counts"
    tiers: [5, 10, 25, 50]
    style: integer
    sql: ${total_session_count} / ${users_with_activity_count} ;;
    }
  dimension: mobile_user_count {
    type:number
    group_label: "Mobile Usage"
    label:"# Mobile Users"
    description: "Number of people using the mobile app on this course"
    alias: [mobile_users]
    sql: COALESCE(${TABLE}.mobile_user_count, 0) ;;
  }
  dimension: mobile_users_tier {
    group_label: "Mobile Usage"
    label:"% Mobile Users (buckets)"
    description: "% people using the mobile app on this course"
    type:tier
    style: relational
    tiers: [0.05, 0.1, 0.25, 0.5, 0.75]
    sql:CASE WHEN ${users_with_activity_count} IS NULL OR ${users_with_activity_count} = 0 THEN 0 ELSE ${mobile_user_count} / ${users_with_activity_count} END;;
    value_format_name: percent_0
  }
  dimension_group: total_active_time_instructor {
    label: "of Instructor Activity"
    type: duration
    intervals: [second, minute, hour, day]
    sql_start: TO_TIMESTAMP(0);;
    sql_end: TO_TIMESTAMP(${TABLE}.total_active_time_instructor::INT) ;;
  }
  dimension_group: total_active_time_per_student {
    label: "of Activity per Student"
    type: duration
    intervals: [second, minute, hour, day]
    sql_start: TO_TIMESTAMP(0);;
    sql_end: TO_TIMESTAMP((${TABLE}.total_active_time_student / ${students_with_activity_count})::INT) ;;
  }

}
