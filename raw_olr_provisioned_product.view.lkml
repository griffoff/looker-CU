view: raw_olr_provisioned_product {
#   sql_table_name: UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT ;;
derived_table: {
    sql:
      Select prod.*,iac.PP_Name,iac.PP_LDAP_Group_name,iac.pp_product_type  from  UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT Prod
        join prod.unlimited.RAW_OLR_EXTENDED_IAC Iac
        on iac.pp_pid = prod.product_id;;
}



  dimension: _hash {
     type: string
     sql: ${TABLE}."_HASH" ;;
   }

  dimension: pp_name {
    label: "Product Name"
  }

  dimension: PP_LDAP_Group_name {
    label: "Group Name"
  }

  dimension: pp_product_type {
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
   }

   dimension: _rsrc {
     type: string
     sql: ${TABLE}."_RSRC" ;;
   }

   dimension: code_type {
     type: string
     sql: ${TABLE}."CODE_TYPE" ;;
   }
   dimension: context_id {
     type: string
     sql: ${TABLE}."CONTEXT_ID" ;;
   }

   dimension: core_text_isbn {
     type: string
     sql: ${TABLE}."CORE_TEXT_ISBN" ;;
   }

  dimension_group: date_added {
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
    type: string
    sql: ${TABLE}."SOURCE_ID" ;;
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
    type: count_distinct
    sql:  ${TABLE}.product_id;;
  }

  measure: user_count{
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
}
