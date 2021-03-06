explore: guid_date_course_new {hidden:yes}

view: guid_date_course_new {
  derived_table: {
    create_process: {
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      AS
      SELECT DISTINCT dim_date.date_value as date, user_sso_guid, 'Courseware' AS content_type, user_type, platform, region, organization, cu_flg
        , CASE WHEN dim_date.date_value >= activation_date THEN TRUE ELSE FALSE END AS paid_flag
        , CASE WHEN activation_date IS NULL AND dim_date.date_value > unpaid_access_end THEN TRUE ELSE FALSE END AS expired_access_flag
      FROM ${dim_date.SQL_TABLE_NAME} dim_date
      LEFT JOIN ${courseware_users.SQL_TABLE_NAME} ON dim_date.date_value BETWEEN course_start AND course_end
      WHERE dim_date.date_value BETWEEN '2017-07-01' AND CURRENT_DATE()
      ORDER BY date

      ;;

        sql_step: ALTER TABLE ${SQL_TABLE_NAME} CLUSTER BY (date) ;;

        sql_step: ALTER TABLE ${SQL_TABLE_NAME} RECLUSTER ;;
      }

      datagroup_trigger: daily_refresh
    }

    dimension: user_sso_guid {
      type: string
    }

    dimension: date {
      type: date
    }

    dimension: fiscal_year {
      type: date
      sql: date_trunc(year,dateadd(month,9,CONVERT_TIMEZONE('UTC',${date}))) ;;
    }

    dimension: content_type {
      type: string
    }

    dimension: user_type {
      type: string
    }

    dimension: paid_flag {
      type: yesno
    }

    dimension: expired_access_flag {
      type: yesno
    }

    dimension: cu_flg {}

    dimension: platform {
      type: string
    }

    dimension: region {
      type: string
    }

    dimension: organization {
      type: string
    }

    measure: user_count {
      type: count_distinct
      sql: ${user_sso_guid} ;;
      label: "# Users"
    }

  }
