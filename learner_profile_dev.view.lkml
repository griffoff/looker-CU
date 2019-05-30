include: "learner_profile.view"

view: learner_profile_dev {
  extends: [learner_profile]
  label: "Learner Profile - Dev"
  sql_table_name: dev.cu_user_analysis_dev.learner_profile ;;

#   set: marketing_fields {
#     fields: [learner_profile_dev.user_sso_guid, learner_profile_dev.subscription_start_date, learner_profile_dev.subscription_end_date, learner_profile_dev.products_added_count, learner_profile_dev.products_added_tier,
#       learner_profile_dev.courseware_added_count, learner_profile_dev.courseware_added_tier]
#   }


  ### Dimension section ###
  dimension: courses {
    group_label: "Courses"
    label: "Course Keys"
    description: "List of course keys the user has"
    sql: ${TABLE}.courses ;;
  }

#   dimension: marketing_segment_fb {
#     type: string
#     sql: CASE
# --             WHEN courseware_net_price_non_cu_on_dashboard >= 120
# --             THEN 'Students who have not paid but have courseware on dashboard >= $120'
# --             WHEN courseware_net_price_non_cu_on_dashboard < 120 AND courseware_net_price_non_cu_on_dashboard <> 0 AND courseware_net_price_non_cu_on_dashboard IS NOT NULL
# --             THEN 'Students who have not paid but have courseware on dashboard < $120'
#             WHEN courseware_net_price_non_cu_activated >= 120
#             THEN 'Students who have paid for standalone digital courseware >= $120'
#             WHEN courseware_net_price_non_cu_activated < 120
#             THEN 'Students who have paid for standalone digital courseware < $120'
#             WHEN courseware_net_price_non_cu_enrolled >= 120
#             THEN 'Students who have enrolled in courseware but not activated or added to dashboard >= $120'
#             WHEN courseware_net_price_non_cu_enrolled < 120
#             THEN 'Students who have enrolled in courseware but not activated or added to dashboard < $120'
#             WHEN courseware_net_price_non_cu_on_dashboard IS NOT NULL
#             THEN 'Students who have added courseware to dashboard, but have no enrollments or activations'
#             ELSE 'No enrollments or activations or courseware on dashboard'
#          END
# ;;
#   }

#   dimension: courseware_net_price_non_cu_activated {
#     type: number
#     group_label: "Courses"
#     description: "Total net cost of active courseware activated since the end of a user's last CU subscription (i.e. not covered by CU)"
#     value_format_name: usd_0
#   }

#   dimension: courseware_net_price_non_cu_enrolled{
#     type: number
#     label: "Courseware net price (outside of CU subscription)"
#     group_label: "Courses"
#     description: "Total net cost of active courseware enrolled in but not activated since the end of a user's last CU subscription (i.e. not covered by CU)"
#     value_format_name: usd_0
#   }

#   parameter: no_of_groups {
#     label: "Select a number of groups to split the data into"
#     description: "Select a number of groups to split the records into
#     the Assigned Group dimension will display a number between 1 and the number of groups chosen for every record in your dataset"
#     type: unquoted
#     allowed_value: {
#       label: "No split, all records in the same group"
#       value: "1"
#     }
#     allowed_value: {
#       label: "2 groups: Split the dataset into 2 different groups"
#       value: "2"
#     }
#     allowed_value: {
#       label: "3 groups: Split the dataset into 3 different groups"
#       value: "3"
#     }
#     allowed_value: {
#       label: "4 groups: Split the dataset into 4 different groups"
#       value: "4"
#     }
#     default_value: "1"
#     view_label: "** MODELLING TOOLS **"
#     required_fields: [assigned_group]
#   }
#
#   dimension: assigned_group {
#     label: "Assigned Group"
#     description: "When data is split into groups, this field represents the group letter (A,B,etc.) to which a record belongs"
#     sql: CHAR(64+${assigned_group_no}) ;;
#   }
#
#   dimension: assigned_group_no {
#     label: "Assigned Group #"
#     description: "When data is split into groups, this field represents the group no (1, 2, etc.) to which a record belongs"
#     sql: uniform(1, {% parameter no_of_groups %}, random()) ;;
#     # calculation to make this number the same for a given guid
#     # Both versions require a known GUID field, the examples use a hard coded one which will need to be changed
#     # VERSION 1
#     # this version based on the guid itself, so may not be evenly distributed
#     # sql: (mod(abs(hash("olr_courses.instructor_guid")), {% parameter no_of_groups %})) + 1
#
#     # VERSION 2
#     # this version should be evenly distributed but will need to be a measure
#     # sql: mod(dense_rank() over (order by "olr_courses.instructor_guid"), {% parameter no_of_groups %}) + 1
#     view_label: "** MODELLING TOOLS **"
#   }

  dimension: cu_price {
    type: number
    sql: 120 ;;
    hidden: yes
  }

  dimension: potential_savings {
    type: number
    group_label: "Courses"
    description: "Potential saving if student purchases CU"
    sql: CASE
          WHEN NOT ${live_subscription_status.is_trial} THEN NULL
          WHEN ${TABLE}.courseware_net_price_non_cu_enrolled >= ${cu_price} THEN ${TABLE}.courseware_net_price_non_cu_enrolled - ${cu_price}
          END;;
    value_format_name: usd_0
  }

#   dimension: courseware_net_price_non_cu_on_dashboard{
#     type: number
#     group_label: "Courses"
#     description: "Total net cost of active courseware on the users dashboard since the end of a user's last CU subscription (i.e. not covered by CU)"
#     value_format_name: usd_0
#     sql:  courseware_net_price_non_cu_on_dashboard::number;;
#   }

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

#   dimension_group: time_since_first_log {
#     group_label: "Time since first event"
#     sql_start: ${first_interaction_time} ;;
#     sql_end: ${all_events.event_time} ;;
#     type: duration
#     intervals: [ hour, day, week, month]
#   }

  dimension: courseware_net_value_tier {
    group_label: "Provisioned Products"
    label: "Courseware net value (buckets)"
    type: tier
    style: integer
    tiers: [120, 200, 300, 500, 1000]
    sql: ${courseware_net_value} ;;
    value_format_name: usd_0
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

  dimension: courseware_net_val {
    group_label: "Provisioned Products"
    label: "Courses net value"
    type: number
    sql: ${courseware_net_value} ;;
    value_format_name: usd_0
  }


  dimension: cost_savings {
    group_label: "Cost savings"
    label: "Cost savings"
    description: "Difference between net price of user's provisioned courseware products and $120 (CU Subscription cost)"
    sql:  ${courseware_net_value} - 120 ;;
    type: number
    value_format_name: usd_0
  }

  dimension: cost_savings_t {
    group_label: "Cost savings"
    label: "Cost savings all products"
    description: "Difference between net price of user's provisioned products and $120 (CU Subscription cost)"
    sql:  ${total_products_net_value} - 120 ;;
    type: number
    value_format_name: usd_0
  }

  dimension: cost_savings_tiers {
    group_label: "Cost savings"
    label: "Cost savings (buckets)"
    description: "Cost savings bucketed"
    sql:   ${cost_savings};;
    type: tier
    tiers: [-210, -180, -150, -120, -90, -60, -30, 0,30,60, 90, 120, 150, 180, 210]
    style: relational
    value_format_name: usd_0
  }

  dimension: cost_savings_tiers_t {
    group_label: "Cost savings"
    label: "Cost savings all products (buckets)"
    description: "Cost savings for all products bucketed"
    sql:   ${cost_savings_t};;
    type: tier
    tiers: [-210, -180, -150, -120, -90, -60, -30, 0,30,60,90,120,150,180,210]
    style: relational
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

  dimension_group: time_in_current_status {
    group_label: "Current subscription time in status"
    type: duration
    intervals: [day, week, month]
    sql_start: ${subscription_start_date} ;;
    sql_end: current_date() ;;
    hidden: yes
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



  dimension_group: time_since_first_login {
    group_label: "Time since first login"
    type: duration
    sql_start: ${TABLE}.first_interaction_date ;;
    sql_end: current_date() ;;
    intervals: [day, week, month, year]
  }

  dimension: contract_ids {
    group_label: "CU Subscription"
    label: "Contract IDs"
    description: "All of the contract IDs attached to this user"
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


  dimension_group: latest_trial_start  {
    type: time
    timeframes: [date, week, month, month_name]
    sql: ${TABLE}.latest_trial_start_date ;;
  }


  dimension_group: latest_trial_end {
    type: time
    timeframes: [date, week, month, month_name]
    sql: ${TABLE}.latest_trial_end_date ;;
  }


  dimension_group: latest_full_access_subscription_start {
    type: time
    timeframes: [date, week, month, month_name]
    sql: ${TABLE}.latest_full_access_subscription_start ;;
    description: "Date on which this users full access CU subscription started"
  }

  dimension_group: latest_full_access_subscription_end {
    type: time
    timeframes: [date, week, month, month_name]
    sql: ${TABLE}.latest_full_access_subscription_end ;;
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

  dimension_group: trial_length {
    group_label: "Trial Duration"
    description: "How long after trial start did they convert to full access?"
    type: duration
    sql_start: ${TABLE}.latest_trial_start_date ;;
    sql_end: ${TABLE}.latest_full_access_subscription_start_date ;;
    intervals: [day, week]
  }

#   measure: trial_length_to_subscription_length_correlation{
#     type: number
#     sql: corr(${cu_subscription_length}, ${days_trial_length}) ;;
#   }

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

  dimension: no_purchase_trial_user {
    type: yesno
    label: "Trial user without purchase"
    description: "This is a flag for trial users that have not purchased anything to start the trial or since starting their trial"
    sql: ${TABLE}."NO_PURCHASE_TRIAL_USER" = 1 ;;
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
