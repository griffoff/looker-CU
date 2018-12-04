include: "cengage_unlimited.model.lkml"
include: "/core/common.lkml"

view: learner_profile {
  view_label: "Learner Profile"
  sql_table_name: CU_USER_ANALYSIS.learner_profile ;;

  set: details {
    fields: [user_sso_guid, subscription_status, cu_subscription_length, subscription_start_date, subscription_end_date
      , non_courseware_net_value
      ,new_customer, first_activation_date]
  }

  dimension: user_sso_guid {
    primary_key: yes
    label: "User SSO GUID"
    link: {
      label: "See this user's journey"
      url: "/explore/cengage_unlimited/event_analysis?fields=all_events.product_platform,all_sessions.session_start_time,all_events.event_time,all_sessions.lat_lon,all_events.event_type,all_events.event_action,event_groups.event_group,all_events.event_name,all_events.event_data,all_events.sum_of_time_to_next_event&f[learner_profile_2.user_sso_guid]={{ value | url_encode }}&f[event_groups.event_group]=-Timers&sorts=all_events.event_time+desc&limit=500&toggle=vse"
    }
  }

  dimension: subscription_status {
    group_label: "CU Subscription"
    label: "Subscription status"
    sql: coalesce(${TABLE}.subscription_status, 'Never tried CU');;
    description: "Current CU Subscription State"
  }

  dimension: is_cu_subscriber {
    group_label: "Customer Type"
    hidden: no
    type: yesno
    sql: lower(${subscription_status}) = 'full access' ;;
  }

  dimension: cu_subscription_length {
    type: number
    group_label: "CU Subscription"
    label: "CU subscription Length"
    description: "Current length of CU subscription"
    sql: CASE WHEN datediff(month, ${subscription_start_date}, ${subscription_end_date}) = 3 THEN 4
            WHEN datediff(month, ${subscription_start_date}, ${subscription_end_date}) = 11 THEN 12
            WHEN datediff(month, ${subscription_start_date}, ${subscription_end_date}) = 23 THEN 24
            ELSE datediff(month, ${subscription_start_date}, ${subscription_end_date}) END;;
    value_format: "0 \m\o\n\t\h\s"
  }

  dimension_group: subscription_start {
    type: time
    timeframes: [date, week, month, month_name]
    group_label: "Current subscription state start date"
    description: "The user's current subscription state (trial or full) start date"
    sql:  ${TABLE}.subscription_start::timestamp_ntz ;;
  }

  dimension_group: subscription_end {
    type: time
    timeframes: [date, week, month, month_name]
    group_label: "Current subscription state end date"
    description: "The user's current subscription state (trial or full) end date"
  }

  dimension_group: first_activation {
    type: time
    timeframes: [raw, date, month, year]
    description: "The earliest date this user activated any product with Cengage"
    sql: ${TABLE}.first_activation_date ;;
    hidden: yes
  }

  dimension: is_new_customer {
    group_label: "Customer Type"
    hidden: yes
    type: yesno
    sql: ${first_activation_raw} > '2018-08-01' or ${first_activation_raw} is null;;
  }

  dimension: new_customer {
    group_label: "Customer Type"
    case: {
      when: {
        sql: ${is_new_customer} AND ${is_cu_subscriber};;
        label: "New cengage customer purchased CU"
      }
      when: {
        sql: ${is_new_customer} AND NOT ${is_cu_subscriber} ;;
        label: "New Customer purchased stand alone after CU released"
      }
      when: {
        sql: NOT ${is_new_customer} AND ${is_cu_subscriber} ;;
        label: "Returning customer purchased CU"
      }
      when: {
        sql: ${first_activation_raw} is null ;;
        label: "No subscription or Standalone"
      }
      when: {
        sql: NOT ${is_new_customer} AND NOT ${is_cu_subscriber} ;;
        label: "Returning customer purchased stand alone after CU released"
      }
    }
  }

  dimension: searches_with_results {
    group_label: "Searches"
    label: "# Searches with results"
    description: "Number of searches by this user that returned results"
  }

  dimension: searches_without_results {
    group_label: "Searches"
    label: "# Searches without results"
    description: "Number of searches by this user that did not return results"
  }

  dimension: searches_with_results_tier {
    group_label: "Searches"
    label: "# Searches with results (buckets)"
    type: tier
    tiers: [1, 10, 20, 30]
    style: integer
    sql: ${searches_with_results} ;;
    description: "Number of searches by this user that returned results"
  }

  dimension: searches_without_results_tier {
    group_label: "Searches"
    label: "# Searches without results (buckets)"
    type: tier
    tiers: [1, 10, 20, 30]
    style: integer
    sql: ${searches_without_results} ;;
    description: "Number of searches by this user that did not return results"
  }

  dimension: search_terms_with_results {
    group_label: "Searches"
    label: "Search terms with results"
    description: "A list of search terms searched by this user that returned results"
  }

  dimension: search_terms_without_results {
    group_label: "Searches"
    label: "Search terms without results"
    description: "A list of search terms searched by this user that did not return results"
  }

  dimension:  non_courseware_net_value {
    group_label: "Provisioned Products"
    type: number
    label: "Non-courseware net value"
    description: "Sum of the net price of all ebooks provisioned to this users dashboard where there was not an associated course key"
    value_format_name: usd_0
    sql: ${TABLE}.non_courseware_ebooks_net_price_value ;;
    alias: [non_courseware_ebooks_net_price_value]
    hidden: yes
  }

  dimension: courseware_net_value {
    group_label: "Provisioned Products"
    type: number
    label: "Courseware net value"
    description: "Total net price of all courseware provisioned to this users dashboard"
    value_format_name: usd_0
    sql:  ${TABLE}.courseware_ebooks_net_price_value ;;
    alias: [courseware_ebooks_net_price_value]
    hidden: yes
  }

  dimension: non_courseware_user {
    group_label: "Customer Type"
    sql: CASE
            WHEN ${non_courseware_net_value} > 0 AND ${courseware_net_value} > 0 THEN 'Courseware and non-courseware user'
           WHEN (${non_courseware_net_value} <= 0 OR ${non_courseware_net_value} IS NULL) AND ${courseware_net_value} > 0 THEN 'Courseware only user'
          WHEN ${non_courseware_net_value} > 0 AND (${courseware_net_value} <= 0 OR ${courseware_net_value} IS NULL) THEN 'Non-courseware only user'
            --WHEN ${non_courseware_net_value} is null and ${courseware_net_value} is null then 'No products in dashboard'
            ELSE 'No products added to dashboard'
                    END;;
    type: string
    description: "Does this person use just courseware or other products or both?"
  }

  measure: count {
    type: count
    label: "# Students"
    drill_fields: [details*]
  }



}
