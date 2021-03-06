# include: "/views/cu_user_analysis/live_subscription_status.view"
# include: "/views/cu_user_analysis/merged_cu_user_info.view"
# include: "/views/uploads/uploads.cu_sidebar_cohort.view"

# explore: raw_olr_provisioned_product {hidden:yes}

# view: raw_olr_provisioned_product {
#   view_label: "Provisioned Product"

# derived_table: {
#   sql:
#   with prod as (
#     select
#       ssn.HUB_SERIALNUMBER_KEY
#       ,ssn.registration_date
#       , coalesce(su.linked_guid, hu.uid) as merged_guid
#       , concat(merged_guid, spp.DATE_ADDED::date, spp.PRODUCT_ID) as provision_key
#       , spp.DATE_ADDED::date as date_added
#       , spp.CONTEXT_ID
#       , spp.EXPIRATION_DATE
#       , spp.IAC_ISBN
#       , spp.PRODUCT_ID
#       , COALESCE(spp.USER_TYPE
#         ,
#         CASE WHEN su.k12 THEN 'k12' ELSE '' END
#         || CASE WHEN su.instructor THEN 'instructor' ELSE 'student' END
#         ) as user_type
#       , INITCAP(REPLACE(SUBSTRING(spp.modified_by, 4), '_', ' ')) as added_by
#     from prod.DATAVAULT.SAT_PROVISIONED_PRODUCT_V2 spp
#     INNER JOIN prod.datavault.hub_user hu ON spp.user_sso_guid = hu.uid
#     INNER JOIN prod.datavault.sat_user_v2 su ON hu.hub_user_key = su.hub_user_key AND su._latest
#     LEFT JOIN prod.datavault.sat_user_internal sui ON hu.hub_user_key = sui.hub_user_key AND sui.internal AND sui.active
#     left join prod.DATAVAULT.LINK_SERIALNUMBER_USER lsu on lsu.HUB_USER_KEY = hu.HUB_USER_KEY
#     left join prod.DATAVAULT.LINK_PRODUCT_PROVISIONEDPRODUCT lpp on lpp.HUB_PROVISIONED_PRODUCT_KEY = spp.HUB_PROVISIONED_PRODUCT_KEY
#     left join prod.DATAVAULT.LINK_SERIALNUMBER_PRODUCT lsp on lsp.HUB_PRODUCT_KEY = lpp.HUB_PRODUCT_KEY and lsp.HUB_SERIALNUMBER_KEY = lsu.HUB_SERIALNUMBER_KEY
#     left join prod.DATAVAULT.SAT_SERIAL_NUMBER_CONSUMED ssn on ssn.HUB_SERIALNUMBER_KEY = lsp.HUB_SERIALNUMBER_KEY and ssn._LATEST
#     where spp._LATEST
#       --and sui.INTERNAL is null
#       --and spp.USER_TYPE ilike 'student'
#     )
#     ,prod_clean as (
#       select
#         merged_guid
#         , provision_key
#         , DATE_ADDED
#         , PRODUCT_ID
#         , USER_TYPE
#         , iac_isbn
#         , added_by
#         , max(registration_date) as registration_date
#         , max(HUB_SERIALNUMBER_KEY) as hub_serial_number_key
#         , array_agg(distinct CONTEXT_ID) as context_id_array
#         , max(EXPIRATION_DATE) as expiration_date
#       from prod
#       group by 1,2,3,4,5,6,7
#     )

#     , types AS (
#       SELECT iac.pp_pid
#         , iac.pp_product_type
#         , iac.pp_name
#         , array_agg(DISTINCT iac.cp_product_type) AS cppt
#       FROM prod.unlimited.raw_olr_extended_iac AS iac
#       GROUP BY iac.pp_pid, iac.pp_product_type, pp_name
#     )

#     SELECT
#       pp.*
#       , iac.pp_product_type
#       , pp_name
#       , coalesce(registration_date,date_added) as date_paid
#       , nullif(context_id_array,array_construct()) as context_id
#       , case when hub_serial_number_key is not null then 1 else 0 end as paid_provision
#       , case when hub_serial_number_key is not null then 0 else 1 end as unpaid_provision

