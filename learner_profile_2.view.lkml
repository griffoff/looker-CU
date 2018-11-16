include: "cengage_unlimited.model.lkml"
include: "/core/common.lkml"

view: learner_profile_2 {
  view_label: "Learner Profile"
  sql_table_name: zpg.learner_profile ;;


  ### Dimension section ###
  dimension: courses {
    label: "Courses"
    description: "List of course keys the user has"
  }

  dimension: unique_courses {
    type: number
    label: "Courses (number of)"
    description: "Number of courses the user has enrolled in (course keys with event action: OLR enrollment)"
  }

  dimension: all_products_add {
    label: "All products added"
    description: "List of all iac_isbn provisioned to dashboard from the provisioned product table"
  }

  dimension: total_ebooks_net_price_value {
    label: "Total ebooks net value"
    description: "Sum of the net price of all the ebooks provisioned to this users dashboard"
  }

  dimension: courseware_ebooks_net_price_value {
    type: number
    label: "Courseware ebook net value"
    description: "Sum of the net price of all ebooks provisioned to this users dashboard where there was an associated course key"
  }

  dimension:  non_courseware_ebooks_net_price_value {
    type: number
    label: "Non-courseware ebook net value"
    description: "Sum of the net price of all ebooks provisioned to this users dashboard where there was an associated course key"
  }

  dimension: WA_activations {
    type: number
    group_label: "Activations"
    label: "WebAssign Activations"
    description: "Number of WebAssign activations prior to CU launch on 08/01/2018"
  }

  dimension: MT_activations {
    type: number
    group_label: "Activations"
    label: "MindTap activations"
    description: "Number of Mindtap activations prior to CU launch on 08/01/2018"
  }

  dimension: other_activations {
    type: number
    group_label: "Activations"
    label: "Other activations"
    description: "Number of activations that aren't WebAssign or MindTap prior to CU launch on 08/01/2018"
  }

  dimension: first_activation_date {
    type: date
    label: "First activation date"
    description: "The earliest date this user activated a product"
  }

  dimension: new_customer {
    type: string
    sql: CASE WHEN first_activation_date > '08/01/2018' AND subscription_status IN ('Full Access', 'Trial Access') THEN 'New Cengage Customer'
              WHEN first_activation_date > '08/01/2018' AND subscription_status NOT IN ('Full Access', 'Trial Access') THEN 'Stand alone purchase after CU released'
              WHEN first_activation_date < '08/01/2018' AND subscription_status IN ('Full Access', 'Trial Access')  THEN 'Returning Customer purchased CU'
              WHEN first_activation_date < '08/01/2018' AND subscription_status NOT IN ('Full Access', 'Trial Access' )    THEN 'Returning Customer purchased stand alone after CU released'
              ELSE 'other' END
              ;;
  }



  dimension: frequency_avg {
    label: "Frequency average (over all GUIDs)"
    description: "Average frequency calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: intensity_avg {
    label: "Intensity average (over all GUIDs)"
    description: "Average intensity calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: frequency_prank {
    label: "Percentage ranked frequency (over all GUIDs)"
    description: "Percentage ranked frequency calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: intensity_prank {
    label: "Percentage ranked intensity (over all GUIDs)"
    description: "Percentage ranked intensity calulcated accross all GUIDs (even if filters are applied)"
    type: number
    }

  dimension: days_since_first_login {
    type: number
    sql: -DATEDIFF(d, current_date(), ${first_interaction_date} ) ;;
    label: "Days since first login"
    description: "Calculated as the number of days since the user first logged in"
  }

  dimension: user_sso_guid {
    primary_key: yes
    label: "User SSO GUID"
  }

  dimension: subscription_status {
    label: "Subscription status"
  }

  dimension: session_count {
    label: "Session count"
    type: number
  }

  dimension: relative_day_number {
    label: "Relative day number"
    description: "Calculated as a unique count of dates starting from and including the first login"
    type: number
  }

  dimension: session_count_tier {
    type: tier
    tiers: [ 2, 3, 4, 5, 6, 7, 8, 9, 10]
    style: integer
    sql: ${TABLE}."SESSION_COUNT" ;;
    label: "Session count tier"
    description: "Tiers for bucketing data by session counts"
  }

  dimension: active_user {
    type: string
    sql: CASE WHEN ${frequency} >= 2 AND ${recency} >= -14 AND ${intensity} > 4 THEN 'active' ELSE 'non-active' END;;
    label: "Active user status"
    description: "A user is active when they have a frequency >= 2, a recency >= 14, and an intensity > 4"
  }

  dimension: days_active {
    type: number
    label: "Total days active"
    description: "Calculated as the total number of days a user was active"
  }
  dimension: days_active_per_week {
    type: number
    label: "Days active per week"
    description: "Calculated as the average number of days a user was active per week"
  }
  dimension: days_since_last_login {
    type: number
    label: "Days since last login"
    description: "Calculated as the number of days since the user last logged in"
  }
  dimension: events_per_session {
    type: number
    label: "Events per session"
    description: "Calculated as the average number of events per session by a user"
  }
  dimension_group: first_interaction {
    sql: ${TABLE}.first_event_time ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
    label: "First interaction timestamp"
    description: "The time components of the timestamp when the user first logged in"
  }
  dimension_group: latest_interaction {
    sql: ${TABLE}.latest_event_time ;;
    type: time
    timeframes: [time, date, day_of_week, month, hour]
    label: "Latest interaction timestamp"
    description: "The time components of the timestamp when the user most recently logged in"
  }
  dimension: frequency {
    type: number
     label: "Frequency"
     description: "Calculated as the average times a user logs in per week"
  }
  dimension: intensity {
    type: number
    label: "Intensity"
    description: "Calculated as the average number of events per session by the user"
  }
  dimension: recency {
    type: number
    label: "Recency"
    description: "Calculated as the number of days since the user last logged in"
  }

  dimension: total_user_duration {
    type:  number
    sql: total_user_duration  / (60 * 60 * 24) ;;
    value_format_name: duration_hms
    label: "Total user duration"
    description: "The total duration a user has spent doing something on one of the platforms"
  }

  dimension: total_user_duration_tiers {
    type: tier
    sql: ${total_user_duration} * (24) ;;
    tiers: [0.25, 0.5, 1, 2, 4, 8, 16, 24, 36, 48, 60, 72, 84, 96]
    style: relational

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

  dimension: contract_ids {
    label: "Contract IDs"
    description: "All of the contract IDs attached to this user"
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
    label: "# Searches with results"
    type: tier
    tiers: [1, 10, 20, 30]
    style: integer
    sql: ${searches_with_results} ;;
    description: "Number of searches by this user that returned results"
  }

  dimension: searches_without_results_tier {
    group_label: "Searches"
    label: "# Searches without results"
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
    tiers: [1, 10, 20, 30]
    style: integer
    sql: ${faq_clicks} ;;
    description: "Number of times this user clicked the FAQ button"
  }

  dimension_group: subscription_start {
    type: time
    timeframes: [date, week, month, month_name]
    label: "Current subscription start date"
    description: "The user's current subscription state (trial or full) start date"
  }

  dimension_group: subscription_end {
    type: time
    timeframes: [date, week, month, month_name]
    label: "Current subscription end date"
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
    label: "Subscription start date"
    description: "Date onw hich this users full access CU subscription started"
  }

  dimension_group: full_access_end {
    type: time
    timeframes: [date, week, month, month_name]
    label: "Subscription end date"
    description: "Date onwhich this users full access CU subscription ended"
  }

  dimension: trial_sessions {
    label: "# Trial sessions"
    description: "Number of sessions while this user is in trial"
  }

  dimension: subscription_sessions {
    label: "# Full access sessions"
    description: "Number of sessions while this user is in full access CU subscription"
  }

  dimension: trial_events_duration {
    type:  number
    sql: trial_events_duration  / (60 * 60 * 24) ;;
    value_format_name: duration_hms
    label: "Time active during trial period"
    # TO DO: better description
    description: "The sum of all event durations for this user while in CU trial access"
  }
  dimension: subscription_events_duration {
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
  }

  dimension: non_courseware_user {
    sql: CASE WHEN ${non_courseware_ebooks_net_price_value} > 0 THEN 'Non-courseware ebook user'
              WHEN ${non_courseware_ebooks_net_price_value} <= 0
                    OR ${non_courseware_ebooks_net_price_value} IS NULL THEN 'Courseware only user'
                    END;;
    type: string
  }

  dimension:  course_ware_duration {
    sql: course_ware_duration ;;
  }

  dimension:  non_courseware_duration {
    sql: non_courseware_duration / (60 * 60 * 24) ;;
    value_format_name: duration_dhm
  }



### Measure's section ###


  measure: frequency_avg_filterable {
    label: "Average frequency"
    description: "Average frequency calulcated accorss querried population (filtered results)"
    type: number
    sql: AVG(frequency) OVER () ;;}

  measure: intensity_avg_filterable {
    label: "Average intensity"
    description: "Average intensity calulcated accorss querried population (filtered results)"
    type: number
    sql: AVG(intensity) OVER ();;}

  measure: frequency_prank_filterable {
    label: "Percentage ranked frequency"
    description: "Percentage ranked frequency calulcated accorss querried population (filtered results)"
    type: number
    sql: PERCENT_RANK() OVER (ORDER BY frequency);;}

  measure: intensity_prank_filterable {
    label: "Percentage ranked intensity"
    description: "Percentage ranked intensity calulcated accorss querried population (filtered results)"
    type: number
    sql: PERCENT_RANK() OVER (ORDER BY intensity);;}


  measure: count {
    type: count
    label: "# Students"
  }

  measure: average_cw_value {
    type:  average
    sql: ${courseware_ebooks_net_price_value} ;;
    value_format: "$#.00;($#.00)"
  }

  measure: average_non_cw_value {
    type:  average
    sql: ${non_courseware_ebooks_net_price_value};;
    value_format: "$#.00;($#.00)"
  }

  measure: average_total_ebook_value {
    type:  average
    sql: ${total_ebooks_net_price_value};;
    value_format: "$#.00;($#.00)"
  }

  measure: CU_users_with_cw_added{
    type: count_distinct
    sql: CASE WHEN ${unique_courses} > 0 THEN ${user_sso_guid} END;;
  }

  measure: CU_users_with_non_cw_added{
    type: count_distinct
    sql: CASE WHEN ${unique_courses} > 0 AND ${non_courseware_ebooks_net_price_value} > 0 THEN ${user_sso_guid} END;;
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
    sql: non_courseware_duration / (60 * 60 * 24) ;;
    value_format_name: duration_dhm
  }


}
