connection: "snowflake_dev"

# include all the views
include: "/cu_ua_log.all_events_check.view"
include: "/cu_ua_log.all_sessions_check.view"
include: "/cu_ua_log.learner_profile_check.view"

datagroup: cu_dev_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: cu_dev_default_datagroup

explore: all_events_check {}

explore: all_sessions_check {}

explore: learner_profile_check {}
