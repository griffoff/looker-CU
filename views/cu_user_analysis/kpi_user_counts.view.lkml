explore: kpi_user_counts {hidden: yes}

view: kpi_user_counts {
  view_label: "User Count KPIs"

  derived_table: {
    create_process: {
      sql_step: use warehouse heavyduty ;;

      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.kpi_user_counts
        CLUSTER BY (date)
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
        ,userbase_full_access_cu_etextbook_only_guid STRING comment ''
        ,userbase_trial_access_cu_etextbook_only_guid STRING comment ''
        ,all_instructors_active_course_guid STRING comment ''
        ,all_courseware_guid STRING comment ''
        ,all_ebook_guid STRING comment ''
        ,all_paid_ebook_guid STRING comment ''
        ,all_full_access_cu_guid STRING comment ''
        ,all_trial_access_cu_guid STRING comment ''
        ,all_full_access_cu_etextbook_guid STRING comment ''
        ,all_trial_access_cu_etextbook_guid STRING comment ''
        ,all_active_user_guid STRING comment ''
        ,all_paid_active_user_guid STRING comment ''
        ,payment_cui_guid STRING comment ''
        ,payment_ia_guid STRING comment ''
        ,payment_direct_purchase_guid STRING comment ''
        )
      ;;

      sql_step:
      DELETE FROM LOOKER_SCRATCH.kpi_user_counts WHERE date > dateadd(d,-3, current_date())
      ;;

      sql_step:
      SET max_date = (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts)
      ;;

# guid date course
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (
        SELECT date, user_sso_guid, region, organization, platform, user_type, max(paid_flag) as paid_flag
        FROM ${guid_date_course.SQL_TABLE_NAME} WHERE expired_access_flag = FALSE
        AND date < current_date() and date > $max_date
        GROUP BY date, user_sso_guid, region, organization, platform, user_type
        ) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform AND k.user_type = c.user_type
        WHEN MATCHED THEN UPDATE
          SET
            k.userbase_digital_user_guid = CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
            ,k.all_instructors_active_course_guid = CASE WHEN c.user_type = 'Instructor' THEN c.user_sso_guid END
            ,k.all_courseware_guid = CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
            ,k.userbase_paid_user_guid = CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
            ,k.userbase_paid_courseware_guid = CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
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
          ,userbase_paid_user_guid
          ,userbase_paid_courseware_guid
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
          ,CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
          ,CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
        )
        ;;

#         sql_step:
#         CREATE OR REPLACE TABLE prod.looker_scratch.kpi_test_1
#         CLONE LOOKER_SCRATCH.kpi_user_counts
#         ;;

#   guid date ebook
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (
        SELECT date, user_sso_guid, region, organization, platform, MAX(paid_flag) AS paid_flag
        FROM ${guid_date_ebook.SQL_TABLE_NAME}
        WHERE date < current_date() and date > $max_date
        GROUP BY date, user_sso_guid, region, organization, platform
        ) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
        WHEN MATCHED THEN UPDATE
        SET
          k.userbase_digital_user_guid = c.user_sso_guid
          ,k.all_ebook_guid = c.user_sso_guid
          ,k.all_paid_ebook_guid = COALESCE(CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END, k.all_paid_ebook_guid)
          ,k.userbase_paid_user_guid = COALESCE(CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END, k.userbase_paid_user_guid)
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
          ,userbase_paid_user_guid
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
          ,CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
          ,CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
        )
        ;;

