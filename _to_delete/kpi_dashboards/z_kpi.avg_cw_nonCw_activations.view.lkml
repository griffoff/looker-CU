# explore:  z_kpi_avg_cu_noncu_activations {}

# view: z_kpi_avg_cu_noncu_activations {
#     derived_table: {
#       explore_source: z_kpi_sf_activations {
#         column: user_guid {}
#         column: cu_activations {}
#         column: non_cu_activations {}
#         filters: {
#           field: dim_date.fiscalyear
#           value: "FY20,FY19"
#         }
#         filters: {
#           field: z_kpi_sf_activations.organization
#           value: "-NULL"
#         }
#         filters: {
#           field: z_kpi_sf_activations.platform
#           value: "-Cengage Unlimited,-MindTap Reader"
#         }
#         filters: {
#           field: z_kpi_sf_activations.platform_other
#           value: "-Unknown"
#         }
#         filters: {
#           field: z_kpi_sf_activations.registrationtype
#           value: "OLR"
#         }
#       }
#     }
#     dimension: user_guid {}
#     dimension: cu_activations {
#       label: "CU Activations"
#       type: number
#     }
#     dimension: non_cu_activations {
#       label: "Standalone Activations"
#       type: number
#     }

#     measure: average_cu_activations {
#       type: average
#       sql: ${cu_activations} ;;
#       label: "Average # CU Activations"
#       value_format_name: decimal_2
#     }

#   measure: average_non_cu_activations {
#     type: average
#     sql: ${non_cu_activations} ;;
#     label: "Average # Standalone Activations"
#     value_format_name: decimal_2
#   }


#   }
