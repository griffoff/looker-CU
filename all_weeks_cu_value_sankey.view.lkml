explore: all_weeks_cu_value_sankey {
}

view: all_weeks_cu_value_sankey {
    derived_table: {
      persist_for: "24 hours"
      explore_source: all_weeks_cu_value {
        column: user_sso_guid { field: all_weeks_cu_value.user_sso_guid }
        column: age_in_weeks { field: all_weeks_cu_value.age_in_weeks}
        column: cu_soft_value_tiers {field: all_weeks_cu_value.cu_soft_value_tiers}
        derived_column: week_0 {sql: cu_soft_value_tiers;;}
        derived_column: week_1 {sql: LEAD(cu_soft_value_tiers) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_2 {sql: LEAD(cu_soft_value_tiers, 2) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_3 {sql: LEAD(cu_soft_value_tiers, 3) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_4 {sql: LEAD(cu_soft_value_tiers, 4) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_5 {sql: LEAD(cu_soft_value_tiers, 5) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_6 {sql: LEAD(cu_soft_value_tiers, 6) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_7 {sql: LEAD(cu_soft_value_tiers, 7) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_8 {sql: LEAD(cu_soft_value_tiers, 8) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_9 {sql: LEAD(cu_soft_value_tiers, 9) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}
        derived_column: week_10 {sql: LEAD(cu_soft_value_tiers, 10) OVER (PARTITION BY user_sso_guid ORDER BY age_in_weeks);;}

        }
      }

    dimension: age_in_weeks {
      type: number
    }

    dimension: user_sso_guid {
      label: "Student Usage Metrics User Sso Guid"
      primary_key: yes
    }

  dimension: week_0 {
    type: string
  }

  dimension: week_1 {
    type: string
  }

  dimension: week_2 {
    type: string
  }

  dimension: week_3 {
    type: string
  }

  dimension: week_4 {
    type: string
  }

  dimension: week_5 {
    type: string
  }

  dimension: week_6 {
    type: string
  }

  dimension: week_7 {
    type: string
  }

  dimension: week_8 {
    type: string
  }

  dimension: week_9 {
    type: string
  }

  dimension: week_10 {
    type: string
  }

    measure: count {
      type:  count
    }
  }
