view: yru {
  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.YRU
        (
          date DATE
          ,users INT
          ,instructors INT
          ,students INT
        )
      ;;
      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.YRU_incremental
        AS
        WITH dates AS (
          SELECT d.datevalue
          FROM ${dim_date.SQL_TABLE_NAME} d
          WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.YRU)
          AND d.datevalue < CURRENT_DATE()
        )
        ,all_events_merged AS (
          SELECT DISTINCT e.user_sso_guid AS merged_guid, CASE WHEN e.user_type = 'Instructor' then TRUE ELSE FALSE END AS instructor, e.date as event_time
          FROM ${guid_date_active.SQL_TABLE_NAME} e
        )
        ,first_mutation AS (
          SELECT DISTINCT COALESCE(e.linked_guid, hu.uid) AS merged_guid, e.instructor, e.rsrc_timestamp::date AS event_time
          FROM prod.datavault.hub_user hu
          INNER JOIN prod.datavault.SAT_USER_V2 e ON hu.hub_user_key = e.hub_user_key AND e._LATEST
          LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
          WHERE merged_guid IS NOT NULL
          AND event_time NOT IN ('2018-08-03','2019-08-22')
          AND ui.hub_user_key IS NULL
        )
        ,users AS (
        SELECT *
        FROM all_events_merged
        UNION
        SELECT *
        FROM first_mutation
        )
        SELECT
            d.datevalue AS date
            ,COUNT(DISTINCT CASE WHEN instructor THEN u.merged_guid END) AS instructors
            ,COUNT(DISTINCT CASE WHEN NOT instructor OR instructor IS NULL THEN u.merged_guid END) AS students
            ,COUNT(DISTINCT u.merged_guid) AS users
        FROM dates d
        INNER JOIN users u ON u.event_time <= d.datevalue
          AND u.event_time > DATEADD(DAY, -365, d.datevalue)
        GROUP BY 1
      ;;
      sql_step:
      INSERT INTO LOOKER_SCRATCH.YRU
      SELECT date, users, instructors, students
      FROM looker_scratch.YRU_incremental
      ;;
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.YRU;;

      }
      datagroup_trigger: daily_refresh
    }

    dimension: date {
      hidden: yes
      type: date
      primary_key: yes
    }

    dimension_group: date {
      hidden: yes
      label: "Calendar"
      type:time
      timeframes: [raw,date,month,year]
    }

    dimension: max_date {
      hidden: yes
      type: date
      sql: (SELECT MAX(date) FROM LOOKER_SCRATCH.yru);;
    }

    measure: yru {
      group_label: "Registered Users"
      label: "# Total YRU"
      description: "Users with an event or change to their user profile in the last 365 days, relative to the filtered date (max over period if not reported on a single day)"
      type: number
      sql: MAX(${TABLE}.users) ;;
      value_format_name: decimal_0
    }

    measure: yru_instructors {
      group_label: "Registered Users"
      label: "# YRU Instructors"
      description: "Instructors with an event or change to their user profile in the last 365 days, relative to the filtered date (max over period if not reported on a single day)"
      type: number
      sql: MAX(${TABLE}.instructors) ;;
      value_format_name: decimal_0
    }

    measure: yru_students {
      group_label: "Registered Users"
      label: "# YRU Students"
      description: "Students with an event or change to their user profile in the last 365 days, relative to the filtered date (max over period if not reported on a single day)"
      type: number
      sql: MAX(${TABLE}.students) ;;
      value_format_name: decimal_0
    }
  }
