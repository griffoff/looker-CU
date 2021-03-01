explore: guid_date_renewal {}
view: guid_date_renewal {
  derived_table: {
    sql:
    WITH dates AS (
      SELECT date_value as date, GOVERNMENTDEFINEDACADEMICTERM AS season, GOVERNMENTDEFINEDACADEMICTERMYEAR AS term_year, GOVERNMENTDEFINEDACADEMICTERMID as season_no
      FROM bpl_mart.prod.dim_date
    )

    ,subs as (
      SELECT
        CASE WHEN bp._effective_from IS NOT NULL THEN bp.USER_SSO_GUID ELSE ss.CURRENT_GUID END AS user_guid
        , COALESCE(bp._effective_from, ss.subscription_start)::date AS subscription_start
        , COALESCE(COALESCE(bp._effective_to, bp.subscription_end),
                    COALESCE(ss.cancelled_time, ss.subscription_end))::date AS subscription_end
        , CASE WHEN bp.SUBSCRIPTION_STATE IS NOT NULL THEN bp.SUBSCRIPTION_STATE
          ELSE ss.SUBSCRIPTION_PLAN_ID END AS subscription_type
        , hs.SUBSCRIPTION_ID
        FROM prod.datavault.hub_subscription hs
        LEFT JOIN prod.datavault.sat_subscription_sap ss ON hs.hub_subscription_key = ss.hub_subscription_key
          AND (ss.SUBSCRIPTION_PLAN_ID ILIKE 'Full%' OR ss.SUBSCRIPTION_PLAN_ID ILIKE 'Limited%')
          AND ss.SUBSCRIPTION_STATE <> 'Pending'
          AND ss.CANCELLED_TIME IS NULL
          AND ss._LATEST
        LEFT JOIN prod.datavault.sat_subscription_bp bp ON hs.hub_subscription_key = bp.hub_subscription_key
          AND bp.SUBSCRIPTION_STATE IN ('full_access')
        WHERE user_guid IS NOT NULL
          AND COALESCE(bp._effective_from, ss.subscription_start)::date >= '2018-08-01'
        )
    ,subs_clean as (
      select
        subs.user_guid
        , subscription_start
        , max(subscription_end) as subscription_end
      from subs
      group by subs.user_guid, subscription_start
    )
    ,subs_len as (
      select
        user_guid
        , subscription_start
        , subscription_end
        , datediff(d,subscription_start,subscription_end) AS sub_length
        , case when sub_length < 150 then '4 Month'
                when sub_length < 210 then '6 Month'
                when sub_length < 390 then '12 Month'
                else '24 Month'
          end as sub_length_bucket
      from subs_clean
      where sub_length > 90
      )

    ,sub_dates AS (
      SELECT s.USER_guid
        , s.subscription_end
        , s.subscription_start
        , s.sub_length_bucket
        , MIN(a.subscription_start) AS next_start
        , COALESCE(MIN(a.subscription_start),DATEADD(d,49,s.subscription_end)) AS renewal_date
      FROM subs_len s
      LEFT JOIN subs_len a ON s.USER_guid = a.user_guid AND a.subscription_start > s.subscription_end AND DATEDIFF(d,s.subscription_end,a.subscription_start) <= 49
      GROUP BY 1,2,3,4
    )

    ,renewals AS (
      SELECT *
        , DATEDIFF(d,subscription_end,next_start) AS time_to_next
        , CASE WHEN time_to_next < 49 THEN 'Renewed'
                WHEN time_to_next IS NULL THEN 'Did not renew'
          END AS sub_type
      FROM sub_dates
    )
    SELECT d.*, r.*
    FROM dates d
    INNER JOIN renewals r ON renewal_date = date
    ;;
    datagroup_trigger: daily_refresh
  }

  dimension_group: date {
    label: "Calendar"
    type:time
    timeframes: [raw,date,week,month,year]
  }

  dimension: term_year {}
  dimension: season {}
  dimension: season_no {type:number}

  dimension: current_season_no {
    sql:(select max(season_no) from ${guid_date_renewal.SQL_TABLE_NAME} where sub_type = 'Renewed') ;;
    type: number
  }



  dimension: sub_length_bucket {}





  measure: renewed {
    type: count_distinct
    sql: case when ${TABLE}.sub_type = 'Renewed' then ${TABLE}.user_guid end ;;
  }



  measure: did_not_renew {
    type: count_distinct
    sql: case when ${TABLE}.sub_type = 'Did not renew' then ${TABLE}.user_guid end ;;
  }




}