#       sql_step:
#       CREATE OR REPLACE TABLE prod.looker_scratch.kpi_test_2
#       CLONE LOOKER_SCRATCH.kpi_user_counts
#       ;;

          #   guid date subscription
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (
        SELECT DISTINCT s.date, s.user_sso_guid, s.region, s.organization, s.platform, s.user_type
          , last_value(s.content_type) over (partition by s.date, s.user_sso_guid, s.region, s.organization, s.platform, s.user_type order by (CASE WHEN s.content_type = 'CU Full Access' THEN 1 WHEN s.content_type = 'CU eTextbook Full Access' THEN 2 WHEN s.content_type = 'CU Trial' THEN 3 WHEN s.content_type = 'CU eTextbook Trial' THEN 4 END) desc) AS content_type
        FROM ${guid_date_subscription.SQL_TABLE_NAME} s
        WHERE s.date < current_date() and s.date > $max_date
        ) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.user_type = c.user_type
        WHEN MATCHED THEN UPDATE
          SET
            k.userbase_digital_user_guid = c.user_sso_guid
            ,k.all_full_access_cu_guid = COALESCE(CASE WHEN c.content_type = 'CU Full Access' THEN c.user_sso_guid END,k.all_full_access_cu_guid)
            ,k.all_trial_access_cu_guid = COALESCE(CASE WHEN c.content_type = 'CU Trial' THEN c.user_sso_guid END,k.all_trial_access_cu_guid)
            ,k.all_full_access_cu_etextbook_guid = COALESCE(CASE WHEN c.content_type = 'CU eTextbook Full Access' THEN c.user_sso_guid END,k.all_full_access_cu_etextbook_guid)
            ,k.all_trial_access_cu_etextbook_guid = COALESCE(CASE WHEN c.content_type = 'CU eTextbook Trial' THEN c.user_sso_guid END,k.all_trial_access_cu_etextbook_guid)
            ,k.userbase_paid_user_guid = COALESCE(CASE WHEN c.content_type IN ('CU Full Access','CU eTextbook Full Access') THEN c.user_sso_guid END,k.userbase_paid_user_guid)

            ,k.userbase_paid_courseware_guid = COALESCE(CASE WHEN c.content_type = 'CU Full Access' THEN k.all_courseware_guid END,k.userbase_paid_courseware_guid)
            ,k.all_paid_ebook_guid = COALESCE(CASE WHEN c.content_type IN ('CU Full Access','CU eTextbook Full Access') THEN k.all_ebook_guid END,k.all_paid_ebook_guid)
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
          ,all_full_access_cu_etextbook_guid
          ,all_trial_access_cu_etextbook_guid
          ,userbase_paid_user_guid
        )
        VALUES
        (
          c.date
          ,c.user_sso_guid
          ,c.region
          ,c.organization
          ,c.platform
          ,c.user_type

          ,c.user_sso_guid
          ,CASE WHEN c.content_type = 'CU Full Access' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU Trial' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU eTextbook Full Access' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU eTextbook Trial' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type IN ('CU Full Access','CU eTextbook Full Access') THEN c.user_sso_guid END
        )
        ;;

