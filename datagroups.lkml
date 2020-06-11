datagroup: provisioned_product {
  sql_trigger: Select COUNT(*) from UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT  ;;
}

datagroup: cu_user_analysis {
  sql_trigger: SELECT COUNT(*) FROM cu_user_analysis.learner_profile ;;
}

datagroup: subscription_event_merged {
  sql_trigger: SELECT COUNT(*) FROM cu_user_analysis.subscription_event_merged ;;
}

datagroup: daily_refresh {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "16 hours"
}

datagroup: do_not_update {
  sql_trigger: SELECT 1 ;;
}
