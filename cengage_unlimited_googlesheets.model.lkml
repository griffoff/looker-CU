connection: "snowflake_googlesheets"
include: "all_events.view.lkml"         # include all views in this project

case_sensitive: no

######## User Experience Journey Start ###################

explore: all_events {
  }
