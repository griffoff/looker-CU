view: fair_use_deviceid2 {
  derived_table: {
    sql: SELECT
          g.userssoguid
          ,SPLIT(g.eventlabel, '|')[1] AS title
          ,REPLACE(SPLIT(g.eventlabel, '|')[2], '-', '') AS ga_isbn
          ,g.eventlabel AS label
          ,CASE when eventaction like 'Calls To Action (CTAs)' and LOWER(eventlabel) like 'dashboard%ebook%' then 'eBook launched'
              when eventaction like 'Dashboard Course Launched Name%' then 'Courseware launched' END AS type
          ,g.geonetwork_metro
          ,g.fullvisitorid
          ,TO_TIMESTAMP(g.visitstarttime) AS visit_start_time
          ,LAG(g.geonetwork_metro) OVER (PARTITION BY g.userssoguid, p.isbn13 ORDER BY g.visitstarttime) AS lag_city
          ,LAG(g.fullvisitorid) OVER (PARTITION BY g.userssoguid, p.isbn13 ORDER BY g.visitstarttime) AS lag_device
      FROM prod.raw_ga.ga_dashboarddata g
      LEFT JOIN prod.stg_clts.products p
          ON p.title = SPLIT(g.eventlabel, '|')[1]
      LEFT JOIN prod.unlimited.raw_olr_provisioned_product pp
          ON g.coursekey = pp.source_id
      LEFT JOIN prod.unlimited.raw_olr_extended_iac iac
          ON pp.product_id = iac.pp_pid
          AND pp.user_type LIKE 'student'
      WHERE eventcategory = 'Dashboard'
      AND ((eventaction LIKE '%Calls%'AND LOWER(eventlabel) LIKE 'dashboard%ebook%' ) OR eventaction LIKE '%Course Launched Name%')
      AND userssoguid <> '0'
      AND userssoguid <> ''
      AND userssoguid IS NOT NULL;
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: userssoguid {
    type: string
    sql: ${TABLE}."USERSSOGUID" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: ga_isbn {
    type: string
    sql: ${TABLE}."GA_ISBN" ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}."LABEL" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: geonetwork_metro {
    type: string
    sql: ${TABLE}."GEONETWORK_METRO" ;;
  }

  dimension: fullvisitorid {
    type: string
    sql: ${TABLE}."FULLVISITORID" ;;
  }

  dimension_group: visit_start_time {
    type: time
    sql: ${TABLE}."VISIT_START_TIME" ;;
  }

  dimension: lag_city {
    type: string
    sql: ${TABLE}."LAG_CITY" ;;
  }

  dimension: lag_device {
    type: string
    sql: ${TABLE}."LAG_DEVICE" ;;
  }


  measure: unique_cities {
    type:  count_distinct
    sql: ${geonetwork_metro} ;;
  }

  measure: unique_device_ids {
    type:  count_distinct
    sql: ${fullvisitorid} ;;
  }

  measure: unique_isbn13 {
    type:  count_distinct
    sql: ${ga_isbn} ;;
  }



  set: detail {
    fields: [
      userssoguid,
      title,
      ga_isbn,
      label,
      type,
      geonetwork_metro,
      fullvisitorid,
      visit_start_time_time,
      lag_city,
      lag_device
    ]
  }
}
