# include: "cohorts.base.view"

# view: cohorts_paid_access_non_cu {

#   extends: [cohorts_base_number]

#   derived_table: {


#     sql:WITH
#         enrollment_terms AS
#         (
#         SELECT
#               e.user_sso_guid
#               ,terms_chron_order_desc
#               ,governmentdefinedacademicterm
#               ,COUNT(DISTINCT olr_course_key) AS unique_courses
#           FROM prod.cu_user_analysis.user_courses e
#           LEFT JOIN ${date_latest_5_terms.SQL_TABLE_NAME} d
#               ON e.activation_date::DATE >= d.start_date AND e.activation_date::DATE <= d.end_date
#           WHERE cu_subscription_id IS NULL
#           GROUP BY 1, 2, 3
#           )
#           SELECT
#             user_sso_guid
#             ,SUM(CASE WHEN terms_chron_order_desc = 1 THEN unique_courses ELSE 0 END) AS "1"
#             ,SUM(CASE WHEN terms_chron_order_desc = 2 THEN unique_courses ELSE 0 END) AS "2"
#             ,SUM(CASE WHEN terms_chron_order_desc = 3 THEN unique_courses ELSE 0 END) AS "3"
#             ,SUM(CASE WHEN terms_chron_order_desc = 4 THEN unique_courses ELSE 0 END) AS "4"
#             ,SUM(CASE WHEN terms_chron_order_desc = 5 THEN unique_courses ELSE 0 END) AS "5"
#           FROM enrollment_terms
#           GROUP BY 1

#           ;;
#   }

#   dimension: user_sso_guid_merged {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#     hidden: yes
#   }

#   dimension: current { group_label: "# Paid Courses (Non-CU)" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: minus_1 { group_label: "# Paid Courses (Non-CU)" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: minus_2 { group_label: "# Paid Courses (Non-CU)" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: minus_3 { group_label: "# Paid Courses (Non-CU)" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: minus_4 { group_label: "# Paid Courses (Non-CU)" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

# }
