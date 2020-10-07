include: "//core/common.lkml"
include: "all_sessions.view.lkml"

# view: all_events_user_course_day {
#
#   derived_table: {
#     explore_source: course_sections {
#       column: active_time_per_day { field: all_events.event_duration_total }
#       column: user_sso_guid { field: learner_profile.user_sso_guid }
#       column: olr_course_key { field: user_courses.olr_course_key }
#       column: event_date { field: all_events.local_est_date }
#     }
#     persist_for: "24 hours"
#   }
#   dimension: active_time_per_day {
#     label: "Total Time Active per day"
#     value_format_name:  minutes
#     type: number
#     hidden: yes
#   }
#   dimension: user_sso_guid {
#     hidden: yes
#   }
#   dimension: olr_course_key {
#     hidden: yes
#   }
#   dimension: event_date_raw {
#     type: date_raw
#     hidden: yes
#     sql: ${TABLE}.event_date ;;
#   }
#
#   measure: active_time_per_day_p05 {
#     type: percentile
#     percentile: 5
#     sql: ${active_time_per_day} ;;
#     value_format: "[m]:ss \m\i\n\s"
#   }
#
#   dimension_group: time_since_course_start {
#     label: "Time between course start and event"
#     type: duration
#     intervals: [hour, day, week, month]
#     sql_start: ${user_courses.course_start_raw} ;;
#     sql_end: ${event_date_raw} ;;
#
#   }
#
#   measure: active_time_per_day_avg {
#     type: average
#     sql: ${active_time_per_day} ;;
#     value_format: "[m]:ss \m\i\n\s"
#   }
#
#   measure: active_time_per_day_p25 {
#     type: percentile
#     percentile: 25
#     sql: ${active_time_per_day} ;;
#     value_format: "[m]:ss \m\i\n\s"
#   }
#
#   measure: active_time_per_day_p50 {
#     type: percentile
#     percentile: 50
#     sql: ${active_time_per_day} ;;
#     value_format: "[m]:ss \m\i\n\s"
#   }
#
#   measure: active_time_per_day_p75 {
#     type: percentile
#     percentile: 75
#     sql: ${active_time_per_day} ;;
#     value_format: "[m]:ss \m\i\n\s"
#   }
#
#   measure: active_time_per_day_p95 {
#     type: percentile
#     percentile: 95
#     sql: ${active_time_per_day} ;;
#     value_format: "[m]:ss \m\i\n\s"
#   }
#
# }

view: all_events_tags {
  view_label: "Events"
  dimension: key {group_label: "Event Tags"}
  dimension: value {group_label: "Event Tags"}
}

view: all_events {
  extends: [all_events_base]

  dimension_group: time_since_session_start {
    label: "Time between start of session and event"
    type: duration
    intervals: [hour, day, week, month]
    sql_start: ${all_sessions.session_start_raw} ;;
    sql_end: ${event_date_raw} ;;

  }

  dimension_group: time_since_enrollment {
    label: "Time between enrollment and event"
    type: duration
    intervals: [hour, day, week, month]
    sql_start: ${user_courses.enrollment_raw} ;;
    sql_end: ${event_date_raw} ;;

  }

  dimension_group: time_since_course_start {
    label: "Time between course start and event"
    type: duration
    intervals: [hour, day, week, month]
    sql_start: ${user_courses.course_start_raw} ;;
    sql_end: ${event_date_raw} ;;

  }
}

