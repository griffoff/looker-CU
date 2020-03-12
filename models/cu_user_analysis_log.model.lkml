connection: "snowflake_dev"

# include all the views
include: "/views/cu_user_analysis_log/*.view.lkml"

datagroup: cu_dev_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: cu_dev_default_datagroup

explore: all_events_check {}

explore: all_sessions_check {}

explore: learner_profile_check {}
