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
    group_label: "Active"
    description: "Active users are those who have had some activity within the past 30 days"
    type: yesno
    sql: ${date} >= DATEADD(day, -30, CURRENT_DATE()) ;;
    label: "User Active Flag"
  }
  dimension: active_desc {
    group_label: "Active"
    label: "User Active (Description)"
    description: "Active users are those who have had some activity within the past 30 days"
    type: string
    sql: CASE WHEN ${active} THEN 'Active' ELSE 'Inactive' END ;;

  }
}
