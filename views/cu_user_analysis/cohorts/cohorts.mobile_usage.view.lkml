include: "cohorts.base.view"

view: mobile_usage {
  derived_table: {
    sql: SELECT
          user_sso_guid
          ,d.terms_chron_order_desc
          ,d.governmentdefinedacademicterm
          ,event_data:course_key::STRING as course_key
          ,COUNT(*) as events
          ,SUM(event_data:event_duration) / 60 AS duration
      FROM prod.cu_user_analysis.all_events e
      INNER JOIN ${date_latest_5_terms.SQL_TABLE_NAME} d
        ON e.event_time::DATE >= d.start_date AND e.event_time::DATE <= d.end_date
      WHERE load_metadata:source = 'Mobile'
      AND user_sso_guid != ''
      GROUP BY 1, 2, 3, 4;;
    }
}

view: cohorts_mobile_usage {
  extends: [cohorts_base_binary]
  #extends: [cohorts_base_number]
  derived_table: {
    sql:
         SELECT
            user_sso_guid AS user_sso_guid_merged
            ,SUM(CASE WHEN terms_chron_order_desc = 1 THEN duration ELSE 0 END) AS "1"
            ,SUM(CASE WHEN terms_chron_order_desc = 2 THEN duration ELSE 0 END) AS "2"
            ,SUM(CASE WHEN terms_chron_order_desc = 3 THEN duration ELSE 0 END) AS "3"
            ,SUM(CASE WHEN terms_chron_order_desc = 4 THEN duration ELSE 0 END) AS "4"
            ,SUM(CASE WHEN terms_chron_order_desc = 5 THEN duration ELSE 0 END) AS "5"
          FROM ${mobile_usage.SQL_TABLE_NAME}
          GROUP BY 1
            ;;
  }

  dimension: current {group_label: "Mobile App Used"
    #value_format: "0.0 \m\i\n\s" description: "Time spent using mobile app"
    }

  dimension: minus_1 {group_label: "Mobile App Used"
    #value_format: "0.0 \m\i\n\s" description: "Time spent using mobile app"
    }

  dimension: minus_2 {group_label: "Mobile App Used"
    #value_format: "0.0 \m\i\n\s" description: "Time spent using mobile app"
    }

  dimension: minus_3 {group_label: "Mobile App Used"
    #value_format: "0.0 \m\i\n\s" description: "Time spent using mobile app"
    }

  dimension: minus_4 {group_label: "Mobile App Used"
    #value_format: "0.0 \m\i\n\s" description: "Time spent using mobile app"
    }

}
