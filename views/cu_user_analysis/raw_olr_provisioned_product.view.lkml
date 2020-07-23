include: "/views/cu_user_analysis/live_subscription_status.view"
include: "/views/cu_user_analysis/merged_cu_user_info.view"
include: "/views/uploads/uploads.cu_sidebar_cohort.view"

explore: raw_olr_provisioned_product {
  label: "CU Provisioned Product"

  join: live_subscription_status {
    relationship: one_to_one
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${live_subscription_status.user_sso_guid} ;;
  }

  join: merged_cu_user_info {
    relationship: one_to_one
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${merged_cu_user_info.user_sso_guid} ;;
  }

  join: uploads_cu_sidebar_cohort {
    view_label: "CU sidebar cohort"
    sql_on: ${raw_olr_provisioned_product.merged_guid} = ${uploads_cu_sidebar_cohort.merged} ;;
    relationship: many_to_one
  }
  }

view: raw_olr_provisioned_product {
  view_label: "Provisioned Product"
#   sql_table_name: UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT ;;
derived_table: {

# --        SELECT prod.*,iac.PP_Name,iac.PP_LDAP_Group_name,iac.pp_product_type
#  --         FROM  olr.prod.provisioned_product Prod
# --              JOIN prod.unlimited.RAW_OLR_EXTENDED_IAC Iac
# --                ON iac.pp_pid = prod.product_id
# --                  AND prod.user_type like 'student'
# --                --  AND prod."source" like 'unlimited'
# --                  and prod.user_sso_guid not in (select user_sso_guid from prod.unlimited.EXCLUDED_USERS);;

  sql:
WITH pp AS (
             SELECT prod.*, COALESCE(su.linked_guid, prod.user_sso_guid) AS merged_guid
             FROM olr.prod.provisioned_product_v4 prod
                  INNER JOIN prod.datavault.hub_user hu ON prod.user_sso_guid = hu.uid
                  INNER JOIN prod.datavault.sat_user_v2 su ON hu.hub_user_key = su.hub_user_key AND su._latest
                  LEFT JOIN prod.datavault.sat_user_internal sui
                            ON hu.hub_user_key = sui.hub_user_key AND sui.internal AND sui.active
             WHERE prod.user_type LIKE 'student'
               AND sui.hub_user_key IS NULL
           )
   , types AS (
                SELECT iac.pp_pid
                     , iac.pp_product_type
                     , iac.pp_name
                     , array_agg(DISTINCT iac.cp_product_type) AS cppt
                FROM prod.unlimited.raw_olr_extended_iac AS iac
                GROUP BY iac.pp_pid, iac.pp_product_type, pp_name
              )
SELECT pp.*
     , iac.pp_product_type
     , pp_name
     , CASE
         WHEN iac.pp_product_type NOT LIKE 'SMART' THEN iac.pp_product_type
         WHEN ARRAY_CONTAINS('MTC'::VARIANT, cppt) THEN 'MTC'
         WHEN ARRAY_CONTAINS('CSFI'::VARIANT, cppt) THEN 'CSFI'
         WHEN ARRAY_CONTAINS('4LT'::VARIANT, cppt) THEN '4LT'
         WHEN ARRAY_CONTAINS('APLIA'::VARIANT, cppt) THEN 'APLIA'
         WHEN ARRAY_CONTAINS('SAM'::VARIANT, cppt) THEN 'SAM'
         WHEN ARRAY_CONTAINS('CNOWV8'::VARIANT, cppt) THEN 'CNOWV8'
         WHEN ARRAY_CONTAINS('NATGEO'::VARIANT, cppt) THEN 'NATGEO'
         WHEN ARRAY_CONTAINS('MT4'::VARIANT, cppt) THEN 'MT4'
         WHEN ARRAY_CONTAINS('4LTV1'::VARIANT, cppt) THEN '4LTV1'
         WHEN ARRAY_CONTAINS('DEV-MATH'::VARIANT, cppt) THEN 'DEV-MATH'
         WHEN ARRAY_CONTAINS('OWL'::VARIANT, cppt) OR ARRAY_CONTAINS('OWLV8'::VARIANT, cppt) THEN 'OWL'
         WHEN ARRAY_CONTAINS('MTS'::VARIANT, cppt) THEN 'MTS'
         WHEN ARRAY_CONTAINS('WA'::VARIANT, cppt) THEN 'WA'
         WHEN ARRAY_CONTAINS('WA3P'::VARIANT, cppt) THEN 'WA3P'
         ELSE 'other'
       END AS product_type_platform
FROM pp
     LEFT JOIN types iac
               ON iac.pp_pid = pp.product_id
    ;;
}

  dimension: _hash {
     type: string
     sql: ${TABLE}."_HASH" ;;
    hidden: yes
   }

  dimension: pp_name {
    label: "Product Name"
  }
  dimension: merged_guid {}
#
#   dimension: PP_LDAP_Group_name {
#
#     label: "Group Name"
#   }

  dimension: pp_product_type {
    description: "Can be filtered on to differentiate between courseware and ebook usage"
    label: "Product Type"
  }

  dimension: product_type_platform {
    description: "Platform names derived from 'SMART' product type"
#     sql: ${product_type_platform} ;;
  }

dimension_group: _ldts {
     type: time
     timeframes: [
       raw,
       time,
       date,
       week,
       month,
       quarter,
       year
     ]
     sql: ${TABLE}."_LDTS" ;;
    hidden: yes
   }

   dimension: _rsrc {
     type: string
     sql: ${TABLE}."_RSRC" ;;
    hidden: yes
   }

   dimension: code_type {

     type: string
     sql: ${TABLE}."CODE_TYPE" ;;
   }
   dimension: context_id {
    description: "Course registration key"
     type: string
     sql: ${TABLE}."CONTEXT_ID" ;;
   }

   dimension: core_text_isbn {
     type: string
     sql: ${TABLE}."CORE_TEXT_ISBN" ;;
   }

  dimension_group: date_added {
    description: "Date this product was provisioned i.e. added to the dashboard"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]

  }

  dimension_group: expiration {
    description: "Date this product will expire"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."EXPIRATION_DATE" ;;
  }

  dimension: iac_isbn {
    type: string
    sql: ${TABLE}."IAC_ISBN" ;;
  }

  dimension: institution_id {
    type: string
    sql: ${TABLE}."INSTITUTION_ID" ;;
  }

   dimension_group: local {
    description: "Local time this product was provisioned"
     type: time
     timeframes: [
       raw,
       time,
       date,
       week,
       month,
       quarter,
       year
     ]
     sql: ${TABLE}."LOCAL_TIME" ;;
   }

   dimension: message_format_version {
     type: number
     sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
   }

   dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."source" ;;
  }

  dimension: source_id {
    description: "The products contract ID"
    type: string
    sql: ${TABLE}."SOURCE_ID" ;;
  }

  dimension: status {
    description: "The users CU status (trial, full, etc.) when the product was provisioned"
    sql:
      case
        when (source_id like 'TRIAL') then 'TRIAL_ACCESS'
        when (is_double(TRY_TO_DOUBLE(source_id))) then 'FULL_ACCESS'
      else 'EMPTY' end ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  measure: product_count{
    label: "# Products Provisioned"
    description: "Count of unique product ids"
    type: count_distinct
    drill_fields: [detail*]
    sql:  ${TABLE}.product_id;;
  }

  dimension: product_provisioned {
    label: "Product provisioned"
    type: "yesno"
    sql:  case when current_date() between ${TABLE}.date_added and ${TABLE}.expiration_date then 1 else 0 end;;
  }

  dimension: ebook_provisioned {
    label: "eBook provisioned"
    type: "yesno"
    sql:  case when ${TABLE}.context_id is null and current_date() between ${TABLE}.date_added and ${TABLE}.expiration_date then 1 else 0 end;;
  }


  measure: current_product_count {
    label: "# Current Products Provisioned"
    description: "Count of unique product ids where date added is in the past and expiration date is in the future"
    type: sum
#     drill_fields: [detail*]
    sql:  ${product_provisioned};;
  }

  measure: current_ebook_product_count {
    label: "# Current eBooks Provisioned"
    description: "Count of unique product ids with no context id where date added is in the past and expiration date is in the future"
    type: sum
#     drill_fields: [detail*]
    sql:  ${ebook_provisioned};;
  }

  measure: user_count{
    description: "Count of unique user guids"
    type: count_distinct
    sql:  ${TABLE}.user_sso_guid;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
  }

  measure: count {
    type: count
    hidden: yes
    drill_fields: []
  }

  set: detail {
    fields: [
      user_sso_guid,
      local_time,
      iac_isbn,
      pp_product_type,
      "source",
      user_type
    ]
  }
}
