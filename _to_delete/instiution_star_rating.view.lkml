# view: instiution_star_rating {
#   sql_table_name: UPLOADS.CU.INSTIUTION_STAR_RATING ;;

#   set: marketing_fields {
#     fields: [star_rating_2_nd_pass]
#   }

#   dimension: entity_ {
#     type: number
#     sql: ${TABLE}."ENTITY_" ;;
#   }

#   dimension: institution {
#     type: string
#     sql: ${TABLE}."INSTITUTION" ;;
#   }

#   dimension: star_rating_2_nd_pass {
#     label: "MOAT Star Rating"
#     type: number
#     sql: ${TABLE}."STAR_RATING_2_ND_PASS" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }
# }
