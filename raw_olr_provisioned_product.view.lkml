view: raw_olr_provisioned_product {
#   sql_table_name: UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT ;;
derived_table: {
        sql:
        SELECT prod.*,iac.PP_Name,iac.PP_LDAP_Group_name,iac.pp_product_type
          FROM  prod.UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT Prod
              JOIN prod.unlimited.RAW_OLR_EXTENDED_IAC Iac
                ON iac.pp_pid = prod.product_id
                  AND prod.user_type like 'student'
                --  AND prod."source" like 'unlimited'
                  and prod.user_sso_guid not in (select user_sso_guid from prod.unlimited.EXCLUDED_USERS);;
}

  dimension: _hash {
     type: string
     sql: ${TABLE}."_HASH" ;;
    hidden: yes
   }

  dimension: pp_name {
    label: "Product Name"
  }

  dimension: PP_LDAP_Group_name {

    label: "Group Name"
  }

  dimension: pp_product_type {
    description: "Can be filtered on to differentiate between courseware and ebook usage"
    label: "Product Type"
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
