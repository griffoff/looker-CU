explore: kpi_user_counts {}
view: kpi_user_counts {

  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.kpi_user_counts
        (
        date DATE
        ,user_sso_guid STRING
        ,region STRING
        ,organization STRING
        ,platform STRING
        ,user_type STRING

        ,userbase_digital_user_guid STRING comment ''
        ,userbase_paid_user_guid STRING comment ''
        ,userbase_paid_courseware_guid STRING comment ''
        ,userbase_paid_ebook_only_guid STRING comment ''
        ,userbase_full_access_cu_only_guid STRING comment ''
        ,userbase_trial_access_cu_only_guid STRING comment ''

        ,all_instructors_active_course_guid STRING comment ''
        ,all_courseware_guid STRING comment ''
        ,all_ebook_guid STRING comment ''
        ,all_paid_ebook_guid STRING comment ''
        ,all_full_access_cu_guid STRING comment ''
        ,all_trial_access_cu_guid STRING comment ''

        /*
        ,active_users_dau_guid STRING comment ''
        ,active_users_dau_paid_guid STRING comment ''
        ,active_users_wau_guid STRING comment ''
        ,active_users_wau_paid_guid STRING comment ''
        ,active_users_mau_guid STRING comment ''
        ,active_users_mau_paid_guid STRING comment ''
        */

        ,payment_cui_guid STRING comment ''
        ,payment_ia_guid STRING comment ''
        ,payment_direct_purchase_guid STRING comment ''
        )
      ;;

# guid date course
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING (SELECT * FROM ${guid_date_course.SQL_TABLE_NAME} WHERE expired_access_flag = FALSE AND date < current_date() and date > (SELECT MAX(date) FROM LOOKER_SCRATCH.kpi_user_counts)) c
        --AND c.date < current_date() and c.date > (SELECT MAX(date) FROM LOOKER_SCRATCH.kpi_user_counts)
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform AND k.user_type = c.user_type
        WHEN MATCHED THEN UPDATE
          SET
            k.userbase_digital_user_guid = CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
            ,k.all_instructors_active_course_guid = CASE WHEN c.user_type = 'Instructor' THEN c.user_sso_guid END
            ,k.all_courseware_guid = CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
        WHEN NOT MATCHED THEN INSERT
        (
          date
          ,user_sso_guid
          ,region
          ,organization
          ,platform
          ,user_type
          ,all_instructors_active_course_guid
          ,userbase_digital_user_guid
          ,all_courseware_guid
        )
        VALUES
        (
          c.date
          ,c.user_sso_guid
          ,c.region
          ,c.organization
          ,c.platform
          ,c.user_type
          ,CASE WHEN c.user_type = 'Instructor' THEN c.user_sso_guid END
          ,CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
          ,CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
        )
        ;;

#   guid date ebook
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING (SELECT * FROM ${guid_date_ebook.SQL_TABLE_NAME} WHERE date < current_date() and date > (SELECT MAX(date) FROM LOOKER_SCRATCH.kpi_user_counts))c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
        WHEN MATCHED THEN UPDATE
        SET
          k.userbase_digital_user_guid = c.user_sso_guid
          ,k.all_ebook_guid = c.user_sso_guid
          ,k.all_paid_ebook_guid = CASE WHEN c.paid_flag IS NOT NULL THEN c.user_sso_guid END
        WHEN NOT MATCHED THEN INSERT
        (
          date
          ,user_sso_guid
          ,region
          ,organization
          ,platform
          ,user_type
          ,userbase_digital_user_guid
          ,all_ebook_guid
          ,all_paid_ebook_guid
        )
        VALUES
        (
          c.date
          ,c.user_sso_guid
          ,c.region
          ,c.organization
          ,c.platform
          ,'Student'
          ,c.user_sso_guid
          ,c.user_sso_guid
          ,CASE WHEN c.paid_flag IS NOT NULL THEN c.user_sso_guid END
        )
        ;;

          #   guid date subscription
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING (SELECT * FROM ${guid_date_subscription.SQL_TABLE_NAME} WHERE date < current_date() and date > (SELECT MAX(date) FROM LOOKER_SCRATCH.kpi_user_counts)) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
        WHEN MATCHED THEN UPDATE
          SET
            k.userbase_digital_user_guid = c.user_sso_guid
            ,k.all_full_access_cu_guid = CASE WHEN c.content_type = 'Full Access CU Subscription' THEN c.user_sso_guid END
            ,k.all_trial_access_cu_guid = CASE WHEN c.content_type = 'Trial CU Subscription' THEN c.user_sso_guid END
        WHEN NOT MATCHED THEN INSERT
        (
        date
          ,user_sso_guid
          ,region
          ,organization
          ,platform
          ,user_type
          ,userbase_digital_user_guid
          ,all_full_access_cu_guid
          ,all_trial_access_cu_guid
        )
        VALUES
        (
          c.date
          ,c.user_sso_guid
          ,c.region
          ,c.organization
          ,c.platform
          ,'Student'
          ,c.user_sso_guid
          ,CASE WHEN c.content_type = 'Full Access CU Subscription' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'Trial CU Subscription' THEN c.user_sso_guid END
        )
        ;;


            #   guid date paid
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING (SELECT * FROM ${guid_date_paid.SQL_TABLE_NAME} WHERE date < current_date() and date > (SELECT MAX(date) FROM LOOKER_SCRATCH.kpi_user_counts) and paid_content_rank = 1) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
        WHEN MATCHED THEN UPDATE
          SET
            k.userbase_paid_user_guid = CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
            ,k.userbase_paid_courseware_guid = CASE WHEN c.content_type = 'Courseware' THEN c.user_sso_guid END
            ,k.userbase_paid_ebook_only_guid = CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END
            ,k.userbase_full_access_cu_only_guid = CASE WHEN c.content_type = 'Full Access CU Subscription' THEN c.user_sso_guid END
            ,k.userbase_trial_access_cu_only_guid = CASE WHEN c.content_type = 'Trial CU Subscription' THEN c.user_sso_guid END
        WHEN NOT MATCHED THEN INSERT
        (
          date
          ,user_sso_guid
          ,region
          ,organization
          ,platform
          ,user_type
          ,userbase_paid_user_guid
          ,userbase_paid_courseware_guid
          ,userbase_paid_ebook_only_guid
          ,userbase_full_access_cu_only_guid
          ,userbase_trial_access_cu_only_guid
        )
        VALUES
        (
          c.date
          ,c.user_sso_guid
          ,c.region
          ,c.organization
          ,c.platform
          ,'Student'
          ,CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'Courseware' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'Full Access CU Subscription' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'Trial CU Subscription' THEN c.user_sso_guid END
        )
        ;;

#         merge for wau USING

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
#
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

#         --LEFT JOIN paid p on d.datevalue = p.date AND u.user_sso_guid = p.user_sso_guid

#         LEFT JOIN active_course_instructors c ON d.datevalue = c.date AND u.user_sso_guid = c.user_sso_guid

#         GROUP BY 1, ROLLUP(2)



        sql_step:
        CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
        CLONE LOOKER_SCRATCH.kpi_user_counts
        ;;
      }

      datagroup_trigger: daily_refresh
    }

