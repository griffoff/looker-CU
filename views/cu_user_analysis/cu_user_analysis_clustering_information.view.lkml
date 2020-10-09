explore: cu_user_analysis_clustering_information {}

explore: cu_user_analysis_clustering_information_history {
  join: partition_depth_histogram {
    sql: cross join lateral flatten(clustering_information:partition_depth_histogram) AS partition_depth_histogram;;
  }
}

view: partition_depth_histogram {
  dimension: unique_values_partition {type: number sql:${TABLE}.key;; value_format:"00000"}

  dimension: partition_count {type: number sql: ${TABLE}.value;;}

  measure: partition_count_avg {type: number sql: AVG(${TABLE}.value);;}
}

view: clustering_information_fields {
  dimension: refresh_time {label: "Refresh Time EST" type:date_time sql: convert_timezone('America/New_York', ${TABLE}.refresh_time) ;;}

  dimension: table_name {
    sql:${TABLE}.table_info:TABLE_NAME::STRING ;;
  }

  dimension: clustering_key {
    sql:${TABLE}.table_info:CLUSTERING_KEY::STRING ;;
  }

  dimension: auto_clustering_on {
    type: yesno
    sql:${TABLE}.table_info:AUTO_CLUSTERING_ON::BOOLEAN ;;
  }

}

view: cu_user_analysis_clustering_information_history {
  extends: [clustering_information_fields]

  derived_table: {
    create_process: {
      sql_step:
        CREATE TRANSIENT TABLE IF NOT EXISTS LOOKER_SCRATCH.clustering_information
        (
          table_info VARIANT
          , refresh_time TIMESTAMP DEFAULT(current_timestamp())
          , clustering_information  VARIANT
          , _latest BOOLEAN DEFAULT(TRUE)
        )
      ;;
      sql_step:
        UPDATE LOOKER_SCRATCH.clustering_information
        SET _latest = FALSE
      ;;
      sql_step:
        INSERT INTO LOOKER_SCRATCH.clustering_information (table_info, clustering_information)
        SELECT
            OBJECT_CONSTRUCT(t.*)
            ,PARSE_JSON(v.$4::VARIANT) as clustering_information
        FROM values
        ('PROD', 'CU_USER_ANALYSIS', 'ALL_EVENTS', system$clustering_information('prod.cu_user_analysis.all_events'))
        ,('PROD', 'CU_USER_ANALYSIS', 'ALL_SESSIONS', system$clustering_information('prod.cu_user_analysis.all_sessions')) v
        INNER JOIN prod.information_schema.tables t ON (v.$1, v.$2, v.$3) = (t.table_catalog, t.table_schema, t.table_name)
        ;;
      sql_step:
        CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME} CLONE LOOKER_SCRATCH.clustering_information;;
    }

    sql_trigger_value: SELECT CURRENT_DATE() ;;
  }

}

view: cu_user_analysis_clustering_information {
  extends: [clustering_information_fields, partition_depth_histogram]

  derived_table: {
    sql:
      select
        h.*
        , c.key
        , c.value
      from ${cu_user_analysis_clustering_information_history.SQL_TABLE_NAME} h
      cross join lateral flatten (h.clustering_information:partition_depth_histogram) c
      where h._latest
      ;;
  }

}
