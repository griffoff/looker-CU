view: date_latest_5_terms {
  derived_table: {
    persist_for: "5 hours"
    sql:
    WITH dates_broken AS
    (
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
      LIMIT 5
      )
      SELECT
            governmentdefinedacademicterm
            ,start_date
            ,CASE WHEN end_date = '2019-10-07' THEN '2019-12-31'::date ELSE end_date END AS end_date
            ,terms_chron_order_desc
      FROM dates_broken
      ;;
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
