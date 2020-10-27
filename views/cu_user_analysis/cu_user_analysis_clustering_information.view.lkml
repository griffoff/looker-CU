explore: cu_user_analysis_clustering_information {}

explore: cu_user_analysis_clustering_information_history {
  from: cu_user_analysis_clustering_information_history
  view_name: cu_user_analysis_clustering_information
  join: partition_depth_histogram {
    sql: cross join lateral flatten(clustering_information:partition_depth_histogram) AS partition_depth_histogram;;
    relationship: many_to_many
  }
}

view: partition_depth_histogram {
  dimension: unique_values_partition_sort {
    type: number
    sql:${TABLE}.key::INT;;
    hidden: yes
  }
  dimension: unique_values_partition {
    type: string
    sql:${TABLE}.key::STRING;;
    order_by_field: unique_values_partition_sort
  }

  dimension: partition_count {type: number sql: ${TABLE}.value;;}

  measure: partition_count_avg {type: number sql: AVG(${TABLE}.value);;}
}

view: clustering_information_fields {
  dimension: refresh_time {label: "Refresh Time EST" type:date_time sql: convert_timezone('America/New_York', ${TABLE}.refresh_time) ;;}

  dimension_group: refresh_age {
    label: "Since Refresh"
    type: duration
    intervals: [minute, hour, day, week]
    sql_start: ${refresh_est_raw} ;;
    sql_end: CURRENT_TIMESTAMP() ;;
  }

  dimension_group: refresh_est {label: "Refresh Date EST"
    type:time
    timeframes: [raw, time, date, week]
    sql: convert_timezone('America/New_York', ${TABLE}.refresh_time) ;;
  }

  dimension: average_overlaps {
    type: number
    sql: ${TABLE}.clustering_information:average_overlaps ;;
  }

  dimension: average_depth {
    type: number
    sql: ${TABLE}.clustering_information:average_depth ;;
  }

  dimension: table_name {
    case: {
      when: {
        label: "ALL_EVENTS" sql:${TABLE}.table_info:TABLE_NAME = 'ALL_EVENTS';;
      }
      when: {
        label: "ALL_SESSIONS" sql:${TABLE}.table_info:TABLE_NAME = 'ALL_SESSIONS';;
      }
      when: {
        label: "CLIENT_ACTIVITY_EVENT" sql:${TABLE}.table_info:TABLE_NAME = 'CLIENT_ACTIVITY_EVENT';;
      }
    }
    # sql:${TABLE}.table_info:TABLE_NAME::STRING ;;
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
          refresh_time TIMESTAMP DEFAULT(current_timestamp())
          , table_info VARIANT
          , clustering_information  VARIANT
          , _latest BOOLEAN DEFAULT(TRUE)
        )
      ;;
      sql_step:
        MERGE INTO LOOKER_SCRATCH.clustering_information o
        USING (
          SELECT
              OBJECT_CONSTRUCT(t.*) as table_info
              ,PARSE_JSON(v.$4::VARIANT) as clustering_information
          FROM values
          ('PROD', 'CU_USER_ANALYSIS', 'ALL_EVENTS', system$clustering_information('prod.cu_user_analysis.all_events'))
          ,('PROD', 'CU_USER_ANALYSIS', 'ALL_SESSIONS', system$clustering_information('prod.cu_user_analysis.all_sessions')) v
          INNER JOIN prod.information_schema.tables t ON (v.$1, v.$2, v.$3) = (t.table_catalog, t.table_schema, t.table_name)
          UNION ALL
          SELECT
              OBJECT_CONSTRUCT(t.*) as table_info
              ,PARSE_JSON(v.$4::VARIANT) as clustering_information
          FROM values
          ('CAP_EVENTING', 'PROD', 'CLIENT_ACTIVITY_EVENT', system$clustering_information('cap_eventing.prod.client_activity_event')) v
          INNER JOIN cap_eventing.information_schema.tables t ON (v.$1, v.$2, v.$3) = (t.table_catalog, t.table_schema, t.table_name)
        ) n ON o.table_info:TABLE_NAME = n.table_info:TABLE_NAME
            and o._latest
            and hash(o.clustering_information) = hash(n.clustering_information)
        WHEN NOT MATCHED THEN
          INSERT (table_info, clustering_information)
          VALUES (n.table_info, n.clustering_information)
        ;;

        sql_step:
              MERGE INTO LOOKER_SCRATCH.clustering_information o
              USING (
                  SELECT table_info:TABLE_NAME as table_name, MAX(refresh_time) as latest_time
                  FROM LOOKER_SCRATCH.clustering_information
                  GROUP BY 1
              ) l ON o.table_info:TABLE_NAME = l.table_name AND o._latest
              WHEN MATCHED AND o.refresh_time != l.latest_time THEN
                  UPDATE SET _latest = FALSE
              ;;

          sql_step:
                  CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME} CLONE LOOKER_SCRATCH.clustering_information;;
        }

        sql_trigger_value: SELECT CURRENT_TIMESTAMP() ;;
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
