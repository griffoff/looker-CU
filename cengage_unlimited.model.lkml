connection: "snowflake_prod"

include: "*.view.lkml"         # include all views in this project


include: "/core/common.lkml"





##### Raw Snowflake Tables #####
explore: additional_info_products {
  label: "Provisioned Products Buckets"
}

explore: raw_olr_provisioned_product {
  label: "CU Provisioned Product"

}

explore: provisioned_product {
  from: raw_olr_provisioned_product
  join: raw_subscription_event {
    sql_on: ${provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid} ;;
    relationship: many_to_one
  }

  join:  raw_vitalsource_event {
    sql_on: ${provisioned_product.user_sso_guid} = ${raw_vitalsource_event.user_sso_guid} ;;
    relationship: many_to_many
  }
}

explore: raw_subscription_event {
  join: raw_olr_provisioned_product {
    sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid};;
    relationship: many_to_one
  }
}
##### END  Raw Snowflake Tables #####



##### Dashboard #####
explore: ga_dashboarddata {
  label: "CU Dashboard"
  join: raw_subscription_event {
    sql_on: ${ga_dashboarddata.userssoguid} = ${raw_subscription_event.user_sso_guid} ;;
    type: full_outer
    relationship: many_to_one
  }
  join: raw_olr_provisioned_product {
    sql_on: ${raw_olr_provisioned_product.user_sso_guid} = ${raw_subscription_event.user_sso_guid};;
    relationship: many_to_one
  }
  }

explore: dashboard_use_over_time {}

explore: dashboard_use_over_time_bucketed {}

explore: dashboardbuckets {
  label: "CU Dashboard Actions Bucketed"
  join: ga_dashboarddata {
    sql_on: ${ga_dashboarddata.userssoguid}=${dashboardbuckets.userssoguid} ;;
    relationship: many_to_many
    type: left_outer
  }
}
##### End Dashboard #####



##### Fair Useage #####
explore: ebook_usage_aggregated {}
explore: ebook_usage_aggregated_by_week {}

explore: coursewares_activated_week {}
explore: coursewares_activated {}

explore: device_changes {}
explore: device_changes_all_time {}

explore: unique_cities_per_user_per_week{}
explore: unique_cities_per_user {}
explore: weeks_above_threshhold_cities {}

explore: courseware_activations_per_user {}

explore: fair_use_tracking {
  label: "Fair Use Tracking"
}

explore: indicators {
  label: "Indicators"

join: fair_use_indicators {
  sql_on: ${indicators.indicator_id} = ${fair_use_indicators.indicator_id};;
  relationship: one_to_many
}
join: fair_use_indicators_aggregated {
  sql_on: ${indicators.indicator_id} = ${fair_use_indicators_aggregated.indicator_count} ;;
  relationship: one_to_many
}
}

explore: fair_use_tracking_vitalsource {}

explore: fair_use_indicators {}

explore: fair_use_indicators_aggregated {
  label: "Fair Use Indicators agg"}

explore: ind {
  from: indicators
  label: "Ind"

  join: fair_use_indicators {
    sql_on: ${ind.indicator_id} = ${fair_use_indicators.indicator_id};;
    relationship: one_to_many
  }}

  explore:raw_fair_use_logins
  {
    label: "CMP Dashboard"
  }
##### End Fair Useage #####





##### Ebook Usage #####
  explore: ebook_usage_actions {
    join: raw_subscription_event {
      type: full_outer
      sql_on: ${ebook_usage_actions.user_sso_guid} = ${raw_subscription_event.user_sso_guid} ;;
      relationship: many_to_one
    }

    join: ebook_mapping {
      type: left_outer
      sql_on: ${ebook_usage_actions.event_action} = ${ebook_mapping.action} AND ${ebook_usage_actions.source} = ${ebook_mapping.source} ;;
      relationship: many_to_one
    }
  }
##### End Ebook Usage #####
