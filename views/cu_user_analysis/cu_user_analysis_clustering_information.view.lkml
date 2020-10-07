explore: cu_user_analysis_clustering_information {}
view: cu_user_analysis_clustering_information {
  derived_table: {
    sql:
    select t.*, convert_timezone('America/New_York',current_timestamp()) as refresh_time, key as unique_values_partition, value as partition_count
    from prod.information_schema.tables t
    cross join lateral flatten (parse_json(system$clustering_information('prod.cu_user_analysis.all_events')::variant):partition_depth_histogram)
    where TABLE_NAME = 'ALL_EVENTS'
    and TABLE_SCHEMA = 'CU_USER_ANALYSIS'
    union all
    select t.*, convert_timezone('America/New_York',current_timestamp()) as refresh_time, key as unique_values_partition, value as partition_count
    from prod.information_schema.tables t
    cross join lateral flatten (parse_json(system$clustering_information('prod.cu_user_analysis.all_sessions')::variant):partition_depth_histogram)
    where TABLE_NAME = 'ALL_SESSIONS'
    and TABLE_SCHEMA = 'CU_USER_ANALYSIS'
    ;;
  }

  dimension: refresh_time {label: "Refresh Time EST" type:date_time}

  dimension:  unique_values_partition {}

  dimension: partition_count {type: number}

  dimension: table_name {}

  dimension: clustering_key {}

  dimension: auto_clustering_on {}

}