# view: active_users_platforms {
#
#   view_label: "User Counts"
#
#   parameter: offset {
#     description: "Offset (days/weeks/months depending on metric) to use when comparing vs prior year, can be positive to move prior year values forwards or negative to shift prior year backwards"
#     type: number
#     default_value: "0"
#   }
#
#   derived_table: {
#     sql:  SELECT DISTINCT COALESCE(productplatform, 'UNKNOWN') as product_platform
#     FROM ${guid_platform_date_active.SQL_TABLE_NAME} ;;
#   }
#
#   dimension: product_platform {
#     label: "Product Platform"
#     hidden: yes
#   }
#
#   dimension: product_platform_clean {
#     sql: CASE
#           WHEN ${product_platform} ILIKE 'cnow' THEN 'CNOW'
#           WHEN ${product_platform} ILIKE 'aplia' THEN 'Aplia'
#           WHEN ${product_platform} = 'imilac'  THEN 'IMILAC'
#           WHEN ${product_platform} = 'q4'  THEN 'Q4'
#           WHEN ${product_platform} ILIKE '%dashboard%' THEN 'CU Dashboard'
#           WHEN ${product_platform} ILIKE 'mobile-app' THEN 'Mobile'
#           WHEN ${product_platform} ILIKE '%gradebook%' THEN 'MindTap - Gradebook'
#           WHEN ${product_platform} ILIKE 'mindtap' OR ${product_platform} ILIKE 'mt%' THEN 'MindTap'
#           WHEN ${product_platform} ILIKE '%side-bar%'  OR ${product_platform} ILIKE '%sidebar%' THEN 'CU Sidebar'
#           WHEN ${product_platform} ILIKE 'WA' OR ${product_platform} ILIKE 'webassign' THEN 'WebAssign'
#           WHEN ${product_platform} ILIKE 'natgeo%' THEN 'National Geographic'
#           WHEN ${product_platform} ILIKE 'ecomm%'  THEN 'Ecommerce'
#           WHEN ${product_platform} ='LO' OR ${product_platform} = 'LO-OPENNOW' THEN 'Learning Objects'
#
#         ELSE ${product_platform} END
#
#     ;;
#     description: "Works with DAU/WAU/MAU measures"
#
#     label: "Product Platform"
#
# #     group_label: "Active Users"
#
#   }
#
# }



