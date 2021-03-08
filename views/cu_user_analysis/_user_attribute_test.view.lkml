access_grant: access_dev_data {
  user_attribute: access_dev_data
  allowed_values: [ "yes" ]
}

explore: _user_attribute_test {hidden:yes}
view: _user_attribute_test {

  sql_table_name: "DM_CUI_ACTIVATIONS".{% parameter schema_name %}."FACT_SUBSCRIPTION_STATE_CHANGE";;

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

    default_value: "PROD_V1"
    description: ""

    required_access_grants: [access_dev_data]
  }

  measure: new_subscription_count {
    type: sum
    sql: ${TABLE}."COUNT_NEW_SUBSCRIPTION";;
  }

  # dimension: show_schema_name {
  #   sql:
  #     {% if _user_attributes['access_dev_data'] == 'yes' %}
  #     -- {{ _user_attributes['access_dev_data'] }}
  #       ${TABLE}.show_schema_name
  #     {% else %} nullif(${TABLE}.show_schema_name,'NONPROD_V1')
  #     {% endif %}
  #   ;;
  #   hidden: no
  # }

}
