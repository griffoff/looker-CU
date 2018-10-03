include: "cengage_unlimited.model.lkml"

view: learner_profile {
    view_label: "Learner Profile"
    derived_table: {
      explore_source: all_events {
        column: user_sso_guid {}
        column: session_count {}
        column: days_active {}
        column: days_active_per_week {}
        column: days_since_last_login {}
        column: events_per_session {}
        column: first_event_time {}
        column: latest_event_time {}
        column: frequency {}
        column: intensity {}
        column: recency {}
        column: subscription_status {field:student_subscription_status.subscription_status}

        derived_column: frequency_avg {sql: AVG(frequency) OVER ();;}
        derived_column: intensity_avg {sql: AVG(intensity) OVER ();;}

        derived_column: frequency_prank {sql: PERCENT_RANK() OVER (ORDER BY frequency);;}
        derived_column: intensity_prank {sql: PERCENT_RANK() OVER (ORDER BY intensity);;}
      }

      persist_for: "6 hours"
    }

    dimension: user_sso_guid {
      primary_key: yes
    }
    dimension: subscription_status {}
    dimension: session_count {
      type: number
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
