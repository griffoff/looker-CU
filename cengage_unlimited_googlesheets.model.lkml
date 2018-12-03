connection: "snowflake_googlesheets"
#Snowflake for accessing looks from google sheets
#Snowflake_prod can't used for this purpose
#This connection dont have a user attribute in the JDBC connection string
include: "all_events.view.lkml"
include: "all_event_actions.view.lkml"


case_sensitive: no

explore: all_events {
  }

explore: all_event_actions {
}
