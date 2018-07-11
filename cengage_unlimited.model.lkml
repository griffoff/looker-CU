connection: "snowflake_dev"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project
include: "/core/common.lkml"

explore: raw_subscription_event {}

explore: ga_dashboarddata_temp {
  label: "CU Dashboard Events"

}
