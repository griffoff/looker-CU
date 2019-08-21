# include: "/core/common.lkml"
view: all_events {
  view_label: "Events"
  sql_table_name: prod.cu_user_analysis.all_events ;;

  set: marketing_fields {
    fields: [all_events.event_subscription_state, all_events.product_platform, all_events.event_name, all_events.local_date, all_events.local_time, all_events.local_week]
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    label: "User SSO GUID"
    hidden: yes
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
    primary_key: yes
    label: "Event ID"
    description: "A unique identifier given to each event"
    hidden: yes
  }

  dimension: event_subscription_state {
    label: "Subscription State"
    type: string
    sql: COALESCE(${TABLE}.subscription_state, INITCAP(REPLACE(${TABLE}.event_data:subscription_state, '_', ' ')));;
    description: "Subscription state at the time of the event"
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
    label: "Event type"
    description: "The highest level in the hierarchy of event classicfication above event action"
    hidden: yes
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
    label: "Event data"
    description: "Data associated with a given event in a json format containing information like page number, URL, coursekeys, device information, etc."
  }

  dimension: campaign_msg_id{
    type: string
    sql: CASE WHEN ${event_name} ilike 'IPM%'
          THEN ${event_data}:message_id
          ELSE NULL
          END;;
  }

  dimension: side_bar_coursekey {
    group_label: "Sidebar tag events"
    label: "Course key"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:courseKey::string END ;;
    hidden: no
  }


  dimension: side_bar_carouselName {
    group_label: "Sidebar tag events"
    label: "Carousel name"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:carouselName::string END ;;
    hidden: no
  }

  dimension: side_bar_carouselSessionId {
    group_label: "Sidebar tag events"
    label: "Carousel session Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:carouselSessionId::string END ;;
    hidden: no
  }


  dimension: side_bar_activityId {
    group_label: "Sidebar tag events"
    label: "Activity Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:activityId::string END ;;
    hidden: no
  }

  dimension: side_bar_checkpointId {
    group_label: "Sidebar tag events"
    label: "checkpoint Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:checkpointId::string END ;;
    hidden: no
  }


  dimension: side_bar_contentType {
    group_label: "Sidebar tag events"
    label: "Content type"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:contentType::string END ;;
    hidden: no
  }

  dimension: side_bar_pointInSemester {
    group_label: "Sidebar tag events"
    label: "Point In Semester"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:pointInSemester::string END ;;
    hidden: no
  }

  dimension: side_bar_discipline {
    group_label: "Sidebar tag events"
    label: "Discipline"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:discipline::string END ;;
    hidden: no
  }

  dimension: side_bar_studyToolCgi {
    group_label: "Sidebar tag events"
    label: "Study Tool Cgi"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:studyToolCgi::string END ;;
    hidden: no
  }

  dimension: side_bar_ISBN {
    group_label: "Sidebar tag events"
    label: "ISBN"
    type: string
    sql: CASE WHEN ${product_platform} = 'cu-side-bar' THEN ${event_data}:ISBN::string END ;;
    hidden: no
  }


  dimension: product_platform {
    type: string
    group_label: "Event Classification"
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
    label: "Event Source"
    description: "Where did this event come from? e.g. VitalSource, CU DASHBOARD, MT4, MT3, SubscriptionService, cares-dashboard, olr"
    hidden: no
  }

  dimension: session_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SESSION_ID" ;;
    label: "Session ID"
    description: "A unique identfier given to each session"
    hidden: yes
  }

  dimension: search_flag {
    label: "Dashboard Search Flags"
    sql: CASE WHEN ${event_name} ilike 'Dashboard Search%' THEN 'Dashboard Search' ELSE 'No Dashboard Search' END ;;
  }

  dimension:search_outcome{
    group_label: "Search"
    label: "Search outcome successful"
    description: "Y indicates search resulted in the user adding a product to their dashboard and N if not"
    sql:   event_data:search_outcome;;
  }

  dimension: search_term {
    group_label: "Search"
    label: "Search term"
    description: "The term the user searched for on this given search"
    sql: event_data:search_term ;;
  }

  dimension: system_category {
    group_label: "Event Classification"
    type: string
    sql: ${TABLE}."SYSTEM_CATEGORY" ;;
    label: "System category"
    description: " Categorizes events by system eg: Cengage Unlimited, Registrations"
  }

  dimension: event_action {
    group_label: "Event Classification"
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
    label: "Event action"
    description: "A classification of event within the hierachy of events beneath event type and above event name i.e. 'OLR Enrollment'"
    hidden: yes
  }

  dimension: event_name {
    group_label: "Event Classification"
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
    label: "Event name"
    description: "The lowest level in hierarchy of event classification below event action. Can be asscoaited with describing a user action in plain english i.e. 'Buy Now Button Click'"
  }

  dimension_group: local {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year]
    sql: convert_timezone('UTC', ${TABLE}."LOCAL_TIME") ;;
    group_label: "Event Time"
    label: "Event"
    description: "Components of the events local timestamp"
  }

  measure: user_count {
    label: "# people"
    type: count_distinct
    sql: ${user_sso_guid} ;;
    drill_fields: [system_category, product_platform, event_type, event_action, count]
    description: "Measure for counting unique users (drill fields)"
    hidden: yes
  }

  measure: count {
    group_label: "# Events"
    label: "# Events"
    type: count
#     drill_fields: [event_day_of_week, count]
    description: "Measure for counting events (drill fields)"
  }

  measure: events_in_full_access {
    group_label: "# Events"
    label: "# Events while in full access"
    type: number
    sql: COUNT(CASE WHEN ${event_subscription_state} = 'Full Access' THEN 1 END) ;;
  }

  measure: events_in_locker {
    group_label: "# Events"
    label: "# Events while in locker status"
    type: number
    sql: COUNT(CASE WHEN ${event_subscription_state} = 'Provisional Locker' THEN 1 END) ;;

  }

  measure: month_count {
    hidden: yes
    type: count_distinct
    sql: ${local_month} ;;
  }

  measure: user_month_count {
    hidden: yes
    type: count_distinct
    sql: HASH(${user_sso_guid}, ${local_month}) ;;
  }

  measure: user_day_count {
    hidden: yes
    type: count_distinct
    sql: HASH(${user_sso_guid}, ${local_date}) ;;
  }

  measure: day_count {
    type: count_distinct
    sql: ${local_date} ;;
    hidden: yes
  }

  measure: event_duration_total {
    group_label: "Time spent"
    label: "Total Time Active"
    type: sum
    sql: ${event_data}:event_duration / 3600 / 24  ;;
    value_format_name: duration_hms
  }

  measure: average_time_spent_per_student {
    group_label: "Time spent"
    label: "Average time spent per student"
    description: "Slice this metric by different dimensions"
    type: number
    sql: ${event_duration_total} / ${user_count} ;;
    value_format_name: duration_hms
  }

  measure: average_time_spent_per_student_per_week {
    group_label: "Time spent"
    label: "Average time spent per student per week"
    type: number
    sql: ${event_duration_total} / ${user_count} / (${day_count} / 7);;
    value_format: "[m] \m\i\n\s"
  }

  measure: average_time_spent_per_student_per_month {
    group_label: "Time spent"
    label: "Average time spent per student per month"
    type: number
    sql: ${event_duration_total} / ${user_month_count} ;;
    value_format_name: duration_hms
  }

  measure: event_duration_per_day {
    group_label: "Time spent"
    label: "Average Time spent per student per day"
    type: number
    sql: ${event_duration_total} / ${user_day_count} ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: days_active_avg {
    group_label: "Activity"
    label: "Average days with activity per user"
    type: number
    sql: ${user_day_count} / ${user_count};;
  }

  measure: days_active_avg_per_month {
    group_label: "Activity"
    label: "Average days with activity per user per month"
    type: number
    sql: ${user_day_count} / ${user_count} / ${month_count};;
  }

  measure: cu_resource_opens {
    label: "# of CU resource opens"
    description: "Number of times a CU resource was used"
    type: count_distinct
    sql: CASE WHEN event_name IN ('One month Free Chegg Clicked',  'Clicked on Quizlet', 'Clicked on Kaplan', 'Clicked on Evernote', 'Clicked on Dashlane',  'Study Resources Page Visited'
         ,'Study Tools Launched', 'Flashcards Launched',  'Test Prep Launched', 'Pathbrite Launched', 'Clicked on Career Center', 'eBook Launched'
        ) OR  (event_action = 'LAUNCH' AND  event_type IN ('STUDY_TOOLS_PAGE', 'MY_RENTALS', 'MY_ACCOUNT', 'MY_ORDERS', 'CAREER_CENTER', 'PARTNER_OFFERS', 'SIDEBAR', 'FULL_COURSE_MATERIAL'
        ,'PRINT_OPTIONS', 'CAREER_CENTER_MATERIAL', 'COLLEGE_SUCCESS_CENTER', 'QUICK_LESSON', 'COURSES', 'STUDY_PACK_MATERIAL', 'BILLING_AND_SHIPPING', 'COLLEGE_SUCCESS_MATERIAL', 'SUBSCRIBE_NOW'
        ,'LEARN_MORE') OR (event_action = 'JUMP' AND event_type IN ('GAIN_THE_SKILLS', 'EXPLORE_CAREERS', 'GET_THE_JOB', 'TOPICAL_CAROUSELTHEN') THEN event_id END;;
  }

#   measure: session_count {
#     label: "# sessions"
#     type: count_distinct
#     sql: ${session_id} ;;
# #     drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
#     description: "Measure for counting unique sessions (drill fields)"
#   }
}
