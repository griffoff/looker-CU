view: dashboard_bucketed {
    derived_table: {
      explore_source: ga_dashboarddata_aggregated {
        column: userssoguid {}
        column: Added_content {}
        column: test {}
      }
    }
    dimension: userssoguid {}
    dimension: Added_content {}
    dimension: test {}

  dimension: count_click_buckets {
    label: "Ga Dashboard Clicks by Action Buckets"
    type:  tier
    tiers: [1, 2, 5, 8, 11]
    style:  integer
    sql:  ${test} ;;
  }

  measure: count_users {
    type:  count_distinct
    sql: ${userssoguid} ;;

  }


  }
