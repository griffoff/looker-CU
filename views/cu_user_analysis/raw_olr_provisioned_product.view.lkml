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

derived_table: {
  sql:
  with prod as (
    select
      p.message_format_version
      , p.message_type
      , p.user_sso_guid
      , p.user_environment
      , p.PRODUCT_PLATFORM
      , p.platform_environment
      , p.date_added::date as date_added
      , array_agg(p.context_id) as context_id_array
      , max(p.expiration_date::date) as expiration_date
      , p.iac_isbn
      , p.product_id
      , p.user_type
      , case when (s.subscription_plan_id <> 'Trial' or p.context_id is not null) then 1 else 0 end as paid_provision
    FROM olr.prod.provisioned_product_v4 p
    left join prod.DATAVAULT.HUB_SUBSCRIPTION h on p.source_id = h.SUBSCRIPTION_ID
    inner join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP s on h.HUB_SUBSCRIPTION_KEY = s.HUB_SUBSCRIPTION_KEY and s._LATEST

    where user_type ilike 'student'


    group by 1,2,3,4,5,6,7,10,11,12,13
    )

    , pp AS (
             SELECT distinct
            message_format_version
            , message_type
            , user_environment
            , PRODUCT_PLATFORM
            , platform_environment
            , date_added
            , expiration_date
            , iac_isbn
            , product_id
            , user_type
            , nullif(context_id_array,array_construct()) as context_id
            , COALESCE(su.linked_guid, prod.user_sso_guid) AS merged_guid

             FROM prod
                  INNER JOIN prod.datavault.hub_user hu ON prod.user_sso_guid = hu.uid
                  INNER JOIN prod.datavault.sat_user_v2 su ON hu.hub_user_key = su.hub_user_key AND su._latest
                  LEFT JOIN prod.datavault.sat_user_internal sui
                            ON hu.hub_user_key = sui.hub_user_key AND sui.internal AND sui.active
             WHERE sui.hub_user_key IS NULL
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

         , case when current_date() between date_added and expiration_date then 1 else 0 end as current_provision
         , case when context_id is null and (current_date() between date_added and expiration_date) then 1 else 0 end as current_ebook_provision

         --, sum(current_provision) over (partition by merged_guid) as current_user_provisions
         --, sum(case when paid_provision = 1 then current_provision end) over (partition by merged_guid) as current_paid_user_provisions

         --, sum(current_ebook_provision) over (partition by merged_guid) as current_user_ebook_provisions
         --, sum(current_ebook_provision) over (partition by merged_guid) as current_user_ebook_provisions


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

dimension: pk {
  primary_key: yes
  sql: concat(${TABLE}.merged_guid,${TABLE}.date_added,${TABLE}.product_id ;;
  hidden:  yes
}



  dimension: pp_name {
    label: "Product Name"
  }

  dimension: merged_guid {}

  dimension: user_sso_guid {
    sql: ${merged_guid} ;;
    hidden: yes
  }

  dimension: pp_product_type {
    description: "Can be filtered on to differentiate between courseware and ebook usage"
    label: "Product Type"
  }

  dimension: product_type_platform {
    description: "Platform names derived from 'SMART' product type"
  }

   dimension: context_id {
    description: "Course registration key"
     sql: ${TABLE}."CONTEXT_ID" ;;
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


  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }


  measure: count {
    label: "# Products Provisioned"
    description: "Count of unique product ids"
    type: count
    drill_fields: [detail*]
  }

  dimension: product_provisioned {
    label: "Product provisioned"
    description: "Product is currently provisioned (expiration date not passed)"
     type: number
    sql:  case when current_date() between ${TABLE}.date_added and ${TABLE}.expiration_date then 1 else 0 end;;
  }

  dimension: ebook_provisioned {
    label: "eBook provisioned"
    description: "Product has no context_id and is currently provisioned (expiration date not passed)"
     type: number
    sql:  case when (${TABLE}.context_id is null and (current_date() between ${TABLE}.date_added and ${TABLE}.expiration_date)) then 1 else 0 end;;
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

#   measure: count {
#     type: count
#     hidden: no
#     drill_fields: []
#   }

  set: detail {
    fields: [
      user_sso_guid,
      date_added_time,
      iac_isbn,
      pp_product_type,
      user_type
    ]
  }
}
