explore: usage_by_week {}

view: usage_by_week {
    derived_table: {
      explore_source: session_analysis {
        column: user_sso_guid { field: all_events.user_sso_guid }
        column: recency { field: all_events.recency }
        column: intensity { field: all_events.intensity }
        column: frequency { field: all_events.frequency }
        column: event_week { field: all_events.event_week }
        column: usage_score { field: all_events.usage_score }
        column: usage_score_prank { field: all_events.usage_score_prank }
        filters: {
          field: learner_profile.subscription_status
          value: "Full Access"
        }
      }
    }
    dimension: user_sso_guid {
      label: "User Events User SSO GUID"
    }
    dimension: recency {
      label: "User Events Recency"
      description: "Calculated as the number of days since the last login"
      type: number
    }
    dimension: intensity {
      label: "User Events Intensity"
      description: "Calculated as the average number of events per session"
      type: number
    }
    dimension: frequency {
      label: "User Events Frequency"
      description: "Calculated as the average number of days active per week"
      type: number
    }
    dimension: event_week {
      label: "User Events Event timestamp UTC Week"
      description: "Components of the events timestamp stored in TZ format"
      type: date_week
    }
    dimension: usage_score {
      label: "User Events Usage score"
      type: number
    }
    dimension: usage_score_prank {
      label: "User Events Usage Score Prank"
      type: number
    }

  dimension: usage_classification{
    type: string
    sql: CASE WHEN ${usage_score_prank} < .34 THEN 'LOW'
              WHEN ${usage_score_prank} < .67 THEN 'MEDIUM'
              ELSE 'HIGH' END ;;
  }


    }
