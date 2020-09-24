explore: past_x_days_filter {
  always_filter: {filters:[date_range: ""]}
  hidden: no
}

view: past_x_days_filter {

    filter: date_range {
      type: date
      datatype: date
    }

    parameter: x_days {
      type: number
    }

    derived_table: {
      sql:
          select
            d1.datevalue as end_date
            , dateadd(d,-{{ x_days._parameter_value }}, d1.datevalue) as begin_date
            , d2.datevalue as middle_date
          from ${dim_date.SQL_TABLE_NAME} d1
          inner join ${dim_date.SQL_TABLE_NAME} d2 on d2.datevalue between dateadd(d,-{{ x_days._parameter_value }}, d1.datevalue) and d1.datevalue
          where {% condition date_range %} d1.datevalue {% endcondition %}
          ;;

      }

      dimension: begin_date {hidden: yes
      }

#   dimension: middle_date_raw {type:date hidden:yes sql:middle_date;;}

      dimension_group: middle_date {
        type:time
        timeframes: [raw]
        hidden: yes
        }

      dimension: end_date {type: date
      }


    }
