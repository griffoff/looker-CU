explore: cu_renewals_by_term {}
view: cu_renewals_by_term {
  derived_table: {
    create_process: {
      sql_step:
      USE SCHEMA looker_scratch
      ;;

      sql_step:
      CREATE TEMPORARY TABLE subs AS (
        SELECT CASE WHEN bp._effective_from IS NOT NULL THEN bp.USER_SSO_GUID ELSE ss.CURRENT_GUID END AS user_guid
          , COALESCE(bp._effective_from, ss.subscription_start)::DATE AS subscription_start
          , COALESCE(COALESCE(bp._effective_to, bp.subscription_end), COALESCE(ss.cancelled_time, ss.subscription_end))::DATE AS subscription_end
          , datediff(d
              , COALESCE(bp._effective_from, ss.subscription_start)::DATE
              , COALESCE(COALESCE(bp._effective_to, bp.subscription_end), COALESCE(ss.cancelled_time, ss.subscription_end))::DATE
              ) AS sub_length
          , CASE WHEN sub_length < 150 THEN '4 Month'
              WHEN sub_length < 210 THEN '6 Month'
              WHEN sub_length < 390 THEN '12 Month'
              ELSE '24 Month'
            END AS sub_length_bucket
          , CASE WHEN bp.SUBSCRIPTION_STATE IS NOT NULL THEN bp.SUBSCRIPTION_STATE
              ELSE ss.SUBSCRIPTION_PLAN_ID END AS subscription_type
          , hs.SUBSCRIPTION_ID
        FROM prod.datavault.hub_subscription hs
        LEFT JOIN prod.datavault.sat_subscription_sap ss ON hs.hub_subscription_key = ss.hub_subscription_key
          AND (ss.SUBSCRIPTION_PLAN_ID ILIKE 'Full%' OR ss.SUBSCRIPTION_PLAN_ID ILIKE 'Limited%')
          AND ss.SUBSCRIPTION_STATE <> 'Pending'
          AND ss._LATEST
        LEFT JOIN prod.datavault.sat_subscription_bp bp ON hs.hub_subscription_key = bp.hub_subscription_key
          AND bp.SUBSCRIPTION_STATE IN ('full_access')
        WHERE user_guid IS NOT NULL
          AND COALESCE(bp._effective_from, ss.subscription_start)::DATE >= '2018-08-01'
          AND sub_length > 14
      );;

      sql_step:
      CREATE TEMPORARY TABLE sub_inds AS (
        WITH seq AS (
          SELECT -N AS n
          FROM prod.common.tally
          )
          , dates AS (
          SELECT year(current_date) AS term_year,concat(year(current_date),'-08-01')::DATE AS term_start,concat(year(current_date),'-10-31')::DATE AS term_end, 'Fall' AS season
          UNION
          SELECT year(current_date) AS term_year,concat(year(current_date),'-11-01')::DATE AS term_start,concat(1+year(current_date),'-03-31')::DATE AS term_end, 'Spring' AS season
          UNION
          SELECT year(current_date) AS term_year,concat(1+year(current_date),'-04-01')::DATE AS term_start,concat(1+year(current_date),'-07-31')::DATE AS term_end, 'Summer' AS season
          )
          ,terms AS (
          SELECT n+term_year AS term_year
            , DATEADD(y,n,term_start) AS term_start
            , DATEADD(y,n,term_end) AS term_end
            , 1-ROW_NUMBER() OVER (ORDER BY DATEADD(y,n,term_start) DESC) AS season_no
            , season
          FROM dates
              CROSS JOIN seq
          WHERE DATEADD(y,n,term_start) BETWEEN '2018-08-01' AND CURRENT_DATE
          ORDER BY term_start DESC
          )
          ,users AS (
          SELECT distinct USER_GUID, terms.*
          FROM subs
          CROSS JOIN terms
          )
        SELECT
          s.USER_GUID, s.term_year, s.term_start, s.term_end, s.season_no, s.season
          ,subs.user_guid as sub_user_guid
          ,subscription_start
          ,subscription_end
          ,subscription_type
          ,sub_length_bucket
        FROM users s
        LEFT JOIN subs ON (subs.subscription_start BETWEEN DATEADD(d,-14,s.term_start) AND DATEADD(d,-14,s.term_end) AND s.USER_GUID = subs.user_guid)
      );;

      sql_step:
      ALTER SESSION SET ERROR_ON_NONDETERMINISTIC_MERGE = FALSE
      ;;

      sql_step:
      MERGE INTO sub_inds s USING subs
      ON (subs.subscription_end between DATEADD(d,14,s.term_start) AND DATEADD(d,14,s.term_end) AND s.USER_GUID = subs.user_guid)
      WHEN MATCHED THEN UPDATE
        SET
          s.USER_GUID = subs.user_guid
          ,s.subscription_start = subs.subscription_start
          ,s.subscription_end = subs.subscription_end
          ,s.subscription_type = subs.subscription_type
          ,s.sub_length_bucket = subs.sub_length_bucket
      ;;

      sql_step:
      ALTER SESSION SET ERROR_ON_NONDETERMINISTIC_MERGE = TRUE
      ;;

      sql_step:
        CREATE OR REPLACE TABLE LOOKER_SCRATCH.cu_renewals_by_term AS
        (
        SELECT
          s.USER_GUID, s.term_year, s.term_start, s.term_end, s.season_no, s.season
          ,subscription_start
          ,subscription_end
          ,subscription_type
          ,sub_length_bucket
          , LAG(subscription_start) OVER (partition BY s.user_guid ORDER BY (subscription_start IS NULL) DESC, subscription_start, season_no) AS prev_start
          , LAG(subscription_start) OVER (PARTITION BY s.user_guid ORDER BY season_no, subscription_start) AS prev_start_season
          , LAG(s.season_no) OVER (partition BY s.user_guid ORDER BY (subscription_start IS NULL) DESC, subscription_start, season_no) AS prev_season_no
          , LAG(sub_length_bucket) OVER (PARTITION BY s.user_guid ORDER BY season_no, subscription_start) AS prev_subscription_type
          , LAG(sub_length_bucket) OVER (partition BY s.user_guid ORDER BY (subscription_start IS NULL) DESC, subscription_start, season_no) AS prev_subscription_type_returning
          , IFF(s.subscription_start BETWEEN DATEADD(d,-14,s.term_start) AND DATEADD(d,-14,s.term_end),1,0) AS sub_starting_ind
          , IFF((subscription_start <> prev_start AND s.season_no - prev_season_no <=  1),1,0) AS renewal_ind
          , IFF((subscription_start <> prev_start AND s.season_no - prev_season_no >  1),1,0) AS returning_ind
          , IFF(prev_start is NULL AND subscription_start IS NOT NULL,1,0) AS new_ind
          , IFF(s.subscription_end BETWEEN DATEADD(d,14,s.term_start) AND DATEADD(d,14,s.term_end),1,0) AS sub_ending_ind
          , IFF(s.subscription_start IS NULL AND prev_start_season IS NOT NULL,1,0) AS not_renew_ind
        FROM sub_inds s
        );;

      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE LOOKER_SCRATCH.cu_renewals_by_term
      ;;
      }
      datagroup_trigger: daily_refresh
    }

  dimension: sub_length_bucket {hidden:yes}
  dimension: prev_subscription_type {hidden:yes}

  dimension: season {}
  dimension: term_year {}
  dimension: season_no {type:number}
  dimension: sub_type {sql:COALESCE(sub_length_bucket,prev_subscription_type);;}

  measure: sub_starting_ind {type:sum}
  measure: renewal_ind {type:sum}
  measure: returning_ind {type:sum}
  measure: new_ind {type:sum}
  measure: sub_ending_ind {type:sum}
  measure: not_renew_ind {type:sum}

  measure: total_subs {
    type: sum
    sql: (${TABLE}.new_ind + ${TABLE}.renewal_ind + ${TABLE}.returning_ind);;
  }

  measure: renewal_rate {
    sql: IFF((${renewal_ind}+${not_renew_ind})>0,${renewal_ind}/(${renewal_ind}+${not_renew_ind}),0)  ;;
    value_format: "0.00%"
  }
  }
