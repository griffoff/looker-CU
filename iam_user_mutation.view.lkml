view: iam_user_mutation {
  derived_table: {
    sql: WITH raw AS (
          SELECT
            linked_guid as primary_guid
            ,user_sso_guid as partner_guid
            ,LEAD(event_time) OVER (PARTITION BY user_sso_guid ORDER BY event_time ASC) IS NULL AS latest
            ,*
          FROM IAM.PROD.USER_MUTATION
        )
          SELECT
          *
          FROM raw
          WHERE latest
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_guid {
    type: string
    sql: ${TABLE}."PRIMARY_GUID" ;;
  }

  dimension: partner_guid {
    type: string
    sql: ${TABLE}."PARTNER_GUID" ;;
  }

  dimension: latest {
    type: string
    sql: ${TABLE}."LATEST" ;;
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

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: uid {
    type: string
    sql: ${TABLE}."UID" ;;
  }

  dimension: cengage_crowd_id {
    type: string
    sql: ${TABLE}."CENGAGE_CROWD_ID" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}."POSTAL_CODE" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: instructor {
    type: string
    sql: ${TABLE}."INSTRUCTOR" ;;
  }

  dimension: birth_year {
    type: string
    sql: ${TABLE}."BIRTH_YEAR" ;;
  }

  dimension: marketing_opt_out {
    type: string
    sql: ${TABLE}."MARKETING_OPT_OUT" ;;
  }

  dimension_group: marketing_opt_out_last_update {
    type: time
    sql: ${TABLE}."MARKETING_OPT_OUT_LAST_UPDATE" ;;
  }

  dimension: k12_user {
    type: string
    sql: ${TABLE}."K12_USER" ;;
  }

  dimension: tl_institution_id {
    type: string
    sql: ${TABLE}."TL_INSTITUTION_ID" ;;
  }

  dimension: tl_institution_name {
    type: string
    sql: ${TABLE}."TL_INSTITUTION_NAME" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: linked_guid {
    type: string
    sql: ${TABLE}."LINKED_GUID" ;;
  }

  dimension: modification {
    type: string
    sql: ${TABLE}."MODIFICATION" ;;
  }

  set: detail {
    fields: [
      primary_guid,
      partner_guid,
      latest,
      _ldts_time,
      _rsrc,
      message_format_version,
      message_type,
      event_time_time,
      platform,
      platform_environment,
      user_environment,
      user_sso_guid,
      uid,
      cengage_crowd_id,
      created_by,
      first_name,
      last_name,
      country,
      postal_code,
      email,
      instructor,
      birth_year,
      marketing_opt_out,
      marketing_opt_out_last_update_time,
      k12_user,
      tl_institution_id,
      tl_institution_name,
      note,
      account_type,
      linked_guid,
      modification
    ]
  }
}
