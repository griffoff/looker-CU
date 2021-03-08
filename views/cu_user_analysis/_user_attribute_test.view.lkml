explore: _user_attribute_test {hidden:yes}
view: _user_attribute_test {

  derived_table: {
    sql:
    select 'PROD_V1' as show_schema_name
    {% if _user_attributes['access_dev_data'] == 'yes' %}
    union all
    select 'NONPROD_V1'
    {% endif %}
    ;;
  }

  parameter: schema_name {
    type: unquoted
    allowed_value: {
      label: "PROD_V1"
      value: "PROD_V1"
    }
    allowed_value: {
      label: "NONPROD_V1"
      value: "NONPROD_V1"
    }

    suggest_dimension: show_schema_name

    default_value: "PROD_V1"
    description: ""
  }

  dimension: show_schema_name {
    sql:
      {% if _user_attributes['access_dev_data'] == 'yes' %}
      -- {{ _user_attributes['access_dev_data'] }}
        ${TABLE}.show_schema_name
      {% else %} nullif(${TABLE}.show_schema_name,'NONPROD_V1')
      {% endif %}
    ;;
    hidden: no
  }

}
