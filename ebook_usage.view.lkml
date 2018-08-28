view: ebook_usage {
  derived_table: {
    sql:
    WITH combined_ebook_data AS
     (SELECT
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
      AND course_uri LIKE '%course-key:Cengage%'

      UNION

      SELECT
      TO_TIMESTAMP_LTZ(visitstarttime) AS event_time
      ,userssoguid AS user_sso_guid
      ,ssoisbn AS ebook_id
      ,eventaction AS event_action
      ,'mind tap mobile' AS source
      FROM prod.raw_ga.ga_mobiledata
      WHERE eventcategory = 'Reader'
      AND ssoisbn IS NOT NULL)


      SELECT
        ced.event_time AS event_time
        ,ced.user_sso_guid AS user_sso_guid
        ,ced.ebook_id AS ebook_id
        ,ced.event_action AS event_action
        ,ced.source AS source
        ,CASE WHEN (rse.message_type = 'CUSubscription') THEN 1 ELSE 0 END AS unlimited_user
      FROM combined_ebook_data ced
      JOIN unlimited.raw_subscription_event rse
      ON ced.user_sso_guid = rse.user_sso_guid
      WHERE ced.user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.clts_excluded_users) ;;
  }

# dimension_group: event_time {
#   type: time
#   timeframes: [date, week, month, quarter, year]
# }

  dimension: event_time {
    type: date
#     sql: ${TABLE}.event_time ;;
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

  dimension: unlimited_user {
    type: number
  }

measure: count {
  type: count
}

measure: unique_product_count {
  type: count_distinct
  sql: ${ebook_id} ;;
}
  }