#       , case when current_date() between date_added and expiration_date then 1 else 0 end as current_provision
#       , case when (current_date() between date_added and expiration_date) and context_id is null then 1 else 0 end as current_ebook_provision
#       , case when (current_date() between date_added and expiration_date) and context_id is not null then 1 else 0 end as current_courseware_provision

#       , sum(current_courseware_provision) over (partition by merged_guid) as current_user_courseware_provisions
#       , sum(case when paid_provision = 1 then current_courseware_provision else 0 end) over (partition by merged_guid) as current_user_paid_courseware_provisions
#       , sum(current_provision) over (partition by merged_guid) as current_user_provisions
#       , sum(case when paid_provision = 1 then current_provision else 0 end) over (partition by merged_guid) as current_paid_user_provisions

#       , sum(case when unpaid_provision = 1 then current_provision else 0 end) over (partition by merged_guid) as current_unpaid_user_provisions

#       , sum(current_ebook_provision) over (partition by merged_guid) as current_user_ebook_provisions
#       , sum(case when paid_provision = 1 then current_ebook_provision else 0 end) over (partition by merged_guid) as current_paid_user_ebook_provisions

#       , CASE
#           WHEN iac.pp_product_type NOT LIKE 'SMART' THEN iac.pp_product_type
#           WHEN ARRAY_CONTAINS('MTC'::VARIANT, cppt) THEN 'MTC'
#           WHEN ARRAY_CONTAINS('CSFI'::VARIANT, cppt) THEN 'CSFI'
#           WHEN ARRAY_CONTAINS('4LT'::VARIANT, cppt) THEN '4LT'
#           WHEN ARRAY_CONTAINS('APLIA'::VARIANT, cppt) THEN 'APLIA'
#           WHEN ARRAY_CONTAINS('SAM'::VARIANT, cppt) THEN 'SAM'
#           WHEN ARRAY_CONTAINS('CNOWV8'::VARIANT, cppt) THEN 'CNOWV8'
#           WHEN ARRAY_CONTAINS('NATGEO'::VARIANT, cppt) THEN 'NATGEO'
#           WHEN ARRAY_CONTAINS('MT4'::VARIANT, cppt) THEN 'MT4'
#           WHEN ARRAY_CONTAINS('4LTV1'::VARIANT, cppt) THEN '4LTV1'
#           WHEN ARRAY_CONTAINS('DEV-MATH'::VARIANT, cppt) THEN 'DEV-MATH'
#           WHEN ARRAY_CONTAINS('OWL'::VARIANT, cppt) OR ARRAY_CONTAINS('OWLV8'::VARIANT, cppt) THEN 'OWL'
#           WHEN ARRAY_CONTAINS('MTS'::VARIANT, cppt) THEN 'MTS'
#           WHEN ARRAY_CONTAINS('WA'::VARIANT, cppt) THEN 'WA'
#           WHEN ARRAY_CONTAINS('WA3P'::VARIANT, cppt) THEN 'WA3P'
#           ELSE 'other'
#         END AS product_type_platform
#     FROM prod_clean pp
#     LEFT JOIN types iac ON iac.pp_pid = pp.product_id
#     ;;

#   datagroup_trigger: daily_refresh
# }

#   dimension: provision_key {
#     primary_key: yes
#     hidden:  yes
#   }

#   dimension: iac_isbn {
#     type: string
#     sql: ${TABLE}."IAC_ISBN" ;;
#   }

#   dimension: pp_name {
#     label: "Product Name"
#   }

#   dimension: merged_guid {hidden:yes}

#   dimension: user_sso_guid {
#     sql: ${merged_guid} ;;
#     hidden: yes
#   }

#   dimension: HUB_SERIAL_NUMBER_KEY {hidden:yes}


#   dimension: pp_product_type {
#     description: "Can be filtered on to differentiate between courseware and ebook usage"
#     label: "Product Type"
#   }

#   dimension: product_type_platform {
#     description: "Platform names derived from 'SMART' product type"
#   }

#   dimension: context_id {
#     description: "Course registration key (array to allow for multiple values)"
#     sql: ${TABLE}."CONTEXT_ID" ;;
#   }

#   dimension: date_paid {
#     type: date
#     sql: case when ${HUB_SERIAL_NUMBER_KEY} is not null then ${TABLE}.date_paid end ;;
#     label: "Date paid (approximate)"
#     description: "Date added for ebook or courseware with serial number consumed"
#   }

