# include: "/views/cu_user_analysis/user_courses.view"
# include: "//core/common.lkml"

# view: user_courses_dev {
#   extends: [user_courses]
#   view_label: "User Courses Dev"
#   sql_table_name: dev.cu_user_analysis.user_courses ;;

#   set: marketing_fields_dev {
#     fields: [user_courses_dev.net_price_enrolled, user_courses_dev.amount_to_upgrade_tiers, user_courses_dev.ala_cart_purchases, user_courses_dev.distinct_ala_cart_purchase
#       , user_courses_dev.cu_subscription_id, user_courses_dev.cui_flag, user_courses_dev.no_enrollments, user_courses_dev.cu_flag, user_courses_dev.cu_purchase, user_courses_dev.activations_minus_a_la_carte,
#       user_courses_dev.enrollments_minus_activations]

#   }

#   #course_used_flag

#   dimension: instructor_guid {
#     type: string
#     sql: ${TABLE}."instructor_guid" ;;
#   }

#   dimension: net_price_enrolled {
#     view_label: "Learner Profile"
#     label: "$ value of enrolled courses"
#     type: number
#     sql: ${TABLE}."NET_PRICE_ENROLLED" ;;
#   }



#   dimension: amount_to_upgrade_tiers {
#     view_label: "Learner Profile"
#     type: string
#     sql: CASE
#             WHEN ${net_price_enrolled} = 0 THEN '$0.00'
#             WHEN ${net_price_enrolled} < 10 THEN '$0.01-$9.99'
#             WHEN ${net_price_enrolled} < 20 THEN '$10.00-$19.99'
#             WHEN ${net_price_enrolled} < 30 THEN '$20.00-$29.99'
#             WHEN ${net_price_enrolled} < 40 THEN '$30.00-$39.99'
#             WHEN ${net_price_enrolled} < 50 THEN '$40.00-$49.99'
#             ELSE 'over $50.00'
#             END
#             ;;
#   }

#   dimension: course_used_flag_test {
#     type: yesno
#     sql: ${TABLE}.course_used_flag ;;
#     label: "Course used flag test"
#     description: "This user's course has both an olr course key and an activation code"
#   }



# #   dimension: courses_used {
# #     type: number
# #     sql: ARRYA_AGG(CASE WHEN course_used_flag = 'yes' THEN course_key)
# #     {olr_course_key} IS NOT NULL AND ${activation_code} IS NOT NULL;;
# #     label: "Course used flag"
# #     description: "This user's course has both an olr course key and an activation code"
# #   }


#   dimension_group: first_session_start {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."FIRST_SESSION_START" ;;
#   }

#   dimension_group: latest_session_start {
#     type: duration
#     intervals: [day, week, month]
#     sql_start: ${TABLE}."LATEST_SESSION_START" ;;
#     sql_end: CURRENT_DATE() ;;
#   }

#   dimension: session_count {
#     type: string
#     sql: ${TABLE}."SESSION_COUNT" ;;
#   }


#   dimension: activation_date {
#     type: date
#     # intervals: [day, week, month]
#   }




#   dimension: date_added {
#     type: date
#   }

#   dimension: net_price_on_dashboard {
#     type: number
#   }

# #   dimension: course_used_flag {
# #     type: yesno
# #     sql: ${olr_course_key} IS NOT NULL AND ${activation_code} IS NOT NULL;;
# #     label: "Course used flag"
# #     description: "This user's course has both an olr course key and an activation code"
# #   }


#   measure: count {
#     type: count
#     drill_fields: []
#   }


# #   measure: non_activated_enrollments {
# #     label: "# of non-activated enrollments"
# #     type: number
# #     sql: ${course_section_facts.total_noofactivations};;
# #   }



#   measure: activated_courses {
#     label: "# Users with Activated Courses"
#     type: count_distinct
#     sql: case when ${olr_activation_key} is not null then ${user_sso_guid} end;;
#     value_format_name: decimal_0
#   }

#   measure: found_courses {
#     label: "# Users with Matched OLR Course Key"
#     type: count_distinct
#     sql: case when ${olr_course_key} is not null then ${user_sso_guid} end;;
#     value_format_name: decimal_0
#   }

# #   measure: captured_course_keys {
# #     label: "# Users with Captured Course Keys"
# #     type: count_distinct
# #     sql: case when ${captured_key} is not null then ${user_sso_guid} end;;
# #     value_format_name: decimal_0
# #   }


# }
