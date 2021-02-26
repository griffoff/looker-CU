view: study_tool_launch {
    derived_table: {
      explore_source: session_analysis {
        column: user_sso_guid { field: live_subscription_status.user_sso_guid }
        column: count { field: all_events.count }
        filters: {
          field: all_events.event_name
          value: "** STUDY_TOOLS_PAGE: LAUNCH **"
        }
      }
    }
    dimension: user_sso_guid {
      label: "Learner Profile - Live Subscription Status User SSO GUID"
      description: "Parimary user sso guid, after shadonw guid lookup and merge"
      hidden: yes
    }
    dimension: count {
      label: "Events # Events"
      description: "Measure for counting events (drill fields)"
      type: number
      hidden: yes
    }

    dimension: count_bucket {
      label: "# times study tool launched (bucket)"
      group_label: "Activity buckets"
      type: tier
      tiers: [0, 1, 2, 3]
      style: integer
      sql: ${count} ;;
      hidden: no

    }

    measure: users {
      type: count_distinct
      sql: ${user_sso_guid} ;;
      hidden: yes
    }


  }