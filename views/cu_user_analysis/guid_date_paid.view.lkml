explore: guid_date_paid {}

view: guid_date_paid {
  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.guid_date_paid
        (
          date DATE
          ,user_sso_guid STRING
          ,region STRING
          ,platform STRING
          ,organization STRING
          ,paid_flag BOOLEAN
          ,content_type STRING
          ,paid_content_rank INT
        )
      ;;

      sql_step:
      DELETE FROM LOOKER_SCRATCH.guid_date_paid WHERE date > dateadd(d,-3, current_date())
      ;;

        sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.guid_date_paid_incremental
        AS
        WITH dates AS (
          SELECT d.datevalue
          FROM ${dim_date.SQL_TABLE_NAME} d
          WHERE d.datevalue > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.guid_date_paid)
          AND d.datevalue < CURRENT_DATE()
        )
        ,paid_courseware_users AS (
          SELECT DISTINCT c.date, c.user_sso_guid, region, platform, organization
          FROM ${guid_date_course.SQL_TABLE_NAME} c
          INNER JOIN dates d on d.datevalue = c.date
          WHERE c.paid_flag = TRUE
        )
        ,paid_ebook_users AS (
          SELECT DISTINCT e.date, e.user_sso_guid, region, platform, organization
          FROM ${guid_date_ebook.SQL_TABLE_NAME} e
          INNER JOIN dates d on d.datevalue = e.date
          WHERE e.paid_flag = TRUE
        )
        ,paid_cu_only_users AS (
          SELECT DISTINCT s.date, s.user_sso_guid, s.content_type, region, platform, organization
          FROM ${guid_date_subscription.SQL_TABLE_NAME} s
          INNER JOIN dates d on d.datevalue = s.date
        )
        ,paid_union as (
          SELECT date, user_sso_guid, region, platform, organization, TRUE AS paid_flag, 'Courseware' AS content_type, 1 AS content_order FROM paid_courseware_users
          UNION ALL
          SELECT date, user_sso_guid, region, platform, organization, TRUE AS paid_flag, 'eBook' AS content_type, 2 AS content_order FROM paid_ebook_users
          UNION ALL
          SELECT date, user_sso_guid, region, platform, organization
          , CASE WHEN content_type = 'Full Access CU Subscription' THEN TRUE ELSE FALSE END AS paid_flag
          , content_type
          , CASE WHEN content_type = 'Full Access CU Subscription' THEN 3 ELSE 4 END AS content_order
          FROM paid_cu_only_users
        )
        select date, user_sso_guid, region, platform, organization, paid_flag, content_type
          , rank() over(partition by date,user_sso_guid order by content_order) AS paid_content_rank
        from paid_union
        ;;
        sql_step:
              INSERT INTO LOOKER_SCRATCH.guid_date_paid
              SELECT date, user_sso_guid, region, platform, organization, paid_flag, content_type, paid_content_rank
              FROM looker_scratch.guid_date_paid_incremental
              ;;
          sql_step:
                CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
                CLONE LOOKER_SCRATCH.guid_date_paid;;
          }
          datagroup_trigger: daily_refresh
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

  dimension: paid_flag {
    type: yesno
    sql: ${TABLE}.paid_flag ;;
  }

  dimension: paid_content_rank {
    type: number
  }

  dimension: region {
    type: string
  }

  dimension: platform {
    type: string
  }

  dimension: organization {
    type: string
  }

  measure: user_count {
    type: count_distinct
    sql: ${TABLE}.USER_SSO_GUID ;;
    label: "# Users"
  }
}
