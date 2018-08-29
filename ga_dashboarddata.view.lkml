view: ga_dashboarddata {
  sql_table_name: RAW_GA.GA_DASHBOARDDATA ;;

  dimension: browser {
    type: string
    sql: ${TABLE}."BROWSER" ;;
    hidden: yes
  }

  dimension: browserversion {
    type: string
    sql: ${TABLE}."BROWSERVERSION" ;;
  }

  dimension: coursekey {
    type: string
    sql: ${TABLE}."COURSEKEY" ;;
    hidden: yes
  }

  dimension: devicecategory {
    type: string
    sql: ${TABLE}."DEVICECATEGORY" ;;
  }

  dimension: environment {
    type: string
    sql: ${TABLE}."ENVIRONMENT" ;;
    hidden: yes
  }

  dimension: eventaction {
    type: string
    sql: ${TABLE}."EVENTACTION" ;;
  }

  dimension: search_term_with_results{
    type: string
    label: "Search Terms"
    sql:  case when ${eventcategory} like 'Dashboard' and eventaction like 'Search Term%' then split_part(${eventlabel},'|',1) else ${eventlabel} END;;
  }

  dimension: search_term_with_no_results{
    type: string
    label: "No Result Search Terms"
    sql:  case when ${eventcategory} like 'Dashboard' and eventaction like 'Search Bar No%' then split_part(${eventlabel},'|',1) else ${eventlabel} END;;
  }

  dimension: Added_content{
    label: "Event Dimensions"
    type: string
    sql: case when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Add To My Content Position%' then 'Added Content To Dashboard'
              when eventaction like 'Search Term%'  then 'Searched Items With Results'
              when eventaction like 'Calls To Action (CTAs)' and LOWER(eventlabel) like 'dashboard%ebook%' then 'ebook launched'
              when eventaction like 'Dashboard Course Launched Name%' then 'courseware launched'
              when eventaction like 'Explore Catalog%' then 'catalog explored'
              when eventaction like 'Rent From Chegg%'  then 'Rented from Chegg'
              when  eventaction like 'Exclusive Partner Clicked' then 'One month Chegg clicks'
              when eventaction like 'Search Bar No%'  then 'No Results Search'
              when eventaction like 'Support Clicked' then 'Support Clicked'
              when eventaction like '%FAQ%' then 'FAQ Clicked'
              when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Buy Now Button Click' then 'Clicked on UPGRADE (yellow banner)'
              when ${eventcategory} like 'Course Key Registration' then 'Course Key Registration'
              when ${eventcategory} like 'Access Code Registration' then 'Access Code Registration'
              when ${eventcategory} like 'Videos' and eventaction like 'Meet Cengage Unlimited' then 'CU videos viewed'
              ELSE 'Other'
              END
    ;;
  }

  measure: AddTodash_events{
    label: "Added Content"
    type: sum
    sql: case when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Add To My Content Position%' then 1 else 0 end   ;;
  }

  measure: Search_events{
    label: "# searchs"
    type: sum
    sql: case when eventaction like 'Search With Results%'  then 1 else 0 end   ;;
  }

  measure: noresult_search{
    label: "# No results search"
    type: sum
    sql: case when eventaction like 'Search Bar No%'  then 1 else 0 end   ;;
  }

  measure: ebook_launch{
    label: "# eBooks launched"
    type: sum
    sql: case when eventaction like 'Calls To Action (CTAs)' and LOWER(eventlabel) like 'dashboard%ebook%' then 1 else 0 end   ;;
  }

  measure: courseware_launch{
    label: "# Courseware launched"
    type: sum
    sql: case when eventaction like 'Dashboard Course Launched Name%' then 1 else 0 end   ;;
  }

  measure: catalog_clicks{
    label: "# Clicks on catalog"
    type: sum
    sql: case when eventaction like 'Explore Catalog%' then 1 else 0 end   ;;
  }

  measure: rent_chegg_clicks{
    label: "# Rent From Chegg Clicks"
    type: sum
    sql: case when eventaction like 'Rent From Chegg%' then 1 else 0 end   ;;
  }

  measure: one_month_chegg_clicks{
    label: "# 1 Month Chegg Clicks"
    type: sum
    sql: case when eventaction like 'Exclusive Partner%' then 1 else 0 end   ;;
  }

  measure: support_clicks{
    label: "# support clicks"
    type: sum
    sql: case when eventaction like 'Support%' then 1 else 0 end   ;;
  }

  measure: faq_clicks{
    label: "# FAQ clicks"
    type: sum
    sql: case when eventaction like '%FAQ%' then 1 else 0 end   ;;
  }

  measure: upgrade_clicks {
    label: "UPGRADE button clicks"
    type: sum
    sql: case when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Buy Now Button Click' then 1 else 0 end  ;;
  }

  measure: course_key_events {
    label: "Course Key Registrations"
    type: sum
    sql: case when ${eventcategory} like 'Course Key Registration' then 1 else 0 end  ;;
  }

  measure: access_code_events {
    label: "Access Code Registrations"
    type: sum
    sql: case when ${eventcategory} like 'Access Code Registration' then 1 else 0 end  ;;
  }

  measure: cu_video_events {
    label: "CU video viewed"
    type: sum
    sql: case when ${eventcategory} like 'Videos' and eventaction like 'Meet Cengage Unlimited' then 1 else 0 end  ;;
  }


  dimension: eventcategory {
    type: string
    sql: ${TABLE}."EVENTCATEGORY" ;;
  }

  dimension: eventlabel {
    type: string
    sql: ${TABLE}."EVENTLABEL" ;;
  }

  dimension: fullvisitorid {
    type: string
    sql: ${TABLE}."FULLVISITORID" ;;
    hidden: yes
  }

  dimension: geonetwork_country {
    group_label: "Geo Data"
    type: string
    sql: ${TABLE}."GEONETWORK_COUNTRY" ;;
  }

  dimension: geonetwork_metro {
    group_label: "Geo Data"
    type: string
    sql: ${TABLE}."GEONETWORK_METRO" ;;
  }

  dimension: geonetwork_region {
    group_label: "Geo Data"
    type: string
    sql: ${TABLE}."GEONETWORK_REGION" ;;
  }

  dimension: haspurchased {
    type: string
    sql: ${TABLE}."HASPURCHASED" ;;
    hidden: yes
  }

  dimension: hits_hitnumber {
    type: number
    sql: ${TABLE}."HITS_HITNUMBER" ;;
    hidden: yes
  }

  dimension: hits_hour {
    type: number
    sql: ${TABLE}."HITS_HOUR" ;;
    hidden: yes
  }

  dimension: hits_minute {
    type: number
    sql: ${TABLE}."HITS_MINUTE" ;;
    hidden: yes
  }

  dimension: hits_time {
    type: number
    sql: ${TABLE}."HITS_TIME" ;;
    hidden: yes
  }

  dimension: hits_type {
    type: string
    sql: ${TABLE}."HITS_TYPE" ;;
    hidden: yes
  }

  dimension: hostname {
    type: string
    sql: ${TABLE}."HOSTNAME" ;;
    hidden: yes
  }

  dimension: isloggedin {
    type: string
    sql: ${TABLE}."ISLOGGEDIN" ;;
    hidden: yes
  }

  dimension: ismobile {
    type: string
    sql: ${TABLE}."ISMOBILE" ;;
    hidden: yes
  }

  dimension_group: ldts {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."LDTS" ;;
    hidden: yes
  }

  dimension: mobiledevicebranding {
    type: string
    sql: ${TABLE}."MOBILEDEVICEBRANDING" ;;
    hidden: yes
  }

  dimension: operatingsystem {
    type: string
    sql: ${TABLE}."OPERATINGSYSTEM" ;;
    hidden: yes
  }

  dimension: operatingsystemversion {
    type: string
    sql: ${TABLE}."OPERATINGSYSTEMVERSION" ;;
    hidden: yes
  }

  dimension: pagebrand {
    type: string
    sql: ${TABLE}."PAGEBRAND" ;;
    hidden: yes
  }

  dimension: pagename {
    type: string
    sql: ${TABLE}."PAGENAME" ;;
    hidden: yes
  }

  dimension: pagepath {
    type: string
    sql: ${TABLE}."PAGEPATH" ;;
    hidden: yes
  }

  dimension: pagesection {
    type: string
    sql: ${TABLE}."PAGESECTION" ;;
    hidden: yes
  }

  dimension: pagesitename {
    type: string
    sql: ${TABLE}."PAGESITENAME" ;;
    hidden: yes
  }

  dimension: pagetitle {
    type: string
    sql: ${TABLE}."PAGETITLE" ;;
    hidden: yes
  }

  dimension: pagetype {
    type: string
    sql: ${TABLE}."PAGETYPE" ;;
    hidden: yes
  }

  dimension: pageurl {
    type: string
    sql: ${TABLE}."PAGEURL" ;;
    hidden: yes
  }

  dimension: partnercid {
    type: string
    sql: ${TABLE}."PARTNERCID" ;;
    hidden: yes
  }

  dimension: productsdigitaltype {
    type: string
    sql: ${TABLE}."PRODUCTSDIGITALTYPE" ;;
    hidden: yes
  }

  dimension: productsdiscipline {
    type: string
    sql: ${TABLE}."PRODUCTSDISCIPLINE" ;;
    hidden: yes
  }

  dimension: productsformat {
    type: string
    sql: ${TABLE}."PRODUCTSFORMAT" ;;
    hidden: yes
  }

  dimension: registered {
    type: string
    sql: ${TABLE}."REGISTERED" ;;
    hidden: yes
  }

  dimension: rsrc {
    type: string
    sql: ${TABLE}."RSRC" ;;
    hidden: yes
  }

  dimension: schoolid {
    type: string
    sql: ${TABLE}."SCHOOLID" ;;
  }

  dimension: schoolname {
    type: string
    sql: ${TABLE}."SCHOOLNAME" ;;
    hidden: yes
  }

  dimension: schooltype {
    type: string
    sql: ${TABLE}."SCHOOLTYPE" ;;
    hidden: yes
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
    hidden: yes
  }

  dimension: timeonscreen {
    type: number
    sql: ${TABLE}."TIMEONSCREEN" ;;
    hidden: yes
  }

  dimension: totals_hits {
    type: number
    sql: ${TABLE}."TOTALS_HITS" ;;
    hidden: yes
  }

  dimension: totals_pageviews {
    type: number
    sql: ${TABLE}."TOTALS_PAGEVIEWS" ;;
    hidden: yes
  }

  dimension: totals_timeonsite {
    type: number
    sql: ${TABLE}."TOTALS_TIMEONSITE" ;;
    hidden: yes
  }

  dimension: totals_visits {
    type: number
    sql: ${TABLE}."TOTALS_VISITS" ;;
    hidden: yes
  }

  dimension: urlrequested {
    type: string
    sql: ${TABLE}."URLREQUESTED" ;;
    hidden: yes
  }

  dimension: useracqdate {
    type: string
    sql: ${TABLE}."USERACQDATE" ;;
    hidden: yes
  }

  dimension: userid {
    type: number
    value_format_name: id
    sql: ${TABLE}."USERID" ;;
    hidden: yes
  }

  dimension: userlastlogindate {
    type: string
    sql: ${TABLE}."USERLASTLOGINDATE" ;;
  }

  dimension: userrole {
    type: string
    sql: ${TABLE}."USERROLE" ;;
  }

  dimension: userssoguid {
    type: string
    sql: ${TABLE}."USERSSOGUID" ;;
  }

  dimension: visitid {
    type: number
    value_format_name: id
    sql: ${TABLE}."VISITID" ;;
    hidden: yes
  }

  dimension: visitnumber {
    type: number
    sql: ${TABLE}."VISITNUMBER" ;;
    hidden: yes
  }

  dimension: visitstarttime {
    type: date
    sql:TO_TIMESTAMP(${TABLE}."VISITSTARTTIME");;
  }

  dimension: event_date {
    description: "Date on which a user did an event"
    type: date_time
    sql: TO_DATE(TO_TIMESTAMP(((${TABLE}."VISITSTARTTIME"*1000) + ${hits_time})/1000)) ;;
  }

  measure: count_clicks {
    label: "# Users"
    description: "Number of Distinct Users "
    type: count_distinct
    sql:  ${TABLE}."USERSSOGUID" ;;
  }

  measure: count {
    type: count
    drill_fields: [hostname, schoolname, pagesitename, pagename]
  }


}
