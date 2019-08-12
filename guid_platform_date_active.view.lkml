# If necessary, uncomment the line below to include explore_source.

# include: "cengage_unlimited.model.lkml"

view: guid_platform_date_active {
  derived_table: {
    explore_source: session_analysis {
      column: user_sso_guid { field: live_subscription_status.user_sso_guid }
      column: productplatform { field: dim_productplatform.productplatform }
      column: local_date { field: all_events.local_date }
      column: count { field: all_events.count }
      column: event_duration_total { field: all_events.event_duration_total }
      derived_column: latest {sql: ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY local_date DESC) = 1;;}
      derived_column: latest_by_platform {sql: ROW_NUMBER() OVER (PARTITION BY user_sso_guid, productplatform ORDER BY local_date DESC) = 1;;}
      filters: {
        field: all_events.local_date
        value: "NOT NULL"
      }
    }

  }
  dimension: user_sso_guid {
    label: "Learner Profile User SSO GUID"
  }
  dimension: latest {
    type: yesno
  }
  dimension: latest_by_platform {
    type: yesno
  }
  dimension: productplatform {
    label: "Product Platform name"
    description: "MindTap, Aplia, CNOW, etc."
  }
  dimension: local_date {
    label: "Events Event Date"
    description: "Components of the events local timestamp"
    type: date
  }
  dimension: count {
    label: "Events # Events"
    description: "Measure for counting events (drill fields)"
    type: number
  }
  dimension: event_duration_total {
    label: "Events Total Time Active"
    value_format: "hh:mm:ss"
    type: number
  }
  measure: average_time_spent_per_student_per_day {
    type: average
    sql: ${event_duration_total} ;;
    value_format: "hh:mm:ss"
  }
}
