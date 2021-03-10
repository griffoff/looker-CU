# include: "cohorts.base.view"



# view: cohorts_term_courses {

#   extends: [cohorts_base_number]

#   derived_table: {


#     sql:WITH
#           enrollment_terms AS
#           (
#           SELECT
#                 e.user_sso_guid
#                 ,terms_chron_order_desc
#                 ,governmentdefinedacademicterm
#                 ,COUNT(DISTINCT olr_course_key) AS unique_courses
#             FROM prod.cu_user_analysis.user_courses e
#             LEFT JOIN ${date_latest_5_terms.SQL_TABLE_NAME} d
#                 ON e.course_start_date::DATE >= d.start_date AND e.course_start_date <= d.end_date
#               --ON DATEADD('d', -30, s.subscription_start::DATE) <= d.start_date
#               --AND s.subscription_end::DATE >= DATEADD('d', -30, d.end_date)
#             --AND user_sso_guid_merged IN ('033b20b27ca503d5:20c4c7b6:15f6f339f0c:-5f8b', '033b20b27ca503d5:20c4c7b6:15e2fad1470:5223', 'efa047457a23f24d:-260a5249:1655840aed1:-1568')
#             GROUP BY 1, 2, 3
#             )
#             SELECT
#               user_sso_guid
#               ,SUM(CASE WHEN terms_chron_order_desc = 1 THEN unique_courses ELSE 0 END) AS "1"
#               ,SUM(CASE WHEN terms_chron_order_desc = 2 THEN unique_courses ELSE 0 END) AS "2"
#               ,SUM(CASE WHEN terms_chron_order_desc = 3 THEN unique_courses ELSE 0 END) AS "3"
#               ,SUM(CASE WHEN terms_chron_order_desc = 4 THEN unique_courses ELSE 0 END) AS "4"
#               ,SUM(CASE WHEN terms_chron_order_desc = 5 THEN unique_courses ELSE 0 END) AS "5"
#             FROM enrollment_terms
#             GROUP BY 1

#             ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#     hidden: yes
#   }

#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#     hidden: yes
#   }

#   dimension: governmentdefinedacademicterm {
#     type: string
#     sql: ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ;;
#   }

#   dimension: current { group_label: "# Courses in Terms" type:number description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec" }

#   dimension: minus_1 { group_label: "# Courses in Terms" type:number description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec" }

#   dimension: minus_2 { group_label: "# Courses in Terms" type:number description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec" }

#   dimension: minus_3 { group_label: "# Courses in Terms" type:number description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec" }

#   dimension: minus_4 { group_label: "# Courses in Terms" type:number description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec" }

# }

# view: cohorts_term_courses_old {
#   extends: [cohorts_base_number]
#   derived_table: {
#     sql:WITH
#     term_dates AS
#     (
#       SELECT
#         governmentdefinedacademicterm
#         ,1 AS groupbyhack
#         ,MIN(datevalue) AS start_date
#         ,MAX(datevalue) AS end_date
#       FROM prod.dw_ga.dim_date
#       WHERE governmentdefinedacademicterm IS NOT NULL
#       GROUP BY 1
#       ORDER BY 4 DESC
#     )
#     ,term_dates_five_most_recent AS
#     (
#         SELECT
#           RANK() OVER (ORDER BY start_date DESC) AS terms_chron_order_desc
#           ,*
#         FROM term_dates
#         WHERE start_date < CURRENT_DATE()
#         ORDER BY terms_chron_order_desc
#         LIMIT 5
#     )
#     ,enrollment_terms AS
#     (
#     SELECT
#           e.user_sso_guid
#           ,terms_chron_order_desc
#           ,governmentdefinedacademicterm
#           ,COUNT(DISTINCT olr_course_key) AS unique_courses
#       FROM prod.cu_user_analysis.user_courses e
#       LEFT JOIN term_dates_five_most_recent d
#           ON e.course_start_date::DATE >= d.start_date AND e.course_start_date <= d.end_date
#         --ON DATEADD('d', -30, s.subscription_start::DATE) <= d.start_date
#         --AND s.subscription_end::DATE >= DATEADD('d', -30, d.end_date)
#       --AND user_sso_guid_merged IN ('033b20b27ca503d5:20c4c7b6:15f6f339f0c:-5f8b', '033b20b27ca503d5:20c4c7b6:15e2fad1470:5223', 'efa047457a23f24d:-260a5249:1655840aed1:-1568')
#       GROUP BY 1, 2, 3
#       )
#       ,enrollment_terms_pivoted AS
#       (
#       SELECT
#           *
#       FROM enrollment_terms
#       PIVOT (SUM(unique_courses) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
#       )
#       SELECT
#         user_sso_guid
#         ,SUM(CASE WHEN "1" > 0 THEN "1" ELSE 0 END) AS "1"
#         ,SUM(CASE WHEN "2" > 0 THEN "2" ELSE 0 END) AS "2"
#         ,SUM(CASE WHEN "3" > 0 THEN "3" ELSE 0 END) AS "3"
#         ,SUM(CASE WHEN "4" > 0 THEN "4" ELSE 0 END) AS "4"
#         ,SUM(CASE WHEN "5" > 0 THEN "5" ELSE 0 END) AS "5"
#       FROM enrollment_terms_pivoted
#       GROUP BY 1
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#     hidden: yes
#   }

#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#     hidden: yes
#   }

#   dimension: governmentdefinedacademicterm {
#     type: string
#     sql: ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ;;
#   }

#   dimension: current { group_label: "# Courses in Terms"
#     sql: CASE WHEN ${TABLE}."1" > 4 THEN '4+' ELSE ${TABLE}."1"::string END;;
#     }

#   dimension: minus_1 { group_label: "# Courses in Terms" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: minus_2 { group_label: "# Courses in Terms" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: minus_3 { group_label: "# Courses in Terms" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: minus_4 { group_label: "# Courses in Terms" description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

# }
