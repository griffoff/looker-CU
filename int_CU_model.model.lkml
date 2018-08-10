connection: "snowflake_int"

include: "*.view.lkml"         # include all views in this project
# include: "/cengage_unlimited/.*.dashboard.lookml"  # include all dashboards in this project
# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#

explore: int_raw_subscription {

}