#   dimension_group: date_added {
#     description: "Date this product was provisioned i.e. added to the dashboard"
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

#   }

#   dimension_group: expiration {
#     description: "Date this product will expire"
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
#     sql: ${TABLE}."EXPIRATION_DATE" ;;
#   }

#   dimension: product_id {
#     type: string
#     sql: ${TABLE}."PRODUCT_ID" ;;
#   }

#   measure: count {
#     label: "# Products Provisioned"
#     description: "Count of unique products provisioned (guid + date added + product ID combinations)"
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: current_provision {
#     label: "Product provisioned"
#     description: "Product is currently provisioned (expiration date not passed)"
#     type: number
#   }

#   dimension: current_ebook_provision {
#     label: "eBook provisioned"
#     description: "Product has no context_id and is currently provisioned (expiration date not passed)"
#     type: number
#   }


# #   measure: current_product_count_number {
# #     label: "# Current Products Provisioned (type: number)"
# #     description: "Count of unique product ids where date added is in the past and expiration date is in the future"
# #     type: number
# #     drill_fields: [detail*]
# #     sql:  sum(${current_provision});;
# #   }

#   measure: current_paid_product_count_sum {
#     label: "# Current Paid Products Provisioned"
#     description: "Count of unique product ids where date added is in the past and expiration date is in the future that the user has paid for"
#     type: sum
#     drill_fields: [detail*]
#     sql: ${TABLE}.paid_provision * ${current_provision};;
#   }

#   measure: current_paid_ebook_count_sum {
#     label: "# Current Paid eBooks Provisioned"
#     description: "Count of unique ebook product ids where date added is in the past and expiration date is in the future that the user has paid for"
#     type: sum
#     drill_fields: [detail*]
#     sql: ${TABLE}.paid_provision * ${current_ebook_provision};;
#   }


#   measure: current_product_count_sum {
#     label: "# Current Products Provisioned"
#     description: "Count of unique product ids where date added is in the past and expiration date is in the future"
#     type: sum
#     drill_fields: [detail*]
#     sql: ${current_provision};;
#   }

# #   measure: current_ebook_product_number {
# #     label: "# Current eBooks Provisioned"
# #     description: "Count of unique product ids with no context id where date added is in the past and expiration date is in the future"
# #     type: number
# #     drill_fields: [detail*]
# #     sql:  sum(${current_ebook_provision});;
# #   }

#   measure: user_count{
#     description: "Count of unique user guids"
#     type: count_distinct
#     sql:  ${user_sso_guid};;
#   }

#   dimension: user_type {
#     type: string
#     sql: ${TABLE}."USER_TYPE" ;;
#   }

#   dimension: added_by {
#     type: string
#   }

#   dimension: current_user_provisions {
#     type:number
#     description:"For particular user guid"
#     sql: coalesce(${TABLE}.current_user_provisions,0) ;;
#     }

#   dimension: current_paid_user_provisions {
#     type:number
#     description:"For particular user guid"
#     sql: coalesce(${TABLE}.current_paid_user_provisions,0) ;;
#     }

#   dimension: current_unpaid_user_provisions {
#     type:number
#     description:"For particular user guid"
#     sql: coalesce(${TABLE}.current_unpaid_user_provisions,0) ;;
#     }

#   dimension: current_user_ebook_provisions {
#     type:number
#     description:"For particular user guid"
#     sql: coalesce(${TABLE}.current_user_ebook_provisions,0) ;;
#     }

#   dimension: current_paid_user_ebook_provisions {
#     type:number
#     description:"For particular user guid"
#     sql: coalesce(${TABLE}.current_paid_user_ebook_provisions,0) ;;
#     }

#   dimension: current_user_courseware_provisions {
#     type:number
#     description:"For particular user guid"
#     sql: coalesce(${TABLE}.current_user_courseware_provisions,0) ;;
#     }

#   dimension: current_user_paid_courseware_provisions {
#     type:number
#     description:"For particular user guid"
#     sql: coalesce(${TABLE}.current_user_paid_courseware_provisions,0) ;;
#     }



#   set: detail {
#     fields: [
#       user_sso_guid,
#       date_added_time,
#       pp_product_type,
#       user_type
#     ]
#   }
# }
