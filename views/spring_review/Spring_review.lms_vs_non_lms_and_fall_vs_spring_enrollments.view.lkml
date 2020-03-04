explore: lms_vs_non_lms_and_fall_vs_spring_enrollments {}

view: lms_vs_non_lms_and_fall_vs_spring_enrollments {
  derived_table: {
    sql: SELECT * FROM zpg.lms_vs_non_lms_and_fall_vs_spring_enrollments
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure:  user_count {
    type: count_distinct
    sql: ${user_sso_guid_merged} ;;
  }

  measure: course_key_count {
    type: count_distinct
    sql: ${course_key} ;;
  }

  measure: at_least_one_course_enrolled {
    type: yesno
    sql: ${course_key_count} > 0 ;;
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  }

  dimension: original_guid {
    type: string
    sql: ${TABLE}."ORIGINAL_GUID" ;;
  }

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
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

  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
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

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: access_role {
    type: string
    sql: ${TABLE}."ACCESS_ROLE" ;;
  }

  dimension: lms_vs_non_lms_user {
    type: string
    sql: ${TABLE}."LMS_VS_NON_LMS_USER" ;;
  }

  dimension: fall_vs_spring_user {
    type: string
    sql: ${TABLE}."FALL_VS_SPRING_USER" ;;
  }

  set: detail {
    fields: [
      user_sso_guid_merged,
      original_guid,
      _hash,
      _ldts_time,
      _rsrc,
      message_format_version,
      message_type,
      local_time_time,
      user_sso_guid,
      user_environment,
      product_platform,
      platform_environment,
      course_key,
      access_role,
      lms_vs_non_lms_user,
      fall_vs_spring_user
    ]
  }
}
