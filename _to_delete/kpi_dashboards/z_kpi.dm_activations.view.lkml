# # explore: dm_activations {}

# view: dm_activations {
#   derived_table: {
#     sql:
# select
#     PUB_SERIES_DE
#     ,actv_entity_name
#     ,"SOURCE"
#     ,organization
#     ,actv_region
#     ,cu_flg
#     ,print_digital_config_cd
#     ,actv_dt
#     ,actv.platform AS platform
# ,sum(case when actv.platform = 'WebAssign' then actv_count_wo_sitelic else actv_count_w_sitelic end) as activations
# ,sum(CASE WHEN source = 'OLR' then case when actv.platform = 'WebAssign' then actv_count_wo_sitelic else actv_count_w_sitelic end end) as olr_activations
# ,sum(CASE WHEN source <> 'OLR' then case when actv.platform = 'WebAssign' then actv_count_wo_sitelic else actv_count_w_sitelic end end) as non_olr_activations
# from dev.aa_kpi.dm_activations actv
# inner join dev.aa_kpi.dm_products product on actv.product_skey = product.product_skey
# GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   measure: activations_sum {
#     type: sum
#     sql: ${TABLE}."ACTIVATIONS" ;;
#     drill_fields: [detail*]
#   }

#   measure: activations_cu {
#     type: sum
#     sql: CASE WHEN ${cu_flg} = 'Y' THEN ${TABLE}."ACTIVATIONS"  ELSE 0 END ;;
#     drill_fields: [detail*]
#   }

#   measure: activations_non_cu {
#     type: sum
#     sql: CASE WHEN ${cu_flg} = 'N' THEN ${TABLE}."ACTIVATIONS"  ELSE 0 END ;;
#     drill_fields: [detail*]
#   }

#   dimension: platform {
#     label: "Platform (original name)"
#     type: string
#     sql: ${TABLE}."PLATFORM" ;;
#   }

#   dimension: platform_other {
#     label: "Platform"
#     type: string
#     sql:  CASE WHEN ${TABLE}."PLATFORM" IN ('MindTap', 'WebAssign', 'MindTap Reader', 'CNOW', 'Aplia', 'OWL V2', 'SAM', 'Quia') THEN ${TABLE}."PLATFORM"
#                 WHEN ${TABLE}."PLATFORM" IS NULL THEN 'Unknown'
#                 WHEN ${TABLE}."PLATFORM" ILIKE '%4LTR%' THEN '4LTR' ELSE 'Other' END ;;
#   }



#   dimension: pub_series_de {
#     type: string
#     sql: ${TABLE}."PUB_SERIES_DE" ;;
#   }


#   dimension: actv_entity_name {
#     type: string
#     sql: ${TABLE}."ACTV_ENTITY_NAME" ;;
#   }


#   dimension: source {
#     type: string
#     sql: ${TABLE}."SOURCE" ;;
#   }

#   dimension: organization {
#     type: string
#     sql: ${TABLE}."ORGANIZATION" ;;
#   }


#   dimension: actv_region {
#     type: string
#     sql: ${TABLE}."ACTV_REGION" ;;
#   }

#   dimension: cu_flg {
#     type: string
#     sql: ${TABLE}."CU_FLG" ;;
#   }

#   dimension: print_digital_config_cd {
#     type: string
#     sql: ${TABLE}."PRINT_DIGITAL_CONFIG_CD" ;;
#   }



#   dimension: actv_dt {
#     type: date
#     sql: ${TABLE}."ACTV_DT" ;;
#   }


#   dimension: activations {
#     type: number
#     sql: ${TABLE}."ACTIVATIONS" ;;
#   }

#   dimension: olr_activations {
#     type: number
#     sql: ${TABLE}."OLR_ACTIVATIONS" ;;
#   }

#   dimension: non_olr_activations {
#     type: number
#     sql: ${TABLE}."NON_OLR_ACTIVATIONS" ;;
#   }

#   set: detail {
#     fields: [pub_series_de, activations, olr_activations, non_olr_activations]
#   }
# }
