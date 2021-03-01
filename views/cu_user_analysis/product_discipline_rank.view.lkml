include: "./user_products.view"
include: "./course_info.view"
include: "./product_info.view"

explore: product_discipline_rank {
  hidden: yes
}

view: product_discipline_rank {
derived_table: {
  sql:
  SELECT
    product_info.discipline_de as discipline
    ,COUNT(DISTINCT course_info.course_identifier) AS coursesections
      ,COUNT(DISTINCT user_products.user_sso_guid) AS users
      ,COUNT(DISTINCT CASE WHEN UPPER(product_info.product_platform) = 'MINDTAP' THEN user_sso_guid END) AS mt_users
      ,COUNT(DISTINCT CASE WHEN UPPER(product_info.product_platform) = 'WEBASSIGN' THEN user_sso_guid END) AS wa_users
      ,COUNT(DISTINCT CASE WHEN UPPER(COALESCE(product_info.product_platform, '')) NOT IN ('MINDTAP', 'WEBASSIGN') THEN user_sso_guid END) AS other_users
      ,RANK() OVER (ORDER BY mt_users DESC) as rank_mt_users
      ,RANK() OVER (ORDER BY wa_users DESC) as rank_wa_users
      ,RANK() OVER (ORDER BY users DESC) as rank_total_users
  FROM ${course_info.SQL_TABLE_NAME} AS course_info
  LEFT JOIN ${product_info.SQL_TABLE_NAME} AS product_info ON course_info.iac_isbn = product_info.ISBN13
  LEFT JOIN ${user_products.SQL_TABLE_NAME}  AS user_products ON course_info.course_identifier = user_products.course_key
  WHERE course_info.begin_date >= DATEADD(month, -6, CURRENT_DATE())
  GROUP BY 1
  ORDER BY users DESC
  ;;

  persist_for: "24 hours"
  }

  dimension: discipline {
    hidden: yes
    primary_key: yes
  }

  dimension: rank_mt_users {
    type: number
    group_label: "Discipline Rank (Last 6 months)"
    label: "Rank by number of MindTap users"
  }

  dimension: rank_wa_users {
    type: number
    group_label: "Discipline Rank (Last 6 months)"
    label: "Rank by number of WebAssign users"
  }

  dimension: rank_total_users {
    type: number
    group_label: "Discipline Rank (Last 6 months)"
    label: "Rank by number of total users (All platforms)"
  }

}
