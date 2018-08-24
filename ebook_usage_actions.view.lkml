view: ebook_usage_actions {
    derived_table: {
      sql:
          WITH combined_ebook_data AS
           (SELECT
              event_time
              ,user_sso_guid
              ,vbid AS ebook_id
              ,event_action
              ,event_type AS event_category
              ,'vital source' AS source
              ,NULL AS reading_page_view
              ,NULL AS reading_page_count
              ,target_name
              ,search_term
            FROM unlimited.raw_vitalsource_event
            WHERE event_action NOT IN ('LoggedIn', 'NavigatedTo')

            UNION

            SELECT
              event_time
              ,user_identifier AS user_sso_guid
              ,core_text_isbn AS ebook_id
              ,event_action
              ,event_category
              ,'mind tap reader' AS source
              ,reading_page_view
              ,reading_page_count
              ,NULL AS target_name
              ,NULL AS search_term
            FROM cap_er.prod.raw_mt_resource_interactions
            WHERE (event_category = 'READING' AND event_action = 'VIEW')
            OR (event_category = 'BOOKMARKS' AND event_action ='CREATE')
            OR event_category = 'HIGHTLIGHT'
            OR (event_category = 'QUICKNOTE' AND event_action = 'CREATE')

            UNION

           SELECT
            TO_TIMESTAMP_LTZ(visitstarttime) AS event_time
            ,userssoguid AS user_sso_guid
            ,ssoisbn AS ebook_id
            ,eventaction AS event_action
            ,eventcategory AS event_category
            ,'mind tap mobile' AS source
            ,NULL AS reading_page_view
            ,NULL AS reading_page_count
            ,NULL AS target_name
            ,NULL AS search_term
            FROM prod.raw_ga.ga_mobiledata
            WHERE ssoisbn IS NOT NULL
            AND (
            eventaction ILIKE '%Highlight%'
            OR eventaction IN ('Bookmark', 'Note', 'Search', 'Listen TTS', 'Change Speed', 'Font Change')
            OR eventaction IN ('Book Download Cellular', 'Book Download Success', 'EBook Download Complete')
            )
            )


            SELECT
              ced.event_time AS event_time
              ,subscription_start
              ,subscription_end
              ,subscription_state
              ,DATEDIFF('week', subscription_start, event_time) AS event_age_weeks
              ,DATEDIFF('day', subscription_start, event_time) AS event_age_days
              ,ced.user_sso_guid AS user_sso_guid
              ,ced.ebook_id AS ebook_id
              ,ced.event_action AS event_action
              ,ced.event_category AS event_category
              ,ced.source AS source
              ,reading_page_view
              ,reading_page_count
              ,target_name
              ,search_term
              ,COALESCE(em.map, event_action) AS common_action
              ,CASE WHEN (rse.message_type = 'CUSubscription') THEN 1 ELSE 0 END AS unlimited_user
              ,CASE WHEN (ced.user_sso_guid IN (SELECT DISTINCT user_sso_guid FROM unlimited.clts_excluded_users)) THEN 1 ELSE 0 END AS internal_user
            FROM combined_ebook_data ced
            LEFT JOIN unlimited.raw_subscription_event rse
            ON ced.user_sso_guid = rse.user_sso_guid
            LEFT JOIN uploads.ebook_usage.ebook_mapping em
            ON ced.event_action = em.action
            AND ced.source = em.source
            ;;

    }



    dimension: read_page_view {
      type: string
    }

  dimension: reading_page_count {
    type: number
  }

  dimension: target_name {
    type: string
  }

  dimension: search_term {
    type: string
  }

  dimension: subscription_start {
    type: date
  }

  dimension: subscription_end {
    type: date
  }

  dimension: subscription_state {
    type: string
  }

  dimension: event_age_weeks {
    type: number
  }

  dimension: event_age_days {
    type: number
  }


    dimension_group: event_time {
      type: time
      timeframes: [year, month, week, date]

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

    dimension: event_category {
      type: string
    }

    dimension: source {
      type: string
    }

    dimension: unlimited_user {
      type: number
    }

  dimension: internal_user {
    type: number
  }

  dimension: common_action {
    type: string
  }


    measure: count {
      type: count
    }

    measure: unique_product_count {
      type: count_distinct
      sql: ${ebook_id} ;;
    }

    measure: unique_user_count {
      type: count_distinct
      sql: ${user_sso_guid} ;;
    }
  }
