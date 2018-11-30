include: "cengage_unlimited.model.lkml"
include: "/core/common.lkml"

view: learner_profile_prod {
  view_label: "Learner Profile"
  sql_table_name: CU_USER_ANALYSIS.learner_profile ;;


  set: details {
    fields: [user_sso_guid, subscription_status, cu_subscription_length, subscription_start_date, subscription_end_date
      ,total_products_net_value_tier, non_courseware_net_value
      ,courses_enrolled, new_customer, first_activation_date
      ,products_added]
  }

  ### Dimension section ###
  dimension: courses {
    group_label: "Courses"
    label: "Course Keys"
    description: "List of course keys the user has"
  }

  dimension: courses_enrolled {
    group_label: "Courses"
    type: number
    label: "# Courses Enrolled"
    description: "Number of courses the user has enrolled in (course keys with event action: OLR enrollment)"
    sql: ${TABLE}.unique_courses ;;
    alias: [unique_courses]
  }

  dimension: courses_enrolled_tier {
    group_label: "Courses"
    type: tier
    style: integer
    tiers: [1, 2, 3, 5]
    sql: ${courses_enrolled} ;;
    label: "# Courses Enrolled (buckets)"
    description: "Number of courses the user has enrolled in (course keys with event action: OLR enrollment) bucketed"
  }

  dimension: products_added {
    group_label: "Provisioned Products"
    label: "products added"
    description: "List of all iac_isbn provisioned to dashboard from the provisioned product table"
    drill_fields: [details*]
    sql: array_to_string(${TABLE}.all_products_add, ', ') ;;
    alias: [all_products_add]
  }

  dimension: products_added_count {
    group_label: "Provisioned Products"
    type: number
    label: "# products"
    sql: array_size(${TABLE}.all_products_add) ;;
    description: "Number of different iac_isbn provisioned to dashboard"
  }

  dimension: products_added_tier {
    group_label: "Provisioned Products"
    label: "# products (buckets)"
    type: tier
    style: integer
    tiers: [1, 2, 5, 10]
    sql: ${products_added_count} ;;
  }

  dimension: total_products_net_value {
    group_label: "Provisioned Products"
    label: "Total net value"
    description: "Total net price of all products provisioned to this users dashboard"
    value_format_name: usd_0
    sql: ${TABLE}.total_ebooks_net_price_value ;;
    alias: [total_ebooks_net_price_value]
  }

  dimension: total_products_net_value_tier {
    group_label: "Provisioned Products"
    label: "Total net value (buckets)"
    type: tier
    style: integer
    tiers: [120, 200, 300, 500, 1000]
    sql: ${total_products_net_value} ;;
    value_format_name: usd_0
  }

  dimension: courseware_net_value {
    group_label: "Provisioned Products"
    type: number
    label: "Courseware net value"
    description: "Total net price of all courseware provisioned to this users dashboard"
    value_format_name: usd_0
    sql:  ${TABLE}.courseware_ebooks_net_price_value ;;
    alias: [courseware_ebooks_net_price_value]
  }

  dimension_group: time_since_first_log {
    group_label: "Time since first event"
    sql_start: ${first_interaction_time} ;;
    sql_end: ${all_events.event_time} ;;
    type: duration
    intervals: [ hour, day, week, month]
  }

  dimension: courseware_net_value_tier {
    group_label: "Provisioned Products"
    label: "Courseware net value (buckets)"
    type: tier
    style: integer
    tiers: [120, 200, 300, 500, 1000]
    sql: ${courseware_net_value} ;;
    value_format_name: usd_0
  }

  dimension:  non_courseware_net_value {
    group_label: "Provisioned Products"
    type: number
    label: "Non-courseware net value"
    description: "Sum of the net price of all ebooks provisioned to this users dashboard where there was not an associated course key"
    value_format_name: usd_0
    sql: ${TABLE}.non_courseware_ebooks_net_price_value ;;
    alias: [non_courseware_ebooks_net_price_value]
  }

  dimension: non_courseware_net_value_tier {
    group_label: "Provisioned Products"
    label: "Non-courseware net value (buckets)"
    type: tier
    style: integer
    tiers: [120, 200, 300, 500, 1000]
    sql: ${non_courseware_net_value} ;;
    value_format_name: usd_0
  }


  dimension: WA_activations {
    type: number
    group_label: "Activations"
    label: "WebAssign Activations"
    sql: coalesce(${TABLE}.WA_Activations, 0);;
    description: "Number of WebAssign activations prior to CU launch on 08/01/2018"
  }

  dimension: MT_activations {
    type: number
    group_label: "Activations"
    label: "MindTap activations"
    sql: coalesce(${TABLE}.MT_Activations, 0) ;;
    description: "Number of Mindtap activations prior to CU launch on 08/01/2018"
  }

  dimension: other_activations {
    type: number
    group_label: "Activations"
    label: "Other activations"
    sql: coalesce(${TABLE}.other_Activations, 0);;
    description: "Number of activations that aren't WebAssign or MindTap prior to CU launch on 08/01/2018"
  }

  dimension_group: first_activation {
    type: time
    timeframes: [raw, date, month, year]
    description: "The earliest date this user activated any product with Cengage"
    sql: ${TABLE}.first_activation_date ;;
  }

#   dimension: new_customer {
#     type: string
#     sql: CASE WHEN first_activation_date > '2018-08-01' AND subscription_status IN ('Full Access', 'Trial Access') THEN 'New Cengage Customer'
#               WHEN first_activation_date > '2018-08-01' AND subscription_status NOT IN ('Full Access', 'Trial Access') THEN 'Stand alone purchase after CU released'
#               WHEN first_activation_date < '2018-08-01' AND subscription_status IN ('Full Access', 'Trial Access')  THEN 'Returning Customer purchased CU'
#               WHEN first_activation_date < '2018-08-01' AND subscription_status NOT IN ('Full Access', 'Trial Access' )    THEN 'Returning Customer purchased stand alone after CU released'
#               ELSE 'other' END
#               ;;
#     description: "Type of customer: new/returning/etc."
#   }

  dimension: is_new_customer {
    group_label: "Customer Type"
    hidden: no
    type: yesno
    sql: ${first_activation_raw} > '2018-08-01' or ${first_activation_raw} is null;;
  }

  dimension: is_cu_subscriber {
    group_label: "Customer Type"
    hidden: no
    type: yesno
    sql: lower(${subscription_status}) = 'full access' ;;
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



dimension: latest_activation_date {
  label: "Latest Activation Date"
  description: "Most recent activation date"
}


dimension: frequency_avg {
  group_label: "RFI"
  label: "Frequency average (over all GUIDs)"
  description: "Average frequency calulcated accross all GUIDs (even if filters are applied)"
  type: number
}

dimension: intensity_avg {
  group_label: "RFI"
  label: "Intensity average (over all GUIDs)"
  description: "Average intensity calulcated accross all GUIDs (even if filters are applied)"
  type: number
}

dimension: frequency_prank {
  group_label: "RFI"
  label: "Percentage ranked frequency (over all GUIDs)"
  description: "Percentage ranked frequency calulcated accross all GUIDs (even if filters are applied)"
  type: number
}

dimension: intensity_prank {
  group_label: "RFI"
  label: "Percentage ranked intensity (over all GUIDs)"
  description: "Percentage ranked intensity calulcated accross all GUIDs (even if filters are applied)"
  type: number
}

dimension: days_since_first_login {
  hidden: no
  type: number
  sql: -DATEDIFF(d, current_date(), ${first_interaction_date} ) ;;
  label: "Days since first login"
  description: "Calculated as the number of days since the user first logged in"
}

dimension_group: time_since_first_login {
  group_label: "Time since first login"
  type: duration
  sql_start: ${TABLE}.first_interaction_date ;;
  sql_end: current_date() ;;
  intervals: [day, week, month, year]
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

dimension: contract_ids {
  group_label: "CU Subscription"
  label: "Contract IDs"
  description: "All of the contract IDs attached to this user"
}

dimension: cu_subscription_length {
  type: number
  group_label: "CU Subscription"
  label: "CU subscription Length"
  description: "Current length of CU subscription"
  sql: datediff(month, ${subscription_start_date}, ${subscription_end_date}) ;;
  value_format: "0 \m\o\n\t\h\s"
}


dimension: active_user {
  type: string
  sql: CASE WHEN ${frequency} >= 2 AND ${recency} >= -14 AND ${intensity} > 4 THEN 'active' ELSE 'non-active' END;;
  label: "Active user status"
  description: "A user is active when they have a frequency >= 2, a recency >= 14, and an intensity > 4"
}

dimension: relative_day_number {
  label: "# of different days (unique dates) logged in to CU"
  description: "Calculated as a unique count of dates starting from and including the first login"
  type: number
}
# TODO: is above the same as below?
dimension: days_active {
  group_label: "Days Active"
  type: number
  label: "Total days active"
  description: "Calculated as the total number of days a user was active"
}
dimension: days_active_per_week {
  type: number
  group_label: "Days Active"
  label: "Days active per week"
  description: "Calculated as the average number of days a user was active per week"
  value_format_name: decimal_1
}
dimension: days_active_per_week_tier {
  type: tier
  style: integer
  tiers: [1, 2, 3, 5]
  sql: ${days_active_per_week} ;;
  group_label: "Days Active"
  label: "Days active per week (bucket)"
  description: "Calculated as the average number of days a user was active per week"
}

dimension: days_since_last_login {
  hidden: yes
  type: number
  label: "Days since last login"
  description: "Calculated as the number of days since the user last logged in"
}
dimension_group: time_since_last_login {
  group_label: "Time since latest login"
  type: duration
  sql_start: ${TABLE}.latest_event_time ;;
  sql_end: current_date() ;;
  intervals: [hour, day, week, month]
}
dimension: events_per_session {
  type: number
  label: "Events per session"
  description: "Calculated as the average number of events per session by a user"
}
dimension_group: first_interaction {
  sql: ${TABLE}.first_event_time
  type: time
  timeframes: [raw, time, date, day_of_week, month, hour]
  description: "The time components of the timestamp when the user first logged in"
}
dimension_group: latest_interaction {
  sql: ${TABLE}.latest_event_time ;;
  type: time
  timeframes: [time, date, day_of_week, month, hour]
  description: "The time components of the timestamp when the user most recently logged in"
}
dimension: frequency {
  group_label: "RFI"
  type: number
  label: "Frequency"

  description: "Calculated as the average times a user logs in per week"
}
dimension: intensity {
  group_label: "RFI"
  type: number
  label: "Intensity"
  description: "Calculated as the average number of events per session by the user"
}
dimension: recency {
  group_label: "RFI"
  type: number
  label: "Recency"
  sql: -recency ;;
  description: "Calculated as the number of days since the user last logged in"
}

dimension: total_user_duration {
  group_label: "Time spent online with Cengage"
  type:  number
  sql: total_user_duration  / (60 * 60 * 24) ;;
  value_format_name: duration_hms
  label: "Total user time spent"
  description: "The total duration a user has spent doing something on one of the platforms or the dashboard"
}

dimension: total_user_duration_tiers {
  group_label: "Time spent online with Cengage"
  label: "Total user time (buckets)"
  type: tier
  sql: ${total_user_duration} * (24) ;;
  tiers: [0.25, 0.5, 1, 2, 4, 8, 16, 24, 36, 48, 60, 72, 84, 96]
  style: relational

}

  dimension: total_user_duration_tier {
    group_label: "Time spent online with Cengage"
    case: {
      when: {
       sql: ${total_user_duration} * (24) < 0.25 AND  ${total_user_duration} * (24) > 0;;
        label: "0 to 15 mins"
      }
      when: {
        sql: ${total_user_duration} * (24) < 0.5 AND  ${total_user_duration} * (24) > 0.25;;
        label: "15 to 30 mins"
      }
      when: {
        sql: ${total_user_duration} * (24) < 1 AND  ${total_user_duration} * (24) > 0.5;;
        label: "30 to 60 mins"
      }

      when: {
        sql: ${total_user_duration} * (24) < 2 AND  ${total_user_duration} * (24) > 1;;
        label: "1 to 2 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 4 AND  ${total_user_duration} * (24) > 2;;
        label: "2 to 4 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 8 AND  ${total_user_duration} * (24) > 4;;
        label: "4 to 8 hrs"
      }

      when: {
        sql: ${total_user_duration} * (24) < 16 AND  ${total_user_duration} * (24) > 8;;
        label: "8 to 16 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 24 AND  ${total_user_duration} * (24) > 16;;
        label: "16 to 24 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 36 AND  ${total_user_duration} * (24) > 24;;
        label: "24 to 36 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 48 AND  ${total_user_duration} * (24) > 36;;
        label: "36 to 48 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 60 AND  ${total_user_duration} * (24) > 48;;
        label: "48 to 60 hrs"
      }

      when: {
        sql: ${total_user_duration} * (24) < 72 AND  ${total_user_duration} * (24) > 60;;
        label: "60 to 72 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 84 AND  ${total_user_duration} * (24) > 72;;
        label: "72 to 84 hrs"
      }
      when: {
        sql: ${total_user_duration} * (24) < 96 AND  ${total_user_duration} * (24) > 84;;
        label: "84 to 96 hrs"
      }
      else: "Great than 96 hrs"
  }
  }

dimension: platforms_with_registrations {
  label: "Platforms with registrations"
  description: "A list of platforms this user has had registrations on"
}


dimension: usage_category {
  case: {
    when: {
      sql: ${frequency_prank} > 0.6  and ${intensity_prank} > 0.6 ;;
      label: "High Usage F AND I"
    }
    when: {
      sql: ${frequency_prank} > 0.6  or ${intensity_prank} > 0.6 ;;
      label: "High Usage F OR I"
    }
    when: {
      sql: ${frequency_prank} < 0.4  or ${intensity_prank} < 0.4 ;;
      label: "Low Usage"
    }
    else: "Medium Usage"
  }
  group_label: "Usage category"
  description: "Usage categories for bucketing data by how frequently and intensly a user uses CU relative to other users"
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

dimension: faq_clicks {
  group_label: "FAQ Clicks"
  label: "# FAQ clicks"
  description: "Number of times this user clicked the FAQ button"
}

dimension: faq_clicks_tier {
  group_label: "FAQ Clicks"
  label: "# FAQ clicks (buckets)"
  type: tier
  tiers: [1, 2, 4, 7, 10]
  style: integer
  sql: ${faq_clicks} ;;
  description: "Number of times this user clicked the FAQ button"
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

dimension_group: trial_start  {
  type: time
  timeframes: [date, week, month, month_name]
}

dimension_group: trial_end {
  type: time
  timeframes: [date, week, month, month_name]
}

dimension_group: full_access_start {
  type: time
  timeframes: [date, week, month, month_name]
  sql: ${TABLE}.subscription_start_date ;;
  description: "Date on which this users full access CU subscription started"
}

dimension_group: full_access_end {
  type: time
  timeframes: [date, week, month, month_name]
  sql: ${TABLE}.subscription_end_date ;;
  description: "Date on which this users full access CU subscription ended"
}

dimension: session_count {
  group_label: "Sessions"
  label: "# Sessions"
  type: number
  description: "Number of sessions this user has had with Cengage online. A session is defined as groups of activity where there is no more than 30 minutes gap"
}

dimension: session_count_tier {
  group_label: "Sessions"
  type: tier
  tiers: [2, 5, 10, 25, 50, 100]
  style: integer
  sql: ${session_count} ;;
  label: "# Sessions (buckets)"
  description: "Tiers for bucketing data by session counts"
}

dimension: trial_sessions {
  group_label: "Sessions"
  label: "# Trial sessions"
  description: "Number of sessions while this user is in trial"
}

dimension: trial_session_count_tier {
  group_label: "Sessions"
  type: tier
  tiers: [2, 5, 10, 25, 50, 100]
  style: integer
  sql: ${trial_sessions} ;;
  label: "# Trial sessions (buckets)"
  description: "Tiers for bucketing data by session counts"
}

dimension: subscription_sessions {
  group_label: "Sessions"
  label: "# Full access sessions"
  description: "Number of sessions while this user is in full access CU subscription"
}

dimension: subscription_session_count_tier {
  group_label: "Sessions"
  type: tier
  tiers: [2, 5, 10, 25, 50, 100]
  style: integer
  sql: ${subscription_sessions} ;;
  label: "# Full access sessions (buckets)"
  description: "Tiers for bucketing data by session counts"
}


dimension: trial_events_duration {
  group_label: "Time spent online with Cengage"
  type:  number
  sql: trial_events_duration  / (60 * 60 * 24) ;;
  value_format_name: duration_hms
  label: "Time active during trial period"
  # TO DO: better description
  description: "The sum of all event durations for this user while in CU trial access"
}
dimension: subscription_events_duration {
  group_label: "Time spent online with Cengage"
  type:  number
  sql: subscription_events_duration  / (60 * 60 * 24) ;;
  value_format_name: duration_hms
  label: "Time active during full access"
  description: "The sum of all event durations for this user while in a full access CU subscription"

}
dimension: total_months_cu_subscription {
  label: "Total months of CU subscription"
  description: "Total number of months this user has had a CU subscription"
}

dimension: purchase_path {
  label: "Purchase path"
  description: "The path this user came through to purchase CU (course link, micro-site, student dashboard, product detail page, other)"
  sql: coalesce(${TABLE}.purchase_path, 'Unknown') ;;
}

dimension: non_courseware_user {
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

dimension: subscription_term_length {
  type: number
  sql: DATEDIFF(month, ${full_access_start_date}, ${full_access_end_date}) ;;
}

dimension:  courseware_duration {
  group_label: "Time spent in products"
  sql: ${TABLE}.course_ware_duration ;;
  value_format_name: duration_dhm
  alias: [course_ware_duration]
}

dimension:  non_course_ware_duration {
  group_label: "Time spent in products"
  sql: ${TABLE}.non_course_ware_duration / (60 * 60 * 24) ;;
  value_format_name: duration_dhm
}



### Measure's section ###

measure: average_courses_added {
  type: average
  sql: ${TABLE}.unique_courses ;;
}

  measure: recency_avg_filterable {
    label: "Average recency"
    description: "Average frequency calulcated accorss querried population (filtered results)"
    type: number
    sql: AVG(-recency) OVER () ;;
    }

measure: frequency_avg_filterable {
  label: "Average frequency"
  description: "Average frequency calulcated accorss querried population (filtered results)"
  type: number
  sql: AVG(frequency) OVER () ;;
  }

measure: intensity_avg_filterable {
  label: "Average intensity"
  description: "Average intensity calulcated accorss querried population (filtered results)"
  type: number
  sql: AVG(intensity) OVER ();;
  }

measure: frequency_prank_filterable {
  label: "Percentage ranked frequency"
  description: "Percentage ranked frequency calulcated accorss querried population (filtered results)"
  type: number
  sql: PERCENT_RANK() OVER (ORDER BY frequency);;
  }

measure: intensity_prank_filterable {
  label: "Percentage ranked intensity"
  description: "Percentage ranked intensity calulcated accorss querried population (filtered results)"
  type: number
  sql: PERCENT_RANK() OVER (ORDER BY intensity);;
  }


measure: count {
  type: count
  label: "# Students"
  drill_fields: [details*]
}

measure: average_cw_value {
  type:  average
  sql: ${courseware_net_value} ;;
  value_format: "$#.00;($#.00)"
}

measure: average_non_cw_value {
  type:  average
  sql: ${non_courseware_net_value};;
  value_format: "$#.00;($#.00)"
}

measure: average_total_ebook_value {
  type:  average
  sql: ${total_products_net_value};;
  value_format: "$#.00;($#.00)"
}

measure: CU_users_with_cw_added{
  type: count_distinct
  sql: CASE WHEN ${courses_enrolled} > 0 THEN ${user_sso_guid} END;;
}

measure: CU_users_with_non_cw_added{
  type: count_distinct
  sql: CASE WHEN ${courses_enrolled} > 0 AND ${non_courseware_net_value} > 0 THEN ${user_sso_guid} END;;
}

measure: percent_users_adding_non_cw {
  type: number
  sql: ${CU_users_with_non_cw_added} / ${CU_users_with_cw_added}  ;;
  value_format_name: percent_2
}


measure: average_cw_duration {
  type: average
  sql: course_ware_duration / (60 * 60 * 24) ;;
  value_format_name: duration_dhm
}

measure: average_non_cw_duration {
  type: average
  sql: non_course_ware_duration / (60 * 60 * 24) ;;
  value_format_name: duration_dhm
}

}
