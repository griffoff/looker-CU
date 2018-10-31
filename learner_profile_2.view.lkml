include: "cengage_unlimited.model.lkml"

explore: learner_profile_2 {}

view: learner_profile_2 {
  view_label: "Learner Profile"
  sql_table_name: zpg.learner_profile ;;

  measure: frequency_avg_filterable {
    type: number
    sql: AVG(frequency) OVER () ;;}

  measure: intensity_avg_filterable {
    type: number
    sql: AVG(intensity) OVER ();;}

  measure: frequency_prank_filterable {
    type: number
    sql: PERCENT_RANK() OVER (ORDER BY frequency);;}

  measure: intensity_prank_filterable {
    type: number
    sql: PERCENT_RANK() OVER (ORDER BY intensity);;}

  dimension: frequency_avg {
    type: number
    }

  dimension: intensity_avg {
    type: number
    }

  dimension: frequency_prank {
    type: number
    }

  dimension: intensity_prank {
    type: number
    }


  dimension: user_sso_guid {
    primary_key: yes
  }

  dimension: subscription_status {}

  dimension: session_count {
    type: number
  }

  dimension: session_count_tier {
    type: tier
    tiers: [ 2, 3, 4, 5, 6, 7, 8, 9, 10]
    style: integer
    sql: ${TABLE}."SESSION_COUNT" ;;
  }

  dimension: active_user {
    type: string
    sql: CASE WHEN ${frequency} >= 2 AND ${recency} >= -14 AND ${intensity} > 4 THEN 'active' ELSE 'non-active' END;;
  }


  dimension: days_active {
    type: number
  }
  dimension: days_active_per_week {
    type: number
  }
  dimension: days_since_last_login {
    type: number
  }
  dimension: events_per_session {
    type: number
  }
  dimension_group: first_interaction {
    sql: ${TABLE}.first_event_time ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
  }
  dimension_group: latest_interaction {
    sql: ${TABLE}.latest_event_time ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
  }
  dimension: frequency {
    type: number
  }
  dimension: intensity {
    type: number
  }
  dimension: recency {
    type: number
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
  }

  measure: count {
    type: count
  }
}
