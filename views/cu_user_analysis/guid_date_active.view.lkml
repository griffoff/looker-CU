explore: guid_date_active {hidden:yes}
view: guid_date_active {
  derived_table: {
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS LOOKER_SCRATCH.guid_date_active
        (
          date DATE
          ,user_sso_guid STRING
          ,region STRING
          ,platform STRING
          ,organization STRING
          ,user_type STRING
        )
      ;;

      sql_step:
      DELETE FROM LOOKER_SCRATCH.guid_date_active WHERE date > dateadd(d,-3, current_date())
      ;;

      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.guid_date_active_incremental
        AS
        WITH dates AS (
          SELECT d.date_value
          FROM bpl_mart.prod.dim_date d
          WHERE d.date_value > (SELECT COALESCE(MAX(date), '2018-08-01') FROM LOOKER_SCRATCH.guid_date_active)
          AND d.date_value < CURRENT_DATE()
        )
        ,events AS (
          SELECT DISTINCT
            e.user_sso_guid
            , e.event_time::DATE AS date
            , CASE e.product_platform
              WHEN 'WEBASSIGN' THEN 'WebAssign'
              WHEN 'MT3' THEN 'MindTap'
              WHEN 'WA RESPONSES' THEN 'WebAssign'
              WHEN 'CNOW' THEN 'CNOW'
              WHEN 'APLIA' THEN 'Aplia'
              WHEN 'MINDTAP' THEN 'MindTap'
              WHEN 'CNOWV7' THEN 'CNOW'
              WHEN 'CAS-MTS' THEN 'MindTap'
              WHEN 'MT4' THEN 'MindTap'
              WHEN 'GRADEBOOK-MT' THEN 'MindTap'
              WHEN 'CAS-MT' THEN 'MindTap'
              WHEN 'MTS' THEN 'MindTap'
            END AS product_platform_old
            , case
              when e.event_data:host_platform = 'lite' then 'Middle Product'
              else COALESCE(e.course_key_platform, e.product_isbn_platform, product_platform_old)
            end as product_platform
            , e.course_key
          FROM prod.cu_user_analysis.all_sessions s
          INNER JOIN prod.cu_user_analysis.all_events e USING(session_id)
          INNER JOIN dates d ON s.session_start::DATE = d.date_value
        )

        SELECT DISTINCT
        a.date
        , COALESCE(su.linked_guid,a.user_sso_guid) AS user_sso_guid
        , COALESCE(CASE WHEN u."#CONTEXT_ID" LIKE 'GWMTP%' THEN 'Middle Product' END, a.product_platform, 'Other') AS platform
        , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
        , CASE WHEN e.mkt_seg_maj_cd = 'PSE' AND e.mkt_seg_min_cd in ('056','060') THEN 'Career'
               WHEN e.mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
               ELSE 'Other' END AS organization
        , CASE WHEN su.instructor = TRUE THEN 'Instructor' ELSE 'Student' END AS user_type
        FROM events a
        LEFT JOIN prod.stg_clts.olr_courses u ON a.course_key = u.course_key
        LEFT JOIN prod.datavault.hub_user hu ON a.user_sso_guid = hu.UID
        LEFT JOIN prod.datavault.SAT_USER_V2 su ON hu.hub_user_key = su.hub_user_key AND su._LATEST
        LEFT JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
        LEFT JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key and sui.active
        LEFT JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
        LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
        LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal
        WHERE ui.hub_user_key IS NULL
        ;;
      sql_step:
              INSERT INTO LOOKER_SCRATCH.guid_date_active
              SELECT date, user_sso_guid, region, platform, organization, user_type
              FROM looker_scratch.guid_date_active_incremental
              ORDER BY date
              ;;

      sql_step: ALTER TABLE LOOKER_SCRATCH.guid_date_active CLUSTER BY (date);;
      sql_step: ALTER TABLE LOOKER_SCRATCH.guid_date_active RECLUSTER;;
      sql_step:
                CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
                CLONE LOOKER_SCRATCH.guid_date_active;;
    }
    datagroup_trigger: daily_refresh
  }

  dimension_group: date {
    label: "Calendar"
    type:time
    timeframes: [raw,date,week,month,year,week_of_year]
  }

  dimension: user_sso_guid {}
  dimension: region {}
  dimension: platform {}
  dimension: organization {}
  dimension: user_type {}

  measure: user_sso_guid_count {
    sql: ${user_sso_guid} ;;
    type: count_distinct
    label: "# Users"
  }


 }
