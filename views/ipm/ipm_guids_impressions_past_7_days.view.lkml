include: "/models/IPM.model.lkml"

explore: ipm_guids_impressions_past_7_days {}

view: ipm_guids_impressions_past_7_days {
  view_label: "IPM Guids Impressions Last 7 Days"
  derived_table: {
    explore_source: ipm_campaign_analysis {
      column: user_sso_guid { field: ipm_browser_event.user_sso_guid }
      filters: {
        field: ipm_browser_event.local_est_date
        value: "7 days"
      }
      filters: {
        field: ipm_browser_event.displayed_count
        value: ">0"
      }
    }
  }
  dimension: user_sso_guid {
    label: "IPM Events User Sso Guid"
  }

  set: marketing_fields {
    fields: [ipm_guids_impressions_past_7_days.user_sso_guid]
  }

}
