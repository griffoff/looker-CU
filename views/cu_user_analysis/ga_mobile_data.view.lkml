view: ga_mobiledata {
  sql_table_name: RAW_GA.GA_MOBILEDATA ;;

  dimension: activityid {
    type: string
    sql: ${TABLE}."ACTIVITYID" ;;
  }

  measure: count_activity {
    label: "# Activities"
    type: count_distinct
    sql: ${TABLE}."ACTIVITYID" ;;
  }

  dimension: activitytype {
    type: string
    sql: ${TABLE}."ACTIVITYTYPE" ;;
  }

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
    hidden: yes
  }

  dimension: primary {
    type: string
    sql: CONCAT(CONCAT(${fullvisitorid},${visitid}),${hits_hitnumber}) ;;
    primary_key: yes
  }

  dimension: geonetwork_country {
    type: string
    sql: ${TABLE}."GEONETWORK_COUNTRY" ;;
    hidden: yes
  }

  dimension: geonetwork_metro {
    type: string
    sql: ${TABLE}."GEONETWORK_METRO" ;;
    hidden: yes
  }

  dimension: geonetwork_region {
    type: string
    sql: ${TABLE}."GEONETWORK_REGION" ;;
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

  dimension: eventdate{
    label: "Event Date"
    type: date
    sql: TO_DATE(TO_TIMESTAMP(((VISITSTARTTIME*1000) + HITS_TIME)/1000));;
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

  dimension: pagepath {
    type: string
    sql: ${TABLE}."PAGEPATH" ;;
    hidden: yes
  }

  dimension: pagetitle {
    type: string
    sql: ${TABLE}."PAGETITLE" ;;
    hidden: yes
  }

  dimension: rsrc {
    type: string
    hidden: yes
    sql: ${TABLE}."RSRC" ;;
  }

  dimension: ssoisbn {
    type: string
    sql: ${TABLE}."SSOISBN" ;;
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

  dimension: userid {
    type: number
    value_format_name: id
    sql: ${TABLE}."USERID" ;;
    hidden: yes
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
    type: number
    sql: ${TABLE}."VISITSTARTTIME" ;;
    hidden: yes
  }

  measure: count_clicks {
    label: " # Users"
    type: count_distinct
    sql: ${TABLE}."USERSSOGUID"  ;;
    drill_fields: [userssoguid,eventdate]
  }

  measure: total_clicks {
    label: " # clicks"
    type: count
    drill_fields: [userssoguid,eventdate]
  }

  measure: count {
    type: count
    drill_fields: [hostname]
    hidden: yes
  }

  measure: attendance_events{
    label: "# attendance completed"
    description: "The number of times a user or other grouping (by instituion, trial user, etc.) completed attendance"
    type: sum
    sql: case when ga_mobiledata.eventaction like 'Attendance event completed'  then 1 else 0 end   ;;
  }
  measure: flashcard_events{
    label: "# flashcard events"
    description: "The number of times a user or other grouping (by instituion, trial user, etc.) carried out a flashcard event"
    type: count_distinct
    sql: case when ${TABLE}."EVENTACTION" ilike 'flashcard%'  then 1 else 0 end   ;;
  }

}
