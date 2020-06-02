explore: kpi_user_counts_filter_combinations {hidden:yes}
view: kpi_user_counts_filter_combinations {
  view_label: "Filters"

  derived_table: {
    create_process: {
      sql_step:
      CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.kpi_user_counts_filter_combinations
      (
      date DATE
      ,region STRING
      ,organization STRING
      ,platform STRING
      ,user_type STRING
      )
      ;;

      sql_step:
      INSERT INTO LOOKER_SCRATCH.kpi_user_counts_filter_combinations
      SELECT DISTINCT date, region, organization, platform, user_type
      FROM looker_scratch.kpi_user_counts
      WHERE date < current_date() and date > (SELECT COALESCE(MAX(date),'2018-08-01') FROM LOOKER_SCRATCH.kpi_user_counts_filter_combinations)
      ;;
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.kpi_user_counts_filter_combinations
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




   }
