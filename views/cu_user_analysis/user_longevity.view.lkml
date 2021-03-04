explore: user_longevity {hidden:yes}

view: user_longevity {
  derived_table: {
    create_process: {
      sql_step:
        CREATE OR REPLACE TABLE looker_scratch.user_longevity AS
        WITH terms AS (
            SELECT gov_ay_term_full
                 , MIN(date_value)                                      AS term_start
                 , MAX(date_value)                                      AS term_end
                 , 1 - ROW_NUMBER() OVER (ORDER BY term_start DESC)     AS relative_term
                 , LEAD(gov_ay_term_full, 3) OVER (ORDER BY term_start) AS ny_term
                 , LEAD(term_start, 3) OVER (ORDER BY term_start)       AS ny_term_start
                 , LEAD(term_end, 3) OVER (ORDER BY term_start)         AS ny_term_end
            FROM ${dim_date.SQL_TABLE_NAME}
            WHERE date_value <= CURRENT_DATE()
            GROUP BY gov_ay_term_full
        )
           , current_guids AS (
            SELECT DISTINCT user_sso_guid, user_type
            FROM ${courseware_users.SQL_TABLE_NAME}
        )
        SELECT *, 0 AS term_user, 0 AS last_5_terms
        FROM current_guids
             CROSS JOIN (SELECT * FROM terms WHERE relative_term > -12)
        ORDER BY user_sso_guid, relative_term DESC
      ;;
      sql_step:
        UPDATE LOOKER_SCRATCH.user_longevity e
        SET term_user = 1
        FROM ${courseware_users.SQL_TABLE_NAME} g
        WHERE e.user_sso_guid = g.user_sso_guid
          AND g.activation_date BETWEEN e.term_start AND e.term_end
          AND g.USER_TYPE = 'Student'
      ;;
      sql_step:
        UPDATE looker_scratch.user_longevity e
        SET term_user = 1
        FROM ${courseware_users.SQL_TABLE_NAME} g
        WHERE e.user_sso_guid = g.user_sso_guid
          AND g.course_start BETWEEN e.term_start AND e.term_end
          AND g.user_type = 'Instructor'
          AND g.activation_date IS NULL
      ;;

      sql_step:
        UPDATE looker_scratch.user_longevity e
        SET e.last_5_terms = v.last_5_terms
        FROM (
                 SELECT user_sso_guid
                      , user_type
                      , relative_term
                      , SUM(COALESCE(term_user, 0))
                            OVER (PARTITION BY user_sso_guid, user_type ORDER BY relative_term ROWS BETWEEN 5 PRECEDING AND CURRENT ROW ) AS last_5_terms
                 FROM looker_scratch.user_longevity
             ) v
        WHERE v.user_sso_guid = e.user_sso_guid
          AND v.user_type = e.user_type
          AND v.relative_term = e.relative_term
      ;;

      sql_step:
        CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} AS
        SELECT user_sso_guid
             , user_type
             , last_5_terms     AS term_longevity
             , gov_ay_term_full AS current_term
             , term_start
             , term_end
             , ny_term
             , ny_term_start
             , ny_term_end
        FROM looker_scratch.user_longevity
        WHERE term_user = 1
      ;;
    }
    datagroup_trigger: daily_refresh
  }

  dimension: user_sso_guid {}
  dimension: user_type {}
  dimension: term_longevity {}
  dimension: current_term {}
  dimension_group: term_start {type:time hidden:yes}
  dimension_group: term_end {type:time hidden:yes}
  dimension: ny_term {hidden: yes}
  dimension_group: ny_term_start {type:time hidden:yes}
  dimension_group: ny_term_end {type:time hidden:yes}

  dimension: term_longevity_bucket {
    sql: case
          when ${term_longevity} = 1 then '1 Term'
          when ${term_longevity} = 2 then '2 Terms'
          when ${term_longevity} = 3 then '3 Terms'
          else '4+ Terms'
        end
      ;;
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }


}
