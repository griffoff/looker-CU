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
  with e as (
    select * from bpl_mart.prod.dim_date
    where {% condition date_range %} date_value {% endcondition %}
  )
  select e1.*
  {% if dim_date_to_date.cumulative_counts._parameter_value == 'true' %}
  , e2.date_value as middle_date
  {% else %}
  , e1.date_value as middle_date
  {% endif %}
  from e e1
  {% if dim_date_to_date.cumulative_counts._parameter_value == 'true' %}
  inner join e e2 on e1.date_value >= e2.date_value
  {% endif %}


  /*
  with e as (
    select date_value as end_date, *
    from bpl_mart.prod.dim_date
    where {% condition date_range %} date_value {% endcondition %}
  )
  {% if dim_date_to_date.cumulative_counts._parameter_value == 'true' %}
  , b as (
    select {% date_start date_range %}::date as begin_date
  )
  {% endif %}
    select distinct
    e1.*
    {% if dim_date_to_date.cumulative_counts._parameter_value == 'true' %}
    , b.begin_date
    , e2.end_date as middle_date
    {% else %}
    , e1.date_value as begin_date
    , e1.date_value as middle_date
    {% endif %}
    from e e1
    {% if dim_date_to_date.cumulative_counts._parameter_value == 'true' %}
    cross join b
    inner join e e2 on e2.end_date between b.begin_date and e1.end_date
    {% endif %}
    */
  ;;
}

# dimension: begin_date {}

dimension_group: middle_date {
  type: time
  hidden: yes
}

dimension_group: date_value {
  label: "Calendar"
  type: time
  hidden: no
  can_filter: no
}

  # dimension_group: cumulative_period_start {
  #   label: "Calendar"
  #   type: time
  #   can_filter: no
  # }

 }
