connection: "snowflake_dev"

include: "all_events.view.lkml"
include: "first_session_events.view.lkml"
include: "as_user_journey.view.lkml"
include: "all_events_diff.view.lkml"
#include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
# include: "usage_by_week.view.lkml"
# include: "week_to_week_sankey.view.lkml"
# include: "cengage_unlimited.model.lkml"


explore: first_session_events {}

explore: as_user_journey {}


explore: all_events {
  join: all_events_diff {
    sql_on: ${all_events.event_id} = ${all_events_diff.event_id} ;;
    relationship: many_to_one
    type: inner
  }
}

# explore: usage_by_week {}
#
# explore: week_to_week_sankey {}
