# # explore: z_kpi_activations_dashboard_tieout_2 {}

# view: z_kpi_sf_activations {
# derived_table: {
#   sql:
# with
#       orgs as (
#               select
#                   actv_olr_id as activationid
#                   ,organization
#                   ,'OLR' as registrationtype
#                   ,cu_flg
#                   ,user_guid
#                   ,platform
#                   ,code_type
#                   ,actv_code
#                   ,actv_dt
#               from stg_clts.activations_olr
#               where organization is not null
#               and latest
#               and actv_region = 'USA'
#               AND actv_dt > '2018-08-01'
#                   AND dw_deleted = FALSE
#               and in_actv_flg = 1
#               union all
#               select
#                   actv_non_olr_id
#                   ,organization
#                   ,'Non_OLR'
#                   ,cu_flg
#                   ,unique_user_id
#                   ,platform
#                   ,'non olr'
#                   ,actv_code
#                   ,actv_dt
#               from stg_clts.activations_non_olr
#               where organization is not null
#               and latest
#               AND actv_dt > '2018-08-01'
#               and actv_region = 'USA'
#               AND dw_deleted = FALSE
#               group by 1, 2, 4, 5, 6, 7, 8, 9
#             )
#           SELECT
#             *
#           FROM orgs
# ;;
# }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   measure: cu_activations {
#     label: "CU Activations"
#     type: sum
#     sql: CASE WHEN ${cu_flg} = 'Y' THEN 1 ELSE 0 END ;;
#     drill_fields: [detail*]
#   }

#   measure: non_cu_activations {
#     label: "A La Carte Activations"
#     type: sum
#     sql: CASE WHEN ${cu_flg} = 'N' THEN 1 ELSE 0 END ;;
#     drill_fields: [detail*]
#   }

#   dimension: activationid {
#     type: number
#     sql: ${TABLE}."ACTIVATIONID" ;;
#   }

#   dimension: organization {
#     type: string
#     sql: ${TABLE}."ORGANIZATION" ;;
#   }

#   dimension: registrationtype {
#     type: string
#     sql: ${TABLE}."REGISTRATIONTYPE" ;;
#   }

#   dimension: cu_flg {
#     type: string
#     sql: ${TABLE}."CU_FLG" ;;
#   }

#   dimension: user_guid {
#     type: string
#     sql: ${TABLE}."USER_GUID" ;;
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
#     }


#   dimension: code_type {
#     type: string
#     sql: ${TABLE}."CODE_TYPE" ;;
#   }

#   dimension: actv_code {
#     type: string
#     sql: ${TABLE}."ACTV_CODE" ;;
#   }

#   dimension: actv_dt {
#     type: date
#     sql: ${TABLE}."ACTV_DT" ;;
#   }

#   set: detail {
#     fields: [
#       activationid,
#       organization,
#       registrationtype,
#       cu_flg,
#       user_guid,
#       platform,
#       code_type,
#       actv_code,
#       actv_dt
#     ]
#   }
# }
