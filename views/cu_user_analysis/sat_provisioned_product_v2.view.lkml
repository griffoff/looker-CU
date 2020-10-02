view: sat_provisioned_product_v2 {
  derived_table: {
    sql:
    select *
    from prod.datavault.sat_provisioned_product_v2
    where _latest
    ;;
  }



  dimension_group: _effective_from {
    hidden: yes
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
    sql: CAST(${TABLE}."_EFFECTIVE_FROM" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: _effective_to {
    hidden: yes
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
    sql: CAST(${TABLE}."_EFFECTIVE_TO" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _latest {
    hidden: yes
    type: yesno
    sql: ${TABLE}."_LATEST" ;;
  }

  dimension_group: _ldts {
    hidden: yes
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
    hidden: yes
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: code_type {
    hidden: yes
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
    sql: CAST(${TABLE}."DATE_ADDED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    hidden: yes
    type: yesno
    sql: ${TABLE}."DELETED" ;;
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
    sql: CAST(${TABLE}."EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hash_diff {
    hidden: yes
    type: string
    sql: ${TABLE}."HASH_DIFF" ;;
  }

  dimension: hub_provisioned_product_key {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}."HUB_PROVISIONED_PRODUCT_KEY" ;;
  }

  dimension: iac_isbn {
    type: string
    sql: ${TABLE}."IAC_ISBN" ;;
  }

  dimension: institution_id {
    type: string
    sql: ${TABLE}."INSTITUTION_ID" ;;
  }

  dimension: modified_by {
    hidden: yes
    type: string
    sql: ${TABLE}."MODIFIED_BY" ;;
  }

  dimension: order_number {
    hidden: yes
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension_group: payment {
    hidden: yes
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
    sql: CAST(${TABLE}."PAYMENT_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: payment_type {
    hidden: yes
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }

  dimension: product_id {
    hidden: yes
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: provisioning_type {
    hidden: yes
    type: string
    sql: ${TABLE}."PROVISIONING_TYPE" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension_group: rsrc_timestamp {
    hidden: yes
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
    sql: CAST(${TABLE}."RSRC_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: source {
    hidden: yes
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: source_id {
    hidden: yes
    type: string
    sql: ${TABLE}."SOURCE_ID" ;;
  }

  dimension: src_environment {
    hidden: yes
    type: string
    sql: ${TABLE}."SRC_ENVIRONMENT" ;;
  }

  dimension: src_platform {
    hidden: yes
    type: string
    sql: ${TABLE}."SRC_PLATFORM" ;;
  }

  dimension: user_environment {
    hidden: yes
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    hidden: yes
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: user_type {
    hidden: yes
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
