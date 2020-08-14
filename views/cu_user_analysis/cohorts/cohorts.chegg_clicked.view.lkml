include: "cohorts.base.view"

view: cohorts_chegg_clicked {
  extends: [cohorts_base_events_count]

  parameter: events_to_include {
    default_value: "One month Free Chegg Clicked"
  }

#   parameter: term_descr {
#     type: string
#     default_value: "(Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec)"
#   }

  dimension: current {group_label: "Partners: Chegg clicked" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

  dimension: minus_1 {group_label: "Partners: Chegg clicked" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

  dimension: minus_2 {group_label: "Partners: Chegg clicked" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

  dimension: minus_3 {group_label: "Partners: Chegg clicked" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

  dimension: minus_4 {group_label: "Partners: Chegg clicked" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

}
