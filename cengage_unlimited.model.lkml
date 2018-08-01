connection: "snowflake_prod"

include: "*.view.lkml"         # include all views in this project
include: "/core/common.lkml"

explore: raw_subscription_event {}

explore: ga_dashboarddata_temp {
  label: "CU Dashboard Events"

}

explore: raw_olr_provisioned_product {
  label: "CU Provisioned Product"

}
