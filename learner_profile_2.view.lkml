include: "cengage_unlimited.model.lkml"

view: learner_profile_2 {
  view_label: "Learner Profile"
  sql_table_name: zpg.learner_profile ;;


  ### Dimension section ###

  dimension: frequency_avg {
    label: "Frequency average (over all GUIDs)"
    description: "Average frequency calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: intensity_avg {
    label: "Intensity average (over all GUIDs)"
    description: "Average intensity calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: frequency_prank {
    label: "Percentage ranked frequency (over all GUIDs)"
    description: "Percentage ranked frequency calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: intensity_prank {
    label: "Percentage ranked intensity (over all GUIDs)"
    description: "Percentage ranked intensity calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: days_since_first_login {
    type: number
    sql: -DATEDIFF(d, current_date(), ${first_interaction_date} ) ;;
    label: "Days since first login"
    description: "Calculated as the number of days since the user first logged in"
  }

  dimension: user_sso_guid {
    primary_key: yes
    label: "User SSO GUID"
  }

  dimension: subscription_status {
    label: "Subscription status"
  }

  dimension: session_count {
    label: "Session count"
    type: number
  }

  dimension: relative_day_number {
    label: "Relative day number"
    description: "Calculated as a unique count of dates starting from and including the first login"
    type: number
  }

  dimension: session_count_tier {
    type: tier
    tiers: [ 2, 3, 4, 5, 6, 7, 8, 9, 10]
    style: integer
    sql: ${TABLE}."SESSION_COUNT" ;;
    label: "Session count tier"
    description: "Tiers for bucketing data by session counts"
  }

  dimension: active_user {
    type: string
    sql: CASE WHEN ${frequency} >= 2 AND ${recency} >= -14 AND ${intensity} > 4 THEN 'active' ELSE 'non-active' END;;
    label: "Active user status"
    description: "A user is active when they have a frequency >= 2, a recency >= 14, and an intensity > 4"
  }

  dimension: days_active {
    type: number
    label: "Total days active"
    description: "Calculated as the total number of days a user was active"
  }
  dimension: days_active_per_week {
    type: number
    label: "Days active per week"
    description: "Calculated as the average number of days a user was active per week"
  }
  dimension: days_since_last_login {
    type: number
    label: "Days since last login"
    description: "Calculated as the number of days since the user last logged in"
  }
  dimension: events_per_session {
    type: number
    label: "Events per session"
    description: "Calculated as the average number of events per session by a user"
  }
  dimension_group: first_interaction {
    sql: ${TABLE}.first_event_time ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
    label: "First interaction timestamp"
    description: "The time components of the timestamp when the user first logged in"
  }
  dimension_group: latest_interaction {
    sql: ${TABLE}.latest_event_time ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
    label: "Latest interaction timestamp"
    description: "The time components of the timestamp when the user most recently logged in"
  }
  dimension: frequency {
    type: number
     label: "Frequency"
     description: "Calculated as the average times a user logs in per week"
  }
  dimension: intensity {
    type: number
    label: "Intensity"
    description: "Calculated as the average number of events per session by the user"
  }
  dimension: recency {
    type: number
    label: "Recency"
    description: "Calculated as the number of days since the user last logged in"
  }

  dimension: total_user_duration {
    type:  number
    sql: total_user_duration  / (60 * 60 * 24) ;;
    value_format_name: duration_hms
    label: "Total user duration"
    description: "The total duration a user has spent doing something on one of the platforms"
  }

  dimension: usage_category {
    case: {
      when: {
        sql: ${frequency_prank} > 0.6  and ${intensity_prank} > 0.6 ;;
        label: "High Usage F AND I"
      }
      when: {
        sql: ${frequency_prank} > 0.6  or ${intensity_prank} > 0.6 ;;
        label: "High Usage F OR I"
      }
      when: {
        sql: ${frequency_prank} < 0.4  or ${intensity_prank} < 0.4 ;;
        label: "Low Usage"
      }
      else: "Medium Usage"
    }
    group_label: "Usage category"
    description: "Usage categories for bucketing data by how frequently and intensly a user uses CU relative to other users"
  }

  dimension: contract_ids {}
  dimension: subscription_start {}
  dimension: subscription_end {}
  dimension: products {}
  dimension: searches_with_results {}
  dimension: searches_without_results {}
  dimension: search_terms_with_results {}
  dimension: search_terms_without_results {}
  dimension: faq_clicks {}


### Measure's section ###


  measure: frequency_avg_filterable {
    label: "Average frequency"
    description: "Average frequency calulcated accorss querried population (filtered results)"
    type: number
    sql: AVG(frequency) OVER () ;;}

  measure: intensity_avg_filterable {
    label: "Average intensity"
    description: "Average intensity calulcated accorss querried population (filtered results)"
    type: number
    sql: AVG(intensity) OVER ();;}

  measure: frequency_prank_filterable {
    label: "Percentage ranked frequency"
    description: "Percentage ranked frequency calulcated accorss querried population (filtered results)"
    type: number
    sql: PERCENT_RANK() OVER (ORDER BY frequency);;}

  measure: intensity_prank_filterable {
    label: "Percentage ranked intensity"
    description: "Percentage ranked intensity calulcated accorss querried population (filtered results)"
    type: number
    sql: PERCENT_RANK() OVER (ORDER BY intensity);;}

  measure: count {
    type: count}

  measure: average {
    type:  average
  }
}
