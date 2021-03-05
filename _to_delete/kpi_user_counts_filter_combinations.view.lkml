# explore: kpi_user_counts_filter_combinations {hidden:yes}

# view: kpi_user_counts_filter_combinations_agg {
#   extends: [kpi_user_counts_filter_combinations]
#   sql_table_name:
#   {% if kpi_user_stats.datevalue_date._in_query %}
#   ${kpi_user_counts_filter_combinations.SQL_TABLE_NAME}
#   {% elsif kpi_user_stats.datevalue_week._in_query %}
#   LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly
#   {% elsif kpi_user_stats.datevalue_month._in_query %}
#   LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly
#   {% else %}
#   ${kpi_user_counts_filter_combinations.SQL_TABLE_NAME}
#   {% endif %}
#   ;;

# }

# view: kpi_user_counts_filter_combinations {
#   view_label: "Filters"

#   derived_table: {
#     create_process: {
#       sql_step:
#         CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.kpi_user_counts_filter_combinations
#         (
#           date DATE NOT NULL
#           ,user_sso_guid STRING NOT NULL
#           ,region STRING NOT NULL
#           ,organization STRING NOT NULL
#           ,platform STRING NOT NULL
#           ,user_type STRING NOT NULL

#         )
#         ;;

#       sql_step: DELETE FROM  LOOKER_SCRATCH.kpi_user_counts_filter_combinations WHERE date > (SELECT DATEADD(day, -3, MAX(date)) FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations);;

#       sql_step:
#         INSERT INTO LOOKER_SCRATCH.kpi_user_counts_filter_combinations
#         SELECT DISTINCT date, user_sso_guid, region, organization, platform, user_type
#         FROM ${kpi_user_counts.SQL_TABLE_NAME}
#         WHERE date > (SELECT COALESCE(MAX(date), '1970-01-01') FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations)
#         ORDER BY 1

#         ;;

#       sql_step:
#         ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations CLUSTER BY (date);;

#       sql_step:
#         ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations RECLUSTER;;

#       sql_step:
#       CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
#       CLONE LOOKER_SCRATCH.kpi_user_counts_filter_combinations
#       ;;

#       sql_step: CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly LIKE LOOKER_SCRATCH.kpi_user_counts_filter_combinations ;;

#       sql_step: DELETE FROM  LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly WHERE date = (SELECT MAX(date) FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly);;

#       sql_step:
#         INSERT INTO LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly
#         SELECT DISTINCT date_trunc(w,date) as date, user_sso_guid, region, organization, platform, user_type
#         FROM LOOKER_SCRATCH.kpi_user_counts
#         WHERE date > (SELECT COALESCE(MAX(date), '1970-01-01') FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly)
#         ORDER BY 1
#         ;;

#       sql_step:
#         ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly CLUSTER BY(date) ;;

#       sql_step:
#         ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations_weekly RECLUSTER ;;

#       sql_step: CREATE TABLE IF NOT EXISTS  LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly LIKE LOOKER_SCRATCH.kpi_user_counts_filter_combinations ;;

#       sql_step: DELETE FROM  LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly WHERE date = (SELECT MAX(date) FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly);;

#       sql_step:
#         INSERT INTO LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly
#         SELECT DISTINCT date_trunc(month,date) as date, user_sso_guid, region, organization, platform, user_type
#         FROM LOOKER_SCRATCH.kpi_user_counts_weekly
#         WHERE date > (SELECT COALESCE(MAX(date), '1970-01-01') FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly)
#         ORDER BY 1;;

#       sql_step:
#         ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly CLUSTER BY(date) ;;

#       sql_step:
#         ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations_monthly RECLUSTER ;;


#     }
#     datagroup_trigger: daily_refresh

#   }

#   dimension: date {type:date_raw hidden:yes}

#   dimension: epoch_date {type:number hidden:yes}

#   dimension: user_sso_guid {hidden:yes}
#   dimension: region {hidden:yes}
#   dimension: organization {label:"Market Segment"}
#   dimension: platform {hidden: yes}
#   dimension: user_type {hidden: yes}

#   dimension: region_clean {
#     label: "Region"
#     sql: CASE WHEN ${region} = 'USA' THEN 'US' ELSE 'Non-US' END ;;
#   }
#   dimension: platform_clean {
#     label: "Platform"
#     sql: CASE WHEN ${platform} IN ('CU Subscription','Cengage Unlimited') THEN 'Cengage Unlimited'
#               WHEN ${platform} IN ('MindTap Reader', 'Middle Product') THEN ${platform}
#               WHEN ${platform} ILIKE '%MindTap%' THEN 'MindTap'
#               WHEN ${platform} ILIKE '%webassign%' THEN 'WebAssign'
#               WHEN ${platform} ILIKE '%ebook%' THEN 'Other eBook'
#               WHEN ${platform} ILIKE '%cnow%' THEN 'CNOW'
#               WHEN ${platform} ILIKE '%aplia%' THEN 'Aplia'
#               WHEN ${platform} ILIKE '%owl%' THEN 'OWL'
#               WHEN ${platform} ILIKE 'sam' THEN 'SAM'
#               WHEN ${platform} ILIKE '%coursemate%' THEN 'CourseMate'
#               WHEN ${platform} ILIKE '%4ltr%' THEN '4LTR'
#               WHEN ${platform} ILIKE '%national geographic%' THEN 'National Geographic'
#               ELSE 'Other'
#           END
#     ;;
#   }





#   }
