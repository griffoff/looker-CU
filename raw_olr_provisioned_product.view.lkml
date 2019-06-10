include: "live_subscription_status.view"
include: "merged_cu_user_info.view"
include: "uploads.cu_sidebar_cohort.view"

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
#  --         FROM  prod.UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT Prod
# --              JOIN prod.unlimited.RAW_OLR_EXTENDED_IAC Iac
# --                ON iac.pp_pid = prod.product_id
# --                  AND prod.user_type like 'student'
# --                --  AND prod."source" like 'unlimited'
# --                  and prod.user_sso_guid not in (select user_sso_guid from prod.unlimited.EXCLUDED_USERS);;

  sql:
 With pp as (
   SELECT prod.*
          FROM  prod.UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT Prod
              wHERE prod.user_type like 'student'
                  and prod.user_sso_guid not in (select user_sso_guid from prod.unlimited.EXCLUDED_USERS)
     ),prim_map AS(
        SELECT *,LEAD(event_time) OVER (PARTITION BY primary_guid ORDER BY event_time ASC) IS NULL AS latest from prod.unlimited.VW_PARTNER_TO_PRIMARY_USER_GUID
      )
      ,types as (
        SELECT iac.pp_pid
            , iac.pp_product_type
            , array_agg(distinct iac.cp_product_type) as cppt
        from  prod.unlimited.RAW_OLR_EXTENDED_IAC as iac
        group by iac.pp_pid, iac.pp_product_type
      )
      ,guid_mapping AS(
        Select * from prim_map where latest
      )
     select pp.*,COALESCE(m.primary_guid, pp.user_sso_guid) AS merged_guid,iac.pp_product_type,
      case when iac.pp_product_type not like 'SMART' then iac.pp_product_type else
      case when ARRAY_CONTAINS('MTC'::variant, cppt) then 'MTC' else
      case when ARRAY_CONTAINS('CSFI'::variant, cppt) then 'CSFI' else
      case when ARRAY_CONTAINS('4LT'::variant, cppt) then '4LT' else
      case when ARRAY_CONTAINS('APLIA'::variant, cppt) then 'APLIA' else
      case when ARRAY_CONTAINS('SAM'::variant, cppt) then 'SAM' else
      case when ARRAY_CONTAINS('CNOWV8'::variant, cppt) then 'CNOWV8' else
      case when ARRAY_CONTAINS('NATGEO'::variant, cppt) then 'NATGEO' else
      case when ARRAY_CONTAINS('MT4'::variant, cppt) then 'MT4' else
      case when ARRAY_CONTAINS('4LTV1'::variant, cppt) then '4LTV1' else
      case when ARRAY_CONTAINS('DEV-MATH'::variant, cppt) then 'DEV-MATH' else
      case when ARRAY_CONTAINS('OWL'::variant, cppt) or ARRAY_CONTAINS('OWLV8'::variant, cppt) then 'OWL' else
      case when ARRAY_CONTAINS('MTS'::variant, cppt) then 'MTS' else
      case when ARRAY_CONTAINS('WA'::variant, cppt) then 'WA' else
      case when ARRAY_CONTAINS('WA3P'::variant, cppt) then 'WA3P' else 'other' end
      end
      end
      end
      end
      end
      end
      end
      end
      end
      end
      end
      end
      end
      end as product_type_platform
    from pp
     LEFT JOIN types iac
     ON iac.pp_pid = pp.product_id AND pp.user_type like 'student'
     LEFT JOIN guid_mapping m on pp.user_sso_guid = m.partner_guid ;;
}

  dimension: _hash {
     type: string
     sql: ${TABLE}."_HASH" ;;
    hidden: yes
   }

#   dimension: pp_name {
#     label: "Product Name"
#   }
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
    sql: ${TABLE}."DATE_ADDED" ;;
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
