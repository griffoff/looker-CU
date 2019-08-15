view: daily_messaging_info {
  sql_table_name: STRATEGY.LATE_CU_COURSE_ACTIVATORS.DAILY_MESSAGING_INFO ;;

  dimension: actv_days_from_sub_end {
    type: number
    sql: ${TABLE}."ACTV_DAYS_FROM_SUB_END" ;;
  }

  dimension_group: actv_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ACTV_DT" ;;
  }

  dimension: actv_isbn {
    type: string
    sql: ${TABLE}."ACTV_ISBN" ;;
  }

  dimension: always_cui_redemp_flg {
    type: number
    sql: ${TABLE}."ALWAYS_CUI_REDEMP_FLG" ;;
  }

  dimension: context_id {
    type: string
    sql: ${TABLE}."CONTEXT_ID" ;;
  }

  dimension_group: course_begin {
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
    sql: ${TABLE}."COURSE_BEGIN_DATE" ;;
  }

  dimension: course_beyond_subscrip_flg {
    type: number
    sql: ${TABLE}."COURSE_BEYOND_SUBSCRIP_FLG" ;;
  }

  dimension_group: course_end {
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
    sql: ${TABLE}."COURSE_END_DATE" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }

  dimension: cui_flg {
    type: number
    sql: ${TABLE}."CUI_FLG" ;;
  }

  dimension: division_cd {
    type: string
    sql: ${TABLE}."DIVISION_CD" ;;
  }

  dimension: division_de {
    type: string
    sql: ${TABLE}."DIVISION_DE" ;;
  }

  dimension: email_type {
    type: string
    sql: ${TABLE}."EMAIL_TYPE" ;;
  }

  dimension: guid_isbn_multi_count {
    type: number
    sql: ${TABLE}."GUID_ISBN_MULTI_COUNT" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: ipm_type {
    type: string
    sql: ${TABLE}."IPM_TYPE" ;;
  }

  dimension: late_actv_flg {
    type: number
    sql: ${TABLE}."LATE_ACTV_FLG" ;;
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: multi_flg {
    type: number
    sql: ${TABLE}."MULTI_FLG" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: prod_family_cd {
    type: string
    sql: ${TABLE}."PROD_FAMILY_CD" ;;
  }

  dimension: prod_family_de {
    type: string
    sql: ${TABLE}."PROD_FAMILY_DE" ;;
  }

  dimension: pub_series_cd {
    type: string
    sql: ${TABLE}."PUB_SERIES_CD" ;;
  }

  dimension: pub_series_de {
    type: string
    sql: ${TABLE}."PUB_SERIES_DE" ;;
  }

  dimension_group: redemp_local {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REDEMP_LOCAL_DATE" ;;
  }

  dimension: sometimes_cui_redemp_flg {
    type: number
    sql: ${TABLE}."SOMETIMES_CUI_REDEMP_FLG" ;;
  }

  dimension_group: subscription_end_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SUBSCRIPTION_END_DT" ;;
  }

  measure: count {
    type: count
    drill_fields: [course_name]
  }
}
