explore: z_kpi_total_activations_fy_2020 {}

view: z_kpi_total_activations_fy_2020 {
  derived_table: {
    sql: SELECT
          COUNT(*)
      FROM prod.stg_clts.activations_olr
      WHERE actv_dt BETWEEN '2019-04-01' AND CURRENT_DATE()
      AND latest
      AND organization IS NOT null
      AND in_actv_flg
      AND actv_region = 'USA'
      AND dw_deleted = FALSE
      AND platform <> 'Cengage Unlimited'
       ;;
  }

  dimension: count {
    type: number
    sql: ${TABLE}."COUNT(*)" ;;
  }

  measure: count_tile {
    type: number
    sql: ${TABLE}."COUNT(*)" ;;
  }

  set: detail {
    fields: [count]
  }
}
