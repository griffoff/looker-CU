explore:  guid_date_renewal {}
view: guid_date_renewal {
  derived_table: {
    sql:
    with dates as (
    select DATEVALUE as date, t.*
    from prod.dm_common.dim_date_legacy_cube
    inner join ZANDBOX.delderfield.terms t on datevalue between t.term_start and t.term_end and DATEVALUE between '2018-08-01' and current_date()
    )

    ,sub_dates as (
    select s.USER_guid, s.subscription_end, s.subscription_start, max(a.subscription_end) as last_end
    from ZANDBOX.delderfield.subs s
    left join ZANDBOX.delderfield.subs a on s.USER_guid = a.user_guid and a.subscription_end < s.subscription_start
    group by 1,2,3
    )

    ,renewals as (
    select *
         , datediff(d,last_end,subscription_start) as time_from_prev
        , case when time_from_prev is null then 'New'
                when time_from_prev < 120 then 'Renewed'
                else 'Returning'
            end as sub_type
    from sub_dates
    )


    (
        select d.*, r.*, subscription_start as date_key, 'Starting' as sub_status
        from dates d
        inner join renewals r on subscription_start between dateadd(d,-120,date) and date
    )
    union
    (
        select d.*, r.*, subscription_end as date_key, 'Ending' as sub_status
        from dates d
        inner join renewals r on subscription_end between dateadd(d,-120,date) and date
    )


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

  measure: starting {
    type: count_distinct
    sql: case when ${TABLE}.sub_status = 'Starting' then ${TABLE}.user_guid end ;;
  }

  measure: renewed {
    type: count_distinct
    sql: case when ${TABLE}.sub_status = 'Starting' and ${TABLE}.sub_type = 'Renewed' then ${TABLE}.user_guid end ;;
  }

  measure: returning {
    type: count_distinct
    sql: case when ${TABLE}.sub_status = 'Starting' and ${TABLE}.sub_type = 'Returning' then ${TABLE}.user_guid end ;;
  }

  measure: new {
    type: count_distinct
    sql: case when ${TABLE}.sub_status = 'Starting' and ${TABLE}.sub_type = 'New' then ${TABLE}.user_guid end ;;
  }

  measure: ending {
    type: count_distinct
    sql: case when ${TABLE}.sub_status = 'Ending' then ${TABLE}.user_guid end ;;
  }



  }
