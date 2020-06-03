explore: kpi_user_counts_filter_combinations {hidden:yes}
view: kpi_user_counts_filter_combinations {
  view_label: "Filters"

  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.kpi_user_counts_filter_combinations
        (
          user_sso_guid STRING NOT NULL
          ,region STRING NOT NULL
          ,organization STRING NOT NULL
          ,platform STRING NOT NULL
          ,user_type STRING NOT NULL
        )
        ;;

      sql_step:
        INSERT INTO LOOKER_SCRATCH.kpi_user_counts_filter_combinations
        SELECT DISTINCT user_sso_guid, region, organization, platform, user_type
        FROM looker_scratch.kpi_user_counts
        EXCEPT
        (
        SELECT user_sso_guid, region, organization, platform, user_type
        FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations
        )
        ORDER BY user_sso_guid
        ;;

      sql_step:
        ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations CLUSTER BY (user_sso_guid);;

      sql_step:
        ALTER TABLE LOOKER_SCRATCH.kpi_user_counts_filter_combinations RECLUSTER;;

      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.kpi_user_counts_filter_combinations
      ;;
    }
    datagroup_trigger: daily_refresh

  }

  dimension: user_sso_guid {}
  dimension: region {}
  dimension: organization {}
  dimension: platform {}
  dimension: user_type {}




   }
