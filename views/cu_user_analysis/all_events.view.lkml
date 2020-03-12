include: "//core/common.lkml"

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
    group_label: "Subscription State"
    label: "Subscription State"
    type: string
    sql: COALESCE(${TABLE}.subscription_state, INITCAP(REPLACE(${TABLE}.event_data:subscription_state, '_', ' ')));;
    description: "Subscription state at the time of the event"
  }

  dimension: event_data {
    type: string
    sql: ${TABLE}."EVENT_DATA" ;;
    label: "Event data"
    description: "Data associated with a given event in a json format containing information like page number, URL, coursekeys, device information, etc."
  }

  dimension: event_data_course_key {
    type: string
    sql: COALESCE(${TABLE}."EVENT_DATA":courseKey,${TABLE}."EVENT_DATA":course_key)::STRING  ;;
    label: "Course key (event data)"
  }

  dimension: event_data_reader_type {
    type: string
    sql: ${TABLE}."EVENT_DATA":reader_type::STRING  ;;
    label: "Reader type (event data)"
    description: "Reader type (Gutenberg, Tribble, etc.)"
  }

  dimension: reader_mode {
    type: string
    label: "Reader Mode Type (Mindtap only)"
    required_fields: [product_platform]
    sql: CASE WHEN ${event_data_course_key} IS NULL THEN 'Unknown' WHEN ${event_data_course_key} = 'reader-mode' THEN 'Reader Mode' ELSE 'Course Mode' END ;;
  }

  dimension: filter {
    type: string
    sql: ${TABLE}."EVENT_DATA":filter::string ;;
    label: "Filter"
    group_label: "Client Activity Tags"
  }

  dimension: title {
    type: string
    sql: ${TABLE}."EVENT_DATA":title::string ;;
    label: "Title"
    group_label: "Client Activity Tags"
  }

  dimension: filterGroup {
    type: string
    sql: ${TABLE}."EVENT_DATA":filterGroup::string ;;
    label: "Filter Group"
    group_label: "Client Activity Tags"
  }

  dimension: sortFunction {
    type: string
    sql: ${TABLE}."EVENT_DATA":sortFunction::string ;;
    label: "Sort Function"
    group_label: "Client Activity Tags"
  }

  dimension: code_type {
    label: "Activation Code Type"
    sql:  ${event_data}:code_type::string ;;
  }

  dimension: time_to_next_event {
    type:  number
    sql: ${TABLE}."EVENT_DATA":time_to_next_event ;;
    label: "Time to next event"
  }

  dimension: days_in_state {
    group_label: "Subscription State"
    label: "Days in state"
    description: "Number of days user was in a subscription state when they executed this event"
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
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:courseKey::string END ;;
    hidden: no
  }


  dimension: side_bar_carouselName {
    group_label: "Sidebar tag events"
    label: "Carousel name"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:carouselName::string END ;;
    hidden: no
  }

  dimension: side_bar_carouselSessionId {
    group_label: "Sidebar tag events"
    label: "Carousel session Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:carouselSessionId::string END ;;
    hidden: no
  }


  dimension: side_bar_activityId {
    group_label: "Sidebar tag events"
    label: "Activity Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:activityId::string END ;;
    hidden: no
  }

  dimension: side_bar_checkpointId {
    group_label: "Sidebar tag events"
    label: "checkpoint Id"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:checkpointId::string END ;;
    hidden: no
  }


  dimension: side_bar_contentType {
    group_label: "Sidebar tag events"
    label: "Content type"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:contentType::string END ;;
    hidden: no
  }

  dimension: side_bar_pointInSemester {
    group_label: "Sidebar tag events"
    label: "Point In Semester"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:pointInSemester::string END ;;
    hidden: no
  }

  dimension: side_bar_discipline {
    group_label: "Sidebar tag events"
    label: "Discipline"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:discipline::string END ;;
    hidden: no
  }

  dimension: side_bar_studyToolCgi {
    group_label: "Sidebar tag events"
    label: "Study Tool Cgi"
    type: string
    sql: CASE WHEN ${product_platform} = 'CU-SIDE-BAR' THEN ${event_data}:studyToolCgi::string END ;;
    hidden: no
  }

  dimension: side_bar_ISBN {
    group_label: "Sidebar tag events"
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
    hidden: no
  }

  dimension: userRole {
    group_label: "Industry Link tag events"
    label: "User Role"
    type: string
    sql: CASE WHEN ${product_platform} = 'INDUSTRY-LINKS-MINDAPP'  THEN ${event_data}:userRole::string END ;;
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

  dimension: tags_coursekey {
    group_label: "Client Activity Tags"
    label: "Course key"
    type: string
    sql: ${event_data}:courseKey::string ;;
    hidden: no
  }


  dimension: tags_carouselName {
    group_label: "Client Activity Tags"
    label: "Carousel name"
    type: string
    sql: ${event_data}:carouselName::string ;;
    hidden: no
  }

  dimension: tags_carouselSessionId {
    group_label: "Client Activity Tags"
    label: "Carousel session Id"
    type: string
    sql: ${event_data}:carouselSessionId::string  ;;
    hidden: no
  }

  dimension: tags_activityId {
    group_label: "Client Activity Tags"
    label: "Activity Id"
    type: string
    sql: ${event_data}:activityId::string  ;;
    hidden: no
  }

  dimension: tags_checkpointId {
    group_label: "Client Activity Tags"
    label: "checkpoint Id"
    type: string
    sql: ${event_data}:checkpointId::string  ;;
    hidden: no
  }

  dimension: tags_contentType {
    group_label: "Client Activity Tags"
    label: "Content type"
    type: string
    sql: ${event_data}:contentType::string  ;;
    hidden: no
  }

  dimension: tags_appName {
    group_label: "Client Activity Tags"
    label: "App Name"
    type: string
    sql: ${event_data}:appName::string  ;;
    hidden: no
  }

  dimension: tags_external_take_uri {
    group_label: "Client Activity Tags"
    label: "External Take URI"
    type: string
    sql: ${event_data}:externalTakeUri::string  ;;
    hidden: no
  }

  dimension: tags_item_uri {
    group_label: "Client Activity Tags"
    label: "Item URI"
    type: string
    sql: ${event_data}:itemUri::string  ;;
    hidden: no
  }

  dimension: tags_attempt_id {
    group_label: "Client Activity Tags"
    label: "Attempt ID"
    type: string
    sql: ${event_data}:attemptId::string  ;;
    hidden: no
  }

  dimension: tags_activity_uri {
    group_label: "Client Activity Tags"
    label: "Activity URI"
    type: string
    sql: ${event_data}:activityUri::string  ;;
    hidden: no
  }

  dimension: tags_show_grade_indicators {
    group_label: "Client Activity Tags"
    label: "Show Grade Indicators"
    type: string
    sql: ${event_data}:showGradeIndicators::string  ;;
    hidden: no
  }

  dimension: tags_course_uri {
    group_label: "Client Activity Tags"
    label: "Course URI"
    type: string
    sql: ${event_data}:courseUri::string  ;;
    hidden: no
  }

  dimension: tags_course_cgi {
    group_label: "Client Activity Tags"
    label: "Course CGI"
    type: string
    sql: ${event_data}:courseCgi::string  ;;
    hidden: no
  }

  dimension: tags_core_text_isbn {
    group_label: "Client Activity Tags"
    label: "Core Text ISBN"
    type: string
    sql: ${event_data}:coreTextISBN::string  ;;
    hidden: no
  }

  dimension: tags_pointInSemester {
    group_label: "Client Activity Tags"
    label: "Point In Semester"
    type: string
    sql: ${event_data}:pointInSemester::string  ;;
    hidden: no
  }

  dimension: tags_discipline {
    group_label: "Client Activity Tags"
    label: "Discipline"
    type: string
    sql: ${event_data}:discipline::string  ;;
    hidden: no
  }

  dimension: tags_studyToolCgi {
    group_label: "Client Activity Tags"
    label: "Study Tool Cgi"
    type: string
    sql: ${event_data}:studyToolCgi::string  ;;
    hidden: no
  }

  dimension: tags_sequence_uuid {
    group_label: "Client Activity Tags"
    label: "Sequence UUID"
    type: string
    sql: ${event_data}:sequenceUuid::string  ;;
    hidden: no
  }

  dimension: tags_ISBN {
    group_label: "Client Activity Tags"
    label: "ISBN"
    type: string
    sql: ${event_data}:ISBN::string  ;;
    hidden: no
  }

  dimension: tags_institutionId {
    group_label: "Client Activity Tags"
    label: "Institution ID"
    type: string
    sql: ${event_data}:institutionId::string  ;;
    #
    hidden: no
  }

  dimension: tags_userRole {
    group_label: "Client Activity Tags"
    label: "User Role"
    type: string
    sql: ${event_data}:userRole::string ;;
    hidden: no
  }

  dimension: tags_cla_page_number {
    group_label: "Client Activity Tags"
    label: "CLA Page Number"
    type: string
    sql: ${event_data}:claPageNumber::string ;;
    hidden: no
  }

  dimension: tags_number_of_pages {
    group_label: "Client Activity Tags"
    label: "Number of Pages"
    type: string
    sql: ${event_data}:numberOfPages::string ;;
    hidden: no
  }

  dimension: tags_titleIsbn {
    group_label: "Client Activity Tags"
    label: "Title ISBN"
    type: string
    sql: ${event_data}:titleIsbn::string ;;
    hidden: no
  }

  dimension: tags_eIsbn {
    group_label: "Client Activity Tags"
    label: "eISBN"
    type: string
    sql: ${event_data}:eISBN::string ;;
    hidden: no
  }

  dimension: tags_eventData {
    group_label: "Client Activity Tags"
    label: "MT Event Data"
    type: string
    sql: ${event_data}:eventData::string ;;
    hidden: no
  }


  dimension: product_platform {
    type: string
    group_label: "Event Classification"
    sql: UPPER(${TABLE}."PRODUCT_PLATFORM") ;;
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
    sql: CASE WHEN ${event_data}:event_source = 'Client Activity Events' THEN  ${TABLE}."PRODUCT_PLATFORM" ELSE ${TABLE}."SYSTEM_CATEGORY" END ;;
    label: "System category"
    description: " Categorizes events by system eg: Cengage Unlimited, Registrations"
  }

  dimension: event_type {
    group_label: "Event Classification - Raw"
    type: string
    sql: ${TABLE}."EVENT_TYPE" ;;
    label: "Event type"
    description: "Direct from source.
    The highest level in the hierarchy of event classicfication above event action"
    hidden: no
  }


  dimension: event_action {
    group_label: "Event Classification - Raw"
    type: string
    sql: ${TABLE}."EVENT_ACTION" ;;
    label: "Event action"
    description: "Direct from source.
    A classification of event within the hierachy of events beneath event type and above event name i.e. 'OLR Enrollment'"
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
    Can be asscoaited with describing a user action in plain english i.e. 'Buy Now Button Click'
    n.b. These names come from a mapping table to make them friendlier than the raw names from the event stream.
    If no mapping is found the upper case raw name is used with asterisks to signify the difference - e.g. ** EVENT TYPE: EVENT ACTION **
    "
    link: {label: " n.b. These names come from a mapping table to make them friendlier than the raw names from the event stream.
    If no mapping is found the upper case raw name is used with asterisks to signify the difference - e.g. ** EVENT TYPE: EVENT ACTION **" url: "javascript:void"}
  }


  dimension_group: local {
    type: time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week, hour_of_day, hour]
    sql: convert_timezone('UTC', ${TABLE}."EVENT_TIME") ;;
    group_label: "Event Time (UTC)"
    label: "Event (UTC)"
    description: "Components of the events local timestamp converted to UTC"
  }

  dimension: semester {
    type: string
    sql: CASE
          WHEN ${event_date_raw} BETWEEN '2018-08-01' AND '2018-12-31' THEN '1. Fall 2019'
          WHEN ${event_date_raw} BETWEEN '2019-01-01' AND '2019-06-30' THEN '2. Spring 2019'
          WHEN ${event_date_raw} BETWEEN '2019-07-01' AND '2019-07-3`' THEN '3. Summer 2019'
          WHEN ${event_date_raw} BETWEEN '2019-08-01' AND CURRENT_DATE() THEN '4. Fall 2020'
          ELSE 'Other' END
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
  group_label: "Load Metadata"
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
    label: "Avg # Events per day yesterday"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) = 1 THEN 1 END) / NULLIF(COUNT(DISTINCT  CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) = 1 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_7_days {
    group_label: "# Events"
    label: "Avg # Events per day per user in the last 7 days"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) <= 7 THEN 1 END) / NULLIF(COUNT(DISTINCT  CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) <= 7 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_30_days {
    group_label: "# Events"
    label: "Avg # Events per day per user in the last 30 days"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(day,${event_date_raw}, CURRENT_DATE()) <= 30 THEN 1 END) / NULLIF(COUNT(DISTINCT CASE WHEN DATEDIFF(day, ${event_date_raw}, CURRENT_DATE()) <= 30 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_6_months {
    group_label: "# Events"
    label: "Avg # Events per day per user in the last 6 months"
    type: number
    sql: COUNT(CASE WHEN DATEDIFF(month, ${event_date_raw}, CURRENT_DATE()) <= 6 THEN 1 END) / NULLIF(COUNT(DISTINCT CASE WHEN DATEDIFF(month, ${event_date_raw}, CURRENT_DATE()) <= 6 THEN HASH(${user_sso_guid}, ${event_date_raw}) END), 0);;
    value_format_name: decimal_1
  }

  measure: events_last_12_months {
    group_label: "# Events"
    label: "Avg # Events per day per user in the last 12 months"
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
    sql: HASH(${user_sso_guid}, ${local_month}) ;;
  }

  measure: user_day_count {
    hidden: yes
    type: count_distinct
    sql: HASH(${user_sso_guid}, ${local_date}) ;;
  }

  measure: user_week_count {
    type: count_distinct
    sql: HASH(${user_sso_guid}, ${local_week}) ;;
    hidden: no
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
    sql: NULLIF(${event_data}:event_duration::int, 0) / 60 / 60 / 24 ;; #event duration is in seconds
    value_format: "[m] \m\i\n\s"
  }


  measure: event_duration_time_to_next_event {
    group_label: "Time spent"
    label: "Total Time Active (time_to_next_event)"
    type: sum
    sql: ${event_data}:event_duration / 3600 / 24  ;;
    # sql: ${event_data}:time_to_next_event / 3600 / 24  ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: average_time_to_next_event_spent_per_student {
    group_label: "Time spent"
    label: "Average time to next event per student"
    description: "Slice this metric by different dimensions"
    type: number
    sql: ${event_duration_time_to_next_event} / NULLIF(${user_count}, 0)  ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: average_time_spent_per_student {
    group_label: "Time spent"
    label: "Average time spent per student"
    description: "Slice this metric by different dimensions"
    type: number
    sql: ${event_duration_total} / NULLIF(${user_count}, 0)  ;;
    value_format: "[m] \m\i\n\s"
  }

  measure: average_time_spent_per_student_per_week {
    group_label: "Time spent"
    label: "Average time spent per student per week"
    type: number
    sql: ${event_duration_total} / ${user_week_count};;
    value_format: "[m] \m\i\n\s"
  }

  measure: average_time_spent_per_student_per_month {
    group_label: "Time spent"
    label: "Average time spent per student per month"
    type: number
    sql: ${event_duration_total} / ${user_month_count} ;;
    value_format: "[m] \m\i\n\s"
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

  dimension: cu_resource_open {
    type:  yesno
    sql:
    (event_name IN ('One month Free Chegg Clicked',  'Clicked on Quizlet', 'Clicked on Kaplan', 'Clicked on Evernote', 'Clicked on Dashlane',  'Study Resources Page Visited'
         ,'Study Tools Launched', 'Flashcards Launched',  'Test Prep Launched', 'Pathbrite Launched', 'Clicked on Career Center', 'eBook Launched')
        OR  (event_action = 'LAUNCH' AND  event_type IN ('STUDY_TOOLS_PAGE', 'MY_RENTALS', 'MY_ACCOUNT', 'MY_ORDERS', 'CAREER_CENTER', 'PARTNER_OFFERS', 'SIDEBAR', 'FULL_COURSE_MATERIAL'
        ,'PRINT_OPTIONS', 'CAREER_CENTER_MATERIAL', 'COLLEGE_SUCCESS_CENTER', 'QUICK_LESSON', 'COURSES', 'STUDY_PACK_MATERIAL', 'BILLING_AND_SHIPPING', 'COLLEGE_SUCCESS_MATERIAL', 'SUBSCRIBE_NOW'
        ,'LEARN_MORE') )
        OR (event_action = 'JUMP' AND event_type IN ('GAIN_THE_SKILLS', 'EXPLORE_CAREERS', 'GET_THE_JOB', 'TOPICAL_CAROUSEL')) ;;
  }


  dimension: ATC_usage {
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


  measure: cu_resource_opens {
    label: "# of CU resource opens"
    description: "Number of times a CU resource was used"
    type: count_distinct
    sql: CASE WHEN
    (event_name IN ('One month Free Chegg Clicked',  'Clicked on Quizlet', 'Clicked on Kaplan', 'Clicked on Evernote', 'Clicked on Dashlane',  'Study Resources Page Visited'
         ,'Study Tools Launched', 'Flashcards Launched',  'Test Prep Launched', 'Pathbrite Launched', 'Clicked on Career Center', 'eBook Launched'
        ) OR  (event_action = 'LAUNCH' AND  event_type IN ('STUDY_TOOLS_PAGE', 'MY_RENTALS', 'MY_ACCOUNT', 'MY_ORDERS', 'CAREER_CENTER', 'PARTNER_OFFERS', 'SIDEBAR', 'FULL_COURSE_MATERIAL'
        ,'PRINT_OPTIONS', 'CAREER_CENTER_MATERIAL', 'COLLEGE_SUCCESS_CENTER', 'QUICK_LESSON', 'COURSES', 'STUDY_PACK_MATERIAL', 'BILLING_AND_SHIPPING', 'COLLEGE_SUCCESS_MATERIAL', 'SUBSCRIBE_NOW'
        ,'LEARN_MORE') OR (event_action = 'JUMP' AND event_type IN ('GAIN_THE_SKILLS', 'EXPLORE_CAREERS', 'GET_THE_JOB', 'TOPICAL_CAROUSELTHEN') ))) THEN event_id END;;
  }

  dimension: above_the_course {
    type:  yesno
    label:"Above the course usage - no ebook"
    sql:(event_name IN (
      'Rent From Chegg Clicked',
      'Flashcards Launched',
      'Test Prep Launched',
      'Partner Chegg Modal Continue',
      'Partner Dashlane12 Modal Continue',
      'Partner Dashlane6 Modal Continue',
      'Partner Evernote Modal Continue',
      'Partner Kaplan Modal Continue',
      'Partner Quizlet Modal Continue',
      'Launch Career Center Material',
      'Launch College Success Material',
      'Launch Quick Lesson'
              ) )
              OR  (event_action = 'LAUNCH' AND  event_type IN ('STUDY_TOOLS_PAGE', 'MY_RENTALS', 'MY_ACCOUNT', 'MY_ORDERS', 'CAREER_CENTER', 'PARTNER_OFFERS', 'SIDEBAR', 'FULL_COURSE_MATERIAL'
              ,'PRINT_OPTIONS', 'CAREER_CENTER_MATERIAL', 'COLLEGE_SUCCESS_CENTER', 'QUICK_LESSON', 'COURSES', 'STUDY_PACK_MATERIAL', 'BILLING_AND_SHIPPING', 'COLLEGE_SUCCESS_MATERIAL', 'SUBSCRIBE_NOW'
              ,'LEARN_MORE') )
              OR (event_action = 'JUMP' AND event_type IN ('GAIN_THE_SKILLS', 'EXPLORE_CAREERS', 'GET_THE_JOB', 'TOPICAL_CAROUSEL') );;
  }


  measure: above_the_courses {
    label:"# of Above the course usages - no ebook"
    description: "Number of times a CU resource was used"
    type: count_distinct
    sql: CASE WHEN (
    (event_name IN ('Rent From Chegg Clicked',
      'Flashcards Launched',
      'Test Prep Launched',
      'Partner Chegg Modal Continue',
      'Partner Dashlane12 Modal Continue',
      'Partner Dashlane6 Modal Continue',
      'Partner Evernote Modal Continue',
      'Partner Kaplan Modal Continue',
      'Partner Quizlet Modal Continue',
      'Launch Career Center Material',
      'Launch College Success Material',
      'Launch Quick Lesson'))
              OR  (event_action = 'LAUNCH' AND  event_type IN ('STUDY_TOOLS_PAGE', 'MY_RENTALS', 'MY_ACCOUNT', 'MY_ORDERS', 'CAREER_CENTER', 'PARTNER_OFFERS', 'SIDEBAR', 'FULL_COURSE_MATERIAL'
              ,'PRINT_OPTIONS', 'CAREER_CENTER_MATERIAL', 'COLLEGE_SUCCESS_CENTER', 'QUICK_LESSON', 'COURSES', 'STUDY_PACK_MATERIAL', 'BILLING_AND_SHIPPING', 'COLLEGE_SUCCESS_MATERIAL', 'SUBSCRIBE_NOW'
              ,'LEARN_MORE') )
              OR (event_action = 'JUMP' AND event_type IN ('GAIN_THE_SKILLS', 'EXPLORE_CAREERS', 'GET_THE_JOB', 'TOPICAL_CAROUSEL')))

              THEN event_id END;;
  }



#   measure: session_count {
#     label: "# sessions"
#     type: count_distinct
#     sql: ${session_id} ;;
# #     drill_fields: [event_time, system_category, product_platform, event_type, event_action, event_data, count]
#     description: "Measure for counting unique sessions (drill fields)"
#   }
}
