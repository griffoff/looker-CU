explore: raw_enrollment_v4 {}

view: raw_enrollment_v4 {
  derived_table: {
    sql: SELECT * FROM OLR.PROD.RAW_ENROLLMENT_V4
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: context_id {
    type: string
    sql: ${TABLE}."CONTEXT_ID" ;;
  }

  dimension: access_role {
    type: string
    sql: ${TABLE}."ACCESS_ROLE" ;;
  }

  dimension: self_study_isbn13 {
    type: string
    sql: ${TABLE}."SELF_STUDY_ISBN13" ;;
  }

  dimension_group: enrollment_date {
    type: time
    sql: ${TABLE}."ENROLLMENT_DATE" ;;
  }

  dimension: paid_in_full {
    type: string
    sql: ${TABLE}."PAID_IN_FULL" ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: payment_code {
    type: string
    sql: ${TABLE}."PAYMENT_CODE" ;;
  }

  dimension_group: grace_end_date {
    type: time
    sql: ${TABLE}."GRACE_END_DATE" ;;
  }

  dimension: transferred {
    type: string
    sql: ${TABLE}."TRANSFERRED" ;;
  }

  dimension: opt_out_institution_purchase {
    type: string
    sql: ${TABLE}."OPT_OUT_INSTITUTION_PURCHASE" ;;
  }

  dimension: modified_by {
    type: string
    sql: ${TABLE}."MODIFIED_BY" ;;
  }

  dimension: access_code_swap {
    type: string
    sql: ${TABLE}."ACCESS_CODE_SWAP" ;;
  }

  dimension: access_code_isbn13 {
    type: string
    sql: ${TABLE}."ACCESS_CODE_ISBN13" ;;
  }

  dimension: access_code_price {
    type: number
    sql: ${TABLE}."ACCESS_CODE_PRICE" ;;
  }

  dimension: course_isbn_price {
    type: number
    sql: ${TABLE}."COURSE_ISBN_PRICE" ;;
  }

  dimension: billing_type {
    type: string
    sql: ${TABLE}."BILLING_TYPE" ;;
  }

  dimension: payment_isbn13 {
    type: string
    sql: ${TABLE}."PAYMENT_ISBN13" ;;
  }

  dimension: deleted {
    type: string
    sql: ${TABLE}."DELETED" ;;
  }

  set: detail {
    fields: [
      _ldts_time,
      _rsrc,
      message_format_version,
      message_type,
      event_time_time,
      user_sso_guid,
      user_environment,
      product_platform,
      platform_environment,
      context_id,
      access_role,
      self_study_isbn13,
      enrollment_date_time,
      paid_in_full,
      order_number,
      payment_code,
      grace_end_date_time,
      transferred,
      opt_out_institution_purchase,
      modified_by,
      access_code_swap,
      access_code_isbn13,
      access_code_price,
      course_isbn_price,
      billing_type,
      payment_isbn13,
      deleted
    ]
  }
}
