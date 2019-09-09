explore: guid_course_date_paid {}

view: guid_course_date_paid {
  derived_table: {
    sql: WITH
          tally AS
          (
              SELECT
                  SEQ8() AS i
              FROM TABLE(GENERATOR(ROWCOUNT=>10000))
          )
          ,paid_courses AS
          (
              SELECT
                  user_sso_guid
                  ,DATEADD(DAY, t.i, u.course_start_date::DATE) AS active_date
                  ,u.olr_course_key
                  ,HASH(user_sso_guid, active_date) AS pk
                  ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid, active_date ORDER BY CASE WHEN ACTIVATED THEN 0 ELSE 1 END, u.course_start_date DESC, u.course_end_date DESC) AS r
              FROM prod.cu_user_analysis.user_courses u
              INNER JOIN tally t ON i <= DATEDIFF(DAY, u.course_start_date::DATE, LEAST(u.course_end_date::DATE, CURRENT_DATE()))
          )
          ,
          SELECT * FROM paid_courses WHERE r = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: active_date {
    type: date
    sql: ${TABLE}."ACTIVE_DATE" ;;
  }

  dimension: olr_course_key {
    type: string
    sql: ${TABLE}."OLR_COURSE_KEY" ;;
  }

  dimension: pk {
    type: number
    sql: ${TABLE}."PK" ;;
  }

  dimension: r {
    type: number
    sql: ${TABLE}."R" ;;
  }

  set: detail {
    fields: [user_sso_guid, active_date, olr_course_key, pk, r]
  }
}