# view: dau {
#   derived_table: {
#     create_process: {
#       sql_step:
#         CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.dau
#         (
#           date DATE
#           ,product_platform STRING
#           ,users INT
#           ,instructors INT
#           ,students INT
#           ,active_course_instructors INT
#           ,paid_active_users INT
#           ,paid_inactive_users INT
#           ,total_users INT
#           ,total_instructors INT
#           ,total_students INT
#           ,total_active_course_instructors INT
#           ,total_paid_active_users INT
#           ,total_paid_inactive_users INT
#         )
#       ;;
#       sql_step:
#         CREATE OR REPLACE TEMPORARY TABLE looker_scratch.dau_incremental
#         AS
#         WITH dates AS (
#           SELECT d.datevalue
#           FROM ${dim_date.SQL_TABLE_NAME} d
#           WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.dau)
#           AND d.datevalue > (SELECT MIN(date) FROM ${guid_platform_date_active.SQL_TABLE_NAME})
#           AND d.datevalue < CURRENT_DATE()
#         )
#         ,paid AS (
#         SELECT p.*
#         FROM dates d
#         INNER JOIN ${guid_date_paid.SQL_TABLE_NAME} p ON d.datevalue = p.date AND p.paid_content_rank = 1
#         )
#         ,active_course_instructors AS (
#         SELECT c.date, c.user_sso_guid
#         FROM dates d
#         INNER JOIN ${guid_date_course.SQL_TABLE_NAME} c ON d.datevalue = c.date AND c.user_type = 'Instructor'
#         )
#         ,active AS (
#         SELECT *
#         FROM ${guid_platform_date_active.SQL_TABLE_NAME} g
#         WHERE g.date BETWEEN DATEADD(DAY, -1, (SELECT MIN(datevalue) FROM dates)) AND (SELECT MAX(datevalue) FROM dates)
#         )
#         ,users AS (
#         SELECT user_sso_guid
#         FROM paid
#         UNION
#         SELECT user_sso_guid
#         FROM active
#         )
#         SELECT
#             d.datevalue AS date
#             ,COALESCE(au.productplatform, 'UNKNOWN') as product_platform
#             ,COUNT(DISTINCT CASE WHEN instructor THEN au.user_sso_guid END) AS instructors
#             ,COUNT(DISTINCT CASE WHEN NOT instructor OR instructor IS NULL THEN au.user_sso_guid END) AS students
#             ,COUNT(DISTINCT au.user_sso_guid) AS users
#             ,COUNT(DISTINCT CASE WHEN instructor AND c.user_sso_guid IS NOT NULL THEN au.user_sso_guid END) AS active_course_instructors
#             ,COUNT(DISTINCT CASE WHEN paid_flag THEN au.user_sso_guid END) AS paid_active_users
#             ,COUNT(DISTINCT CASE WHEN (paid_flag AND au.user_sso_guid IS NULL) THEN p.user_sso_guid END) AS paid_inactive_users
#         FROM dates d
#         CROSS JOIN users u
#         LEFT JOIN active AS au ON u.user_sso_guid = au.user_sso_guid
#           AND au.date <= d.datevalue
#           AND au.date > DATEADD(DAY, -1, d.datevalue)
#         LEFT JOIN paid p on d.datevalue = p.date AND u.user_sso_guid = p.user_sso_guid
#         LEFT JOIN active_course_instructors c ON d.datevalue = c.date AND u.user_sso_guid = c.user_sso_guid
#         GROUP BY 1, ROLLUP(2)
#         ;;
#       sql_step:
#       INSERT INTO LOOKER_SCRATCH.dau
#       SELECT date, product_platform, users, instructors, students, active_course_instructors, paid_active_users, paid_inactive_users, NULL, NULL, NULL, NULL, NULL, NULL
#       FROM looker_scratch.dau_incremental
#       WHERE product_platform != 'UNKNOWN';;
#       sql_step:
#         MERGE INTO LOOKER_SCRATCH.dau a
#         USING looker_scratch.dau_incremental t ON a.date = t.date AND t.product_platform IS NULL --join to the result of the ROLLUP function i.e. total for all platforms
#         WHEN MATCHED THEN UPDATE
#           SET a.total_users = t.users
#             ,a.total_instructors = t.instructors
#             ,a.total_students = t.students
#             ,a.total_active_course_instructors = t.active_course_instructors
#             ,a.total_paid_active_users = t.paid_active_users
#             ,a.total_paid_inactive_users = t.paid_inactive_users
#       ;;
#       sql_step:
#       CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
#       CLONE LOOKER_SCRATCH.dau;;
#
#       }
#       datagroup_trigger: daily_refresh
#     }
#
#
#
#     dimension: pk {
#       primary_key: yes
#       sql: hash(date, product_platform) ;;
#       hidden: yes
#     }
#
#     dimension: date {
#       hidden: yes
#       type: date
#     }
#
#     dimension: max_date {
#       hidden: yes
#       type: date
#       sql: (SELECT MAX(date) FROM LOOKER_SCRATCH.dau);;
#     }
#
#
#     dimension: product_platform {
#       hidden: yes
#       label: "Product Platform"
#     }
#
#     dimension: au {
#       hidden: yes
#       label: "Active Users"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query or active_users_platforms.product_platform_clean._in_query %}
#         ${TABLE}.users
#       {% else %}
#         ${TABLE}.total_users
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_instructors {
#       hidden: yes
#       label: "Active Instructors"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.instructors
#       {% else %}
#         ${TABLE}.total_instructors
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_students {
#       hidden: yes
#       label: "Active Students"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.students
#       {% else %}
#         ${TABLE}.total_students
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_paid_active_users {
#       hidden: yes
#       label: "Paid Active Users"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.paid_active_users
#       {% else %}
#         ${TABLE}.total_paid_active_users
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_active_course_instructors {
#       hidden: yes
#       label: "Active Instructors (Current Course)"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.active_course_instructors
#       {% else %}
#         ${TABLE}.total_active_course_instructors
#       {% endif %}
#       ;;
#     }
#
#     measure: dau {
#       group_label: "Active Users"
#       label: "DAU"
#       description: "Users with an event in the last 1 day, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: dau_instructor {
#       group_label: "Active Users"
#       label: "DAU Instructor"
#       description: "Instructors with an event in the last 1 day, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_instructors}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: dau_students {
#       group_label: "Active Users"
#       label: "DAU Students"
#       description: "Students with an event in the last 1 day, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_students}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: dau_paid_active_users {
#       group_label: "Active Users"
#       label: "DAU Paid"
#       description: "Paid users with an event in the last 1 day, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_paid_active_users}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: dau_active_course_instructors {
#       group_label: "Active Users"
#       label: "DAU Instructor (Active Course)"
#       description: "Instructors (with an active course) with an event in the last 1 day, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_active_course_instructors}) ;;
#       value_format_name: decimal_0
#     }
#
#   }
#
# view: wau {
#   derived_table: {
#     create_process: {
#       sql_step:
#         CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.wau
#         (
#           date DATE
#           ,product_platform STRING
#           ,users INT
#           ,instructors INT
#           ,students INT
#           ,active_course_instructors INT
#           ,paid_active_users INT
#           ,paid_inactive_users INT
#           ,total_users INT
#           ,total_instructors INT
#           ,total_students INT
#           ,total_active_course_instructors INT
#           ,total_paid_active_users INT
#           ,total_paid_inactive_users INT
#         )
#       ;;
#       sql_step:
#         CREATE OR REPLACE TEMPORARY TABLE looker_scratch.wau_incremental
#         AS
#         WITH dates AS (
#           SELECT d.datevalue
#           FROM ${dim_date.SQL_TABLE_NAME} d
#           WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.wau)
#           AND d.datevalue > (SELECT MIN(date) FROM ${guid_platform_date_active.SQL_TABLE_NAME})
#           AND d.datevalue < CURRENT_DATE()
#         )
#         ,paid AS (
#         SELECT p.*
#         FROM dates d
#         INNER JOIN ${guid_date_paid.SQL_TABLE_NAME} p ON d.datevalue = p.date AND p.paid_content_rank = 1
#         )
#         ,active_course_instructors AS (
#         SELECT c.date, c.user_sso_guid
#         FROM dates d
#         INNER JOIN ${guid_date_course.SQL_TABLE_NAME} c ON d.datevalue = c.date AND c.user_type = 'Instructor'
#         )
#         ,active AS (
#         SELECT *
#         FROM ${guid_platform_date_active.SQL_TABLE_NAME} g
#         WHERE g.date BETWEEN DATEADD(DAY, -7, (SELECT MIN(datevalue) FROM dates)) AND (SELECT MAX(datevalue) FROM dates)
#         )
#         ,users AS (
#         SELECT user_sso_guid
#         FROM paid
#         UNION
#         SELECT user_sso_guid
#         FROM active
#         )
#         SELECT
#             d.datevalue AS date
#             ,COALESCE(au.productplatform, 'UNKNOWN') as product_platform
#             ,COUNT(DISTINCT CASE WHEN instructor THEN au.user_sso_guid END) AS instructors
#             ,COUNT(DISTINCT CASE WHEN NOT instructor OR instructor IS NULL THEN au.user_sso_guid END) AS students
#             ,COUNT(DISTINCT au.user_sso_guid) AS users
#             ,COUNT(DISTINCT CASE WHEN instructor AND c.user_sso_guid IS NOT NULL THEN au.user_sso_guid END) AS active_course_instructors
#             ,COUNT(DISTINCT CASE WHEN paid_flag THEN au.user_sso_guid END) AS paid_active_users
#             ,COUNT(DISTINCT CASE WHEN (paid_flag AND au.user_sso_guid IS NULL) THEN p.user_sso_guid END) AS paid_inactive_users
#         FROM dates d
#         CROSS JOIN users u
#         LEFT JOIN active AS au ON u.user_sso_guid = au.user_sso_guid
#           AND au.date <= d.datevalue
#           AND au.date > DATEADD(DAY, -7, d.datevalue)
#         LEFT JOIN paid p on d.datevalue = p.date AND u.user_sso_guid = p.user_sso_guid
#         LEFT JOIN active_course_instructors c ON d.datevalue = c.date AND u.user_sso_guid = c.user_sso_guid
#         GROUP BY 1, ROLLUP(2)
#         ;;
#       sql_step:
#       INSERT INTO LOOKER_SCRATCH.wau
#       SELECT date, product_platform, users, instructors, students, active_course_instructors, paid_active_users, paid_inactive_users, NULL, NULL, NULL, NULL, NULL, NULL
#       FROM looker_scratch.wau_incremental
#       WHERE product_platform != 'UNKNOWN';;
#       sql_step:
#         MERGE INTO LOOKER_SCRATCH.wau a
#         USING looker_scratch.wau_incremental t ON a.date = t.date AND t.product_platform IS NULL --join to the result of the ROLLUP function i.e. total for all platforms
#         WHEN MATCHED THEN UPDATE
#           SET a.total_users = t.users
#             ,a.total_instructors = t.instructors
#             ,a.total_students = t.students
#             ,a.total_active_course_instructors = t.active_course_instructors
#             ,a.total_paid_active_users = t.paid_active_users
#             ,a.total_paid_inactive_users = t.paid_inactive_users
#       ;;
#       sql_step:
#       CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
#       CLONE LOOKER_SCRATCH.wau;;
#
#       }
#       datagroup_trigger: daily_refresh
#     }
#
#
#
#     dimension: pk {
#       primary_key: yes
#       sql: hash(date, product_platform) ;;
#       hidden: yes
#     }
#
#     dimension: date {
#       hidden: yes
#       type: date
#     }
#
#     dimension: max_date {
#       hidden: yes
#       type: date
#       sql: (SELECT MAX(date) FROM LOOKER_SCRATCH.wau);;
#     }
#
#
#     dimension: product_platform {
#       hidden: yes
#       label: "Product Platform"
#     }
#
#     dimension: au {
#       hidden: yes
#       label: "Active Users"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query or active_users_platforms.product_platform_clean._in_query %}
#         ${TABLE}.users
#       {% else %}
#         ${TABLE}.total_users
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_instructors {
#       hidden: yes
#       label: "Active Instructors"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.instructors
#       {% else %}
#         ${TABLE}.total_instructors
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_students {
#       hidden: yes
#       label: "Active Students"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.students
#       {% else %}
#         ${TABLE}.total_students
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_paid_active_users {
#       hidden: yes
#       label: "Paid Active Users"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.paid_active_users
#       {% else %}
#         ${TABLE}.total_paid_active_users
#       {% endif %}
#       ;;
#     }
#
#     dimension: au_active_course_instructors {
#       hidden: yes
#       label: "Active Instructors (Current Course)"
#       type: number
#       sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.active_course_instructors
#       {% else %}
#         ${TABLE}.total_active_course_instructors
#       {% endif %}
#       ;;
#     }
#
#     measure: wau {
#       group_label: "Active Users"
#       label: "WAU"
#       description: "Users with an event in the last 7 days, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: wau_instructors {
#       group_label: "Active Users"
#       label: "WAU Instructors"
#       description: "Instructors with an event in the last 7 days, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_instructors}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: wau_students {
#       group_label: "Active Users"
#       label: "WAU Students"
#       description: "Students with an event in the last 7 days, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_students}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: wau_paid_active_users {
#       group_label: "Active Users"
#       label: "WAU Paid"
#       description: "Paid Users with an event in the last 7 days, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_paid_active_users}) ;;
#       value_format_name: decimal_0
#     }
#
#     measure: wau_active_course_instructors {
#       group_label: "Active Users"
#       label: "WAU Instructor (Active Course)"
#       description: "Instructors (with an active course) with an event in the last 7 days, relative to the filtered date (average if not reported on a single day)"
#       type: number
#       sql: AVG(${au_active_course_instructors}) ;;
#       value_format_name: decimal_0
#     }
#
#   }
#
#
# view: mau {
#   derived_table: {
#     create_process: {
#       sql_step:
#         CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.mau
#         (
#           date DATE
#           ,product_platform STRING
#           ,users INT
#           ,instructors INT
#           ,students INT
#           ,active_course_instructors INT
#           ,paid_active_users INT
#           ,paid_inactive_users INT
#           ,total_users INT
#           ,total_instructors INT
#           ,total_students INT
#           ,total_active_course_instructors INT
#           ,total_paid_active_users INT
#           ,total_paid_inactive_users INT
#         )
#       ;;
#       sql_step:
#         CREATE OR REPLACE TEMPORARY TABLE looker_scratch.mau_incremental
#         AS
#         WITH dates AS (
#           SELECT d.datevalue
#           FROM ${dim_date.SQL_TABLE_NAME} d
#           WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.mau)
#           AND d.datevalue > (SELECT MIN(date) FROM ${guid_platform_date_active.SQL_TABLE_NAME})
#           AND d.datevalue < CURRENT_DATE()
#         )
#         ,paid AS (
#         SELECT p.*
#         FROM dates d
#         INNER JOIN ${guid_date_paid.SQL_TABLE_NAME} p ON d.datevalue = p.date AND p.paid_content_rank = 1
#         )
#         ,active_course_instructors AS (
#         SELECT c.date, c.user_sso_guid
#         FROM dates d
#         INNER JOIN ${guid_date_course.SQL_TABLE_NAME} c ON d.datevalue = c.date AND c.user_type = 'Instructor'
#         )
#         ,active AS (
#         SELECT *
#         FROM ${guid_platform_date_active.SQL_TABLE_NAME} g
#         WHERE g.date BETWEEN DATEADD(DAY, -30, (SELECT MIN(datevalue) FROM dates)) AND (SELECT MAX(datevalue) FROM dates)
#         )
#         ,users AS (
#         SELECT user_sso_guid
#         FROM paid
#         UNION
#         SELECT user_sso_guid
#         FROM active
#         )
#         SELECT
#             d.datevalue AS date
#             ,COALESCE(au.productplatform, 'UNKNOWN') as product_platform
#             ,COUNT(DISTINCT CASE WHEN instructor THEN au.user_sso_guid END) AS instructors
#             ,COUNT(DISTINCT CASE WHEN NOT instructor OR instructor IS NULL THEN au.user_sso_guid END) AS students
#             ,COUNT(DISTINCT au.user_sso_guid) AS users
#             ,COUNT(DISTINCT CASE WHEN instructor AND c.user_sso_guid IS NOT NULL THEN au.user_sso_guid END) AS active_course_instructors
#             ,COUNT(DISTINCT CASE WHEN paid_flag THEN au.user_sso_guid END) AS paid_active_users
#             ,COUNT(DISTINCT CASE WHEN (paid_flag AND au.user_sso_guid IS NULL) THEN p.user_sso_guid END) AS paid_inactive_users
#         FROM dates d
#         CROSS JOIN users u
#         LEFT JOIN active AS au ON u.user_sso_guid = au.user_sso_guid
#           AND au.date <= d.datevalue
#           AND au.date > DATEADD(DAY, -30, d.datevalue)
#         LEFT JOIN paid p on d.datevalue = p.date AND u.user_sso_guid = p.user_sso_guid
#         LEFT JOIN active_course_instructors c ON d.datevalue = c.date AND u.user_sso_guid = c.user_sso_guid
#         GROUP BY 1, ROLLUP(2)
#         ;;
#       sql_step:
#       INSERT INTO LOOKER_SCRATCH.mau
#       SELECT date, product_platform, users, instructors, students, active_course_instructors, paid_active_users, paid_inactive_users, NULL, NULL, NULL, NULL, NULL, NULL
#       FROM looker_scratch.mau_incremental
#       WHERE product_platform != 'UNKNOWN';;
#       sql_step:
#         MERGE INTO LOOKER_SCRATCH.mau a
#         USING looker_scratch.mau_incremental t ON a.date = t.date AND t.product_platform IS NULL --join to the result of the ROLLUP function i.e. total for all platforms
#         WHEN MATCHED THEN UPDATE
#           SET a.total_users = t.users
#             ,a.total_instructors = t.instructors
#             ,a.total_students = t.students
#             ,a.total_active_course_instructors = t.active_course_instructors
#             ,a.total_paid_active_users = t.paid_active_users
#             ,a.total_paid_inactive_users = t.paid_inactive_users
#       ;;
#       sql_step:
#       CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
#       CLONE LOOKER_SCRATCH.mau;;
#
#       }
#        datagroup_trigger: daily_refresh
#     }
#
#
#
#   dimension: pk {
#     primary_key: yes
#     sql: hash(date, product_platform) ;;
#     hidden: yes
#   }
#
#   dimension: date {
#     hidden: yes
#     type: date
#   }
#
#   dimension: max_date {
#     hidden: yes
#     type: date
#     sql: (SELECT MAX(date) FROM LOOKER_SCRATCH.mau);;
#   }
#
#
#   dimension: product_platform {
#     hidden: yes
#     label: "Product Platform"
#   }
#
#   dimension: au {
#     hidden: yes
#     label: "Active Users"
#     type: number
#     sql:
#       {% if active_users_platforms.product_platform._in_query or active_users_platforms.product_platform_clean._in_query %}
#         ${TABLE}.users
#       {% else %}
#         ${TABLE}.total_users
#       {% endif %}
#       ;;
#   }
#
#   dimension: au_instructors {
#     hidden: yes
#     label: "Active Instructors"
#     type: number
#     sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.instructors
#       {% else %}
#         ${TABLE}.total_instructors
#       {% endif %}
#       ;;
#   }
#
#   dimension: au_students {
#     hidden: yes
#     label: "Active Students"
#     type: number
#     sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.students
#       {% else %}
#         ${TABLE}.total_students
#       {% endif %}
#       ;;
#   }
#
#   dimension: au_paid_active_users {
#     hidden: yes
#     label: "Paid Active Users"
#     type: number
#     sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.paid_active_users
#       {% else %}
#         ${TABLE}.total_paid_active_users
#       {% endif %}
#       ;;
#   }
#
#   dimension: au_active_course_instructors {
#     hidden: yes
#     label: "Active Instructors (Current Course)"
#     type: number
#     sql:
#       {% if active_users_platforms.product_platform._in_query %}
#         ${TABLE}.active_course_instructors
#       {% else %}
#         ${TABLE}.total_active_course_instructors
#       {% endif %}
#       ;;
#   }
#
#   measure: mau {
#     group_label: "Active Users"
#     label: "MAU"
#     description: "Users with an event in the last 30 days, relative to the filtered date  (average if not reported on a single day)"
#     type: number
#     sql: AVG(${au}) ;;
#     value_format_name: decimal_0
#   }
#
#   measure: mau_instructors {
#     group_label: "Active Users"
#     label: "MAU Instructors"
#     description: "Instructors with an event in the last 30 days, relative to the filtered date (average if not reported on a single day)"
#     type: number
#     sql: AVG(${au_instructors}) ;;
#     value_format_name: decimal_0
#   }
#
#   measure: mau_students {
#     group_label: "Active Users"
#     label: "MAU Students"
#     description: "Students with an event in the last 30 days, relative to the filtered date (average if not reported on a single day)"
#     type: number
#     sql: AVG(${au_students}) ;;
#     value_format_name: decimal_0
#   }
#
#   measure: mau_paid_active_users {
#     group_label: "Active Users"
#     label: "MAU Paid"
#     description: "Paid Users with an event in the last 30 days, relative to the filtered date (average if not reported on a single day)"
#     type: number
#     sql: AVG(${au_paid_active_users}) ;;
#     value_format_name: decimal_0
#   }
#
#   measure: mau_active_course_instructors {
#     group_label: "Active Users"
#     label: "MAU Instructor (Active Course)"
#     description: "Instructors (with an active course) with an event in the last 30 days, relative to the filtered date (average if not reported on a single day)"
#     type: number
#     sql: AVG(${au_active_course_instructors}) ;;
#     value_format_name: decimal_0
#   }
#
# }
