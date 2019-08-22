view: guid_latest_activity {
   derived_table: {
    explore_source: guid_platform_date_active {
      column: user_sso_guid { field: guid_platform_date_active.user_sso_guid }
      column: date { field: guid_platform_date_active.date }
      filters: {
        field: guid_platform_date_active.latest
        value: "Yes"
      }
    }

  }

  dimension: user_sso_guid {hidden:yes}
  dimension: date {
    label: "Latest Date of Activity"
  }
  dimension: active {
    description: "Active users are those who have had some activity within the past 7 days"
    type: yesno
    sql: ${date} >= DATEADD(day, -7, CURRENT_DATE()) ;;
  }
}
