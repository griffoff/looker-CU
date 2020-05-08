explore: daily_digital_users {hidden:no}
view: daily_digital_users {

  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.daily_digital_users
        (
          date DATE
          ,courseware_users INT
          ,courseware_instructors INT
          ,ebook_users INT
          ,cu_only_users INT
          ,trial_cu_only_users INT
          ,digital_users INT
        )
      ;;
      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.daily_digital_users_incremental
        AS
        WITH dates AS (
          SELECT d.datevalue
          FROM ${dim_date.SQL_TABLE_NAME} d
          WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.daily_digital_users)
          AND d.datevalue < CURRENT_DATE()
        )
        ,courseware_users AS (
          SELECT c.date, c.user_sso_guid, c.content_type, c. user_type
          FROM ${guid_date_course.SQL_TABLE_NAME} c
          INNER JOIN dates d on c.date = d.datevalue
          WHERE c.expired_access_flag = FALSE
        )
        ,ebook_users AS (
          SELECT e.date, e.user_sso_guid, e.content_type
          FROM ${guid_date_ebook.SQL_TABLE_NAME} e
          INNER JOIN dates d on e.date = d.datevalue
          LEFT JOIN courseware_users c ON e.date = c.date AND e.user_sso_guid = c.user_sso_guid
          WHERE c.user_sso_guid IS NULL
        )
        ,cu_only_users AS (
          SELECT s.date, s.user_sso_guid, s.content_type
          FROM ${guid_date_subscription.SQL_TABLE_NAME} s
          INNER JOIN dates d on s.date = d.datevalue
          LEFT JOIN courseware_users c ON s.date = c.date AND s.user_sso_guid = c.user_sso_guid
          LEFT JOIN ebook_users e ON e.date = s.date AND e.user_sso_guid = s.user_sso_guid
          WHERE c.user_sso_guid IS NULL AND e.user_sso_guid IS NULL
        )
        ,all_users AS (
          SELECT date, user_sso_guid, content_type, user_type FROM courseware_users
          UNION ALL
          SELECT date, user_sso_guid, content_type, NULL as user_type FROM ebook_users
          UNION ALL
          SELECT date, user_sso_guid, content_type, NULL as user_type FROM cu_only_users
        )
      SELECT
        date
        ,COUNT(DISTINCT CASE WHEN content_type = 'Courseware' AND user_type = 'Student' THEN user_sso_guid END) AS courseware_users
        ,COUNT(DISTINCT CASE WHEN content_type = 'Courseware' AND user_type = 'Instructor' THEN user_sso_guid END) AS courseware_instructors
        ,COUNT(DISTINCT CASE WHEN content_type = 'eBook' THEN user_sso_guid END) AS ebook_users
        ,COUNT(DISTINCT CASE WHEN content_type = 'Full Access CU Subscription' THEN user_sso_guid END) AS cu_only_users
        ,COUNT(DISTINCT CASE WHEN content_type = 'Trial CU Subscription' THEN user_sso_guid END) AS trial_cu_only_users
        ,COUNT(DISTINCT CASE WHEN (user_type = 'Student' OR user_type IS NULL) AND content_type <> 'Trial CU Subscription' THEN user_sso_guid END) AS digital_users
      FROM dates d
      INNER JOIN all_users a ON d.datevalue = a.date
      GROUP BY 1
      ;;
      sql_step:
      INSERT INTO LOOKER_SCRATCH.daily_digital_users
      SELECT date, courseware_users, courseware_instructors, ebook_users, cu_only_users, trial_cu_only_users, digital_users
      FROM looker_scratch.daily_digital_users_incremental
      ;;
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.daily_digital_users ;;
      }
      datagroup_trigger: daily_refresh
    }



    dimension: date {
      hidden:  yes
      type: date
      primary_key: yes}

  dimension: max_date {
    hidden: yes
    type: date
    sql: (SELECT MAX(date) FROM LOOKER_SCRATCH.daily_digital_users);;
  }

    measure: courseware_users {
      label: "# Courseware Student Users"
      description: "# Students enrolled in an active course (if more than one day is included in filter, this shows the average over the chosen period)"
      type: number
      sql: AVG(${TABLE}.courseware_users) ;;
      value_format_name: decimal_0
      hidden:  yes
    }

    measure: courseware_instructors {
      label: "# Digital Instructors (Active Course)"
      description: "# Instructors with active courses (if more than one day is included in filter, this shows the average over the chosen period)"
      type: number
      sql: AVG(${TABLE}.courseware_instructors) ;;
      value_format_name: decimal_0
    }

  measure: ebook_users {
    label: "# eBook Only Student Users"
    description: "# Users with access to an eBook but not enrolled in a course (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.ebook_users) ;;
    value_format_name: decimal_0
    hidden:  yes
  }

  measure: cu_only_users {
    label: "# Full Access CU Users, no provisions"
    description: "# Users with a full access CU subscriptions but not enrolled in a course or with access to an eBook (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.cu_only_users) ;;
    value_format_name: decimal_0
    hidden:  yes
  }

  measure: trial_cu_only_users {
    label: "# Trial Access CU Users, no provisions"
    description: "# Users with a trial access CU subscriptions but not enrolled in a course or with access to an eBook (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.trial_cu_only_users) ;;
    value_format_name: decimal_0
  }

  measure: digital_users {
    label: "# Digital Student Users"
    description: "# Users enrolled in an active course, with access to an eBook, or with a full access CU subscription and no provisions (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.digital_users) ;;
    value_format_name: decimal_0
  }


  }
