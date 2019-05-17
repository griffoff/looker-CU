# include: "cengage_unlimited.model.lkml"
 include: "//core/access_grants_file.view"

view: learner_profile {
  view_label: "Learner Profile"
  sql_table_name: prod.cu_user_analysis.learner_profile_temp ;;

  set: details {
    fields: [user_sso_guid, subscription_status, cu_subscription_length, subscription_start_date, subscription_end_date
      , non_courseware_net_value
      ,new_customer, first_activation_date]
  }

  set: marketing_fields {
    fields: [learner_profile.user_sso_guid, learner_profile.subscription_start_date, learner_profile.subscription_end_date, learner_profile.products_added_count, learner_profile.products_added_tier,
      learner_profile.courseware_added_count, learner_profile.courseware_added_tier]
  }


  parameter: no_of_groups {
    label: "Select a number of groups to split the data into"
    description: "Select a number of groups to split the records into
    the Assigned Group dimension will display a number between 1 and the number of groups chosen for every record in your dataset"
    type: unquoted
    allowed_value: {
      label: "No split, all records in the same group"
      value: "1"
    }
    allowed_value: {
      label: "2 groups: Split the dataset into 2 different groups"
      value: "2"
    }
    allowed_value: {
      label: "3 groups: Split the dataset into 3 different groups"
      value: "3"
    }
    allowed_value: {
      label: "4 groups: Split the dataset into 4 different groups"
      value: "4"
    }
    default_value: "1"
    view_label: "** MODELLING TOOLS **"
    required_fields: [assigned_group]
    required_access_grants: [can_view_segment_parameters]
  }

  dimension: assigned_group {
    label: "Assigned Group"
    description: "When data is split into groups, this field represents the group letter (A,B,etc.) to which a record belongs"
    sql: CHAR(64+${assigned_group_no}) ;;
    required_access_grants: [can_view_segment_parameters]
  }

  dimension: assigned_group_no {
    label: "Assigned Group #"
    description: "When data is split into groups, this field represents the group no (1, 2, etc.) to which a record belongs"
    sql: uniform(1, {% parameter no_of_groups %}, random()) ;;
    # calculation to make this number the same for a given guid
    # Both versions require a known GUID field, the examples use a hard coded one which will need to be changed
    # VERSION 1
    # this version based on the guid itself, so may not be evenly distributed
    # sql: (mod(abs(hash("olr_courses.instructor_guid")), {% parameter no_of_groups %})) + 1

    # VERSION 2
    # this version should be evenly distributed but will need to be a measure
    # sql: mod(dense_rank() over (order by "olr_courses.instructor_guid"), {% parameter no_of_groups %}) + 1
    view_label: "** MODELLING TOOLS **"
    required_access_grants: [can_view_segment_parameters]
  }


  dimension: user_sso_guid {
    primary_key: yes
    label: "User SSO GUID"
    link: {
      label: "See this user's journey"
      url: "/explore/cengage_unlimited/event_analysis?fields=all_events.product_platform,all_sessions.session_start_time,all_events.event_time,all_sessions.lat_lon,all_events.event_type,all_events.event_action,event_groups.event_group,all_events.event_name,all_events.event_data,all_events.sum_of_time_to_next_event&f[learner_profile_2.user_sso_guid]={{ value | url_encode }}&f[event_groups.event_group]=-Timers&sorts=all_events.event_time+desc&limit=500&toggle=vse"
    }
  }

  dimension: returning_cu_customer {
    group_label: "Customer Type"
  }

  dimension: purchase_path {
    group_label: "CU Subscription"
    label: "Purchase path"
    description: "WORK IN PROGRESS The path this user came through to purchase CU (course link, micro-site, student dashboard, product detail page, other) WORK IN PROGRESS"
    sql: coalesce(${TABLE}.purchase_path, 'Unknown') ;;
  }

  dimension: no_of_chegg_clicks {
    group_label: "Exclusive Partner Clicks"
    label: "Chegg Clicks"
    type: number
    description: "Number of times a user has clicked on the chegg from CU dashboard"
    sql: ${TABLE}.no_of_chegg_clicks ;;
  }

  dimension: no_of_quizlet_clicks {
    group_label: "Exclusive Partner Clicks"
    label: "Quizlet Clicks"
    type: number
    description: "Number of times a user has clicked on the quizlet from CU dashboard"
    sql: ${TABLE}.no_of_quizlet_clicks ;;
  }

  dimension: no_of_kaplan_clicks {
    group_label: "Exclusive Partner Clicks"
    label: "Kaplan Clicks"
    type: number
    description: "Number of times a user has clicked on the kaplan from CU dashboard"
    sql: ${TABLE}.no_of_kaplan_clicks ;;
  }

  dimension: days_active {
    group_label: "Days Active"
    type: number
    label: "Total days active"
    description: "Calculated as the total number of days a user was active"
  }

  dimension: days_since_first_login {
    group_label: "First Interaction Date"
    hidden: no
    type: number
    sql: -DATEDIFF(d, current_date(), ${first_interaction_date} ) ;;
    label: "Days since first login"
    description: "Calculated as the number of days since the user first logged in"
  }

  dimension: percent_days_active {
    type: number
    sql: ${days_active} / ${days_since_first_login};;
    value_format_name:  percent_2
    group_label: "Days Active"
    label: "% days active"
    description: "Percentage of days since the user first logged in that the user was active"
  }

  dimension_group: first_interaction {
    sql: ${TABLE}.first_event_time ;;
        type: time
        timeframes: [raw, time, date, day_of_week, month, hour]
        label: "First interaction"
        description: "The time components of the timestamp when the user first logged in"
      }

  dimension: days_active_tiers  {
    type: tier
    sql: ${percent_days_active}*100 ;;
    tiers: [10, 25, 50, 75]
    style: integer
    group_label: "Days Active"
    value_format: "0\%"
    label: "% days active (buckets)"
  }


  dimension: subscription_status {
    group_label: "CU Subscription"
    label: "Subscription status"
    sql: coalesce(${TABLE}.subscription_status, 'Never tried CU');;
    description: "Current CU subscription state"
    hidden: yes
  }

  dimension: is_cu_subscriber {
    group_label: "Customer Type"
    label: "Is CU subscriber"
    description: "True if user is currently a full access subscriber and false if they are not"
    hidden: no
    type: yesno
    sql: lower(${subscription_status}) = 'full access' ;;
  }

  dimension: cu_subscription_length {
    type: number
    group_label: "CU Subscription"
    label: "CU subscription Length"
    description: "Current length of CU subscription in months"
    sql: CASE
            WHEN datediff(month, ${subscription_start_raw}, ${subscription_end_raw}) in (3, 4) THEN 4
            WHEN datediff(month, ${subscription_start_raw}, ${subscription_end_raw}) in (11, 12) THEN 12
            WHEN datediff(month, ${subscription_start_raw}, ${subscription_end_raw}) in (23, 24) THEN 24
            --ELSE datediff(month, ${subscription_start_raw}, ${subscription_end_raw})
            END;;
    value_format: "0 \m\o\n\t\h\s"
  }

  dimension_group: subscription_start {
    type: time
    timeframes: [raw, date, week, month, month_name]
    group_label: "Current subscription start date"
    description: "The user's current subscription state (trial or full) start date"
    sql:  ${TABLE}.subscription_start::timestamp_ntz ;;
  }

  dimension_group: subscription_end {
    type: time
    timeframes: [raw, date, week, month, month_name]
    group_label: "Current subscription end date"
    description: "The user's current subscription state (trial or full) end date"
    label: "Subscription end"
  }

  dimension_group: first_activation {
    type: time
    timeframes: [raw, date, month, year]
    description: "The earliest date this user activated any product with Cengage"
    label: "First product activation date"
    sql: ${TABLE}.first_activation_date ;;
    hidden: yes
  }

  dimension: is_new_customer {
    group_label: "Customer Type"
    label: "Is new customer"
    description: "True if the customer has not activated a product prior to the launch of CU on 2018-08-01"
    hidden: yes
    type: yesno
    sql: ${first_activation_raw} > '2018-08-01' or ${first_activation_raw} is null;;
  }

  dimension: new_customer {
    group_label: "Customer Type"
    label: "New customer status"
    description: "A status describing whether a customer is new or returning and whether or not they purchased CU"
    case: {
      when: {
        sql: ${is_new_customer} AND ${is_cu_subscriber};;
        label: "New cengage customer purchased CU"
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
        sql: ${is_new_customer} AND NOT ${is_cu_subscriber} ;;
        label: "New Customer purchased stand alone after CU released"
      }
      when: {
        sql: NOT ${is_new_customer} AND NOT ${is_cu_subscriber} ;;
        label: "Returning customer purchased stand alone after CU released"
      }
    }
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
    label: "Courseware vs non-courseware user"
    sql: CASE
            WHEN ${non_courseware_net_value} > 0 AND ${courseware_net_value} > 0 THEN 'Courseware and non-courseware user'
           WHEN (${non_courseware_net_value} <= 0 OR ${non_courseware_net_value} IS NULL) AND ${courseware_net_value} > 0 THEN 'Courseware only user'
          WHEN ${non_courseware_net_value} > 0 AND (${courseware_net_value} <= 0 OR ${courseware_net_value} IS NULL) THEN 'Non-courseware only user'
            --WHEN ${non_courseware_net_value} is null and ${courseware_net_value} is null then 'No products in dashboard'
            ELSE 'No products added to dashboard'
                    END;;
    type: string
    description: "Has this user added to their CU dashboard just courseware products, just non-courseware products, both or none?"
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
    sql: COALESCE(array_size(${TABLE}.all_products_add), 0) ;;
    description: "Number of different iac_isbn provisioned to dashboard"
  }


  dimension: products_added_tier {
    group_label: "Provisioned Products"
    label: "# products (buckets)"
    description: "Bucketed number of products user added to dashboard"
    case: {
      when: {
        sql: COALESCE(${products_added_count}, 0) = 0 ;;
        label: "No products added to dashboard"
      }
      when: {
        sql: COALESCE(${products_added_count}, 0) = 1 ;;
        label: "One product added to dashboard"
      }
      when: {
        sql: COALESCE(${products_added_count}, 0) = 2 ;;
        label: "Two products added to dashboard"
      }
      when: {
        sql: COALESCE(${products_added_count}, 0) = 3 ;;
        label: "Three products added to dashboard"
      }
      when: {
        sql: COALESCE(${products_added_count}, 0) = 4 ;;
        label: "Four products added to dashboard"
      }
      else: "Five or more products added to dashboard"
    }
  }

  dimension: all_courseware_added {
    group_label: "Provisioned Products"
    label: "courseware added"
    description: "List of all courseware iac_isbn provisioned to dashboard from the provisioned product table"
    drill_fields: [details*]
    sql: array_to_string(${TABLE}.all_courseware_added, ', ') ;;
  }

  dimension: courseware_added_count {
    group_label: "Provisioned Products"
    type: number
    label: "# courseware"
    sql: COALESCE(array_size(${TABLE}.all_courseware_added), 0) ;;
    description: "Number of different courweware iac_isbn provisioned to dashboard"
  }


  dimension: courseware_added_tier {
    group_label: "Provisioned Products"
    label: "# courseware (buckets)"
    description: "Bucketed number of courseware user added to dashboard"
    case: {
      when: {
        sql: COALESCE(${courseware_added_count}, 0) = 0 ;;
        label: "No courseware added to dashboard"
      }
      when: {
        sql: COALESCE(${courseware_added_count}, 0) = 1 ;;
        label: "One courseware added to dashboard"
      }
      when: {
        sql: COALESCE(${courseware_added_count}, 0) = 2 ;;
        label: "Two courseware added to dashboard"
      }
      when: {
        sql: COALESCE(${courseware_added_count}, 0) = 3 ;;
        label: "Three courseware added to dashboard"
      }
      when: {
        sql: COALESCE(${courseware_added_count}, 0) = 4 ;;
        label: "Four courseware added to dashboard"
      }
      else: "Five or more courseware added to dashboard"
    }
  }

  measure: count {
    type: count
    label: "# Students"
    drill_fields: [details*]
    hidden: yes
  }

  dimension: marketing_segment_fb {
    group_label: "User Info - Marketing"
    label: "Paid/Unpaid courseware outside of CU subscription"
    type: string
    sql: CASE
      --             WHEN courseware_net_price_non_cu_on_dashboard >= 120
      --             THEN 'Students who have not paid but have courseware on dashboard >= $120'
      --             WHEN courseware_net_price_non_cu_on_dashboard < 120 AND courseware_net_price_non_cu_on_dashboard <> 0 AND courseware_net_price_non_cu_on_dashboard IS NOT NULL
      --             THEN 'Students who have not paid but have courseware on dashboard < $120'
                  WHEN courseware_net_price_non_cu_activated >= 120
                  THEN 'Students who have paid for standalone digital courseware >= $120'
                  WHEN courseware_net_price_non_cu_activated < 120
                  THEN 'Students who have paid for standalone digital courseware < $120'
                  WHEN courseware_net_price_non_cu_enrolled >= 120
                  THEN 'Students who have enrolled in courseware but not activated or added to dashboard >= $120'
                  WHEN courseware_net_price_non_cu_enrolled < 120
                  THEN 'Students who have enrolled in courseware but not activated or added to dashboard < $120'
                  WHEN courseware_net_price_non_cu_on_dashboard IS NOT NULL
                  THEN 'Students who have added courseware to dashboard, but have no enrollments or activations'
                  ELSE 'No enrollments or activations or courseware on dashboard'
               END
      ;;
  }


  dimension: courseware_net_price_non_cu_activated {
    type: number
    group_label: "Courses"
    description: "Total net cost of active courseware activated since the end of a user's last CU subscription (i.e. not covered by CU)"
    value_format_name: usd_0
    hidden: yes
  }


  dimension: courseware_net_price_non_cu_enrolled {
    type: number
    label: "Courseware net price (outside of CU subscription)"
    group_label: "Courses"
    description: "Total net cost of active courseware enrolled in but not activated since the end of a user's last CU subscription (i.e. not covered by CU)"
    value_format_name: usd_0
    sql: COALESCE(${courseware_net_price_non_cu_activated}, courseware_net_price_non_cu_enrolled);;
  }

  dimension: courseware_net_price_non_cu_on_dashboard{
    type: number
    group_label: "Courses"
    description: "Total net cost of active courseware on the users dashboard since the end of a user's last CU subscription (i.e. not covered by CU)"
    value_format_name: usd_0
    sql:  courseware_net_price_non_cu_on_dashboard::number;;
  }

  dimension: purchased_standalone {
    description: "Did this person activate a course after the end of their last full access subscription?"
    type: yesno
    sql:  courseware_net_price_non_cu_activated IS NOT NULL;;

#    ${user_courses.activation_date} > ${TABLE}.latest_full_access_subscription_end_date
#            OR ${TABLE}.latest_full_access_subscription_end_date IS NULL AND  ${user_courses.activation_date} IS NOT NULL ;;
  }


  dimension: cu_price {
    type: number
    sql: 120 ;;
    hidden: yes
  }

  dimension: courses_enrolled {
    group_label: "Courses"
    type: number
    label: "# Courses Enrolled"
    description: "Number of courses the user has enrolled in (course keys found in OlR enrollments)"
    sql: ${TABLE}.unique_courses_enrolled ;;
    alias: [unique_courses]
  }

  dimension: courses_activated {
    group_label: "Courses"
    type: number
    label: "# Courses Activated"
    description: "Number of courses the user has enrolled in (course keys found in OLR activations)"
    sql: ${TABLE}.unique_courses_activated ;;
  }

  dimension: courses_enrolled_tier {
    group_label: "Courses"
    type: tier
    style: integer
    tiers: [0, 1, 2, 3]
    sql: ${courses_enrolled} ;;
    label: "# Courses Enrolled (buckets)"
    description: "Number of courses the user has enrolled in"
  }

  dimension: courses_activated_tier {
    group_label: "Courses"
    type: tier
    style: integer
    tiers: [0, 1, 2, 3]
    sql: COALESCE(${courses_activated}, 0) ;;
    label: "# Courses Activated (buckets)"
    description: "Number of courses the user has activated"
  }

  dimension: net_price_tier {
    label: "Price of Courseware (buckets)"
    description: "Net Price of Courseware either paid for or not yet paid for"
    type: tier
    style: integer
    group_label: "Courses"
    tiers: [0, 120, 180, 250, 500]
    sql: COALESCE(${TABLE}.courseware_net_price_non_cu_on_dashboard, ${TABLE}.learner_profile.courseware_net_price_non_cu_activated, ${TABLE}.courseware_net_price_non_cu_on_dashboard, 0) ;;
    value_format_name: usd_0
  }

  measure: take_rate {
    description: "% of people who bought CU whose courseware value was higher than the cost of a subscription"
    type: number
    sql: count(distinct CASE WHEN ${courseware_net_value} > ${cu_price} AND ${is_cu_subscriber} THEN ${user_sso_guid} END)
        / NULLIF(count(distinct CASE WHEN ${courseware_net_value} > ${cu_price} THEN ${user_sso_guid} END), 0)
        ;;
    value_format_name: percent_1
  }













}
