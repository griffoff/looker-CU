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

        ,payment_cui_guid STRING comment ''
        ,payment_ia_guid STRING comment ''
        ,payment_direct_purchase_guid STRING comment ''
        )
      ;;

# guid date course
      sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING ${guid_date_course.SQL_TABLE_NAME} c
        ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
        AND c.expired_access_flag = FALSE
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
          ,CASE WHEN c.user_type = 'Instructor' THEN c.user_sso_guid END
          ,CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
          ,CASE WHEN c.user_type = 'Student' THEN c.user_sso_guid END
        )
        ;;

#   guid date ebook
      sql_step:
        MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING ${guid_date_ebook.SQL_TABLE_NAME} c
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
          ,c.user_sso_guid
          ,c.user_sso_guid
          ,CASE WHEN c.paid_flag IS NOT NULL THEN c.user_sso_guid END
        )
        ;;

#   guid date subscription
    sql_step:
      MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING ${guid_date_subscription.SQL_TABLE_NAME} c
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
        ,CASE WHEN c.content_type = 'Full Access CU Subscription' THEN c.user_sso_guid END
        ,CASE WHEN c.content_type = 'Trial CU Subscription' THEN c.user_sso_guid END
      )
      ;;


#   guid date paid
    sql_step:
      MERGE INTO LOOKER_SCRATCH.kpi_user_counts k USING ${guid_date_paid.SQL_TABLE_NAME} c
      ON k.date = c.date AND k.user_sso_guid = c.user_sso_guid AND k.region = c.region AND k.organization = c.organization AND k.platform = c.platform
      WHEN MATCHED AND c.paid_content_rank = 1 THEN UPDATE
        SET
          k.userbase_digital_user_guid = c.user_sso_guid
          ,k.userbase_paid_user_guid = CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
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
        ,userbase_digital_user_guid
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
        ,c.user_sso_guid
        ,CASE WHEN c.paid_flag = TRUE THEN c.user_sso_guid END
        ,CASE WHEN c.content_type = 'Courseware' THEN c.user_sso_guid END
        ,CASE WHEN c.content_type = 'eBook' THEN c.user_sso_guid END
        ,CASE WHEN c.content_type = 'Full Access CU Subscription' THEN c.user_sso_guid END
        ,CASE WHEN c.content_type = 'Trial CU Subscription' THEN c.user_sso_guid END
      )
      ;;


    sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.kpi_user_counts
      ;;
    }

  datagroup_trigger: daily_refresh
  }

  dimension: date {type:date}
  dimension: region {}
  dimension: organization {}
  dimension: platform {}

  measure: userbase_digital_user_guid  {type:count_distinct label: "# Digital Student Users"}
  measure: userbase_paid_user_guid  {type:count_distinct label: "# Paid Student Users"}
  measure: userbase_paid_courseware_guid  {type:count_distinct label: "# Paid Courseware Student Users"}
  measure: userbase_paid_ebook_only_guid  {type:count_distinct label: "# Paid eBook ONLY Student Users"}
  measure: userbase_full_access_cu_only_guid  {type:count_distinct label: "# Paid CU ONLY Student Users (no provisions)"}
  measure: userbase_trial_access_cu_guid  {type:count_distinct label: "# Total Trial Access CU Subscribers"}
  measure: all_courseware_guid  {type:count_distinct label: "# Total Courseware Student Users"}
  measure: all_ebook_guid  {type:count_distinct label: "# Total eBook Student Users"}
  measure: all_paid_ebook_guid  {type:count_distinct label: "# Total Paid eBook Student Users"}
  measure: all_full_access_cu_guid  {type:count_distinct label: "# Total Full Access CU Subscribers"}

}
