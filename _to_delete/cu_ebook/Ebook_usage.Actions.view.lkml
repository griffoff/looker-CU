# view: ebook_usage_actions {
#     derived_table: {
#       persist_for: "24 hours"

#       sql:
#           WITH combined_ebook_data AS
#           (SELECT
#               event_time
#               ,user_sso_guid
#               ,vbid AS ebook_id
#               ,event_action
#               ,event_type AS event_category
#               ,'VS' AS source
#               ,'VitalSource Reader' AS source_full_name
#               ,target_name::string AS page_number
#               ,NULL AS reading_page_count
#               ,search_term
#             FROM unlimited.raw_vitalsource_event
#             WHERE event_action NOT IN ('LoggedIn', 'NavigatedTo')

#             UNION

#             SELECT
#               event_time
#               ,user_identifier AS user_sso_guid
#               ,core_text_isbn AS ebook_id
#               ,event_action
#               ,event_category
#               ,'MTR' AS source
#               ,'MindTap Reader' AS source_full_name
#               ,reading_page_view::string AS page_number
#               ,reading_page_count
#               ,NULL AS search_term
#             FROM cap_er.prod.raw_mt_resource_interactions
#             WHERE (event_category = 'READING' AND event_action = 'VIEW')
#             OR (event_category = 'BOOKMARKS' AND event_action ='CREATE')
#             OR (event_category = 'HIGHLIGHT')
#             OR (event_category = 'QUICKNOTE' AND event_action = 'CREATE')

#             UNION

#           SELECT
#             TO_TIMESTAMP_LTZ(visitstarttime) AS event_time
#             ,userssoguid AS user_sso_guid
#             ,ssoisbn AS ebook_id
#             ,eventaction AS event_action
#             ,eventcategory AS event_category
#             ,'MTM' AS source
#             ,'MindTap Mobile Reader' AS source_full_name
#             ,NULL AS page_number
#             ,NULL AS reading_page_count
#             ,NULL AS search_term
#             FROM prod.raw_ga.ga_mobiledata
#             WHERE ssoisbn IS NOT NULL
#             AND (
#             eventaction ILIKE '%Highlight%'
#             OR eventaction IN ('Bookmark', 'Note', 'Search', 'Listen TTS', 'Change Speed', 'Font Change')
#             OR eventaction IN ('Book Download Cellular', 'Book Download Success', 'EBook Download Complete')
#             )
#             )


#             SELECT
#               *
#             FROM combined_ebook_data
#             ;;

#     }



#     dimension: page_number {
#       type: string
#       sql: TABLE."page_number" ;;
#       label: "Page Number Viewed"
#       description: "The number of the page viewed for a VitalSource or MindTap reader view"
#     }

#   dimension: reading_page_count {
#     type: string
#     sql: TABLE."reading_page_count" ;;
#     label: "Number of Pages"
#     description: "Number of pages in a MindTap Reader reading activity"
#   }


#   dimension: search_term {
#     type: string
#     sql: TABLE."search_term" ;;
#     label: "Search Term"
#     description: "Term searched for in a VitalSource Reader search event"
#   }


#   dimension: event_age_weeks {
#     type: number
#     sql: DATEDIFF(week, ${raw_subscription_event.subscription_start_date}, ${event_time_date})  ;;
#     label: "Weeks since subscription start"
#     description: "Number of weeks after the user's subscription start date to the event occuring"
#   }

#   dimension: event_age_days {
#     type: number
#     sql: DATEDIFF(day, ${raw_subscription_event.subscription_start_date}, ${event_time_date})  ;;
#     label: "Days since subscription start"
#     description: "Number of days after the user's subscription start date to the event occuring"
#   }


#     dimension_group: event_time {
#       type: time
#       timeframes: [year, month, week, date]
#     }

#     dimension: user_sso_guid {
#       type: string
#       primary_key: yes
#     }

