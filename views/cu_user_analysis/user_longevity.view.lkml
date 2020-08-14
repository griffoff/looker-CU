explore: user_longevity {}
view: user_longevity {
  derived_table: {
    create_process: {
      sql_step:
        create or replace table LOOKER_SCRATCH.user_longevity as
          with terms as (
          select GOVERNMENTDEFINEDACADEMICTERM, min(datevalue) as term_start, max(DATEVALUE) as term_end, 1 - row_number() over (order by term_start desc) as relative_term
          from ${dim_date.SQL_TABLE_NAME}
          where DATEVALUE <= current_date()
          group by GOVERNMENTDEFINEDACADEMICTERM
          )
          , current_guids as (
          select distinct user_sso_guid, user_type
          from ${courseware_users.SQL_TABLE_NAME}
          )
          select *, 0 as term_user, 0 as last_5_terms
          from current_guids
          cross join (select * from terms where relative_term > -12)
          order by user_sso_guid, relative_term desc
      ;;
      sql_step:
        UPDATE LOOKER_SCRATCH.user_longevity e
        SET term_user = 1
        FROM ${courseware_users.SQL_TABLE_NAME} g
        WHERE e.user_sso_guid = g.user_sso_guid and g.activation_date between e.term_start and e.term_end and g.USER_TYPE = 'Student'
      ;;
      sql_step:
      UPDATE LOOKER_SCRATCH.user_longevity e
      SET term_user = 1
      FROM ${courseware_users.SQL_TABLE_NAME} g
      WHERE e.user_sso_guid = g.user_sso_guid and g.COURSE_START between e.term_start and e.term_end and g.USER_TYPE = 'Instructor' and g.activation_date is null
      ;;

      sql_step:
        UPDATE LOOKER_SCRATCH.user_longevity e
        SET e.last_5_terms = v.last_5_terms
        from (
        select user_sso_guid
        , user_type
        , relative_term
        , sum(coalesce(TERM_USER,0)) over (partition by USER_SSO_GUID, USER_TYPE order by RELATIVE_TERM rows between 5 preceding and current row ) as last_5_terms
        from LOOKER_SCRATCH.user_longevity
        ) v
        where v.USER_SSO_GUID = e.USER_SSO_GUID
        and v.USER_TYPE = e.USER_TYPE
        and v.RELATIVE_TERM = e.RELATIVE_TERM;
      ;;

      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} as
      select user_sso_guid, user_type, last_5_terms as term_longevity, GOVERNMENTDEFINEDACADEMICTERM as current_term
      from LOOKER_SCRATCH.user_longevity
      where term_user = 1
      ;;
    }
    datagroup_trigger: daily_refresh
  }

  dimension: user_sso_guid {}
  dimension: user_type {}
  dimension: term_longevity {}
  dimension: current_term {}

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
