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

explore: raw_subscription_event {}


explore: additional_info_products {
  label: "Provisioned Products Buckets"
}
#

explore: raw_olr_provisioned_product {
  label: "CU Provisioned Product"
}

explore: fair_use_ip_tracking {
  label: "Fair Use Dashboard"
}

explore: fair_use_device_tracking {
  label: "Fair Use Device Dashboard"
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








explore: fair_use_indicators {}

explore: fair_use_indicators_aggregated {
  label: "Fair Use Indicators agg"
}
