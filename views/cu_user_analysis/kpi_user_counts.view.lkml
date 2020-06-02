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

        ,all_active_user_guid STRING comment ''
        ,all_paid_active_user_guid STRING comment ''

        ,payment_cui_guid STRING comment ''
        ,payment_ia_guid STRING comment ''
        ,payment_direct_purchase_guid STRING comment ''
        )
      ;;

# guid date course
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (SELECT DISTINCT date, user_sso_guid, region, organization, platform, user_type FROM ${guid_date_course.SQL_TABLE_NAME} WHERE expired_access_flag = FALSE
        AND date < current_date() and date > (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts)
        ) c
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
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (SELECT date, user_sso_guid, region, organization, platform, MAX(paid_flag) AS paid_flag FROM ${guid_date_ebook.SQL_TABLE_NAME}
         WHERE date < current_date() and date > (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts WHERE all_ebook_guid IS NOT NULL)
         GROUP BY date, user_sso_guid, region, organization, platform
        ) c
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
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (SELECT date, user_sso_guid, region, organization, platform, user_type, MIN(content_type) AS content_type FROM ${guid_date_subscription.SQL_TABLE_NAME}
         WHERE date < current_date() and date > (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts WHERE all_full_access_cu_guid IS NOT NULL)
         GROUP BY date, user_sso_guid, region, organization, platform, user_type
        ) c
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
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (SELECT * FROM ${guid_date_paid.SQL_TABLE_NAME}
        WHERE date < current_date() and date > (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts WHERE userbase_paid_user_guid IS NOT NULL)
        and paid_content_rank = 1
        ) c
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

# guid date active
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING (
          WITH kpi AS (
            SELECT
              date
              ,user_sso_guid
              ,region
              ,organization
              ,user_type
              ,MAX(userbase_digital_user_guid) as userbase_digital_user_guid
              ,MAX(userbase_paid_user_guid) as userbase_paid_user_guid
              ,MAX(userbase_full_access_cu_only_guid) as userbase_full_access_cu_only_guid
              ,MAX(userbase_trial_access_cu_only_guid) as userbase_trial_access_cu_only_guid
              ,MAX(all_instructors_active_course_guid) as all_instructors_active_course_guid
              ,MAX(all_full_access_cu_guid) as all_full_access_cu_guid
              ,MAX(all_trial_access_cu_guid) as all_trial_access_cu_guid
            FROM LOOKER_SCRATCH.kpi_user_counts
            WHERE date < current_date() and date > (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts WHERE all_active_user_guid IS NOT NULL)
            GROUP BY
            date
            ,user_sso_guid
            ,region
            ,organization
            ,user_type
          )
          SELECT g.*
            ,userbase_digital_user_guid
            ,userbase_paid_user_guid
            ,userbase_full_access_cu_only_guid
            ,userbase_trial_access_cu_only_guid
            ,all_instructors_active_course_guid
            ,all_full_access_cu_guid
            ,all_trial_access_cu_guid
          FROM prod.LOOKER_SCRATCH.guid_date_active g
          LEFT JOIN kpi ON g.date = kpi.date
            AND g.USER_SSO_GUID = kpi.USER_SSO_GUID
            AND g.region =  kpi.region
            AND g.ORGANIZATION = kpi.ORGANIZATION
            AND g.user_type = kpi.user_type
          WHERE g.date < current_date() and g.date > (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts WHERE all_active_user_guid IS NOT NULL)

        ) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
        WHEN MATCHED THEN UPDATE
          SET
            k.all_active_user_guid = c.user_sso_guid
            ,k.all_paid_active_user_guid = CASE WHEN c.userbase_paid_user_guid IS NOT NULL THEN c.user_sso_guid END
        WHEN NOT MATCHED THEN INSERT
          (
           date
          ,user_sso_guid
          ,region
          ,organization
          ,platform
          ,user_type
          ,userbase_digital_user_guid
          ,userbase_paid_user_guid
          ,userbase_full_access_cu_only_guid
          ,userbase_trial_access_cu_only_guid
          ,all_instructors_active_course_guid
          ,all_full_access_cu_guid
          ,all_trial_access_cu_guid
          ,all_active_user_guid
          ,all_paid_active_user_guid
          )
          VALUES
          (
          c.date
          ,c.user_sso_guid
          ,c.region
          ,c.organization
          ,'Other'
          ,c.user_type
          ,c.userbase_digital_user_guid
          ,c.userbase_paid_user_guid
          ,c.userbase_full_access_cu_only_guid
          ,c.userbase_trial_access_cu_only_guid
          ,c.all_instructors_active_course_guid
          ,c.all_full_access_cu_guid
          ,c.all_trial_access_cu_guid
          ,c.user_sso_guid
          ,CASE WHEN c.userbase_paid_user_guid IS NOT NULL THEN c.user_sso_guid END
          )
        ;;

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
  timeframes: [raw,date,week,month,year]
}

dimension: region {}

dimension: organization {}

dimension: platform {}

dimension: user_type {}

dimension: user_sso_guid {hidden: yes}

measure: userbase_digital_user_guid  {type:count_distinct label: "# Digital Student Users"}
measure: userbase_paid_user_guid  {type:count_distinct label: "# Paid Digital Student Users"}
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
measure: all_active_user_guid  {type:count_distinct label: "# Total Active Users"}

measure: all_paid_active_user_guid {
  type: count_distinct
#   sql: CASE WHEN ${TABLE}.userbase_paid_user_guid IS NOT NULL AND ${TABLE}.all_active_user_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END;;
  label: "# Total Paid Active Users"
}

}
