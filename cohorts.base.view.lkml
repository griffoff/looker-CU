include: "datagroups.lkml"

view: cohorts_base {
  extension: required

# fields needed to be exposed in extended explores, otherwise these fields are not available for dynamic naming of cohort labels
  set: params {fields: [primary_key, governmentdefinedacademicterm, user_sso_guid_merged, dimension_current_name, subscription_state, dimension_minus_1_name, dimension_minus_2_name, dimension_minus_3_name, dimension_minus_4_name]}

  set: cohort_term_fields {fields: [current, minus_1, minus_2, minus_3, minus_4, current_tiers, minus_2_tiers,  minus_1_tiers, current_tiers_time, minus_1_tiers_time, minus_2_tiers_time, current_tiers_times, minus_1_tiers_times, minus_2_tiers_times]}

  set: other_fields {fields: []}

  set: marketing_fields {fields: [params*, cohort_term_fields*, other_fields*]}

  derived_table: {sql: select 1;; datagroup_trigger: cu_user_analysis}

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
    default_value: "Fall_2020"
  }

  parameter: dimension_minus_1_name {
    type: unquoted
    hidden: yes
    default_value: "Summer_2019"
  }

  parameter: dimension_minus_2_name {
    type: unquoted
    hidden: yes
    default_value: "Spring_2019"
  }

  parameter: dimension_minus_3_name {
    type: unquoted
    hidden: yes
    default_value: "Fall_2019"
  }

  parameter: dimension_minus_4_name {
    type: unquoted
    hidden: yes
    default_value: "Summer_2018"
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

  dimension: minus_2_tiers {
    label: "2) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_minus_2_name._parameter_value | replace: '_', ' ' }} tiers"
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

  dimension: current_tiers_time {
    label: "1) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_current_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
      when:
      {sql: ${current} = 0 ;;
        label: "0. No time in platform" }
      when: {sql: ${current} < 60 ;;
        label: "1. Less than an hour in platform"}
      when: {sql: ${current} < 120 ;;
        label: "2. Between 1 and 2 hours in platform"}
      when: {sql: ${current} < 180 ;;
        label: "3. Between 2 and 3 hours in platform"}
      when: {sql: ${current} < 240 ;;
        label: "4. Between 3 and 4 hours in platform"}
      else: "5. More than 4 hours in platform"
    }
    hidden: yes
  }

  dimension: minus_1_tiers_time {
    label: "2) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_minus_1_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
      when:
      {sql: ${minus_1} = 0 ;;
        label: "0. No time in platform" }
      when: {sql: ${minus_1} < 60 ;;
        label: "1. Less than an hour in platform"}
      when: {sql: ${minus_1} < 120 ;;
        label: "2. Between 1 and 2 hours in platform"}
      when: {sql: ${minus_1} < 180 ;;
        label: "3. Between 2 and 3 hours in platform"}
      when: {sql: ${minus_1} < 240 ;;
        label: "4. Between 3 and 4 hours in platform"}
      else: "5. More than 4 hours in platform"
    }
    hidden: yes
  }


  dimension: minus_2_tiers_time {
    label: "2) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_minus_2_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
      when:
      {sql: ${minus_2} = 0 ;;
        label: "0. No time in platform" }
      when: {sql: ${minus_2} < 60 ;;
        label: "1. Less than an hour in platform"}
      when: {sql: ${minus_2} < 120 ;;
        label: "2. Between 1 and 2 hours in platform"}
      when: {sql: ${minus_2} < 180 ;;
        label: "3. Between 2 and 3 hours in platform"}
      when: {sql: ${minus_2} < 240 ;;
        label: "4. Between 3 and 4 hours in platform"}
      else: "5. More than 4 hours in platform"
    }
    hidden: yes
  }

  dimension: current_tiers_times {
    label: "1) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_current_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
      when:
      {sql: ${current} = 0 ;;
        label: "0. None" }
      when: {sql: ${current} < 10 ;;
        label: "1. Between 1 and 9 times"}
      when: {sql: ${current} < 50 ;;
        label: "2. Between 10 and 49 times"}
      when: {sql: ${current} < 100 ;;
        label: "3. Between 50 and 99 times"}
      when: {sql: ${current} < 200 ;;
        label: "4. Between 100 and 199 times"}
      else: "5. 200 or more times"
    }
    hidden: yes
  }

  dimension: minus_1_tiers_times {
    label: "2) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_minus_1_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
      when:
      {sql: ${minus_1} = 0 ;;
        label: "0. None" }
      when: {sql: ${minus_1} < 10 ;;
        label: "1. Between 1 and 9 times"}
      when: {sql: ${minus_1} < 50 ;;
        label: "2. Between 10 and 49 times"}
      when: {sql: ${minus_1} < 100 ;;
        label: "3. Between 50 and 99 times"}
      when: {sql: ${minus_1} < 200 ;;
        label: "4. Between 100 and 199 times"}
      else: "5. 200 or more times"
    }
    hidden: yes
  }

  dimension: minus_2_tiers_times {
    label: "3) {{ _view._name | replace: 'cohorts', '' | replace: 'cohort', '' | replace: '_', ' ' | remove_first: ' ' | capitalize }} - {{ dimension_minus_2_name._parameter_value | replace: '_', ' ' }} tiers"
    case: {
      when:
      {sql: ${minus_2} = 0 ;;
        label: "0. None" }
      when: {sql: ${minus_2} < 10 ;;
        label: "1. Between 1 and 9 times"}
      when: {sql: ${minus_2} < 50 ;;
        label: "2. Between 10 and 49 times"}
      when: {sql: ${minus_2} < 100 ;;
        label: "3. Between 50 and 99 times"}
      when: {sql: ${minus_2} < 200 ;;
        label: "4. Between 100 and 199 times"}
      else: "5. 200 or more times"
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

view: cohorts_base_binary {
  extension: required
  # inherist base and implements sql for binary flags (1 or 0)
  extends: [cohorts_base]

  dimension: current {
    type: string
    sql: CASE WHEN ${TABLE}."1" > 0 THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: minus_1 {
    type: string
    sql: CASE WHEN ${TABLE}."2" > 0 THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: minus_2 {
    type: string
    sql: CASE WHEN ${TABLE}."3" > 0 THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: minus_3 {
    type: string
    sql: CASE WHEN ${TABLE}."4" > 0 THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: minus_4 {
    type: string
    sql: CASE WHEN ${TABLE}."5" > 0 THEN 'Yes' ELSE 'No' END  ;;
  }

}

view: cohorts_base_number {
  extension: required
  # inherist base and implements sql for simple numbers (counts)
  extends: [cohorts_base_binary]


  dimension: current {sql: COALESCE(${TABLE}."1", 0);;}
  dimension: minus_1 {sql: COALESCE(${TABLE}."2", 0);;}
  dimension: minus_2 {sql: COALESCE(${TABLE}."3", 0);;}
  dimension: minus_3 {sql: COALESCE(${TABLE}."4", 0);;}
  dimension: minus_4 {sql: COALESCE(${TABLE}."5", 0);;}
}

view: cohorts_base_string {
  extension: required
  extends: [cohorts_base]

  dimension: current {sql: ${TABLE}."1"::STRING;;}
  dimension: minus_1 {sql: ${TABLE}."2"::STRING;;}
  dimension: minus_2 {sql: ${TABLE}."3"::STRING;;}
  dimension: minus_3 {sql: ${TABLE}."4"::STRING;;}
  dimension: minus_4 {sql: ${TABLE}."5"::STRING;;}
}


  view: cohorts_base_events {
    extension: required

#     dimension: user_sso_guid_merged {}

    set: marketing_fields {fields: [params*, cohort_term_fields*, other_fields*]}

    extends: [cohorts_base_number]

    parameter: events_to_include {
      type: string
      default_value: ""
      hidden: yes
      # list values as comma separated list, this will be passed into a SQL "in" operator
      # e.g. "Event Name 1, Event Name 2"
      # or just "Event Name 1" if there is only 1 option
    }

    parameter: aggregation {
      type: unquoted
      default_value: ""
      hidden: yes
      # How do you want to aggregate the values ? SUM, MAX, COUNT, etc.
    }



    set: other_fields {fields: [events_to_include, aggregation]}

    derived_table: {
#       persist_for: "60 minutes"
      sql:
          SELECT
            user_sso_guid_merged
            ,{{ aggregation._parameter_value }} (CASE WHEN terms_chron_order_desc = 1 THEN 1 END) AS "1"
             ,{{ aggregation._parameter_value }} (CASE WHEN terms_chron_order_desc = 2 THEN 1 END) AS "2"
            ,{{ aggregation._parameter_value }} (CASE WHEN terms_chron_order_desc = 3 THEN 1 END) AS "3"
            ,{{ aggregation._parameter_value }} (CASE WHEN terms_chron_order_desc = 4 THEN 1 END) AS "4"
            ,{{ aggregation._parameter_value }} (CASE WHEN terms_chron_order_desc = 5 THEN 1 END) AS "5"
         FROM ${cohorts_user_term_subscriptions.SQL_TABLE_NAME} s
         INNER JOIN ${all_events.SQL_TABLE_NAME} e
                ON s.user_sso_guid_merged = e.user_sso_guid
                AND s.start_date < e.event_time
                AND s.end_date > e.event_time
                AND e.event_name in ( {{ events_to_include._parameter_value | replace: ", ", "," | replace: ",", "', '" }})
         /*
              --Is this necessary?
              INNER JOIN ${user_courses.SQL_TABLE_NAME} u
                ON s.user_sso_guid_merged = u.user_sso_guid
              WHERE s.subscription_state = 'full_access'
              */
         GROUP BY 1
        ;;
    }
}

view: cohorts_base_events_count {
  extension: required
  extends: [cohorts_base_events]

  parameter: aggregation {
    default_value: "sum"
  }

}

view: cohorts_base_events_binary {
  extension: required
  extends: [cohorts_base_events]

  parameter: aggregation {
    default_value: "max"
  }

}
