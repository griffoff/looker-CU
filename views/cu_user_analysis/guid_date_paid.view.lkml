explore: guid_date_paid {}

view: guid_date_paid {

  derived_table: {
    sql:
    WITH paid_courseware_users AS (
      SELECT DISTINCT c.date, c.user_sso_guid
      FROM ${guid_date_course.SQL_TABLE_NAME} c
      WHERE c.paid_flag = TRUE
      )
      ,paid_ebook_users AS (
      SELECT DISTINCT e.date, e.user_sso_guid
      FROM ${guid_date_ebook.SQL_TABLE_NAME} e
      LEFT JOIN paid_courseware_users c ON e.date = c.date AND e.user_sso_guid = c.user_sso_guid
      WHERE e.paid_flag = TRUE
      AND c.user_sso_guid IS NULL
      )
      ,paid_cu_only_users AS (
        SELECT DISTINCT s.date, s.user_sso_guid, s.content_type
        FROM ${guid_date_subscription.SQL_TABLE_NAME} s
        LEFT JOIN paid_courseware_users c ON s.date = c.date AND s.user_sso_guid = c.user_sso_guid
        LEFT JOIN paid_ebook_users e ON e.date = s.date AND e.user_sso_guid = s.user_sso_guid
        WHERE c.user_sso_guid IS NULL AND e.user_sso_guid IS NULL
      )
    SELECT date, user_sso_guid, TRUE AS paid_flag, 'Courseware' AS content_type FROM paid_courseware_users
    UNION ALL
    SELECT date, user_sso_guid, TRUE AS paid_flag, 'eBook' AS content_type FROM paid_ebook_users
    UNION ALL
    SELECT date, user_sso_guid
    , CASE WHEN content_type = 'Full Access CU Subscription' THEN TRUE ELSE FALSE END AS paid_flag
    , content_type
    FROM paid_cu_only_users
    ;;
    persist_for: "24 hours"
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}.USER_SSO_GUID ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: content_type {
    type: string
    sql: ${TABLE}.content_type ;;
  }

  dimension: paid_flag {
    type: yesno
    sql: ${TABLE}.paid_flag ;;
  }

}
