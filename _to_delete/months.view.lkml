view: months {
  view_label: "Report Months"
  derived_table: {
    sql: select dateadd(month, seq4(), '2018-08-01') as month
          from table(generator(rowcount=>24)) ;;
    persist_for: "24 hours"
  }
  dimension_group: month {
    type: time
    timeframes: [month]
    label: "Month"

  }
}
