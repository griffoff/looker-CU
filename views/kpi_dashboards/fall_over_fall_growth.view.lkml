explore: fall_over_fall_growth {}

view: fall_over_fall_growth {
  derived_table: {
    sql: SELECT
        COUNT(DISTINCT CASE WHEN full_access_cohort."4" > 0 THEN learner_profile.user_sso_guid END)  AS fall_2019_students,
        COUNT(DISTINCT CASE WHEN full_access_cohort."1" > 0 THEN learner_profile.user_sso_guid END)  AS fall_2020_students,
        (fall_2020_students - fall_2019_students) / fall_2019_students * 100 AS fall_over_fall_subscription_growth
      FROM prod.cu_user_analysis.learner_profile  AS learner_profile
      LEFT JOIN prod.cu_user_analysis.all_sessions  AS all_sessions ON learner_profile.user_sso_guid = (all_sessions."USER_SSO_GUID")
      LEFT JOIN ${dim_course.SQL_TABLE_NAME} AS dim_course ON (all_sessions."COURSE_KEYS")[0] = dim_course.coursekey
      LEFT JOIN ${dim_institution.SQL_TABLE_NAME} AS dim_institution ON dim_course.INSTITUTIONID = dim_institution.INSTITUTIONID
      LEFT JOIN ${merged_cu_user_info.SQL_TABLE_NAME} AS merged_cu_user_info ON learner_profile.user_sso_guid = merged_cu_user_info.merged_guid
      LEFT JOIN ${full_access_cohort.SQL_TABLE_NAME} AS full_access_cohort ON learner_profile.user_sso_guid = (full_access_cohort."USER_SSO_GUID_MERGED")
       ;;

      sql_trigger_value: SELECT * FROM subscription.prod.raw_subscription_event ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: fall_over_fall_subscription_growth_measure {
    type: sum
    sql: ${fall_over_fall_subscription_growth} ;;
    drill_fields: [detail*]
    value_format: "0.00\%"
  }

  dimension: fall_2019_students {
    type: number
    sql: ${TABLE}."FALL_2019_STUDENTS" ;;
  }

  dimension: fall_2020_students {
    type: number
    sql: ${TABLE}."FALL_2020_STUDENTS" ;;
  }

  dimension: fall_over_fall_subscription_growth {
    type: number
    sql: ${TABLE}."FALL_OVER_FALL_SUBSCRIPTION_GROWTH" ;;
    value_format: "0.00\%"
  }

  set: detail {
    fields: [fall_2019_students, fall_2020_students, fall_over_fall_subscription_growth]
  }
}
