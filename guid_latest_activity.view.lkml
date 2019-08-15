view: guid_latest_activity {
   derived_table: {
    explore_source: guid_platform_date_active {
      column: user_sso_guid { field: guid_platform_date_active.user_sso_guid }
      column: productplatform { field: guid_platform_date_active.productplatform }
      column: date { field: guid_platform_date_active.date }
      filters: {
        field: guid_platform_date_active.latest
        value: "Yes"
      }
    }

  }

  dimension: user_sso_guid {}
  dimension: date {
    label: "Latest Date of Activity"
  }
  dimension: active {
    description: "Active users are those who have has some activity within the past 7 days"
    type: yesno
    sql: ${date} >= DATEADD(day, -7, CURRENT_DATE()) ;;
  }
}