#       sql_step:
#       CREATE OR REPLACE TABLE prod.looker_scratch.kpi_test_3
#       CLONE LOOKER_SCRATCH.kpi_user_counts
#       ;;


            #   guid date paid
        sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING
        (
        SELECT *
        FROM ${guid_date_paid.SQL_TABLE_NAME}
        WHERE date < current_date() and date > $max_date
        AND paid_content_rank = 1
        ) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
        WHEN MATCHED THEN UPDATE
          SET
            k.userbase_digital_user_guid = c.user_sso_guid
            ,k.userbase_paid_user_guid = COALESCE(CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END,k.userbase_paid_user_guid)
            ,k.userbase_paid_courseware_guid = COALESCE(CASE WHEN c.content_type = 'Courseware' THEN c.user_sso_guid END,k.userbase_paid_courseware_guid)
            ,k.userbase_paid_ebook_only_guid = COALESCE(CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END,k.userbase_paid_ebook_only_guid)
            ,k.userbase_full_access_cu_only_guid = COALESCE(CASE WHEN c.content_type = 'CU Full Access' THEN c.user_sso_guid END,k.userbase_full_access_cu_only_guid)
            ,k.userbase_trial_access_cu_only_guid = COALESCE(CASE WHEN c.content_type = 'CU Trial' THEN c.user_sso_guid END,k.userbase_trial_access_cu_only_guid)
            ,k.userbase_full_access_cu_etextbook_only_guid = COALESCE(CASE WHEN c.content_type = 'CU eTextbook Full Access' THEN c.user_sso_guid END,k.userbase_full_access_cu_etextbook_only_guid)
            ,k.userbase_trial_access_cu_etextbook_only_guid = COALESCE(CASE WHEN c.content_type = 'CU eTextbook Trial' THEN c.user_sso_guid END,k.userbase_trial_access_cu_etextbook_only_guid)

            ,k.all_courseware_guid = COALESCE(CASE WHEN c.content_type = 'Courseware' THEN c.user_sso_guid END,k.all_courseware_guid)
            ,k.all_ebook_guid = COALESCE(CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END,k.all_ebook_guid)
            ,k.all_paid_ebook_guid = COALESCE(CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END,k.all_paid_ebook_guid)
            ,k.all_full_access_cu_guid = COALESCE(CASE WHEN c.content_type = 'CU Full Access' THEN c.user_sso_guid END,k.all_full_access_cu_guid)
            ,k.all_trial_access_cu_guid = COALESCE(CASE WHEN c.content_type = 'CU Trial' THEN c.user_sso_guid END,k.all_trial_access_cu_guid)
            ,k.all_full_access_cu_etextbook_guid = COALESCE(CASE WHEN c.content_type = 'CU eTextbook Full Access' THEN c.user_sso_guid END,k.all_full_access_cu_etextbook_guid)
            ,k.all_trial_access_cu_etextbook_guid  = COALESCE(CASE WHEN c.content_type = 'CU eTextbook Trial' THEN c.user_sso_guid END,k.all_trial_access_cu_etextbook_guid)

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
          ,userbase_paid_courseware_guid
          ,userbase_paid_ebook_only_guid
          ,userbase_full_access_cu_only_guid
          ,userbase_trial_access_cu_only_guid
          ,userbase_full_access_cu_etextbook_only_guid
          ,userbase_trial_access_cu_etextbook_only_guid

          ,all_courseware_guid
          ,all_ebook_guid
          ,all_paid_ebook_guid
          ,all_full_access_cu_guid
          ,all_trial_access_cu_guid
          ,all_full_access_cu_etextbook_guid
          ,all_trial_access_cu_etextbook_guid
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
          ,CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'Courseware' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU Full Access' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU Trial' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU eTextbook Full Access' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU eTextbook Trial' THEN c.user_sso_guid END

          ,CASE WHEN c.content_type = 'Courseware' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU Full Access' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU Trial' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU eTextbook Full Access' THEN c.user_sso_guid END
          ,CASE WHEN c.content_type = 'CU eTextbook Trial' THEN c.user_sso_guid END
        )
        ;;

#       sql_step:
#       CREATE OR REPLACE TABLE prod.looker_scratch.kpi_test_4
#       CLONE LOOKER_SCRATCH.kpi_user_counts
#       ;;

# guid date active

# update everything with a match
# then insert 'other' records where there wasnt a match


# update
      sql_step:
      UPDATE LOOKER_SCRATCH.kpi_user_counts k
          SET
              k.all_active_user_guid = c.user_sso_guid
              ,k.all_paid_active_user_guid = COALESCE(CASE WHEN k.userbase_paid_user_guid IS NOT NULL THEN c.user_sso_guid END,k.all_paid_active_user_guid)
          FROM (
              SELECT *
              FROM ${guid_date_active.SQL_TABLE_NAME} g
              WHERE g.date < current_date() and g.date > $max_date
              ) c
          WHERE k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.user_type = c.user_type AND k.platform = c.platform
        ;;

