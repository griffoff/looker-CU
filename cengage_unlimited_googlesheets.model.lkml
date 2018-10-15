connection: "snowflake_googlesheets"
include: "all_events.view.lkml"
include: "all_event_actions.view.lkml"

case_sensitive: no

explore: all_events {
  }

explore: all_event_actions {
}
