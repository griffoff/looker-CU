explore: date_to_date_filter {
  always_filter: {filters:[date_range: ""]}

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
    select * from b cross join e
    ;;

  }

  dimension: begin_date {
  }

  dimension: end_date {
  }


  }