#         insert
#         must still be a merge because platform may be 'other' in kpi_user_counts but not in guid_date_active until after the aggregation in kpi cte
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
              ,MAX(userbase_full_access_cu_etextbook_only_guid) as userbase_full_access_cu_etextbook_only_guid
              ,MAX(userbase_trial_access_cu_etextbook_only_guid) as userbase_trial_access_cu_etextbook_only_guid
              ,MAX(all_instructors_active_course_guid) as all_instructors_active_course_guid
              ,MAX(all_full_access_cu_guid) as all_full_access_cu_guid
              ,MAX(all_trial_access_cu_guid) as all_trial_access_cu_guid
              ,MAX(all_full_access_cu_etextbook_guid) as all_full_access_cu_etextbook_guid
              ,MAX(all_trial_access_cu_etextbook_guid) as all_trial_access_cu_etextbook_guid
            FROM LOOKER_SCRATCH.kpi_user_counts
            WHERE date < current_date() and date > $max_date
              AND all_active_user_guid iS NULL
            GROUP BY
              date
              ,user_sso_guid
              ,region
              ,organization
              ,user_type
          )
          SELECT DISTINCT g.date
            , g.user_sso_guid
            , g.region
            , g.ORGANIZATION
            , 'Other' as platform
            , g.user_type
            , kpi.userbase_digital_user_guid
            , kpi.userbase_paid_user_guid
            , kpi.userbase_full_access_cu_only_guid
            , kpi.userbase_trial_access_cu_only_guid
            , kpi.userbase_full_access_cu_etextbook_only_guid
            , kpi.userbase_trial_access_cu_etextbook_only_guid
            , kpi.all_instructors_active_course_guid
            , kpi.all_full_access_cu_guid
            , kpi.all_trial_access_cu_guid
            , kpi.all_full_access_cu_etextbook_guid
            , kpi.all_trial_access_cu_etextbook_guid
          FROM ${guid_date_active.SQL_TABLE_NAME} g
          LEFT JOIN LOOKER_SCRATCH.kpi_user_counts k ON g.date = k.date
            AND g.USER_SSO_GUID = k.USER_SSO_GUID
            AND g.region = k.region
            AND g.ORGANIZATION = k.ORGANIZATION
            AND g.user_type = k.user_type
          LEFT JOIN kpi ON g.date = kpi.date
            AND g.USER_SSO_GUID = kpi.USER_SSO_GUID
            AND g.region = kpi.region
            AND g.ORGANIZATION = kpi.ORGANIZATION
            AND g.user_type = kpi.user_type
          WHERE g.date < current_date()
            AND g.date > $max_date
            AND k.ALL_ACTIVE_USER_GUID IS NULL
        ) c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.user_type = c.user_type AND k.platform = c.platform
        WHEN MATCHED THEN UPDATE
          SET
            k.all_active_user_guid = c.user_sso_guid
            ,k.all_paid_active_user_guid = COALESCE(CASE WHEN c.userbase_paid_user_guid IS NOT NULL THEN c.user_sso_guid END,k.all_paid_active_user_guid)
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
          ,userbase_full_access_cu_etextbook_only_guid
          ,userbase_trial_access_cu_etextbook_only_guid
          ,all_instructors_active_course_guid
          ,all_full_access_cu_guid
          ,all_trial_access_cu_guid
          ,all_full_access_cu_etextbook_guid
          ,all_trial_access_cu_etextbook_guid
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
          ,c.userbase_full_access_cu_etextbook_only_guid
          ,c.userbase_trial_access_cu_etextbook_only_guid
          ,c.all_instructors_active_course_guid
          ,c.all_full_access_cu_guid
          ,c.all_trial_access_cu_guid
          ,c.all_full_access_cu_etextbook_guid
          ,c.all_trial_access_cu_etextbook_guid
          ,c.user_sso_guid
          ,CASE WHEN c.userbase_paid_user_guid IS NOT NULL THEN c.user_sso_guid END
        )
         ;;

#       sql_step:
#       CREATE OR REPLACE TABLE prod.looker_scratch.kpi_test_5
#       CLONE LOOKER_SCRATCH.kpi_user_counts
#       ;;

      sql_step:
        CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
        CLONE LOOKER_SCRATCH.kpi_user_counts
        ;;

      # sql_step: alter warehouse heavyduty suspend ;;

      sql_step: use warehouse looker_pdt ;;

       }

      datagroup_trigger: daily_refresh
    }

dimension_group: date {
  label: "Calendar"
  type:time
  timeframes: [raw,date,week,month,year]
  hidden: yes
}

dimension: region {}

dimension: organization {}

dimension: platform {}

dimension: user_type {}

dimension: user_sso_guid {hidden: yes}

