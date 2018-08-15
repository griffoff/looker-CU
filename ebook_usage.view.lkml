view: ebook_usage {
  derived_table: {
    sql:
      SELECT
        event_time
        ,user_sso_guid
        ,vbid AS ebook_id
        ,event_action
        ,'vital source' AS source
      FROM unlimited.raw_vitalsource_event
      WHERE event_action = 'Searched'
      OR event_action = 'Viewed'

      UNION

      SELECT
        event_time
        ,user_identifier AS user_sso_guid
        ,core_text_isbn AS ebook_id
        ,event_action
        ,'mind tap reader' AS source
      FROM cap_er.prod.raw_mt_resource_interactions
      WHERE event_category = 'READING'
      AND event_action = 'VIEW'

      UNION

      SELECT
      TO_TIMESTAMP_LTZ(visitstarttime) AS event_time
      ,userssoguid AS user_sso_guid
      ,ssoisbn AS ebook_id
      ,eventcategory AS event_action
      ,'mind tap mobile' AS source
      FROM prod.raw_ga.ga_mobiledata
      WHERE eventcategory = 'Reader'
      AND ssoisbn IS NOT NULL
      ;;
  }

dimension_group: event_time {
  type: time
  timeframes: [date, week, month, quarter, year]
}

dimension: user_sso_guid {
  type: string
  primary_key: yes
}

dimension: ebook_id {
  type: string
}

dimension: event_action {
  type: string
}

dimension: source {
  type: string
}

measure: count {
  type: count
}

measure: unique_product_count {
  type: count_distinct
  sql: ${ebook_id} ;;
}
  }
