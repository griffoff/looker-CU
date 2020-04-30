explore: guid_date_ebook_serial {}

view: guid_date_ebook_serial {
  derived_table: {
    sql:
    WITH ebook_users AS (
    SELECT DISTINCT pp.user_sso_guid, pp.date_added AS ebook_start, pp.expiration_date AS ebook_end
    FROM olr.prod.product_v4 p
    INNER JOIN olr.prod.provisioned_product pp ON p.product_id = pp.product_id
    WHERE p.product_type in ('MTR','SMEB')
      AND pp.user_sso_guid IS NOT NULL
      AND pp.user_type= 'student'
    )
SELECT DISTINCT dim_date.datevalue as date, user_sso_guid, 'eBook' AS content_type
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

}
