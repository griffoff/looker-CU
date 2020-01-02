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
          ,COUNT(DISTINCT g.geonetwork_metro) OVER (PARTITION BY g.userssoguid) as unique_cities
          ,COUNT(DISTINCT g.fullvisitorid) OVER (PARTITION BY g.userssoguid) as unique_devices
      FROM prod.raw_ga.ga_dashboarddata g
      LEFT JOIN prod.stg_clts.products p
          ON p.title = SPLIT(g.eventlabel, '|')[1]
      LEFT JOIN olr.prod.provisioned_product pp
          ON g.coursekey = pp.source_id
      LEFT JOIN prod.unlimited.raw_olr_extended_iac iac
          ON pp.product_id = iac.pp_pid
          AND pp.user_type LIKE 'student'
      LEFT JOIN prod.unlimited.excluded_users eu
        ON g.userssoguid = eu.user_sso_guid
      WHERE eu.user_sso_guid IS NULL
      AND eventcategory = 'Dashboard'
      AND ((eventaction LIKE '%Calls%'AND LOWER(eventlabel) LIKE 'dashboard%ebook%' ) OR eventaction LIKE '%Course Launched Name%')
      AND userssoguid <> '0'
      AND userssoguid <> ''
      AND userssoguid IS NOT NULL

       ;;
  }

  measure: count {
    type: count
  }

  dimension: unique_cities {
    type: number
  }

  dimension: unique_devices {
    type: number
  }

  dimension: userssoguid {
    type: string
    sql: ${TABLE}."USERSSOGUID" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: isbn13 {
    type: string
    sql: ${TABLE}."GA_ISBN" ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}."LABEL" ;;
  }

  dimension: ebook_vs_courseware {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."GEONETWORK_METRO" ;;
  }

  dimension: DeviceID {
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


  measure: unique_cities_m {
    type:  count_distinct
    sql: ${city} ;;
  }

  measure: unique_device_ids_m {
    type:  count_distinct
    sql: ${DeviceID} ;;
  }

  measure: unique_isbn13 {
    type:  count_distinct
    sql: ${isbn13} ;;
  }
}