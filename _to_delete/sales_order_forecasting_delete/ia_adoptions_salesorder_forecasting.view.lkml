
# view: ia_adoptions_salesorder_forecasting {
#   derived_table: {
#     sql: WITH unpiv as (
#         Select * from UPLOADS.CU.IA_ADOPTIONS_SALESORDER
#       unpivot (flags for fiscalyear in (FY_17_IA_ADOPTION_Y_N_,FY_18_IA_ADOPTION_Y_N_,FY_19_IA_ADOPTION_Y_N_))

#         )Select adoption_key,flags,
#           case when fiscalyear like 'FY_17%' THEN 'FY17'
#             WHEN fiscalyear like 'FY_18%' THEN 'FY18'
#             WHEN fiscalyear like 'FY_19%' THEN 'FY19'
#             END AS fiscalyear
#             FROM unpiv
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: adoption_key {
#     type: string
#     sql: ${TABLE}."ADOPTION_KEY" ;;
#   }

#   dimension: flags {
#     label: "IA Flags"
#     type: string
#     sql: ${TABLE}."FLAGS" ;;
#   }

#   dimension: fiscalyear {
#     type: string
#     sql: ${TABLE}."FISCALYEAR" ;;
#   }

#   set: detail {
#     fields: [adoption_key, flags, fiscalyear]
#   }
# }
