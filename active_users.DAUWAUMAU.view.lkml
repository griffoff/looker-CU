view: active_users_platforms {

  view_label: "User Activity Counts"

  derived_table: {
    sql:  SELECT DISTINCT COALESCE(productplatform, 'UNKNOWN') as product_platform
    FROM ${guid_platform_date_active.SQL_TABLE_NAME} ;;
  }

  dimension: product_platform {
    label: "Product Platform"
  }
}

view: dau {
  extends: [au]

  parameter: days {default_value: "1"}
  parameter: view_name {default_value: "dau"}


  measure: dau {
    label: "DAU"
    description: "Daily Active Users  (average if not reported on a single day)"
    type: number
    sql: AVG(${au}) ;;
    value_format_name: decimal_0
  }

}

view: wau {
  extends: [au]

  parameter: days {default_value: "7"}
  parameter: view_name {default_value: "wau"}


  measure: wau {
    label: "WAU"
    description: "Weekly Active Users  (average if not reported on a single day)"
    type: number
    sql: AVG(${au}) ;;
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
          ,total_users INT
        )
      ;;
      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.au
        AS
        SELECT
            d.datevalue AS date
            ,COALESCE(au.productplatform, 'UNKNOWN') as product_platform
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
        SELECT date, product_platform, users, NULL
        FROM looker_scratch.au
        WHERE product_platform IS NOT NULL;;
      sql_step:
        MERGE INTO LOOKER_SCRATCH.{{ view_name._parameter_value }} a
        USING looker_scratch.au t ON a.date = t.date AND t.product_platform IS NULL
        WHEN MATCHED THEN UPDATE
          SET a.total_users = t.users
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

}
