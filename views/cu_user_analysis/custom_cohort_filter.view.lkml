view: custom_cohort_filter {
  derived_table: {
    create_process: {
      sql_step:
        create table if not exists prod.looker_scratch.looker_cohort_detail
        CLUSTER BY (cohort_name)
        (
          filename VARCHAR
          , cohort_name VARCHAR
          , refresh_time TIMESTAMP
          , user_sso_guid VARCHAR
          , pk VARCHAR
        )
      ;;

      sql_step:
        copy into prod.looker_scratch.looker_cohort_detail
        from (
          select
             metadata$filename as filename
            , replace(REGEXP_SUBSTR(FILENAME, 'cohorts/(.+)_\\d{4}-\\d{2}-\\d{2}[T]\\d{4}', 1, 1, 'e'),'_',' ') as cohort_name
            , TO_TIMESTAMP(REGEXP_SUBSTR(FILENAME, '\\d{4}-\\d{2}-\\d{2}[T]\\d{4}', 1, 1),'YYYY-MM-DDTHHMI') as refresh_time
            , $1 as user_sso_guid
            , concat(filename,user_sso_guid) as pk
          from (@prod.looker_scratch.looker_cohorts_stage)
        )
      ;;

      sql_step:
        create table if not exists prod.looker_scratch.looker_cohort_summary (
          filename VARCHAR
          , cohort_name VARCHAR
          , refresh_time TIMESTAMP
          , latest BOOLEAN
          , cohort_size NUMBER
        )
      ;;

      sql_step:
        insert into prod.looker_scratch.looker_cohort_summary
          select
            filename
            , cohort_name
            , refresh_time
            , (lead(refresh_time) over(partition by cohort_name order by refresh_time)) is null as latest
            , count(*) as cohort_size
          from prod.looker_scratch.looker_cohort_detail
          where filename not in (select distinct filename from prod.looker_scratch.looker_cohort_summary)
          group by 1,2,3
      ;;

      sql_step:
        update prod.looker_scratch.looker_cohort_summary s
          set
            s.latest = n.latest
          from (
            select
              filename
              , cohort_name
              , refresh_time
              , (lead(refresh_time) over(partition by cohort_name order by refresh_time)) is null as latest
            from prod.looker_scratch.looker_cohort_summary
          ) n
          where s.filename = n.filename
      ;;

      sql_step:
        delete from prod.looker_scratch.looker_cohort_detail
        where filename not in (select distinct filename from prod.looker_scratch.looker_cohort_summary where latest)
      ;;

      sql_step:
        CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
        CLONE prod.looker_scratch.looker_cohort_detail
      ;;

    }
    sql_trigger_value: select count(*) from (@prod.looker_scratch.looker_cohorts_stage) ;;
  }


  dimension: cohort_name {}

  dimension: user_sso_guid {hidden:yes}

  dimension: refresh_time {}

  dimension: pk {
    primary_key: yes
    hidden: yes
  }
}
