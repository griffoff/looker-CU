view: active_users_platforms {

  view_label: "User Activity Counts"

  derived_table: {
    sql:  SELECT DISTINCT COALESCE(productplatform, 'UNKNOWN') as product_platform
    FROM ${guid_platform_date_active.SQL_TABLE_NAME} ;;
  }

  dimension: product_platform {
    label: "Product Platform"
    hidden: yes
  }

  dimension: product_platform_clean {
    sql: CASE
          WHEN ${product_platform} ILIKE '%cnow%' THEN 'CNOW'
          WHEN ${product_platform} ILIKE '%aplia%' THEN 'Aplia'
          WHEN ${product_platform} ILIKE '%dashboard%' THEN 'CU Dashboard'
          WHEN ${product_platform} ILIKE '%gradebook%' THEN 'Gradebook MT'
          WHEN ${product_platform} ILIKE '%mindtap%' OR ${product_platform} ILIKE '%mt%' THEN 'MindTap'
          WHEN ${product_platform} ILIKE '%side-bar%'  OR ${product_platform} ILIKE '%sidebar%' THEN 'CU Sidebar'
          WHEN ${product_platform} ILIKE '%WA%' OR ${product_platform} ILIKE '%webassign%' THEN 'WebAssign'
          WHEN ${product_platform} ILIKE '%natgeo%' THEN 'National Geographic'
          WHEN ${product_platform} ILIKE '%ecomm%'  THEN 'Ecommerce'
          WHEN ${product_platform} ='LO' OR ${product_platform} = 'LO-OPENNOW' THEN 'Learning Objectives'
        ELSE ${product_platform} END

    ;;
    label: "Product Platform"
  }

}



view: dau {
  extends: [au]

  parameter: days {default_value: "1"}
  parameter: view_name {default_value: "dau"}


  measure: dau {
    label: "DAU"
    description: "Daily Active Users (average if not reported on a single day)"
    type: number
    sql: AVG(${au}) ;;
    value_format_name: decimal_0
  }

  measure: dau_instructor {
    label: "DAU Instructor"
    description: "Daily Active Instructors (average if not reported on a single day)"
    type: number
    sql: AVG(${au_instructors}) ;;
    value_format_name: decimal_0
  }

  measure: dau_students {
    label: "DAU Students"
    description: "Daily Active Students (average if not reported on a single day)"
    type: number
    sql: AVG(${au_students}) ;;
    value_format_name: decimal_0
  }

}

view: wau {
  extends: [au]

  parameter: days {default_value: "7"}
  parameter: view_name {default_value: "wau"}


  measure: wau {
    label: "WAU"
    description: "Weekly Active Users (average if not reported on a single day)"
    type: number
    sql: AVG(${au}) ;;
    value_format_name: decimal_0
  }

  measure: wau_instructors {
    label: "WAU Instructors"
    description: "Weekly Active Instructors (average if not reported on a single day)"
    type: number
    sql: AVG(${au_instructors}) ;;
    value_format_name: decimal_0
  }

  measure: wau_students {
    label: "WAU Students"
    description: "Weekly Active Students (average if not reported on a single day)"
    type: number
    sql: AVG(${au_students}) ;;
    value_format_name: decimal_0
  }
}

view: mau {
  extends: [au]

  parameter: days {default_value: "30"}
  parameter: view_name {default_value: "mau"}

  measure: mau {
    label: "MAU"
    description: "Monthly Active Users (average if not reported on a single day)"
    type: number
    sql: AVG(${au}) ;;
    value_format_name: decimal_0
  }

  measure: mau_instructors {
    label: "MAU Instructors"
    description: "Monthly Active Instructors (average if not reported on a single day)"
    type: number
    sql: AVG(${au_instructors}) ;;
    value_format_name: decimal_0
  }

  measure: mau_students {
    label: "MAU Students"
    description: "Monthly Active Students (average if not reported on a single day)"
    type: number
    sql: AVG(${au_students}) ;;
    value_format_name: decimal_0
  }

}

view: au {
  extension: required

  view_label: "User Activity Counts"

  parameter: days {
    type: unquoted
    default_value: "0"
    hidden: yes
    # how many days to include in the calculation (weekly users would be 7)
  }

  parameter: view_name {
    type: unquoted
    default_value: ""
    hidden: yes
    # name of view, as using _view_name raises an error
  }

  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.{{ view_name._parameter_value }}
        (
          date DATE
          ,product_platform STRING
          ,users INT
          ,instructors INT
          ,students INT
          ,total_users INT
          ,total_instructors INT
          ,total_students INT
        )
      ;;
      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.au
        AS
        SELECT
            d.datevalue AS date
            ,COALESCE(au.productplatform, 'UNKNOWN') as product_platform
            ,COUNT(DISTINCT CASE WHEN instructor THEN au.user_sso_guid END) AS instructors
            ,COUNT(DISTINCT CASE WHEN NOT instructor OR instructor IS NULL THEN au.user_sso_guid END) AS students
            ,COUNT(DISTINCT au.user_sso_guid) AS users
        FROM dw_ga.dim_date d
        LEFT JOIN ${guid_platform_date_active.SQL_TABLE_NAME} AS au ON au.date <= d.datevalue
                                                                    AND au.date > DATEADD(DAY, -{{ days._parameter_value }}, d.datevalue)
        WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.{{ view_name._parameter_value }})
        AND d.datevalue > (SELECT MIN(date) FROM ${guid_platform_date_active.SQL_TABLE_NAME})
        AND d.datevalue < CURRENT_DATE()
        GROUP BY 1, ROLLUP(2)
      ;;
      sql_step:
        INSERT INTO LOOKER_SCRATCH.{{ view_name._parameter_value }}
        SELECT date, product_platform, users, instructors, students, NULL, NULL, NULL
        FROM looker_scratch.au
        WHERE product_platform != 'UNKNOWN';;
      sql_step:
        MERGE INTO LOOKER_SCRATCH.{{ view_name._parameter_value }} a
        USING looker_scratch.au t ON a.date = t.date AND t.product_platform IS NULL
        WHEN MATCHED THEN UPDATE
          SET a.total_users = t.users
            ,a.total_instructors = t.instructors
            ,a.total_students = t.students
      ;;
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.{{ view_name._parameter_value }};;

    }
    datagroup_trigger: daily_refresh
  }


  dimension: pk {
    primary_key: yes
    sql: hash(date, product_platform) ;;
    hidden: yes
  }

  dimension: date {
    hidden: yes
    type: date
  }

  dimension: product_platform {
    hidden: yes
    label: "Product Platform"
  }

  dimension: au {
    hidden: yes
    label: "Active Users"
    type: number
    sql:
      {% if active_users_platforms.product_platform._in_query %}
        {{ _view._name }}.users
      {% else %}
        {{ _view._name }}.total_users
      {% endif %}
      ;;
  }

  dimension: au_instructors {
    hidden: yes
    label: "Active Instructors"
    type: number
    sql:
      {% if active_users_platforms.product_platform._in_query %}
        {{ _view._name }}.instructors
      {% else %}
        {{ _view._name }}.total_instructors
      {% endif %}
      ;;
  }

  dimension: au_students {
    hidden: yes
    label: "Active Students"
    type: number
    sql:
      {% if active_users_platforms.product_platform._in_query %}
        {{ _view._name }}.students
      {% else %}
        {{ _view._name }}.total_students
      {% endif %}
      ;;
  }
}
