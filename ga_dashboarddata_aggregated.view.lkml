
view: ga_dashboarddata_aggregated {
      derived_table: {
        explore_source: ga_dashboarddata {
          column: Added_content {}
          column: userssoguid {}
          column: count {}
        }
    }

    dimension: Added_content {
      label: "Ga Dashboarddata Event Dimensions"
    }
    dimension: count {
      type: number
    }
    dimension: userssoguid {}

  dimension: count_click_buckets {
    label: "Ga Dashboard Clicks by Action Buckets"
    type:  tier
    tiers: [1, 2, 5, 8, 11]
    style:  integer
    sql:  ${count} ;;
  }

  measure: count_users {
    type:  count_distinct
    sql: ${userssoguid} ;;

  }

}