view: all_events_base {
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
    group_label: "Subscription State"
    label: "Subscription State"
    type: string
    sql: COALESCE(${TABLE}.subscription_state, INITCAP(REPLACE(${TABLE}.event_data:subscription_state, '_', ' ')));;
    description: "Subscription state at the time of the event"
    suggest_explore: filter_cache_all_events_subscription_state
    suggest_dimension: filter_cache_all_events_subscription_state.event_subscription_state
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
    label: "Event data"
    description: "Data associated with a given event in a json format containing information like page number, URL, coursekeys, device information, etc."
  }

  dimension: event_data_course_key {
    group_label: "CAFE Tags"
    type: string
    sql: COALESCE(
            ${event_data}:courseKey
            ,${event_data}:course_key
            ,${event_data}:"course key"
            ,${event_data}:courseId
            ,REGEXP_SUBSTR(${event_data}:"courseUri", '.*course-key:(.+)$', 1, 1, 'e')
            ,REGEXP_SUBSTR(${event_data}:"courseUri", '.*prod:course:(.+)$', 1, 1, 'e')
            ,REGEXP_SUBSTR(${event_data}:"course uri", '.*course-key:(.+)$', 1, 1, 'e')
            ,${event_data}:contextId
          )::STRING  ;;
    label: "Course key"
    description: "Event data"
  }

  dimension: has_event_course_key {
    type: yesno
    sql: ${event_data_course_key} is not null ;;
    hidden: yes
  }

  dimension: event_data_reader_type {
    type: string
    group_label: "CAFE Tags"
    sql: ${TABLE}."EVENT_DATA":reader_type::STRING  ;;
    label: "Reader type (event data)"
    description: "Reader type (Gutenberg, Tribble, etc.)"
  }

  dimension: reader_mode {
    group_label: "CAFE Tags"
    type: string
    label: "Reader Mode Type (Mindtap only)"
    required_fields: [product_platform]
    sql: CASE WHEN ${event_data_course_key} IS NULL THEN 'Unknown' WHEN ${event_data_course_key} = 'reader-mode' THEN 'Reader Mode' ELSE 'Course Mode' END ;;
  }

  dimension: filter {
    type: string
    sql: ${TABLE}."EVENT_DATA":filter::string ;;
    label: "Filter"
    group_label: "CAFE Tags"
    description: "Event data"
  }

  dimension: title {
    type: string
    sql: ${TABLE}."EVENT_DATA":title::string ;;
    label: "Title"
    group_label: "CAFE Tags"
    description: "Event data"
  }

  dimension: filterGroup {
    type: string
    sql: ${TABLE}."EVENT_DATA":filterGroup::string ;;
    label: "Filter Group"
    group_label: "CAFE Tags"
    description: "Event data"
  }

  dimension: sortFunction {
    type: string
    sql: ${TABLE}."EVENT_DATA":sortFunction::string ;;
    label: "Sort Function"
    group_label: "CAFE Tags"
    description: "Event data"
  }

  dimension: userInput {
    type: string
    sql: ${TABLE}."EVENT_DATA":userInput::string ;;
    label: "User Input"
    group_label: "CAFE Tags"
    description: "UserInput from event tags"
  }

  dimension: code_type {
    label: "Activation Code Type"
    sql:  ${event_data}:code_type::string ;;
    description: "OLR activation/provisioned code type"
  }

  dimension: time_to_next_event {
    type:  number
    sql: ${TABLE}."EVENT_DATA":time_to_next_event ;;
    label: "Time to next event"
    description: "Event data"
    hidden: yes
  }

  dimension: days_in_state {
    group_label: "Subscription State"
    label: "Days in state"
    description: "Number of days user had been in a subscription state when they executed this event"
    type: number
    sql: ${event_data}:days_in_current_state ;;
  }

  dimension: role {
    type: string
    sql: TRIM(${event_data}:role) ;;
    label: "Webassign role"
    description: "Role from WA CAFe"
  }

  dimension: host_platform {
    type: string
    sql: TRIM(${event_data}:host_platform) ;;
    label: "Host platform (CAFe)"
    description: "Host platform from client activity events"
  }

  dimension: product_platform_lower {
    type: string
    sql: LOWER(${product_platform});;
    hidden: yes
  }

  dimension: campaign_msg_id{
    type: string
    sql: CASE WHEN ${event_name} ilike 'IPM%'
          THEN ${event_data}:message_id
          ELSE NULL
          END;;
          description: "Message ID for IPM events"
  }

  dimension: side_bar_coursekey {
    group_label: "CAFE Tags - Sidebar"
    label: "Course key"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:courseKey::string END ;;
    hidden: no
  }


  dimension: side_bar_carouselName {
    group_label: "CAFE Tags - Sidebar"
    label: "Carousel name"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:carouselName::string END ;;
    hidden: no
  }

  dimension: side_bar_carouselSessionId {
    group_label: "CAFE Tags - Sidebar"
    label: "Carousel session Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:carouselSessionId::string END ;;
    hidden: no
  }


  dimension: side_bar_activityId {
    group_label: "CAFE Tags - Sidebar"
    label: "Activity Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:activityId::string END ;;
    hidden: no
  }

  dimension: side_bar_checkpointId {
    group_label: "CAFE Tags - Sidebar"
    label: "checkpoint Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:checkpointId::string END ;;
    hidden: no
  }


  dimension: side_bar_contentType {
    group_label: "CAFE Tags - Sidebar"
    description: "ISBN Module / Quick Lesson / Study Tool"
    label: "Content type"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:contentType::string END ;;
    hidden: no
  }

  dimension: side_bar_pointInSemester {
    description: "Early Semester, End-of-semester, Mid-semester"
    group_label: "CAFE Tags - Sidebar"
    label: "Point In Semester"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:pointInSemester::string END ;;
    hidden: no
  }

  dimension: side_bar_discipline {
    group_label: "CAFE Tags - Sidebar"
    description: "Subject matter: Art, Philosophy, Criminal Justice, etc."
    label: "Discipline"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:discipline::string END ;;
    hidden: no
  }

  dimension: side_bar_studyToolCgi {
    group_label: "CAFE Tags - Sidebar"
    label: "Study Tool CGI"
    description: "Cengage Global Identifier"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:studyToolCgi::string END ;;
    hidden: no
  }

  dimension: side_bar_ISBN {
    group_label: "CAFE Tags - Sidebar"
    label: "ISBN"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:ISBN::string END ;;
    hidden: no
  }

  dimension: institutionId {
    group_label: "Industry Link tag events"
    label: "Institution ID"
    type: string
    sql: CASE WHEN ${product_platform} = 'INDUSTRY-LINKS-MINDAPP' THEN ${event_data}:institutionId::string END ;;
    #
    hidden: no
  }

  dimension: industryLinkURL {
    group_label: "Industry Link tag events"
    label: "Industry Link URL"
    type: string
    sql: CASE WHEN ${product_platform} = 'INDUSTRY-LINKS-MINDAPP'  THEN ${event_data}:industryLinkURL::string END ;;
    hidden: no
  }

  dimension: industryLinkType {
    group_label: "Industry Link tag events"
    label: "Industry Link Type"
    type: string
    sql: CASE WHEN ${product_platform} = 'INDUSTRY-LINKS-MINDAPP'  THEN ${event_data}:industryLinkType::string END ;;
    description: "custom, global"
    hidden: no
  }

  dimension: userRole {
    group_label: "Industry Link tag events"
    label: "User Role"
    type: string
    sql: CASE WHEN ${product_platform} = 'INDUSTRY-LINKS-MINDAPP'  THEN ${event_data}:userRole::string END ;;
    description: "instructor, primary, student, ta"
    hidden: no
  }

  dimension: titleIsbn {
    group_label: "Industry Link tag events"
    label: "Industry Link Title ISBN"
    type: string
    sql: CASE WHEN ${product_platform} = 'INDUSTRY-LINKS-MINDAPP'  THEN ${event_data}:titleIsbn::string END ;;
    hidden: no
  }

  dimension: industryLinkCoursekey {
    group_label: "Industry Link tag events"
    label: "Course key"
    type: string
    sql: CASE WHEN ${product_platform} = 'INDUSTRY-LINKS-MINDAPP'  THEN  ${event_data}:courseKey::string END ;;
    hidden: no
  }

  dimension: tags_isImpersonated {
    group_label: "CAFE Tags"
    label: "Is Impersonated"
    type: string
    sql: ${event_data}:isImpersonated::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_impersonatorGuid {
    group_label: "CAFE Tags"
    label: "Impersonator Guid"
    type: string
    sql: ${event_data}:impersonatorGuid::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_impersonatorUserType {
    group_label: "CAFE Tags"
    label: "Impersonator User Type"
    type: string
    sql: ${event_data}:impersonatorUserType::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_courseCategoryId {
    group_label: "CAFE Tags"
    label: "Course Category Id"
    type: string
    sql: ${event_data}:courseCategoryId::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_iacISBN {
    group_label: "CAFE Tags"
    label: "IAC ISBN"
    type: string
    sql: ${event_data}:iacISBN::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_UserType {
    group_label: "CAFE Tags"
    label: "User Type"
    type: string
    sql: ${event_data}:userType::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_ContextID {
    group_label: "CAFE Tags"
    label: "Context ID"
    type: string
    sql: ${event_data}:contextId::string ;;
    description: "Event data"
    hidden: no
  }



  dimension: tags_coursekey {
    group_label: "CAFE Tags"
    label: "Course key"
    type: string
    sql: ${event_data}:courseKey::string ;;
    description: "Event data"
    hidden: yes
  }


  dimension: tags_carouselName {
    group_label: "CAFE Tags"
    label: "Carousel name"
    type: string
    sql: ${event_data}:carouselName::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_carouselSessionId {
    group_label: "CAFE Tags"
    label: "Carousel session Id"
    type: string
    sql: ${event_data}:carouselSessionId::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_activityId {
    group_label: "CAFE Tags"
    label: "Activity Id"
    type: string
    sql: ${event_data}:activityId::string  ;;
    hidden: no
    description: "Event data"
#     CGI need to map to source to get metadata such as activity title
  }

  dimension: tags_checkpointId {
    group_label: "CAFE Tags"
    label: "checkpoint Id"
    type: string
    sql: ${event_data}:checkpointId::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_contentType {
    group_label: "CAFE Tags"
    label: "Content type"
    type: string
    sql: ${event_data}:contentType::string  ;;
    description: "Event data - ISBN Module / Quick Lesson / Study Tool"
    hidden: no
  }

  dimension: tags_appName {
    group_label: "CAFE Tags"
    label: "App Name"
    type: string
    sql: ${event_data}:appName::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_external_take_uri {
    group_label: "CAFE Tags"
    label: "External Take URI"
    type: string
    sql: ${event_data}:externalTakeUri::string  ;;
    description: "Event data - Unique Resource Identifier"
    hidden: no
  }

  dimension: tags_item_uri {
    group_label: "CAFE Tags"
    label: "Item URI"
    type: string
    sql: ${event_data}:itemUri::string  ;;
    description: "Event data - Unique Resource Identifier"
    hidden: no
  }

  dimension: tags_attempt_id {
    group_label: "CAFE Tags"
    label: "Attempt ID"
    type: string
    sql: ${event_data}:attemptId::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_activity_uri {
    group_label: "CAFE Tags"
    label: "Activity URI"
    type: string
    sql: ${event_data}:activityUri::string  ;;
    description: "Event data - Unique Resource Identifier"
    hidden: no
  }

  dimension: tags_show_grade_indicators {
    group_label: "CAFE Tags"
    label: "Show Grade Indicators"
    type: string
    sql: ${event_data}:showGradeIndicators::string  ;;
    description: "Event data - true"
    hidden: yes
  }

  dimension: tags_course_uri {
    group_label: "CAFE Tags"
    label: "Course URI"
    type: string
    sql: ${event_data}:courseUri::string  ;;
    description: "Event data - Unique Resource Identifier"
    hidden: no
  }

  dimension: tags_course_cgi {
    group_label: "CAFE Tags"
    label: "Course CGI"
    type: string
    sql: ${event_data}:courseCgi::string  ;;
    description: "Event data - Cengage Global Identifier"
    hidden: no
  }

  dimension: tags_core_text_isbn {
    group_label: "CAFE Tags"
    label: "Core Text ISBN"
    type: string
    sql: ${event_data}:coreTextISBN::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_pointInSemester {
    group_label: "CAFE Tags"
    label: "Point In Semester"
    type: string
    sql: ${event_data}:pointInSemester::string  ;;
    description: "Event data - Early Semester, End-of-semester, Mid-semester"
    hidden: no
  }

  dimension: tags_discipline {
    group_label: "CAFE Tags"
    label: "Discipline"
    type: string
    sql: ${event_data}:discipline::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_studyToolCgi {
    group_label: "CAFE Tags"
    label: "Study Tool CGI"
    type: string
    sql: ${event_data}:studyToolCgi::string  ;;
    description: "Event data - Cengage Global Identifier"
    hidden: no
  }

  dimension: tags_sequence_uuid {
    group_label: "CAFE Tags"
    label: "Sequence UUID"
    type: string
    sql: ${event_data}:sequenceUuid::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_ISBN {
    group_label: "CAFE Tags"
    label: "ISBN"
    type: string
    sql: coalesce(${event_data}:ISBN::string,${event_data}:isbn::string)  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_institutionId {
    group_label: "CAFE Tags"
    label: "Institution ID"
    type: string
    sql: ${event_data}:institutionId::string  ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_userRole {
    group_label: "CAFE Tags"
    label: "User Role"
    type: string
    sql: ${event_data}:userRole::string ;;
    description: "Event data - instructor, primary, student, ta"
    hidden: no
  }

  dimension: tags_cla_page_number {
    group_label: "CAFE Tags"
    label: "CLA Page Number"
    type: number
    sql: ${event_data}:claPageNumber::number ;;
    description: "Event data - Compound Learning Activity"
    hidden: no
  }

  dimension: tags_number_of_pages {
    group_label: "CAFE Tags"
    label: "Number of Pages"
    type: number
    sql: ${event_data}:numberOfPages::number ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_titleIsbn {
    group_label: "CAFE Tags"
    label: "Title ISBN"
    type: string
    sql: ${event_data}:titleIsbn::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_eIsbn {
    group_label: "CAFE Tags"
    label: "eISBN"
    type: string
    sql: ${event_data}:eISBN::string ;;
    description: "Event data"
    hidden: no
  }

  dimension: tags_eventData {
    group_label: "CAFE Tags"
    label: "MT Event Data"
    type: string
    sql: ${event_data}:eventData::string ;;
    hidden: no
    description: "Event data"
  }


  dimension: tags_ISBN13 {
    group_label: "CAFE Tags"
    label: "ISBN13"
    type: string
    sql: replace(${event_data}:isbn13::string,'-','')  ;;
    description: "ISBN13 (Event data tags)"
    hidden: no
  }

  dimension: tags_activityType {
    group_label: "CAFE Tags"
    label: "Activity Type"
    type: string
    sql: ${event_data}:activityType::string  ;;
    description: "activityType (Event data tags)"
    hidden: no
  }

  dimension: tags_activityLaunchSource {
    group_label: "CAFE Tags"
    label: "Activity Launch Source"
    type: string
    sql: ${event_data}:activityLaunchSource::string  ;;
    description: "activityLaunchSourcee (Event data tags)"
    hidden: no
  }

  dimension: tags_grade {
    group_label: "CAFE Tags"
    label: "Grade"
    type: string
    sql: ${event_data}:grade::string ;;
    description: "grade (Event data tags)"
    hidden: no
  }

  dimension: tags_searchTerm {
    group_label: "CAFE Tags"
    label: "Search Term"
    type: string
    sql: ${event_data}:searchTerm::string  ;;
    description: "searchTerm (Event data tags)"
    hidden: no
  }

  dimension: tags_resultsCount {
    group_label: "CAFE Tags"
    label: "Results Count"
    type: number
    sql: ${event_data}:resultsCount::number  ;;
    description: "resultsCount (Event data tags)"
    hidden: no
  }


  dimension: tags_reportType {
    group_label: "CAFE Tags"
    label: "Report Type"
    type: string
    sql: ${event_data}:reportType::string  ;;
    description: "reportType (Event data tags)"
    hidden: no
  }

  dimension: tags_cloneStatus {
    group_label: "CAFE Tags"
    label: "Clone Status"
    type: string
    sql: ${event_data}:cloneStatus::string  ;;
    description: "cloneStatus (Event data tags)"
    hidden: no
  }

  dimension: tags_assignmentStart {
    group_label: "CAFE Tags"
    label: "Assignment Start"
    type: date_time
    sql: ${event_data}:assignmentStart::datetime  ;;
    description: "assignmentStart (Event data tags)"
    hidden: no
  }

  dimension: tags_assignmentDue {
    group_label: "CAFE Tags"
    label: "Assignment Due"
    type: date_time
    sql: ${event_data}:assignmentDue::datetime  ;;
    description: "assignmentDue (Event data tags)"
    hidden: no
  }

  dimension: tags_numberAttempts {
    group_label: "CAFE Tags"
    label: "Number Attempts"
    type: number
    sql: ${event_data}:numberAttempts::number  ;;
    description: "numberAttempts (Event data tags)"
    hidden: no
  }

  dimension: tags_gradebookCategory {
    group_label: "CAFE Tags"
    label: "Gradebook Category"
    type: string
    sql: ${event_data}:gradebookCategory::string  ;;
    description: "gradebookCategory (Event data tags)"
    hidden: no
  }

  dimension: tags_studentCount {
    group_label: "CAFE Tags"
    label: "Student Count"
    type: number
    sql: ${event_data}:studentCount::number  ;;
    description: "studentCount (Event data tags)"
    hidden: no
  }

  dimension: tags_itemID {
    group_label: "CAFE Tags"
    label: "Item ID"
    type: string
    sql: ${event_data}:itemID::string  ;;
    description: "itemID (Event data tags)"
    hidden: no
  }




  dimension: product_platform {
    type: string
    group_label: "Event Classification"
    sql: UPPER(${TABLE}."PRODUCT_PLATFORM") ;;
    label: "Product Platform"
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
    description: "Dashboard Search / No Dashboard Search"
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
    sql: CASE WHEN ${event_data}:event_source = 'Client Activity Events' THEN  ${TABLE}."PRODUCT_PLATFORM" ELSE ${TABLE}."SYSTEM_CATEGORY" END ;;
    label: "System category"
    description: "Categorizes events by system eg: Cengage Unlimited, Registrations, Product Platforms"
  }

  dimension: event_type {
    label: "Event Category"
    group_label: "Event Classification - Raw"
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
    description: "Direct from source.
    The highest level in the hierarchy of event classification above event action"
    hidden: no
  }

  dimension: event_action {
    group_label: "Event Classification - Raw"
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
    label: "Event action"
    description:
    "DEFINITION: Action (verb) taken or performed by user or internal system.
    CAVEAT(S): Action labels are not necessarily consistent from platform to platform.
    SOURCE: CAFe, GTM, OLR, etc. See 'product platform' dimension for details.
    RAW/DERIVED: Raw
    "
    hidden: no

  }

  dimension: event_name_new {
    group_label: "Event Classification"
    label: "New event name (Testing)"
    type: string
    #sql: prod.cu_user_analysis.event_name(${event_action}, ${event_type}) ;;
    sql:  zandbox.pgriffiths.event_name_from_source(${load_metadata_source}, ${host_platform}, ${event_type}, ${event_action}, ${event_data}) ;;
    hidden: no
  }

  dimension: event_name {
    group_label: "Event Classification"
    type: string
    #sql: CASE WHEN ${event_data}:event_source = 'Client Activity Events' THEN  ${TABLE}."EVENT_TYPE" || ' ' || ${event_action} ELSE ${TABLE}."EVENT_NAME" END ;;
  sql:
     CASE WHEN ${product_platform} = 'PERFORMANCE-REPORT-UI' THEN TRIM(INITCAP(LOWER(${product_platform})) || ' ' || INITCAP(LOWER(${event_type})) || ' ' || INITCAP(LOWER(${event_action})))
          ELSE COALESCE(TRIM(${TABLE}."EVENT_NAME"), '** ' || UPPER(${event_type} || ': ' || ${event_action}) || ' **') END
          ;;
    label: "Event name"
    description: "The lowest level in hierarchy of event classification below event action.
    Can be associated with describing a user action in plain english i.e. 'Buy Now Button Click'
    n.b. These names come from a mapping table to make them friendlier than the raw names from the event stream.
    If no mapping is found the upper case raw name is used with asterisks to signify the difference - e.g. ** EVENT TYPE: EVENT ACTION **"
    link: {label: " n.b. These names come from a mapping table to make them friendlier than the raw names from the event stream.
    If no mapping is found the upper case raw name is used with asterisks to signify the difference - e.g. ** EVENT TYPE: EVENT ACTION **" url: "javascript:void"}
  suggest_explore: filter_cache_all_events_event_name
  suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  dimension: event_name_raw {
    group_label: "Event Classification - Raw"
    label: "Raw event name"
    description: "Event Category + Event Action"
    type: string
    sql: CONCAT(${event_type},' ',${event_action});;
    hidden: no
  }


  dimension_group: local {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week, hour_of_day, hour]
    sql: convert_timezone('UTC', ${TABLE}."EVENT_TIME") ;;
    group_label: "Event Time (UTC)"
    label: "Event (UTC)"
    description: "Components of the events local timestamp converted to UTC"
  }

  dimension_group: local_pt {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week, hour_of_day, hour]
    sql: convert_timezone('America/Los_Angeles', ${TABLE}."EVENT_TIME") ;;
    group_label: "Event Time (PT)"
    label: "Event (PT)"
    description: "Components of the events local timestamp converted to pacific time (America/Los_Angeles)"
  }

  dimension: semester {
    type: string
    sql:REPLACE(REPLACE(REPLACE(
            '#s #y/#n'
            ,'#s'
            ,CASE
                WHEN DATE_PART(month, (all_events.event_time::date)) BETWEEN 8 AND 12 THEN 'Fall'
                WHEN DATE_PART(month, (all_events.event_time::date)) BETWEEN 1 AND 6  THEN 'Spring'
                ELSE 'Summer'
              END
           )
           ,'#y', DATE_PART(year, (all_events.event_time::date)) - IFF(DATE_PART(month, (all_events.event_time::date)) BETWEEN 8 AND 12, 1, 0)
           )
           ,'#n', RIGHT(DATE_PART(year, (all_events.event_time::date)) + IFF(DATE_PART(month, (all_events.event_time::date)) BETWEEN 8 AND 12, 0, 1), 2)
           )
          ;;
  }

  dimension: event_date_raw {
    hidden: yes
    type: date
    sql: ${TABLE}.event_time::date ;;

  }



#   dimension: event_day_of_course {
#     label: "Day in course"
#     hidden: no
#     type: number
#     sql: DATEDIFF('day',${dim_date.datevalue_date}, ${local_date}) ;;
#   }
#
#   dimension: event_week_of_course {
#     label: "Week in course"
#     hidden: no
#     type: number
#     sql: DATEDIFF('week',${dim_date.datevalue_date}, ${local_date}) ;;
#   }
#
#   dimension: course_start_date {
#     label: "Course start date"
#     hidden: no
#     type: date
#     sql:${dim_date.datevalue_date} ;;
#   }

  dimension: load_metadata_source {
    group_label: "Event Classification - Raw"
    label: "Load source"
    type: string
    sql: ${TABLE}."LOAD_METADATA":source::string ;;
  }



  dimension_group: local_est {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week, hour_of_day, hour]
    sql: convert_timezone('EST', ${TABLE}."EVENT_TIME") ;;
    group_label: "Event Time (EST)"
    label: "Event (EST)"
    description: "Components of the events local timestamp converted to EST"
  }


  dimension_group: local_unconverted {
    hidden:  yes
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week, hour_of_day]
    sql:  ${TABLE}."LOCAL_TIME" ;;
    group_label: "Event Time (Local)"
    label: "Event (Local)"
    description: "Components of the events local timestamp"
  }

  dimension: referral_path {
    group_label: "Referral Path"
    description: "Which page did the student come from to get here?"
    sql: ${event_data}:"referral path"::STRING ;;
  }

  dimension: subscription_start {
    sql: ${event_data}:"subscription_start" ;;
    type: date
    hidden: yes
  }




  dimension: referral_host {
    group_label: "Referral Path"
    description: "Which site did the student come from to get here?"
    type: string
    sql: coalesce(parse_url(${event_data}:"referral path", 1):host, 'UNKNOWN');;
  }

  dimension: referral_host_type {
    description: "What type of site did the student come from to get here?"
    group_label: "Referral Path"
    type: string
    sql:  case
        when ${referral_host} like '%google%' then 'Google'
        when ${referral_host} like '%bing%' then 'Bing'
        when ${referral_host} like '%yahoo%' then 'Yahoo'
        when ${referral_host} like '%msn.%' then 'MSN'
        when ${referral_host} like '%aol.%' then 'AOL'
        when ${referral_host} like '%moodle%' then 'Moodle'
        when ${referral_host} like '%blackboard%' or ${referral_host} like 'bblearn%' then 'Blackboard'
        when ${referral_host} like '%d2l%' then 'D2L'
        when ${referral_host} like '%canvas%' then 'Canvas'
        when ${referral_host} like '%ilearn%' then 'ILearn'
        when ${referral_host} like '%google%' then 'Google'
        when ${referral_host} like '%qualtrics%' then 'Qualtrics'
        when ${referral_host} like '%quia%' then 'Quia'
        when ${referral_host} like 'cengage.vitalsource.com' then 'VitalSource'
        when ${referral_host} like 'www.chegg.com' then 'Chegg'
        when ${referral_host} like '%.edu' then 'Other EDU'
        when ${referral_host} like 'secureacceptance.cybersource.com' then 'Cengage Support' --??
        when ${referral_host} in ('cengageportal.secure.force.com', 'cengage.force.com', 'support.cengage.com') then 'Cengage Support'
        when ${referral_host} like '%cengagebrain%' or ${referral_host} like '%nelsonbrain%' then 'Cengage Brain'
        when ${referral_host} like 'olradmin.cengage.com' then 'Cengage OLR Admin'
        when ${referral_host} like 'gateway.cengage%' then 'Cengage Gateway'
        when ${referral_host} like '%aplia.com' or ${referral_host} like  'aplia.apps.ng.cengage.com' then 'Cengage Aplia'
        when ${referral_host} like 'sam.cengage.com' then 'Cengage SAM'
        when ${referral_host} like '4ltrpressonline.cengage.com' then 'Cengage 4LTR'
        when ${referral_host} like '%.cengagenow.%' or ${referral_host} like  'www.owlv2.com' then 'Cengage CNow'
        when ${referral_host} like 'instructor.cengage.com' then 'Cengage Instructor Site'
        when ${referral_host} in ('ng.cengage.com', 'mindtap.cengage.com') then 'Cengage MindTap'
        when ${referral_host} like 'www.webassign.net' then 'Cengage Webassign'
        when ${referral_host} like '%.cengage.com' then 'Cengage.com'
        when ${referral_path} is null then 'UNKNOWN'
        else 'Other'
       end;;
  }

  dimension: grace_period_flag {
    type: yesno
    description: "Event occurred before course activation up to midpoint of course or 60 days after start. Event occurred within 14 days of course start if not activated. See Day of Grace Period dimension to filter for events with first X days of course start."
  }

  dimension: day_of_grace_period {
    type: number
    sql: ${event_data}:day_of_grace_period ;;
    description: "Day grace period event occurred relative to course start date."
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

  measure: events_per_student {
    group_label: "# Events"
    label: "# Events per Student"
    type: number
    sql: ${count} /  NULLIF(${user_count}, 0)   ;;
    value_format_name: decimal_1
  }

  measure: events_per_student_per_day {
    group_label: "# Events"
    label: "# Events per Student Per Day"
    type: number
    sql: ${count} / ${user_day_count} ;;
    value_format_name: decimal_1
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

  measure: events_last_1_days {
    group_label: "# Events"
    label: "# Events per day yesterday (avg)"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) = 1 THEN 1 END) / NULLIF(COUNT(DISTINCT  CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) = 1 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_7_days {
    group_label: "# Events"
    label: "# Events per day per user in the last 7 days (avg)"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) <= 7 THEN 1 END) / NULLIF(COUNT(DISTINCT  CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) <= 7 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_30_days {
    group_label: "# Events"
    label: "# Events per day per user in the last 30 days (avg)"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(day,${event_date_raw}, CURRENT_DATE()) <= 30 THEN 1 END) / NULLIF(COUNT(DISTINCT CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) <= 30 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_6_months {
    group_label: "# Events"
    label: "# Events per day per user in the last 6 months (avg)"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(month, ${event_date_raw}, CURRENT_DATE()) <= 6 THEN 1 END) / NULLIF(COUNT(DISTINCT CASE WHEN DATEDIFF(month, ${event_date_raw}, CURRENT_DATE()) <= 6 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_12_months {
    group_label: "# Events"
    label: "# Events per day per user in the last 12 months (avg)"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(month, ${event_date_raw}, CURRENT_DATE()) <= 12 THEN 1 END) / NULLIF(COUNT(DISTINCT CASE WHEN DATEDIFF(month, ${event_date_raw}, CURRENT_DATE()) <= 6 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: event_first_captured {
    group_label: "# Events"
    type: string
    description: "Since when have we been tracking this event?"
    sql: MIN(${event_date_raw}) ;;
  }

  measure: event_last_captured {
    group_label: "# Events"
    type: string
    description: "When was the last time we caught this event?"
    sql: MAX(${event_date_raw}) ;;
  }

  measure: month_count {
    hidden: yes
    type: count_distinct
    sql: ${local_month} ;;
  }


  measure: user_month_count {
    hidden: yes
    type: count_distinct
    sql: ${user_sso_guid}, DATE_TRUNC('month', ${local_raw}) ;;
  }

  measure: user_day_count {
    hidden: yes
    type: count_distinct
    sql: ${user_sso_guid}, ${local_raw}::DATE ;;
  }

  measure: user_week_count {
    label: "# of User Weeks"
    description: "Distinct count of all user SSO guid + week where an event occurred combinations"
    type: count_distinct
    sql: ${user_sso_guid}, DATE_TRUNC('week', ${local_raw}) ;;
    hidden: no
  }

  measure: day_count {
    type: count_distinct
    sql: ${local_raw}::DATE ;;
    hidden: yes
  }

  dimension: event_duration_seconds {
    type: number
    #cut off at 30 mins
    sql: NULLIF(LEAST(${event_data}:event_duration::int, 1800), 0) ;;
    hidden: yes
  }

  dimension: time_to_next_event_seconds {
    type: number
    #cut off at 30 mins
    sql: NULLIF(LEAST(${event_data}:time_to_next_event::int, 1800), 0) ;;
    hidden: yes
  }

  measure: event_duration_total {
    group_label: "Active Time"
    label: "Total Time Active"
    type: sum
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_average {
    group_label: "Active Time"
    label: "Event Duration (Avg)"
    type: average
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_min {
    group_label: "Active Time"
    label: "Event Duration (Min)"
    type: min
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_p05 {
    group_label: "Active Time"
    label: "Event Duration ( 5th Percentile)"
    type: percentile
    percentile: 5
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_p25 {
    group_label: "Active Time"
    label: "Event Duration (25th Percentile)"
    type: percentile
    percentile: 25
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_p50 {
    group_label: "Active Time"
    label: "Event Duration (50th Percentile)"
    type: percentile
    percentile: 50
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_p75 {
    group_label: "Active Time"
    label: "Event Duration (75th Percentile)"
    type: percentile
    percentile: 75
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_p95 {
    group_label: "Active Time"
    label: "Event Duration (95th Percentile)"
    type: percentile
    percentile: 95
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_max {
    group_label: "Active Time"
    label: "Event Duration (Max)"
    type: max
    sql: ${event_duration_seconds} / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event {
    group_label: "Time To Next Event"
    label: "Time to Next Event (Sum)"
    type: sum
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_mean {
    group_label: "Time To Next Event"
    label: "Time to Next Event (Avg)"
    type: average
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_min {
    group_label: "Time To Next Event"
    label: "Time to Next Event (Min)"
    type: min
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_p05 {
    group_label: "Time To Next Event"
    label: "Time to Next Event ( 5th Percentile)"
    type: percentile
    percentile: 5
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_p25 {
    group_label: "Time To Next Event"
    label: "Time to Next Event (25th Percentile)"
    type: percentile
    percentile: 25
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_p50 {
    group_label: "Time To Next Event"
    label: "Time to Next Event (50th Percentile)"
    type: percentile
    percentile: 50
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_p75 {
    group_label: "Time To Next Event"
    label: "Time to Next Event (75th Percentile)"
    type: percentile
    percentile: 75
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_p95 {
    group_label: "Time To Next Event"
    label: "Time to Next Event (95th Percentile)"
    type: percentile
    percentile: 95
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: event_duration_time_to_next_event_max {
    group_label: "Time To Next Event"
    label: "Time to Next Event (Max)"
    type: max
    sql: ${time_to_next_event_seconds} / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: average_time_to_next_event_spent_per_student {
    group_label: "Active Time"
    label: "Average time to next event per student"
    description: "Slice this metric by different dimensions"
    type: number
    sql: ${event_duration_time_to_next_event} / NULLIF(${user_count}, 0)  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: average_time_spent_per_student {
    group_label: "Active Time"
    label: "Average time spent per student"
    description: "Slice this metric by different dimensions"
    type: number
    sql: ${event_duration_total} / NULLIF(${user_count}, 0)  ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: average_time_spent_per_student_per_week {
    group_label: "Active Time"
    label: "Average time spent per student per week"
    type: number
    sql: ${event_duration_total} / NULLIF(${user_week_count}, 0);;
    value_format: "[m]:ss \m\i\n\s"

    description:
    "DEFINITION: The average amount of time a student is active per week.
    CAVEAT(S): Some events are excluded, e.g. event_action = 'STOP'. Event durations are approximate.
    SOURCE: Looker calculation
    RAW/DERIVED: Derived
    "

  }

  measure: average_time_spent_per_student_per_month {
    group_label: "Active Time"
    label: "Average time spent per student per month"
    type: number
    sql: ${event_duration_total} / ${user_month_count} ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: event_duration_per_day {
    group_label: "Active Time"
    label: "Average time spent per student per day"
    type: number
    sql: ${event_duration_total} / ${user_day_count} ;;
    value_format: "[m]:ss \m\i\n\s"
  }

  measure: days_active_avg {
    group_label: "Activity"
    label: "# days with activity per user (avg)"
    type: number
    sql: ${user_day_count} / ${user_count};;
  }

  measure: days_active_avg_per_month {
    group_label: "Activity"
    label: "# days with activity per user per month (avg)"
    type: number
    sql: ${user_day_count} / ${user_count} / ${month_count};;
  }

  dimension: cu_resource_open {
    type:  yesno
    sql:
    (event_name IN ('One month Free Chegg Clicked',  'Clicked on Quizlet', 'Clicked on Kaplan', 'Clicked on Evernote', 'Clicked on Dashlane',  'Study Resources Page Visited'
         ,'Study Tools Launched', 'Flashcards Launched',  'Test Prep Launched', 'Pathbrite Launched', 'Clicked on Career Center', 'eBook Launched')
        OR  (event_action = 'LAUNCH' AND  event_type IN ('STUDY_TOOLS_PAGE', 'MY_RENTALS', 'MY_ACCOUNT', 'MY_ORDERS', 'CAREER_CENTER', 'PARTNER_OFFERS', 'SIDEBAR', 'FULL_COURSE_MATERIAL'
        ,'PRINT_OPTIONS', 'CAREER_CENTER_MATERIAL', 'COLLEGE_SUCCESS_CENTER', 'QUICK_LESSON', 'COURSES', 'STUDY_PACK_MATERIAL', 'BILLING_AND_SHIPPING', 'COLLEGE_SUCCESS_MATERIAL', 'SUBSCRIBE_NOW'
        ,'LEARN_MORE') )
        OR (event_action = 'JUMP' AND event_type IN ('GAIN_THE_SKILLS', 'EXPLORE_CAREERS', 'GET_THE_JOB', 'TOPICAL_CAROUSEL')) ;;
      description: "Extra-courseware resource event (Clicked on a Quizlet, Kaplan, Career Center, etc."
  }

  measure: cu_resource_opens {
    label: "# of CU resource opens"
    description: "Number of times an Extra-courseware resource was used"
    type: count_distinct
    sql: CASE WHEN
          (event_name IN ('One month Free Chegg Clicked',  'Clicked on Quizlet', 'Clicked on Kaplan', 'Clicked on Evernote', 'Clicked on Dashlane',  'Study Resources Page Visited'
               ,'Study Tools Launched', 'Flashcards Launched',  'Test Prep Launched', 'Pathbrite Launched', 'Clicked on Career Center', 'eBook Launched'
              ) OR  (event_action = 'LAUNCH' AND  event_type IN ('STUDY_TOOLS_PAGE', 'MY_RENTALS', 'MY_ACCOUNT', 'MY_ORDERS', 'CAREER_CENTER', 'PARTNER_OFFERS', 'SIDEBAR', 'FULL_COURSE_MATERIAL'
              ,'PRINT_OPTIONS', 'CAREER_CENTER_MATERIAL', 'COLLEGE_SUCCESS_CENTER', 'QUICK_LESSON', 'COURSES', 'STUDY_PACK_MATERIAL', 'BILLING_AND_SHIPPING', 'COLLEGE_SUCCESS_MATERIAL', 'SUBSCRIBE_NOW'
              ,'LEARN_MORE') OR (event_action = 'JUMP' AND event_type IN ('GAIN_THE_SKILLS', 'EXPLORE_CAREERS', 'GET_THE_JOB', 'TOPICAL_CAROUSELTHEN') ))) THEN event_id END;;
  }


  dimension: ATC_usage {
    hidden: yes
    label: "ATC Event"
    description: "Above The Course event Y/N"
    type:  yesno
    sql:
    (event_name IN (
  'Study Tools Launched',
  'Flashcards Launched',
  'Test Prep Launched')
OR  (event_action = 'LAUNCH' AND  event_type IN (
    'STUDY_TOOLS_PAGE',
    'CAREER_CENTER',
    'CAREER_CENTER_MATERIAL',
    'COLLEGE_SUCCESS_CENTER',
    'COLLEGE_SUCCESS_MATERIAL',
    'QUICK_LESSON',
    'COURSES',
    'STUDY_PACK_MATERIAL'))
OR (event_action='modalContinue') --partner offers by continue for each offer
OR (event_action = 'LAUNCH' and ${title} ilike '%study guide%')
OR (event_action = 'JUMP' AND event_type IN (
    'GAIN_THE_SKILLS',
    'EXPLORE_CAREERS',
    'GET_THE_JOB'
    ))) ;;
  }

  measure: above_the_courses{
    hidden:  yes
    label:"# of ATC usages - no ebook"
    description: "Number of times an Above The Course event occurred"
    type: count_distinct
    sql:CASE WHEN((event_name IN (
        'Study Tools Launched',
        'Flashcards Launched',
        'Test Prep Launched')
      OR  (event_action = 'LAUNCH' AND  event_type IN (
          'STUDY_TOOLS_PAGE',
          'CAREER_CENTER',
          'CAREER_CENTER_MATERIAL',
          'COLLEGE_SUCCESS_CENTER',
          'COLLEGE_SUCCESS_MATERIAL',
          'QUICK_LESSON',
          'COURSES',
          'STUDY_PACK_MATERIAL'))
      OR (event_action='modalContinue') --partner offers by continue for each offer
      OR (event_action = 'LAUNCH' and ${title} ilike '%study guide%')
      OR (event_action = 'JUMP' AND event_type IN (
          'GAIN_THE_SKILLS',
          'EXPLORE_CAREERS',
          'GET_THE_JOB'
          ))) ) THEN event_id END;;
  }

dimension: course_key {
  type: string
  description: "Course key associated with the event identified through TAGS. If an event's tags don't contain a course key identifier, the course key from the previous or next event in the same session is given instead."
  label: "Event Course Key"
}

dimension: isbn {
  type: string
  description: "ISBN associated with the event identified through TAGS. If an event's tags don't contain an ISBN identifier, the ISBN from the previous or next event in the same session is given instead."
  label: "Event ISBN"
}

dimension: platform {
  hidden: no
  type: string
  description: "Platform associated with the event identified through TAGS. If an event's tags don't contain a platform identifier, the platform from the previous or next event in the same session is identified instead."
  label: "Event Platform"
  sql: COALESCE(${TABLE}.course_key_platform,${TABLE}.isbn_platform,
    CASE ${TABLE}.product_platform
      WHEN 'WEBASSIGN' THEN 'WebAssign'
      WHEN 'MT3' THEN 'MindTap'
      WHEN 'WA RESPONSES' THEN 'WebAssign'
      WHEN 'CNOW' THEN 'CNOW'
      WHEN 'APLIA' THEN 'Aplia'
      WHEN 'MINDTAP' THEN 'MindTap'
      WHEN 'CNOWV7' THEN 'CNOW'
      WHEN 'CAS-MTS' THEN 'MindTap'
      WHEN 'MT4' THEN 'MindTap'
      WHEN 'GRADEBOOK-MT' THEN 'MindTap'
      WHEN 'CAS-MT' THEN 'MindTap'
      WHEN 'MTS' THEN 'MindTap'
    END
  ) ;;
}





#   measure: session_count {
#     label: "# sessions"
#     type: count_distinct
#     sql: ${session_id} ;;
# #     drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
#     description: "Measure for counting unique sessions (drill fields)"
#   }
}
