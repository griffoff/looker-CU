#connection: "snowflake_prod"

include: "cu_ebook_usage*.view"
include: "sso_merged_guids.view"
include: "products_v.view"
include: "learner_profile*.view"
include: "all_events.view"

explore: learner_profile_dev {

  join: sso_merged_guids {
    sql_on: ${learner_profile_dev.user_sso_guid} = ${sso_merged_guids.primary_guid};;
    relationship: many_to_one
  }
  join: months {
    sql_on: ${learner_profile_dev.subscription_start_month} <= ${months.month_month}
        and ${learner_profile_dev.subscription_end_month} >= ${months.month_month}
    ;;
    relationship: many_to_one
  }

  join: cu_ebook_usage {
    sql_on: coalesce(${sso_merged_guids.shadow_guid}, ${learner_profile_dev.user_sso_guid}) = ${cu_ebook_usage.user_sso_guid}
        and ${months.month_month} = ${cu_ebook_usage.activity_month}
        ;;
    relationship: one_to_many
  }
  join: cu_ebook_usage_user_month {
    sql_on: ${cu_ebook_usage.user_sso_guid} = ${cu_ebook_usage_user_month.user_sso_guid}
      and ${cu_ebook_usage.activity_month} = ${cu_ebook_usage.activity_month};;
    relationship: many_to_one
  }
  join: products_v {
    sql_on: ${cu_ebook_usage.eisbn} = ${products_v.isbn13} ;;
    relationship: many_to_one
  }
}
