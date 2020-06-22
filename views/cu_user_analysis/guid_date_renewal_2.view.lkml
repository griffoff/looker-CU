explore: guid_date_renewal_2 {}
view: guid_date_renewal_2 {
  derived_table: {
    sql:

    with dates as (
    select DATEVALUE as date, t.*
    from prod.dm_common.dim_date_legacy_cube
    inner join ZANDBOX.delderfield.terms t on datevalue between t.term_start and t.term_end
    )

    ,sub_dates as (
    select s.USER_guid
      , s.subscription_end
      , s.subscription_start
      , s.sub_length_bucket
      , min(a.subscription_start) as next_start
      , coalesce(min(a.subscription_start),dateadd(d,49,s.subscription_end)) as renewal_date
    from ZANDBOX.delderfield.subs s
    left join ZANDBOX.delderfield.subs a on s.USER_guid = a.user_guid and a.subscription_start > s.subscription_end and datediff(d,s.subscription_end,a.subscription_start) <= 49
    group by 1,2,3,4
    )

    ,renewals as (
    select *
         , datediff(d,subscription_end,next_start) as time_to_next
        , case when time_to_next < 49 then 'Renewed'
                when time_to_next is null then 'Did not renew'
            end as sub_type
    from sub_dates
    )



        select d.*, r.*
        from dates d
        inner join renewals r on renewal_date = date



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

  dimension: sub_length_bucket {}

#   measure: starting {
#     type: count_distinct
#     sql: case when ${TABLE}.sub_status = 'Starting' then ${TABLE}.user_guid end ;;
#   }

  measure: renewed {
    type: count_distinct
    sql: case when ${TABLE}.sub_type = 'Renewed' then ${TABLE}.user_guid end ;;
  }

#   measure: returned {
#     type: count_distinct
#     sql: case when ${TABLE}.sub_type = 'Returned' then ${TABLE}.user_guid end ;;
#   }

  measure: did_not_renew {
    type: count_distinct
    sql: case when ${TABLE}.sub_type = 'Did not renew' then ${TABLE}.user_guid end ;;
  }

#   measure: ending {
#     type: count_distinct
#     sql: ${TABLE}.user_guid ;;
#   }



}
