# explore:  proc_spring2019_iac_pac {}
# view: proc_spring2019_iac_pac {
#   derived_table: {
#     sql: Select *,Coalesce(pa.primary_guid,mu.user_guid) as mapped_guid
#         from UPLOADS.ZAS.SPRING2019_IAC_PAC mu
#         LEFT JOIN PROD.UNLIMITED.VW_PARTNER_TO_PRIMARY_USER_GUID pa
#         ON mu.user_guid = pa.partner_guid
#       ;;
#     sql_trigger_value: Select * from UPLOADS.ZAS.SPRING2019_IAC_PAC ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }
#
#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#     hidden: yes
#   }
#   dimension: mapped_guid {}
#
#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#   }
#
#   dimension: user_guid {
#     type: string
#     sql: ${TABLE}."USER_GUID" ;;
#   }
#
#   dimension: platform {
#     type: string
#     sql: ${TABLE}."PLATFORM" ;;
#   }
#
#   dimension: actv_dt {
#     type: date
#     sql: ${TABLE}."ACTV_DT" ;;
#   }
#
#   dimension: actv_entity_name {
#     type: string
#     sql: ${TABLE}."ACTV_ENTITY_NAME" ;;
#   }
#
#   dimension: actv_isbn {
#     type: number
#     sql: ${TABLE}."ACTV_ISBN" ;;
#   }
#
#   dimension: code_type {
#     type: string
#     sql: ${TABLE}."CODE_TYPE" ;;
#   }
#
#   dimension: cu_flg {
#     type: string
#     sql: ${TABLE}."CU_FLG" ;;
#   }
#
#   dimension: list_price {
#     type: number
#     sql: ${TABLE}."LIST_PRICE" ;;
#   }
#
#   dimension_group: _fivetran_synced {
#     type: time
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#     hidden: yes
#   }
#
#   set: detail {
#     fields: [
#       _file,
#       _line,
#       user_guid,
#       platform,
#       actv_dt,
#       actv_entity_name,
#       actv_isbn,
#       code_type,
#       cu_flg,
#       list_price,
#       _fivetran_synced_time
#     ]
#   }
# }
