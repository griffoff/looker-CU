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
            d1.date_value as end_date
            , dateadd(d,-{{ x_days._parameter_value }}, d1.date_value) as begin_date
            , d2.date_value as middle_date
          from bpl_mart.prod.dim_date d1
          inner join bpl_mart.prod.dim_date d2 on d2.date_value >= dateadd(d,-{{ x_days._parameter_value }}, d1.date_value) and d2.date_value < d1.date_value
          where {% condition date_range %} d1.date_value {% endcondition %}
          ;;

      }

      dimension: begin_date {hidden: yes
      }

#   dimension: middle_date_raw {type:date hidden:yes sql:middle_date;;}

      dimension_group: middle_date {
        type:time
        timeframes: [raw,date]
        hidden: yes
        }

      dimension: end_date {type: date
        description: "Aggregates measures over the past X days (defined by the filter) relative to the End Date, not including the End Date itself"
      }


    }
