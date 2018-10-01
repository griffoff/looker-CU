view: ebook_usage_actions {
    derived_table: {
      persist_for: "24 hours"

      sql:
          WITH combined_ebook_data AS
           (SELECT
              event_time
              ,user_sso_guid
              ,vbid AS ebook_id
              ,event_action
              ,event_type AS event_category
              ,'VS' AS source
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
              ,'MTR' AS source
              ,reading_page_view
              ,reading_page_count
              ,NULL AS target_name
              ,NULL AS search_term
            FROM cap_er.prod.raw_mt_resource_interactions
            WHERE (event_category = 'READING' AND event_action = 'VIEW')
            OR (event_category = 'BOOKMARKS' AND event_action ='CREATE')
            OR (event_category = 'HIGHLIGHT')
            OR (event_category = 'QUICKNOTE' AND event_action = 'CREATE')

            UNION

           SELECT
            TO_TIMESTAMP_LTZ(visitstarttime) AS event_time
            ,userssoguid AS user_sso_guid
            ,ssoisbn AS ebook_id
            ,eventaction AS event_action
            ,eventcategory AS event_category
            ,'MTM' AS source
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
              *
            FROM combined_ebook_data
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


  dimension: event_age_weeks {
    type: number
    sql: DATEDIFF(week, ${raw_subscription_event.subscription_start_date}, ${event_time_date})  ;;
  }

  dimension: event_age_days {
    type: number
    sql: DATEDIFF(day, ${raw_subscription_event.subscription_start_date}, ${event_time_date})  ;;
  }


    dimension_group: event_time {
      type: time
      timeframes: [year, month, week, date]
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


    measure: number_of_views {
      group_label: "Action Counts"
      type: sum
      sql: CASE WHEN ${ebook_mapping.common_action} = 'Page View' THEN 1 ELSE 0 END ;;
    }

   measure: number_of_bookmarks {
     group_label: "Action Counts"
     type: sum
     sql: CASE WHEN ${ebook_mapping.common_action} = 'Bookmark' THEN 1 ELSE 0 END ;;
   }

   measure: number_of_highlights {
     group_label: "Action Counts"
     type: sum
     sql: CASE WHEN ${ebook_mapping.common_action} = 'Highlight' THEN 1 ELSE 0 END ;;
   }

   measure: number_of_notes {
     group_label: "Action Counts"
     type: sum
     sql: CASE WHEN ${ebook_mapping.common_action} = 'Note' THEN 1 ELSE 0 END ;;
   }

   measure: number_of_searches {
     group_label: "Action Counts"
      type: sum
      sql: CASE WHEN ${ebook_mapping.common_action} = 'Search' THEN 1 ELSE 0 END ;;
    }

    measure: number_of_prints {
      group_label: "Action Counts"
      type: sum
      sql: CASE WHEN ${ebook_mapping.common_action} = 'Print' THEN 1 ELSE 0 END ;;
    }

    measure: number_of_downloads {
      group_label: "Action Counts"
      type: sum
      sql: CASE WHEN ${ebook_mapping.common_action} = 'Search' THEN 1 ELSE 0 END ;;
    }

    measure: number_of_listen_tts {
      group_label: "Action Counts"
      type: sum
      sql: CASE WHEN ${ebook_mapping.common_action} = 'Listen TTS' THEN 1 ELSE 0 END ;;
    }

    measure: number_of_change_speed {
      group_label: "Action Counts"
      type: sum
      sql: CASE WHEN ${ebook_mapping.common_action} = 'Change Speed' THEN 1 ELSE 0 END ;;
    }

    measure: number_of_change_font {
      group_label: "Action Counts"
      type: sum
      sql: CASE WHEN ${ebook_mapping.common_action} = 'Font Change' THEN 1 ELSE 0 END ;;
    }


  }