#     dimension: ebook_id {
#       type: string
#       label: "E-book Identifier"
#       description: "Ebook identifier: VBID for VitalSource, core_text_isbn for MindTap Reader, ssoisbn for MindTap Mobile Reader"
#     }

#     dimension: event_action {
#       type: string
#       label: "User Action"
#       description: "A user action on a reader platform: https://wiki.cengage.com/display/cap/eBook+Reader+Events"
#     }

#     dimension: event_category {
#       type: string
#       label: "Category of User Actions"
#       description: "Category of User Actions differeing accross reader"
#     }

#     dimension: source {
#       type: string
#       label: "Reader Source Abbreviation"
#       description: "Which reader the event came from: MindTap Reader (MTR), MindTap Mobile Reader (MTM), or VitalSource Reader (VS)"
#     }

#   dimension: source_full_name {
#     type: string
#     label: "Reader Source Name"
#     description: "Which reader the event came from: MindTap Reader, MindTap Mobile Reader, or VitalSource Reader"
#   }

#     measure: unique_day_opens {
#       type: count_distinct
#       sql: hash(${event_time_date}, ${ebook_id});;
#     }

#     measure: unique_day_opens_over_2 {
#       type: number
#       sql: CASE WHEN ${unique_day_opens} >= 2 THEN 1 ELSE 0 END ;;
#     }

#     measure: count {
#       type: count
#     }

#     measure: unique_product_count {
#       type: count_distinct
#       sql: ${ebook_id} ;;
#     }

#     measure: unique_user_count {
#       type: count_distinct
#       sql: ${user_sso_guid} ;;
#     }


#     measure: number_of_views {
#       group_label: "Action Counts"
#       type: sum
#       sql: CASE WHEN ${ebook_mapping.common_action} = 'View' THEN 1 ELSE 0 END ;;
#     }

#   measure: number_of_bookmarks {
#     group_label: "Action Counts"
#     type: sum
#     sql: CASE WHEN ${ebook_mapping.common_action} = 'Bookmark' THEN 1 ELSE 0 END ;;
#   }

#   measure: number_of_highlights {
#     group_label: "Action Counts"
#     type: sum
#     sql: CASE WHEN ${ebook_mapping.common_action} = 'Highlight' THEN 1 ELSE 0 END ;;
#   }

#   measure: number_of_notes {
#     group_label: "Action Counts"
#     type: sum
#     sql: CASE WHEN ${ebook_mapping.common_action} = 'Note' THEN 1 ELSE 0 END ;;
#   }

#   measure: number_of_searches {
#     group_label: "Action Counts"
#       type: sum
#       sql: CASE WHEN ${ebook_mapping.common_action} = 'Search' THEN 1 ELSE 0 END ;;
#     }

#     measure: number_of_prints {
#       group_label: "Action Counts"
#       type: sum
#       sql: CASE WHEN ${ebook_mapping.common_action} = 'Print' THEN 1 ELSE 0 END ;;
#     }

#     measure: number_of_downloads {
#       group_label: "Action Counts"
#       type: sum
#       sql: CASE WHEN ${ebook_mapping.common_action} = 'Download' THEN 1 ELSE 0 END ;;
#     }

#     measure: number_of_listen_tts {
#       group_label: "Action Counts"
#       type: sum
#       sql: CASE WHEN ${ebook_mapping.common_action} = 'Listen TTS' THEN 1 ELSE 0 END ;;
#     }

#     measure: number_of_change_speed {
#       group_label: "Action Counts"
#       type: sum
#       sql: CASE WHEN ${ebook_mapping.common_action} = 'Change Speed' THEN 1 ELSE 0 END ;;
#     }

#     measure: number_of_change_font {
#       group_label: "Action Counts"
#       type: sum
#       sql: CASE WHEN ${ebook_mapping.common_action} = 'Font Change' THEN 1 ELSE 0 END ;;
#     }


#   }
