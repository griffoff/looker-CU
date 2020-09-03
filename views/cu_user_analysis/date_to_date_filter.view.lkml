explore: date_to_date_filter {
  always_filter: {filters:[date_range: ""]}
  hidden: yes
}
view: date_to_date_filter {

  filter: date_range {
    type: date
    datatype: date
  }

  derived_table: {
    sql:
    with b as (
    select {% date_start date_range %}::date as begin_date
    )
    , e as (
    select datevalue as end_date from ${dim_date.SQL_TABLE_NAME}
    where {% condition date_range %} datevalue {% endcondition %}


    )
    select b.begin_date, e2.end_date as middle_date, e1.end_date
    from b
    cross join e e1
    inner join e e2 on e2.end_date between b.begin_date and e1.end_date

    ;;

  }

  dimension: begin_date {hidden: yes
  }

  dimension_group: middle_date {
    type:time
    timeframes: [raw]
    hidden: yes
  }

  dimension: end_date {type: date
  }


  }
