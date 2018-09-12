view: fair_use_device_id {
  derived_table: {
    sql: SELECT
          g.userssoguid
          ,p.isbn13
          ,g.geonetwork_metro
          ,g.fullvisitorid
          ,TO_TIMESTAMP(g.visitstarttime) AS visit_start_time
          ,LAG(g.geonetwork_metro) OVER (PARTITION BY g.userssoguid, p.isbn13 ORDER BY g.visitstarttime) AS lag_city
          ,LEAD(g.geonetwork_metro) OVER (PARTITION BY g.userssoguid, p.isbn13 ORDER BY g.visitstarttime) AS lead_city
          ,LAG(g.fullvisitorid) OVER (PARTITION BY g.userssoguid, p.isbn13 ORDER BY g.visitstarttime) AS lag_device
          ,LEAD(g.fullvisitorid) OVER (PARTITION BY g.userssoguid, p.isbn13 ORDER BY g.visitstarttime) AS lead_device
      FROM prod.raw_ga.ga_dashboarddata g
      LEFT JOIN prod.stg_clts.products p
          ON p.title = SPLIT(g.eventlabel, '|')[1]
      LEFT JOIN prod.unlimited.raw_olr_provisioned_product pp
          ON g.coursekey = pp.source_id
      LEFT JOIN prod.unlimited.raw_olr_extended_iac iac
          ON pp.product_id = iac.pp_pid
          AND pp.user_type LIKE 'student'
      WHERE eventcategory = 'Dashboard'
      AND eventaction LIKE '%Call%'
      AND p.isbn13 is not NULL
      AND p.isbn13 NOT LIKE 'undefined'
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: userssoguid {
    type: string
    sql: ${TABLE}."USERSSOGUID" ;;
    drill_fields: [isbn13, geonetwork_metro, fullvisitorid, visit_start_time, detail*]
  }

  dimension: isbn13 {
    type: string
    sql: ${TABLE}."ISBN13" ;;
  }

  dimension: geonetwork_metro {
    type: string
    sql: ${TABLE}."GEONETWORK_METRO" ;;
  }

  dimension: fullvisitorid {
    type: string
    sql: ${TABLE}."FULLVISITORID" ;;
  }

  dimension: visit_start_time {
    type: number
     }

  dimension: lag_city {
    type: string
    sql: ${TABLE}."LAG_CITY" ;;
  }

  dimension: lead_city {
    type: string
    sql: ${TABLE}."LEAD_CITY" ;;
  }

  dimension: lag_device {
    type: string
    sql: ${TABLE}."LAG_DEVICE" ;;
  }

  dimension: lead_device {
    type: string
    sql: ${TABLE}."LEAD_DEVICE" ;;
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
    sql: ${isbn13} ;;
  }




  set: detail {
    fields: [
      userssoguid,
      isbn13,
      geonetwork_metro,
      fullvisitorid,
      visit_start_time,
      lag_city,
      lead_city,
      lag_device,
      lead_device
    ]
  }
}
