connection: "snowflake_dev"

include: "*.view"                       # include all views in this project
#include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
explore: first_session_events {}

explore: as_user_journey {}
