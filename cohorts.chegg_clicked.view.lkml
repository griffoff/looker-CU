include: "cohorts.base.view"

view: cohorts_chegg_clicked {
  extends: [cohorts_base_events_count]

  parameter: events_to_include {
    default_value: "One month Free Chegg Clicked"
  }

  dimension: current {group_label: "Partners: Chegg clicked"}

  dimension: minus_1 {group_label: "Partners: Chegg clicked"}

  dimension: minus_2 {group_label: "Partners: Chegg clicked"}

  dimension: minus_3 {group_label: "Partners: Chegg clicked"}

  dimension: minus_4 {group_label: "Partners: Chegg clicked"}

}
