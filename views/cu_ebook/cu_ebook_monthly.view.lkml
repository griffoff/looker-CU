include: "cu_ebook_rollup.view"
explore:  cu_ebook_monthly {}

view: cu_ebook_monthly {
  extends: [cu_ebook_rollup]

 parameter: table_name {
  default_value: "ebook_usage_guid_month"
}

parameter: report_range_start {
  type: date
  default_value: "2018-08-01"
}


parameter: report_range_end {
  type: date
  default_value: "2019-01-01"
}


}
