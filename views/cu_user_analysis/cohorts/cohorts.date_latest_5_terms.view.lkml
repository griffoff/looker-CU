view: date_latest_5_terms {
  derived_table: {
    persist_for: "5 hours"
    sql:
    WITH dates_broken AS
    (
      SELECT
        GOV_AY_TERM_FULL AS governmentdefinedacademicterm
        ,MIN(date_value) AS start_date
        ,MAX(date_value) AS end_date
        ,RANK() OVER (ORDER BY start_date DESC) AS terms_chron_order_desc
      FROM INT.DM_COMMON.DIM_DATE
      WHERE GOV_AY_TERM_FULL IS NOT NULL
      GROUP BY 1
      HAVING MIN(date_value) < CURRENT_DATE()
      ORDER BY end_date DESC
      LIMIT 5
      )
      SELECT * FROM dates_broken
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