dimension_group: date {
  label: "Calendar"
  type:time
  timeframes: [raw,date,month,year]
}

dimension: region {}

dimension: organization {}

dimension: platform {}

dimension: user_type {}

measure: userbase_digital_user_guid  {type:count_distinct label: "# Digital Student Users"}
measure: userbase_paid_user_guid  {type:count_distinct label: "# Paid Student Users"}
measure: userbase_paid_courseware_guid  {type:count_distinct label: "# Paid Courseware Student Users"}
measure: userbase_paid_ebook_only_guid  {type:count_distinct label: "# Paid eBook ONLY Student Users"}
measure: userbase_full_access_cu_only_guid  {type:count_distinct label: "# Paid CU ONLY Student Users (no provisions)"}
measure: userbase_trial_access_cu_only_guid  {type:count_distinct label: "# Trial CU ONLY Student Users"}

measure: all_courseware_guid  {type:count_distinct label: "# Total Courseware Student Users"}
measure: all_ebook_guid  {type:count_distinct label: "# Total eBook Student Users"}
measure: all_paid_ebook_guid  {type:count_distinct label: "# Total Paid eBook Student Users"}
measure: all_full_access_cu_guid  {type:count_distinct label: "# Total Full Access CU Subscribers"}
measure: all_trial_access_cu_guid  {type:count_distinct label: "# Total Trial Access CU Subscribers"}
measure: all_instructors_active_course_guid  {type:count_distinct label: "# Instructors With Active Digital Course"}

          }