measure: userbase_digital_user_guid  {type:count_distinct label: "# Digital Student Users"}
measure: userbase_paid_user_guid  {type:count_distinct label: "# Paid Digital Student Users"}
measure: userbase_paid_courseware_guid  {type:count_distinct label: "# Paid Courseware Student Users"}

measure: userbase_paid_ebook_only_guid  {
    type:count_distinct
    sql: case when ${TABLE}.userbase_paid_courseware_guid is null
      then ${TABLE}.userbase_paid_ebook_only_guid end  ;;
    label: "# Paid eBook ONLY Student Users"
  }

measure: userbase_full_access_cu_only_guid  {
  type:count_distinct
  sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              then ${TABLE}.userbase_full_access_cu_only_guid end;;
  label: "# Paid CU ONLY Student Users (no provisions)"
  }

measure: userbase_full_access_cu_etextbook_only_guid  {
  type:count_distinct
  sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              and ${TABLE}.all_full_access_cu_guid is null
              then ${TABLE}.userbase_full_access_cu_etextbook_only_guid end;;
  label: "# Paid CU eTextbook ONLY Student Users (no provisions)"
  }

measure: userbase_trial_access_cu_only_guid  {
  type:count_distinct
  sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              and ${TABLE}.all_full_access_cu_guid is null
              and ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
              then ${TABLE}.userbase_trial_access_cu_only_guid end;;
  label: "# Trial CU ONLY Student Users"
  }


measure: userbase_trial_access_cu_etextbook_only_guid  {
  type:count_distinct
  sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              and ${TABLE}.all_full_access_cu_guid is null
              and ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
              and ${TABLE}.all_trial_access_cu_guid is null
              then ${TABLE}.userbase_trial_access_cu_etextbook_only_guid end;;
  label: "# Trial CU eTextbook ONLY Student Users"
  }

measure: all_courseware_guid  {type:count_distinct label: "# Total Courseware Student Users"}
measure: all_ebook_guid  {type:count_distinct label: "# Total eBook Student Users"}
measure: all_paid_ebook_guid  {type:count_distinct label: "# Total Paid eBook Student Users"}
measure: all_full_access_cu_guid  {type:count_distinct label: "# Total Full Access CU Subscribers"}
measure: all_trial_access_cu_guid  {type:count_distinct label: "# Total Trial Access CU Subscribers"}
measure: all_full_access_cu_etextbook_guid  {type:count_distinct label: "# Total Full Access CU eTextbook Subscribers"}
measure: all_trial_access_cu_etextbook_guid  {type:count_distinct label: "# Total Trial Access CU eTextbook Subscribers"}
measure: all_instructors_active_course_guid  {type:count_distinct label: "# Instructors With Active Digital Course"}
measure: all_active_user_guid  {type:count_distinct label: "# Total Active Users"}

measure: all_paid_active_user_guid {
  type: count_distinct
#   sql: CASE WHEN ${TABLE}.userbase_paid_user_guid IS NOT NULL AND ${TABLE}.all_active_user_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END;;
  label: "# Total Paid Active Users"
}

  measure: all_active_instructor_with_active_course_guid {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.all_instructors_active_course_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Active Instructors (Active Course)"
  }


  measure: all_active_instructor {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.user_type = 'Instructor' THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Active Instructors"
  }

  measure: all_active_student {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.user_type = 'Student' THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Active Student Users"
  }

  measure: paid_active_courseware_student {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.userbase_paid_courseware_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Paid Active Courseware Student Users"
  }

  measure: paid_a_la_carte_courseware_users {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.all_full_access_cu_guid IS NULL
                AND ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
              THEN ${TABLE}.userbase_paid_courseware_guid END;;
    label: "# Total Paid a la carte Courseware Student Users"
    description: "Paid courseware users with no CU or CUe subscription"
  }

  measure: paid_a_la_carte_ebook_users {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.all_full_access_cu_guid IS NULL
                AND ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
                AND ${TABLE}.userbase_paid_courseware_guid IS NULL
              THEN ${TABLE}.userbase_paid_ebook_only_guid END;;
    label: "# Total Paid a la carte eBook Student Users"
    description: "Paid ebook users with no courseware access and no CU or CUe subscription"
  }


}
