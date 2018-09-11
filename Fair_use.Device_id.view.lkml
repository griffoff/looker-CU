view: Fair_use_device_id {
  derived_table: {
    sql: WITH c AS(
      SELECT
          g.userssoguid
          ,p.isbn13
          ,g.geonetwork_metro
          ,g.fullvisitorid
          ,g.visitstarttime
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
      )

      SELECT
          userssoguid
          ,COUNT(DISTINCT geonetwork_metro) AS city_count
      FROM c
      WHERE lag_city IS NULL
      AND lead_city IS NULL
      AND lag_device IS NULL
      AND lead_device IS NULL
      GROUP BY 1
      ORDER BY 2 DESC
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

  dimension: city_count {
    type: number
  }

   set: detail {
     fields: [userssoguid, city_count]
   }
}
