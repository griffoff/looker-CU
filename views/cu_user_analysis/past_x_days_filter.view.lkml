explore: past_x_days_filter {
  always_filter: {filters:[date_range: ""]}
  hidden: yes
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
          select datevalue as end_date, dateadd(d,-{{ x_days._parameter_value }}, datevalue) as begin_date from ${dim_date.SQL_TABLE_NAME}
          where {% condition date_range %} datevalue {% endcondition %}
          ;;

      }

      dimension: begin_date {hidden: yes
      }

      dimension: end_date {type: date
      }


    }
