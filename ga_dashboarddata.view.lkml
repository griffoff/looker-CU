view: ga_dashboarddata {
  sql_table_name: RAW_GA.GA_DASHBOARDDATA ;;

  dimension: browser {
    type: string
    sql: ${TABLE}."BROWSER" ;;
  }

  dimension: browserversion {
    type: string
    sql: ${TABLE}."BROWSERVERSION" ;;
  }

  dimension: coursekey {
    type: string
    sql: ${TABLE}."COURSEKEY" ;;
  }

  dimension: devicecategory {
    type: string
    sql: ${TABLE}."DEVICECATEGORY" ;;
  }

  dimension: environment {
    type: string
    sql: ${TABLE}."ENVIRONMENT" ;;
  }

  dimension: eventaction {
    type: string
    sql: ${TABLE}."EVENTACTION" ;;
  }

  dimension: Added_content{
    label: "Event Dimensions"
    type: string
    sql: case when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Add To My Content Position%' then 'Added Content To Dashboard'
              when eventaction like 'Search%'  then 'Searched Items'
              when eventaction like 'Calls To Action (CTAs)' and LOWER(eventlabel) like 'dashboard%ebook%' then 'ebook launched'
              when eventaction like 'Dashboard Course Launched Name%' then 'courseware launched'
              when eventaction like 'Explore Catalog%' then 'catalog explored'
              when eventaction like 'Rent From Chegg%' OR eventaction like 'Exclusive Partner Clicked' then 'Clicked on Chegg'
              ELSE 'Other' END
    ;;
  }

#   dimension: search_event{
#     group_label: "Event Dimensions"
#     type: string
#     sql: case when eventaction like 'Search%'  then 'Searched Items' END  ;;
#   }
#
#   dimension: ebook_launches{
#     group_label: "Event Dimensions"
#     type: string
#     sql: case when eventaction like 'Calls To Action (CTAs)' and LOWER(eventlabel) like 'dashboard%ebook%' then 'ebook launched' end   ;;
#   }
#
#   dimension: courseware_launches{
#     group_label: "Event Dimensions"
#     type: string
#     sql: case when eventaction like 'Dashboard Course Launched Name%' then 'courseware launched' end   ;;
#   }
#
#   dimension: catalog_clicked{
#     group_label: "Event Dimensions"
#     type: string
#     sql: case when eventaction like 'Explore Catalog%' then 'catalog explored' end   ;;
#   }
#
#   dimension: rent_chegg_clicked{
#     group_label: "Event Dimensions"
#     type: string
#     sql: case when eventaction like 'Rent From Chegg%' OR eventaction like 'Exclusive Partner Clicked' then 'Clicked on Chegg' end   ;;
#   }

  measure: AddTodash_events{
    label: "Added Content"
    type: sum
    sql: case when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Add To My Content Position%' then 1 else 0 end   ;;
  }

  measure: Search_events{
    label: "# searchs"
    type: sum
    sql: case when eventaction like 'Search%'  then 1 else 0 end   ;;
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
    type: string
    sql: ${TABLE}."GEONETWORK_COUNTRY" ;;
  }

  dimension: geonetwork_metro {
    type: string
    sql: ${TABLE}."GEONETWORK_METRO" ;;
  }

  dimension: geonetwork_region {
    type: string
    sql: ${TABLE}."GEONETWORK_REGION" ;;
  }

  dimension: haspurchased {
    type: string
    sql: ${TABLE}."HASPURCHASED" ;;
  }

  dimension: hits_hitnumber {
    type: number
    sql: ${TABLE}."HITS_HITNUMBER" ;;
  }

  dimension: hits_hour {
    type: number
    sql: ${TABLE}."HITS_HOUR" ;;
  }

  dimension: hits_minute {
    type: number
    sql: ${TABLE}."HITS_MINUTE" ;;
  }

  dimension: hits_time {
    type: number
    sql: ${TABLE}."HITS_TIME" ;;
  }

  dimension: hits_type {
    type: string
    sql: ${TABLE}."HITS_TYPE" ;;
  }

  dimension: hostname {
    type: string
    sql: ${TABLE}."HOSTNAME" ;;
  }

  dimension: isloggedin {
    type: string
    sql: ${TABLE}."ISLOGGEDIN" ;;
  }

  dimension: ismobile {
    type: string
    sql: ${TABLE}."ISMOBILE" ;;
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
  }

  dimension: operatingsystem {
    type: string
    sql: ${TABLE}."OPERATINGSYSTEM" ;;
  }

  dimension: operatingsystemversion {
    type: string
    sql: ${TABLE}."OPERATINGSYSTEMVERSION" ;;
  }

  dimension: pagebrand {
    type: string
    sql: ${TABLE}."PAGEBRAND" ;;
  }

  dimension: pagename {
    type: string
    sql: ${TABLE}."PAGENAME" ;;
  }

  dimension: pagepath {
    type: string
    sql: ${TABLE}."PAGEPATH" ;;
  }

  dimension: pagesection {
    type: string
    sql: ${TABLE}."PAGESECTION" ;;
  }

  dimension: pagesitename {
    type: string
    sql: ${TABLE}."PAGESITENAME" ;;
  }

  dimension: pagetitle {
    type: string
    sql: ${TABLE}."PAGETITLE" ;;
  }

  dimension: pagetype {
    type: string
    sql: ${TABLE}."PAGETYPE" ;;
  }

  dimension: pageurl {
    type: string
    sql: ${TABLE}."PAGEURL" ;;
  }

  dimension: partnercid {
    type: string
    sql: ${TABLE}."PARTNERCID" ;;
  }

  dimension: productsdigitaltype {
    type: string
    sql: ${TABLE}."PRODUCTSDIGITALTYPE" ;;
  }

  dimension: productsdiscipline {
    type: string
    sql: ${TABLE}."PRODUCTSDISCIPLINE" ;;
  }

  dimension: productsformat {
    type: string
    sql: ${TABLE}."PRODUCTSFORMAT" ;;
  }

  dimension: registered {
    type: string
    sql: ${TABLE}."REGISTERED" ;;
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
  }

  dimension: schooltype {
    type: string
    sql: ${TABLE}."SCHOOLTYPE" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: timeonscreen {
    type: number
    sql: ${TABLE}."TIMEONSCREEN" ;;
  }

  dimension: totals_hits {
    type: number
    sql: ${TABLE}."TOTALS_HITS" ;;
    hidden: yes
  }

  dimension: totals_pageviews {
    type: number
    sql: ${TABLE}."TOTALS_PAGEVIEWS" ;;
  }

  dimension: totals_timeonsite {
    type: number
    sql: ${TABLE}."TOTALS_TIMEONSITE" ;;
  }

  dimension: totals_visits {
    type: number
    sql: ${TABLE}."TOTALS_VISITS" ;;
  }

  dimension: urlrequested {
    type: string
    sql: ${TABLE}."URLREQUESTED" ;;
  }

  dimension: useracqdate {
    type: string
    sql: ${TABLE}."USERACQDATE" ;;
  }

  dimension: userid {
    type: number
    value_format_name: id
    sql: ${TABLE}."USERID" ;;
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
  }

  dimension: visitstarttime {
    type: date
    sql:TO_TIMESTAMP(${TABLE}."VISITSTARTTIME");;
  }

  measure: count_clicks {
    label: "# Users"
    type: count_distinct
    sql:  ${TABLE}."USERSSOGUID" ;;
  }

  measure: count {
    type: count
    drill_fields: [hostname, schoolname, pagesitename, pagename]
  }
}
