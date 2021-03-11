# view: dm_territories {
#   sql_table_name: DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_TERRITORIES ;;

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#   }

#   dimension_group: _fivetran_synced {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#   }

#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#   }

#   dimension_group: added_dt {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."ADDED_DT" ;;
#   }

#   dimension: business_unit_cd {
#     type: number
#     sql: ${TABLE}."BUSINESS_UNIT_CD" ;;
#   }

#   dimension: business_unit_de {
#     type: string
#     sql: ${TABLE}."BUSINESS_UNIT_DE" ;;
#   }

#   dimension_group: changed_dt {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."CHANGED_DT" ;;
#   }

#   dimension: gsf_cd {
#     type: string
#     sql: ${TABLE}."GSF_CD" ;;
#   }

#   dimension: gsf_de {
#     type: string
#     sql: ${TABLE}."GSF_DE" ;;
#   }

#   dimension: rvp_cd {
#     type: string
#     sql: ${TABLE}."RVP_CD" ;;
#   }

#   dimension: rvp_de {
#     type: string
#     sql: ${TABLE}."RVP_DE" ;;
#   }

#   dimension: sales_org_lvl_1_cd {
#     type: string
#     sql: ${TABLE}."SALES_ORG_LVL_1_CD" ;;
#   }

#   dimension: sales_org_lvl_1_de {
#     type: string
#     sql: ${TABLE}."SALES_ORG_LVL_1_DE" ;;
#   }

#   dimension: sales_org_lvl_2_cd {
#     type: string
#     sql: ${TABLE}."SALES_ORG_LVL_2_CD" ;;
#   }

#   dimension: sales_org_lvl_2_de {
#     type: string
#     sql: ${TABLE}."SALES_ORG_LVL_2_DE" ;;
#   }

#   dimension: sales_person_id {
#     type: number
#     sql: ${TABLE}."SALES_PERSON_ID" ;;
#   }

#   dimension: sales_rep_nm {
#     type: string
#     sql: ${TABLE}."SALES_REP_NM" ;;
#   }

#   dimension: territory_id {
#     type: string
#     sql: ${TABLE}."TERRITORY_ID" ;;
#   }

#   dimension: territory_skey {
#     type: number
#     sql: ${TABLE}."TERRITORY_SKEY" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }
# }
