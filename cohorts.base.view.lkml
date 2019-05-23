view: cohorts_base_binary {
  # inherist base and implements sql for binary flags (1 or 0)
  extends: [cohorts_base]

  dimension: current {
    type: number
    sql: CASE WHEN ${TABLE}."1" > 0 THEN 1 ELSE 0 END ;;
  }

  dimension: minus_1 {
    type: number
    sql: CASE WHEN ${TABLE}."2" > 0 THEN 1 ELSE 0 END ;;
  }

  dimension: minus_2 {
    type: number
    sql: CASE WHEN ${TABLE}."3" > 0 THEN 1 ELSE 0 END ;;
  }

  dimension: minus_3 {
    type: number
    sql: CASE WHEN ${TABLE}."4" > 0 THEN 1 ELSE 0 END ;;
  }

  dimension: minus_4 {
    type: number
    sql: CASE WHEN ${TABLE}."5" > 0 THEN 1 ELSE 0 END ;;
  }

}

view: cohorts_base_number {
  # inherist base and implements sql for simple numbers (counts)
  extends: [cohorts_base_binary]

  dimension: current {sql: COALESCE(${TABLE}."1", 0);;}
  dimension: minus_1 {sql: COALESCE(${TABLE}."2", 0);;}
  dimension: minus_2 {sql: COALESCE(${TABLE}."3", 0);;}
  dimension: minus_3 {sql: COALESCE(${TABLE}."4", 0);;}
  dimension: minus_4 {sql: COALESCE(${TABLE}."5", 0);;}
}


view: cohorts_base {

# fields needed to be exposed in extended explores, otherwise these fields are not available for dynamic naming of cohort labels
set: params {fields: [primary_key, governmentdefinedacademicterm, user_sso_guid_merged, dimension_current_name, subscription_state, dimension_minus_1_name, dimension_minus_2_name, dimension_minus_3_name, dimension_minus_4_name]}

set: cohort_term_fields {fields: [current, minus_1, minus_2, minus_3, minus_4, current_tiers, minus_1_tiers]}

set: marketing_fields {fields: [params*, cohort_term_fields*]}

derived_table: {sql: select 1;;}

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

dimension: primary_key {
  type: string
  primary_key: yes
  sql: ${user_sso_guid_merged} ;;
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
  label: "1) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_current_name._parameter_value | replace: '_', ' ' }}"
}

dimension: minus_1 {
  label: "2) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' 'capitalize }} - {{ dimension_minus_1_name._parameter_value | replace: '_', ' ' }}"
}

dimension: minus_2 {
  label: "3) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' 'capitalize }} - {{ dimension_minus_2_name._parameter_value | replace: '_', ' ' }}"
}

dimension: minus_3 {
  label: "4) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' 'capitalize }} - {{ dimension_minus_3_name._parameter_value | replace: '_', ' ' }}"
}

dimension: minus_4 {
  label: "5) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' 'capitalize }} - {{ dimension_minus_4_name._parameter_value | replace: '_', ' ' }}"
}


  dimension: current_tiers {
    label: "1) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_current_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
      when:
      {sql: ${current} = 0 ;;
        label: "$0.00" }
      when: {sql: ${current} < 60 ;;
        label: "$0.01-$59.99"}
      when: {sql: ${current} < 120 ;;
        label: "$60.00-$119.99"}
      when: {sql: ${current} < 180 ;;
        label: "$120.00-$179.99"}
      when: {sql: ${current} < 240 ;;
        label: "$180.00-$239.99"}
      else: "More than $240"
    }
    hidden: yes
  }

  dimension: minus_1_tiers {
    label: "2) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_minus_1_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
        when:
        {sql: ${minus_1} = 0 ;;
        label: "$0.00" }
        when: {sql: ${minus_1} < 60 ;;
        label: "$0.01-$59.99"}
        when: {sql: ${minus_1} < 120 ;;
        label: "$60.00-$119.99"}
        when: {sql: ${minus_1} < 180 ;;
        label: "$120.00-$179.99"}
        when: {sql: ${minus_1} < 240 ;;
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
