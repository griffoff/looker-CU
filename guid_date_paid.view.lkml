explore: guid_date_paid {}

view: guid_date_paid {
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
                  ,CASE WHEN activated THEN 1 ELSE 0 END AS paid_status
                  ,HASH(user_sso_guid, active_date) AS pk
                  ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid, active_date ORDER BY CASE WHEN ACTIVATED THEN 0 ELSE 1 END, u.course_start_date DESC, u.course_end_date DESC) AS r
              FROM prod.cu_user_analysis.user_courses u
              INNER JOIN tally t ON i <= DATEDIFF(DAY, u.course_start_date::DATE, LEAST(u.course_end_date::DATE, CURRENT_DATE()))
          )
          ,active_subs AS (
            SELECT
              user_sso_guid
              ,DATEADD(DAY, t.i, effective_from::DATE) AS active_date
              ,CASE WHEN subscription_state = 'full_access' THEN 1 ELSE 0 END AS paid_status
              ,HASH(user_sso_guid, active_date) AS pk
              ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid, active_date ORDER BY CASE subscription_state WHEN 'full_access' THEN 0 ELSE 1 END, effective_from DESC, effective_to DESC) AS r
            FROM prod.LOOKER_SCRATCH.LR$JJZ2JG1I8WYC7PG3U8HHD_raw_subscription_event e
            INNER JOIN tally t ON i <= DATEDIFF(DAY, effective_from::DATE, LEAST(effective_to::DATE, CURRENT_DATE()))
          )
          ,combined AS (
          SELECT * FROM paid_courses WHERE r = 1
          UNION
          SELECT * FROM active_subs WHERE r = 1
          )
          SELECT user_sso_guid, active_date, MAX(paid_status) FROM combined GROUP BY 1, 2
       ;;
  }

  measure: count {
    type: count
    #drill_fields: [detail*]
  }

  measure: distinct_users {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension_group: active_date {
    type: time
    timeframes: [year, month, date, raw]
    sql: ${TABLE}."ACTIVE_DATE" ;;
  }

  dimension: maxpaid_status {
    type: number
    sql: ${TABLE}."MAX(PAID_STATUS)" ;;
  }

#   set: detail {
#     fields: [user_sso_guid, active_date, maxpaid_status]
#   }
}
