explore: dim_date_to_date {hidden:yes always_filter: {filters:[date_range: "",cumulative_counts: "No"]}}
view: dim_date_to_date {

  filter: date_range {
    type: date
    datatype: date
  }

  parameter: cumulative_counts {
    type: yesno
    default_value: "No"
    description: ""
  }

derived_table: {
  sql:
    select distinct
    {% if dim_date_to_date.cumulative_counts._parameter_value == 'true' %}
      {% date_start dim_date_to_date.date_range %}::date
    {% else %}
      d.date_value
    {% endif %} as cumulative_period_start
    , d.*
    from bpl_mart.prod.dim_date d
    where {% condition dim_date_to_date.date_range %} date_value {% endcondition %}
  ;;
}

dimension_group: date_value {
  type: time
  hidden: yes
}

  dimension_group: cumulative_period_start {
    label: "Calendar"
    type: time
    can_filter: no
  }

 }
