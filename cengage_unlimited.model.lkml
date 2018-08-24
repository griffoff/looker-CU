connection: "snowflake_prod"

include: "*.view.lkml"         # include all views in this project


include: "/core/common.lkml"

explore:raw_fair_use_logins_distinct
{
  label: "CMP Dashboard Distinct"
}

explore:raw_fair_use_logins
{
  label: "CMP Dashboard"
}

explore: raw_subscription_event {

  join: raw_olr_provisioned_product {
    sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid};;
    relationship: many_to_one
  }
}

explore: ga_dashboarddata {
  label: "CU Dashboard"

  join: raw_subscription_event {
    sql_on: ${ga_dashboarddata.userssoguid} = ${raw_subscription_event.user_sso_guid} ;;
    relationship: many_to_one
  }
}


explore: additional_info_products {
  label: "Provisioned Products Buckets"
}
#

explore: raw_olr_provisioned_product {
  label: "CU Provisioned Product"
}

explore: fair_use_tracking {
  label: "Fair Use Tracking"
}

explore: indicators {
  label: "Indicators"

join: fair_use_indicators {
  sql_on: ${indicators.indicator_id} = ${fair_use_indicators.indicator_id};;
  relationship: one_to_many
}
  join: fair_use_indicators_aggregated {
    sql_on: ${indicators.indicator_id} = ${fair_use_indicators_aggregated.indicator_count} ;;
    relationship: one_to_many
}
}

explore: fair_use_tracking_vitalsource {}


explore: fair_use_indicators {}

explore: fair_use_indicators_aggregated {
  label: "Fair Use Indicators agg"}



explore: ind {
  from: indicators
  label: "Ind"

  join: fair_use_indicators {
    sql_on: ${ind.indicator_id} = ${fair_use_indicators.indicator_id};;
    relationship: one_to_many
  }}


explore: provisioned_product {
from: raw_olr_provisioned_product
join: raw_subscription_event {
  sql_on: ${provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid} ;;
  relationship: many_to_one
}
join:  raw_vitalsource_event {
  sql_on: ${provisioned_product.user_sso_guid} = ${raw_vitalsource_event.user_sso_guid} ;;
  relationship: many_to_many

}
 }

explore: ebook_usage {}

explore: ebook_usage_aggregated {}

explore: ebook_usage_aggregated_by_week {}
explore: coursewares_activated_week {}
explore: coursewares_activated {}
explore: device_changes {}
explore: device_changes_all_time {}
explore: unique_cities_per_user_per_week{}
explore: unique_cities_per_user {}
explore: weeks_above_threshhold_cities {}

# explore: ebook_usage {
#   from: raw_vitalsource_event
#   join: raw_mt_resource_interactions {
#     sql: ${ebook_usage.user_sso_guid} = ${raw_mt_resource_interactions.user_identifier};;
#     sql_where: ${raw_mt_resource_interactions.event_category} = 'READING' AND ${raw_mt_resource_interactions.event_action} = 'VIEW' ;;
#   }

#   join: ga_mobiledata {
#     sql: ${raw_vitalsource_event.user_sso_guid} = ${ga_mobiledata.userssoguid} ;;
#   }
