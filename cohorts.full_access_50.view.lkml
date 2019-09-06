explore: cohorts_full_access_50 {}

include: "cohorts.base.view"

view: cohorts_full_access_50 {
  extends: [cohorts_base_binary]

  derived_table: {
    sql: WITH user_term_full_access_sub AS
      (
      SELECT
        a.user_sso_guid
        ,terms_chron_order_desc
        ,SUM(CASE WHEN a.user_sso_guid IS NOT NULL THEN 1 ELSE 0 END) AS active_term_day
        ,MAX(DATEDIFF('d', t.start_date, t.end_date)) AS days_in_term
        ,days_in_term + 1 AS days_in_term_1
        ,MAX(active_date) AS last_term_date_active
        ,MIN(active_date) AS first_term_date_active
        ,active_term_day/days_in_term_1 AS percent_term_days_active
      FROM  ${date_latest_5_terms.SQL_TABLE_NAME} t
      LEFT JOIN ${active_subscription_states.SQL_TABLE_NAME} a
        ON a.active_date BETWEEN t.start_date AND t.end_date
      --WHERE  user_sso_guid = 'a9976257903fb4cb:c148e2a:15e533ee045:424'
      GROUP BY 1, 2
      HAVING percent_term_days_active > .3
      )
      SELECT user_sso_guid
        ,MAX(CASE WHEN terms_chron_order_desc = 1 THEN 1 END) AS "1"
        ,MAX(CASE WHEN terms_chron_order_desc = 2 THEN 1 END) AS "2"
        ,MAX(CASE WHEN terms_chron_order_desc = 3 THEN 1 END) AS "3"
        ,MAX(CASE WHEN terms_chron_order_desc = 4 THEN 1 END) AS "4"
        ,MAX(CASE WHEN terms_chron_order_desc = 5 THEN 1 END) AS "5"
      FROM user_term_full_access_sub s
      GROUP BY 1
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

  dimension: current { group_label: "Full Access 30% active days" description: "Student had a full active subscription for more than of 30% of the semester days (Goverment defined academic calendar)" }

  dimension: minus_1 { group_label: "Full Access 30% active days" description: "Student had a full active subscription for more than of 30% of the semester days (Goverment defined academic calendar)" }

  dimension: minus_2 { group_label: "Full Access 30% active days" description: "Student had a full active subscription for more than of 30% of the semester days (Goverment defined academic calendar)" }

  dimension: minus_3 { group_label: "Full Access 30% active days" description: "Student had a full active subscription for more than of 30% of the semester days (Goverment defined academic calendar)" }

  dimension: minus_4 { group_label: "Full Access 30% active days" description: "Student had a full active subscription for more than of 30% of the semester days (Goverment defined academic calendar)" }


}
