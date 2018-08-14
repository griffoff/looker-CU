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
    relationship: many_to_many
  }
}

explore: ga_dashboarddata {
  label: "CU Dashboard"
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
