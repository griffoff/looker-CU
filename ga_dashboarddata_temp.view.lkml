view: ga_dashboarddata_temp {
  sql_table_name: RAW_GA.GA_DASHBOARDDATA_TEMP ;;

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
  }

  dimension: visitnumber {
    type: number
    sql: ${TABLE}."VISITNUMBER" ;;
  }

  dimension: visitstarttime {
    type: number
    sql: ${TABLE}."VISITSTARTTIME" ;;
  }

  measure: count {
    type: count
    drill_fields: [hostname, schoolname, pagesitename, pagename]
  }
}
