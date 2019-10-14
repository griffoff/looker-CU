explore: mt_activated_active_semester_users_wk_course {}

view: mt_activated_active_semester_users_wk_course {
  derived_table: {
    sql: WITH
        user_activations_count AS
        (
          SELECT
            COALESCE(m.primary_guid, ma.user_guid) AS merged_guid
            ,ma.actv_dt
            ,ma.actv_entity_name
            ,ma.actv_user_type
            ,ma.entity_no
            ,c.begin_date
            ,c.end_date
            ,CASE
              WHEN actv_dt BETWEEN '2018-08-01' AND '2018-09-30' THEN 'Fall 18'
              WHEN actv_dt BETWEEN '2019-08-01' AND '2019-09-30' THEN 'Fall 19'
              ELSE 'other'
            END AS semester
            ,COUNT(DISTINCT ma.actv_code) AS activation_count
          FROM prod.stg_clts.activations_olr ma
          LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
              ON ma.user_guid = m.partner_guid
          LEFT JOIN prod.unlimited.excluded_users e1
              ON ma.user_guid = e1.user_sso_guid
          LEFT JOIN prod.unlimited.excluded_users e2
              ON m.primary_guid = e2.user_sso_guid
          LEFT JOIN prod.stg_clts.olr_courses c
              ON ma.context_id = c."#CONTEXT_ID"
          WHERE ma.user_guid NOT IN (SELECT DISTINCT user_sso_guid FROM prod.unlimited.excluded_users)
          AND e1.user_sso_guid IS NULL AND e2.user_sso_guid IS NULL
          AND platform ILIKE '%mindtap%'
          AND actv_dt >= '2018-08-01'
          GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
        )
        ,mt_activity AS
        (
          SELECT
            COALESCE(m.primary_guid, user_identifier) AS merged_guid
           ,mt.event_time::date AS event_date
           ,CASE
              WHEN mt.event_time::date BETWEEN '2018-08-01' AND '2018-09-30' THEN 'Fall 18'
              WHEN mt.event_time::date BETWEEN '2019-08-01' AND '2019-09-30' THEN 'Fall 19'
              ELSE 'other'
            END AS semester
              ,COUNT(DISTINCT mt_session_id) AS unique_sessions
              ,COUNT(*) AS unique_activities
          FROM cap_er.prod.raw_mt_resource_interactions mt
           LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m
              ON mt.user_identifier = m.partner_guid
          WHERE semester IN ('Fall 18', 'Fall 19')
          --AND mt.event_action = 'ACTIVITY-SUBMITTED'
          AND mt.event_category IN ('READING', 'ACTIVITY', 'ASSESSMENT', 'HOMEWORK')
          AND mt.event_action NOT ILIKE '%unfocused%'
          GROUP BY 1, 2, 3
        )
        ,active_users_mt_semester AS
        (
        SELECT
            uac.semester
            ,COUNT(DISTINCT ma.merged_guid) AS distinct_users
        FROM user_activations_count uac
        LEFT JOIN mt_activity ma
          ON uac.semester = ma.semester
          AND uac.merged_guid = ma.merged_guid
          AND uac.activation_count > 0
          AND ma.unique_sessions > 0
        WHERE uac.semester IN ('Fall 18', 'Fall 19')
        GROUP BY 1
        )
        ,activation_buckets_semester_mt AS
        (
        SELECT
            uac.semester
            ,CASE WHEN uac.activation_count > 4 THEN '5+' ELSE uac.activation_count::string END AS activation_count
            ,COUNT(DISTINCT ma.merged_guid) AS distinct_users
        FROM user_activations_count uac
        LEFT JOIN mt_activity ma
          ON uac.semester = ma.semester
          AND uac.merged_guid = ma.merged_guid
          AND uac.activation_count > 0
          AND ma.unique_sessions > 0
        WHERE uac.semester IN ('Fall 18', 'Fall 19')
        GROUP BY 1, 2
        )
        ,week_in_course_usage AS
        (
            SELECT
              uac.semester
              ,DATEDIFF('week', begin_date, ma.event_date) AS week_in_course
              ,AVG(unique_activities) AS avg_weekly_activites
              ,AVG(unique_sessions) AS avg_weekly_sessions
            FROM user_activations_count uac
            LEFT JOIN mt_activity ma
              ON uac.semester = ma.semester
              AND uac.merged_guid = ma.merged_guid
              AND uac.activation_count > 0
              AND ma.unique_sessions > 0
            WHERE uac.semester IN ('Fall 18', 'Fall 19')
            GROUP BY 1, 2
        )
        SELECT * FROM week_in_course_usage
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: avg_weekly_activites_m {
    type: sum
    sql: ${TABLE}."AVG_WEEKLY_ACTIVITES" ;;
  }

  measure: avg_weekly_sessions_m {
    type: sum
    sql: ${TABLE}."AVG_WEEKLY_SESSIONS" ;;
  }

  dimension: semester {
    type: string
    sql: ${TABLE}."SEMESTER" ;;
  }

  dimension: week_in_course {
    type: number
    sql: ${TABLE}."WEEK_IN_COURSE" ;;
  }

  dimension: avg_weekly_activites {
    type: number
    sql: ${TABLE}."AVG_WEEKLY_ACTIVITES" ;;
  }

  dimension: avg_weekly_sessions {
    type: number
    sql: ${TABLE}."AVG_WEEKLY_SESSIONS" ;;
  }

  set: detail {
    fields: [semester, week_in_course, avg_weekly_activites, avg_weekly_sessions]
  }
}
