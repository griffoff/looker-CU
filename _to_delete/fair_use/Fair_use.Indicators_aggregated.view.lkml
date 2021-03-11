# view: fair_use_indicators_aggregated {
#       derived_table: {
#         explore_source: indicators {
#           column: guid { field: fair_use_indicators.guid }
#           column: indicator_count { field: fair_use_indicators.indicator_count }
#         }
#         persist_for: "24 hours"
#       }
#       dimension: guid {}
#       dimension: indicator_count {
#         type: number
#       }

#       measure: user_count {
#         type: count_distinct
#         sql: ${guid} ;;
#       }



#   }
