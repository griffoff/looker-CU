explore: guid_date_ebook {}

view: guid_date_ebook {
  derived_table: {
    sql:
    WITH ebook_users AS (
    (SELECT DISTINCT s.user_sso_guid, s.registration_date as ebook_start, DATEADD(DAY,s.subscription_length,s.registration_date) AS ebook_end, s.user_type
    FROM olr.prod.product_v4 p
    INNER JOIN olr.prod.serial_number_v4 s ON p.product_id = s.product_id
    WHERE product_type IN ('MTR','SMEB') AND s.user_sso_guid IS NOT NULL AND s.user_type = 'student')
    UNION
    (SELECT DISTINCT pp.user_sso_guid, pp.date_added AS ebook_start, pp.expiration_date AS ebook_end, pp.user_type
    FROM olr.prod.product_v4 p
    INNER JOIN olr.prod.provisioned_product pp ON p.product_id = pp.product_id
    WHERE p.product_type in ('MTR','SMEB') and pp.user_sso_guid IS NOT NULL AND pp.user_type= 'student')
    )
SELECT dim_date.datevalue as date, user_sso_guid, 'eBook' AS content_type, user_type
FROM ${dim_date.SQL_TABLE_NAME} dim_date
  LEFT JOIN ebook_users ON dim_date.datevalue BETWEEN ebook_start AND ebook_end
WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
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

  dimension: user_type {
    type: string
    sql: ${TABLE}.user_type ;;
  }

}
