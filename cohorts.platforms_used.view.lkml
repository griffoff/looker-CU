include: "cohorts.base.view"

view: cohorts_platforms_used {
  extends: [cohorts_base_string]

  derived_table: {
    #VERY SLOW
#     sql:
#       SELECT
#           user_sso_guid_merged
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 1 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 1 THEN productplatform END) AS "1"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 2 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 2 THEN productplatform END) AS "2"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 3 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 3 THEN productplatform END) AS "3"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 4 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 4 THEN productplatform END) AS "4"
#           ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 5 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 5 THEN productplatform END) AS "5"
#        FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME} s
#        INNER JOIN cu_user_analysis.all_sessions  AS all_sessions ON s.user_sso_guid_merged = (all_sessions."USER_SSO_GUID")
#                             AND all_sessions.session_start BETWEEN s.subscription_start AND s.subscription_end
#        CROSS JOIN LATERAL FLATTEN(all_sessions.course_keys) k
#        INNER JOIN LOOKER_SCRATCH.LR$JJBPYXH967MLWE7JQ31QE_dim_course dim_course ON k.value = dim_course.coursekey
#        INNER JOIN DW_GA.DIM_PRODUCTPLATFORM  AS dim_productplatform ON dim_course.PRODUCTPLATFORMID = dim_productplatform.PRODUCTPLATFORMID
#        GROUP BY 1
#       ;;

  #OPTIMIZED
    sql:
      SELECT
          user_sso_guid_merged
          ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 1 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 1 THEN productplatform END) AS "1"
          ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 2 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 2 THEN productplatform END) AS "2"
          ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 3 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 3 THEN productplatform END) AS "3"
          ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 4 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 4 THEN productplatform END) AS "4"
          ,ARRAY_AGG(DISTINCT CASE WHEN terms_chron_order_desc = 5 THEN productplatform END) WITHIN GROUP (ORDER BY CASE WHEN terms_chron_order_desc = 5 THEN productplatform END) AS "5"
       FROM (
         SELECT DISTINCT terms_chron_order_desc, user_sso_guid_merged, k.value
         FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME} s
         INNER JOIN cu_user_analysis.all_sessions  AS all_sessions ON s.user_sso_guid_merged = (all_sessions."USER_SSO_GUID")
                              AND all_sessions.session_start BETWEEN s.subscription_start AND s.subscription_end
         CROSS JOIN LATERAL FLATTEN(all_sessions.course_keys) k
        ) k
       INNER JOIN ${dim_course.SQL_TABLE_NAME} dim_course ON k.value = dim_course.coursekey
       INNER JOIN ${dim_productplatform.SQL_TABLE_NAME}   AS dim_productplatform ON dim_course.PRODUCTPLATFORMID = dim_productplatform.PRODUCTPLATFORMID
       GROUP BY 1
      ;;

  }

  dimension: current { group_label: "Platforms Accessed" }

  dimension: minus_1 { group_label: "Platforms Accessed" }

  dimension: minus_2 { group_label: "Platforms Accessed" }

  dimension: minus_3 { group_label: "Platforms Accessed" }

  dimension: minus_4 { group_label: "Platforms Accessed" }

}
