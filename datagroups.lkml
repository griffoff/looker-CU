datagroup: provisioned_product {
  sql_trigger: Select COUNT(*) from UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT  ;;
}

datagroup: cu_user_analysis {
  sql_trigger: SELECT COUNT(*) FROM cu_user_analysis.learner_profile ;;
}
