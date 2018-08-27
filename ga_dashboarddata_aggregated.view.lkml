

view: ga_dashboarddata_aggregated {
    derived_table: {
      explore_source: ga_dashboarddata {
        column: userssoguid {}
        column: Added_content {}
        column: catalog_clicks {}
        column: one_month_chegg_clicks {}
        column: courseware_launch {}
        column: ebook_launch {}
        column: faq_clicks {}
        column: noresult_search {}
        column: rent_chegg_clicks {}
        column: Search_events {}
        column: support_clicks {}
        column: access_code_events {}
        column: course_key_events {}
        column: cu_video_events {}
      }
    }

  dimension: userssoguid  {}
  dimension: Added_content {}


    dimension: catalog_clicks {
      label: "Ga Dashboarddata # Clicks on catalog"
      type: number
    }
    dimension: one_month_chegg_clicks {
      label: "Ga Dashboarddata # 1 Month Chegg Clicks"
      type: number
    }
    dimension: courseware_launch {
      label: "Ga Dashboarddata # Courseware launched"
      type: number
    }
    dimension: ebook_launch {
      label: "Ga Dashboarddata # eBooks launched"
      type: number
    }
    dimension: faq_clicks {
      label: "Ga Dashboarddata # FAQ clicks"
      type: number
    }
    dimension: noresult_search {
      label: "Ga Dashboarddata # No results search"
      type: number
    }
    dimension: rent_chegg_clicks {
      label: "Ga Dashboarddata # Rent From Chegg Clicks"
      type: number
    }
    dimension: Search_events {
      label: "Ga Dashboarddata # searchs"
      type: number
    }
    dimension: support_clicks {
      label: "Ga Dashboarddata # support clicks"
      type: number
    }
    dimension: access_code_events {
      label: "Ga Dashboarddata Access Code Registrations"
      type: number
    }
    dimension: course_key_events {
      label: "Ga Dashboarddata Course Key Registrations"
      type: number
    }
    dimension: cu_video_events {
      label: "Ga Dashboarddata CU video viewed"
      type: number
    }

    dimension: test {
      sql:  ${catalog_clicks} + ${one_month_chegg_clicks} + ${courseware_launch} + ${ebook_launch} + ${faq_clicks} + ${noresult_search} + ${rent_chegg_clicks} + ${Search_events} + ${support_clicks} + ${access_code_events} + ${course_key_events} +  ${cu_video_events};;
    }

  }
