explore: date_ranges_kpi {hidden:yes}
view: date_ranges_kpi {
  sql_table_name: "LOOKER_SCRATCH"."DATE_RANGES"
  ;;

  dimension_group: date_range_end {
    type:time
    hidden:yes
  }

  dimension_group: date_range_start {
    type:time
    hidden:yes
  }

  dimension: date_range_key {hidden:yes}

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    hidden: yes
  }

}
