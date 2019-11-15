# include: "//mongo_sync/*.lkml"
# include: "//mongo_sync/*.view"



# explore: z_kpi_cnow_usage {}

# view: z_kpi_cnow_usage  {
#     derived_table: {
#       explore_source: all_take_nodes {
#         column: submission_week { field: take_node.submission_week }
#         column: users_taken { field: take_node.users_taken }
#         filters: {
#           field: take_node.submission_month
#           value: "1 years"
#         }
#         filters: {
#           field: take_node.activity_node_system
#           value: "cnow"
#         }
#       }
#     }
#     dimension: submission_week {
#       type: date_week
#     }
#     dimension: users_taken {
#       label: "Take Node # Users taken"
#       type: number
#     }
#   }
