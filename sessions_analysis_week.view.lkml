view: sessions_analysis_week {
    derived_table: {
      explore_source: session_analysis {
        column: user_sso_guid {field: all_sessions.user_sso_guid }
        column: age_in_weeks { field: all_sessions.age_in_weeks }
        column: sum_courseware_events { field: all_sessions.sum_courseware_events }
        column: sum_dashboard_clicks { field: all_sessions.sum_dashboard_clicks }
        column: sum_ebook_events { field: all_sessions.sum_ebook_events }
        column: sum_partner_clicks { field: all_sessions.sum_partner_clicks }
        column: sum_searches { field: all_sessions.sum_searches }
        column: sum_cu_soft_value { field: all_sessions.sum_cu_soft_value }

      derived_column: cu_soft_value_prank {sql: PERCENT_RANK() OVER (ORDER BY sum_cu_soft_value) ;; }
      }
    }

    dimension: user_sso_guid {
    type: string
  }

    dimension: age_in_weeks {
      label: "CU User Analysis Age In Weeks"
      type: number
    }

    dimension: guid_week {
      type: string
      sql: user_sso_guid || age_in_weeks ;;
      primary_key: yes
    }

    dimension: sum_courseware_events {
      label: "CU User Analysis Sum Courseware Events"
      type: number
    }

    dimension: sum_dashboard_clicks {
      label: "CU User Analysis Sum Dashboard Clicks"
      type: number
    }

    dimension: sum_ebook_events {
      label: "CU User Analysis Sum Ebook Events"
      type: number
    }

    dimension: sum_partner_clicks {
      label: "CU User Analysis Sum Partner Clicks"
      type: number
    }

    dimension: sum_searches {
      label: "CU User Analysis Sum Searches"
      type: number
    }

    dimension: sum_cu_soft_value {
      label: "CU User Analysis Sum Cu Soft Value"
      type: number
    }

  dimension: cu_soft_value_prank {
    type: number
  }

  dimension: cu_soft_value_tiers{
    type: string
    sql: CASE WHEN ${cu_soft_value_prank} < .34 THEN 'LOW'
              WHEN ${cu_soft_value_prank} < .67 THEN 'MEDIUM'
              ELSE 'HIGH' END ;;
  }

  measure: count {
    type: count
  }

  }
