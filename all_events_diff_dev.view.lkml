include: "all_events_diff_prod.view"

view: all_events_diff_dev {
  extends: [all_events_diff_prod]
  view_label: "Student Events Categorized"
  sql_table_name: ZPG.ALL_EVENTS_DIFF{% parameter event_type %};;

}
