connection: "snowflake_dev"

include: "*.view"                       # include all views in this project
#include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
explore: first_session_events {}

explore: as_user_journey {}


explore: all_events {
  join: all_events_diff {
    sql_on: ${all_events.event_id} = ${all_events_diff.event_id} ;;
    relationship: many_to_one
    type: inner
  }
}
