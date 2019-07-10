view: date_latest_5_terms {
  derived_table: {
    sql:
      SELECT
        governmentdefinedacademicterm
        ,MIN(datevalue) AS start_date
        ,MAX(datevalue) AS end_date
        ,RANK() OVER (ORDER BY start_date DESC) AS terms_chron_order_desc
      FROM prod.dw_ga.dim_date
      WHERE governmentdefinedacademicterm IS NOT NULL
      GROUP BY 1
      HAVING MIN(datevalue) < CURRENT_DATE()
      ORDER BY end_date DESC
      LIMIT 5;;
  }

  dimension: governmentdefinedacademicterm {
    type: string
  }

  dimension: start_date {
    type: date
  }

  dimension: end_date {
    type: date
  }

  dimension: terms_chron_order_desc {
    type: number
  }
}
