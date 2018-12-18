#connection: "snowflake_prod"

include: "raw*.view"                       # include all views in this project
include: "cu_ebook_usage.view"
include: "sso_merged_guids.view"
include: "products_v.view"
include: "learner_profile*.view"
include: "all_events.view"

explore: raw_mt_resource_interactions {}

explore: cu_ebook_usage {
  join: sso_merged_guids {
    sql_on: ${cu_ebook_usage.user_sso_guid} = ${sso_merged_guids.shadow_guid};;
    relationship: many_to_one
  }
  join: products_v {
    sql_on: ${cu_ebook_usage.eisbn} = ${products_v.isbn13} ;;
    relationship: many_to_one
  }
  join: learner_profile_dev {
    sql_on: coalesce(${sso_merged_guids.shadow_guid}, ${cu_ebook_usage.user_sso_guid}) = ${learner_profile_dev.user_sso_guid} ;;
    relationship: many_to_one
  }
}


explore: learner_profile_dev {

  join: sso_merged_guids {
    sql_on: ${learner_profile_dev.user_sso_guid} = ${sso_merged_guids.primary_guid};;
    relationship: many_to_one
  }
  join: cu_ebook_usage {
    sql_on: coalesce(${sso_merged_guids.shadow_guid}, ${learner_profile_dev.user_sso_guid}) = ${cu_ebook_usage.user_sso_guid};;
    relationship: one_to_many
  }
  join: products_v {
    sql_on: ${cu_ebook_usage.eisbn} = ${products_v.isbn13} ;;
    relationship: many_to_one
  }
}
