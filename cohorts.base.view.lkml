view: cohorts_base {

dimension: user_sso_guid_merged {
  type: string
  sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  hidden: yes
}

dimension: governmentdefinedacademicterm {
  type: string
  sql: ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ;;
  hidden: yes
}

dimension: subscription_state {
  type: string
  sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  hidden: yes
}

parameter: dimension_current_name {
  type: unquoted
  hidden: yes
  default_value: "Spring_2019"
}

parameter: dimension_minus_1_name {
  type: unquoted
  hidden: yes
  default_value: "Fall_2019"
}

parameter: dimension_minus_2_name {
  type: unquoted
  hidden: yes
  default_value: "Summer_2018"
}

parameter: dimension_minus_3_name {
  type: unquoted
  hidden: yes
  default_value: "Spring_2018"
}

parameter: dimension_minus_4_name {
  type: unquoted
  hidden: yes
  default_value: "Fall_2018"
}


dimension: current {
  type: number
  label: "1) {{ _view._name | replace: '_', ' ' | capitalize }} {{ dimension_current_name._parameter_value | replace: '_', ' ' }}"
  sql: COALESCE(${TABLE}."1", 0) ;;
}

dimension: minus_1 {
  type: number
  label: "2) {{ _view._name | replace: '_', ' ' | capitalize }} {{ dimension_minus_1_name._parameter_value | replace: '_', ' ' }}"
  sql:  COALESCE(${TABLE}."2", 0) ;;
}

dimension: minus_2 {
  type: number
  label: "3) {{ _view._name | replace: '_', ' ' | capitalize }} {{ dimension_minus_2_name._parameter_value | replace: '_', ' ' }}"
  sql: COALESCE(${TABLE}."3", 0) ;;
}

dimension: minus_3 {
  type: number
  label: "4) {{ _view._name | replace: '_', ' ' | capitalize }} {{ dimension_minus_3_name._parameter_value | replace: '_', ' ' }}"
  sql:  COALESCE(${TABLE}."4", 0);;
}

dimension: minus_4 {
  type: number
  label: "5) {{ _view._name | replace: '_', ' ' | capitalize }} {{ dimension_minus_4_name._parameter_value | replace: '_', ' ' }}"
  sql:  COALESCE(${TABLE}."5", 0) ;;
}


  dimension: current_tiers {
    label: "Spring 2019 tiers"
    case: {
      when:
      {sql: COALESCE(${TABLE}."1", 0) = 0 ;;
        label: "$0.00" }
      when: {sql: COALESCE(${TABLE}."1", 0) < 60 ;;
        label: "$0.01-$59.99"}
      when: {sql: COALESCE(${TABLE}."1", 0) < 120 ;;
        label: "$60.00-$119.99"}
      when: {sql: COALESCE(${TABLE}."1", 0) < 180 ;;
        label: "$120.00-$179.99"}
      when: {sql: COALESCE(${TABLE}."1", 0) < 240 ;;
        label: "$180.00-$239.99"}
      else: "More than $240"
    }
    hidden: yes
  }

  dimension: minus_1_tiers {
    label: "Fall 2019 tiers"
    case: {
        when:
        {sql: COALESCE(${TABLE}."2", 0) = 0 ;;
        label: "$0.00" }
        when: {sql: COALESCE(${TABLE}."2", 0) < 60 ;;
        label: "$0.01-$59.99"}
        when: {sql: COALESCE(${TABLE}."2", 0) < 120 ;;
        label: "$60.00-$119.99"}
        when: {sql: COALESCE(${TABLE}."2", 0) < 180 ;;
        label: "$120.00-$179.99"}
        when: {sql: COALESCE(${TABLE}."2", 0) < 240 ;;
        label: "$180.00-$239.99"}
        else: "More than $240"
        }
        hidden: yes
        }

   set: detail {
     fields: [
       user_sso_guid_merged,
       governmentdefinedacademicterm,
       subscription_state,
       current, minus_1, minus_2, minus_3, minus_4
     ]
   }
}
