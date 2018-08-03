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
