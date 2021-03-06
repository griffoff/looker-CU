# include: "//core/common.lkml"
# include: "course_info.view"
# include: "institution_info.view"
# # include: "guid_latest_course_activity.view"
# # include: "guid_course_used.view"

# explore: user_courses {
#   hidden: yes
#   join: course_info {
#     sql_on: ${user_courses.olr_course_key} = ${course_info.course_key} ;;
#     relationship: many_to_one
#   }

#   # join: guid_latest_course_activity {
#   #   view_label: "Course Section Details by User"
#   #   sql_on: ${user_courses.user_sso_guid} = ${guid_latest_course_activity.user_sso_guid}
#   #     and ${user_courses.olr_course_key} = ${guid_latest_course_activity.course_key};;
#   #   relationship: one_to_one
#   # }

#   # join: guid_course_used {
#   #   view_label: "Course Section Details by User"
#   #   sql_on: ${user_courses.user_sso_guid} = ${guid_course_used.user_sso_guid}
#   #     and ${user_courses.olr_course_key} = ${guid_course_used.course_key};;
#   #   relationship: one_to_one
#   # }

#   join: institution_info {
#     sql_on: ${user_courses.entity_id} = ${institution_info.institution_id} ;;
#     relationship: many_to_one
#   }
# }

# view: user_courses {
#   view_label: "User Courses"
# #   sql_table_name: prod.cu_user_analysis.user_courses ;;
# derived_table: {
#   create_process: {
#     sql_step:
#     create or replace transient table ${SQL_TABLE_NAME}
#     cluster by (user_sso_guid)
#     as
#     select u.*
#       , sg.lms_user_id
#       , sg.canvas_user_id
#       , sg.lis_person_source_id
#       , sg.deleted
#       , (cu_subscription_id IS NOT NULL AND cu_subscription_id <> 'TRIAL' AND hs.SUBSCRIPTION_ID is not null and coalesce(ss.subscription_plan_id,'') not ilike '%trial%') OR coalesce(cui_flag,'N') = 'Y' as cu_flag
#       , coalesce(try_cast(paid as boolean),false) as paid_bool
#       , coalesce(try_cast(activated as boolean),false) as activated_bool
#       , coalesce(TRY_CAST(enrolled AS BOOLEAN),false) as enrolled_bool
#       , coalesce(course_end_date > CURRENT_DATE(),false) as current_course
#       , HASH(user_sso_guid, olr_course_key) as pk
#       , count(distinct case when (paid_bool or activated_bool) and current_course then pk end) over (partition by user_sso_guid) as current_paid_count
#       , count(distinct case when enrolled_bool and current_course then pk end) over (partition by user_sso_guid) as current_enrollments_count
#       , count(distinct entity_id) over (partition by user_sso_guid) as user_entity_count
#       , last_value(entity_id IGNORE NULLS) over (partition by user_sso_guid order by course_start_date) as current_entity_id
#       , last_value(entity_name IGNORE NULLS) over (partition by user_sso_guid order by course_start_date) as current_institution_name
#       , last_value(product_type IGNORE NULLS) over (partition by user_sso_guid order by course_start_date) as current_product_type
#     from prod.cu_user_analysis.user_courses u
#     left join prod.DATAVAULT.HUB_SUBSCRIPTION hs on hs.SUBSCRIPTION_ID = u.CU_SUBSCRIPTION_ID
#     left join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP ss on ss.HUB_SUBSCRIPTION_KEY = hs.HUB_SUBSCRIPTION_KEY and ss._LATEST
#     left join PROD.DATAVAULT.HUB_USER_GATEWAY hg on hg.UID = u.USER_SSO_GUID
#     left join PROD.DATAVAULT.SAT_USER_GATEWAY sg on sg.HUB_USERGATEWAY_KEY = hg.HUB_USERGATEWAY_KEY
#     order by user_sso_guid
#     ;;

#   }
#   datagroup_trigger: daily_refresh
# }

#   set: marketing_fields {
#     fields: [user_courses.net_price_enrolled, user_courses.amount_to_upgrade_tiers, user_courses.ala_cart_purchases, user_courses.distinct_ala_cart_purchase
#       , user_courses.cu_subscription_id, user_courses.cui_flag, user_courses.no_enrollments, user_courses.cu_flag, user_courses.cu_purchase, user_courses.activations_minus_a_la_carte,
#       user_courses.enrollments_minus_activations, user_courses_dev.net_price_enrolled, user_courses_dev.amount_to_upgrade_tiers, user_courses_dev.ala_cart_purchases, user_courses_dev.distinct_ala_cart_purchase
#       , user_courses_dev.cu_subscription_id, user_courses_dev.cui_flag, user_courses_dev.no_enrollments, user_courses_dev.cu_flag, user_courses_dev.cu_purchase,no_activated
#       ,current_enrollments,current_activations,current_students,current_activations_cu,current_activations_non_cu, current_not_activated_enrollments,current_course_sections]
#   }

#   dimension: current_paid_count {type:number hidden:yes}
#   dimension: current_enrollments_count {type:number hidden:yes}
#   dimension: user_entity_count {type:number hidden:yes}

#   dimension: current_entity_id {
#     description: "Entity ID for user's most recent course by start date"
#   }

#   dimension: current_institution_name {
#     description: "Institution name for user's most recent course by start date"
#   }

#   dimension: current_product_type {
#     description: "Product type for user's most recent course by start date"
#   }

#   dimension: isbn {
#     type: string
#     description: "OLR course ISBN"
#   }

#   dimension: grace_period_flag {
#     group_label: "Grace Period?"
#     type: yesno
#     sql: ${TABLE}."GRACE_PERIOD_FLAG" = 'Yes';;
#     label: "In grace period"
#     description: "User has enrolled on a course but not activated and enrollment date was in the last 14 days"
#   }

#   dimension: grace_period_description {
#     type: string
#     group_label: "Grace Period?"
#     sql: CASE WHEN ${activated} THEN 'Paid' WHEN ${grace_period_flag} THEN 'In Grace Period' ELSE 'Unpaid, Grace period expired' END ;;
#     label: "In grace period (Description)"
#     description: "In Grace Period / Paid / Unpaid, Grace period expired"
#   }

#   dimension: amount_to_upgrade_tiers {
#     view_label: "Learner Profile"
#     type: string
#     sql: CASE
#             WHEN ${net_price_enrolled} = 0 THEN '$0'
#             WHEN ${net_price_enrolled} < 10 THEN '$0.01-$9.99'
#             WHEN ${net_price_enrolled} < 20 THEN '$10.00-$19.99'
#             WHEN ${net_price_enrolled} < 30 THEN '$20.00-$29.99'
#             WHEN ${net_price_enrolled} < 40 THEN '$30.00-$39.99'
#             WHEN ${net_price_enrolled} < 50 THEN '$40.00-$49.99'
#             ELSE 'over $50.00'
#             END
#             ;;
#     hidden:  yes
#   }

#   dimension_group: week_in_course {
#     label: "Time in course"
#     type: duration
#     sql_start: ${course_start_raw} ;;
#     sql_end: CASE WHEN ${course_end_raw} < CURRENT_DATE() THEN ${course_end_raw} ELSE CURRENT_DATE() END ;;
#     intervals: [week]
#     description: "The difference in weeks from the course start date to the current date or the course end date for completed courses."
#   }

#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#     hidden: yes
#   }

#   dimension: canvas_user_id {
#     label: "Canvas User ID"
#     type: string
#     sql: ${TABLE}.canvas_user_id ;;
#     hidden: no
#   }

#   dimension: lms_user_id {
#     label: "lms User ID"
#     type: string
#     sql: ${TABLE}.lms_user_id ;;
#     hidden: no
#   }

#   dimension: sis_user_id {
#     label: "SIS User ID"
#     type: string
#     sql: ${TABLE}.lis_person_source_id ;;
#     hidden: no
#   }

#   dimension: deleted {
#     label: "Severed"
#     type: yesno
#     sql: ${TABLE}.deleted ;;
#     hidden: no
#   }

#   dimension: instructor_guid {
#     type: string
#     sql: ${TABLE}."INSTRUCTOR_GUID" ;;
#     description: "Course instructor GUID"
#     hidden: yes
#   }

#   dimension: entity_id {
#     type: string
#     description: "Institution/school ID#"
#     sql: ${TABLE}."ENTITY_ID"::string ;;
#     hidden:yes
#   }

#   dimension: paid {
#     type: yesno
#     sql: (${TABLE}.paid_bool or ${TABLE}.activated_bool) ;;
#     group_label: "Payment Information"
#     label: "Paid"
#     description: "paid_in_full flag from OLR enrollments table OR activation record for the user_sso_guid and context_id pair"
#   }

#   dimension: date_paid {
#     type: date
#     sql: case when ${paid} then coalesce(${TABLE}.activation_date,${TABLE}.enrollment_date,${TABLE}.course_start_date)::date end ;;
#     group_label: "Payment Information"
#     label: "Date paid (approximate)"
#     description: "Activation date or enrollment date / course start date when paid flag is true"
#     hidden: yes
#   }

#   dimension_group: paid {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       month_name,
#       year,
#       day_of_week,
#       week_of_year,
#       day_of_year
#     ]
#     sql: case when ${paid} then coalesce(${TABLE}.activation_date,${TABLE}.enrollment_date,${TABLE}.course_start_date)::date end ;;
#     label: "Approximate Paid"
#     # group_label: "Payment Information"
#     description: "Activation date or enrollment date / course start date when paid flag is true"
#   }

#   dimension: paid_current {
#     type: yesno
#     sql:(${paid}) and ${course_end_raw} > CURRENT_DATE();;
#     group_label: "Payment Information"
#     label: "Paid Current"
#     description: "paid_in_full flag from OLR enrollments table OR activation record for the user_sso_guid and context_id pair AND course has future end date"
#   }

#   dimension: unpaid_current {
#     type: yesno
#     sql:(NOT ${paid}) and ${course_end_raw} > CURRENT_DATE();;
#     group_label: "Payment Information"
#     label: "Unpaid Current"
#     description: "No paid flag or activation AND course has future end date"
#   }

#   measure: current_paid {
#     group_label: "Payment Information"
#     label: "# Current Paid Courses"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} AND (${paid}) THEN ${pk} END   ;;
#     drill_fields: [marketing_fields*]
#     description: "Count of distinct paid user courses (guid+coursekey combo) that have not yet ended"
#   }

#   dimension: paid_in_full {
#     type: yesno
#     hidden: yes
#     sql: coalesce(TRY_CAST(${TABLE}."PAID_IN_FULL"  AS BOOLEAN),false) ;;
#     group_label: "Payment Information"
#     label: "Paid in full"
#     description: "paid_in_full flag from OLR enrollments table"
#   }



#   dimension: payment_code {
#     type: string
#     sql: ${TABLE}."PAYMENT_CODE"::string ;;
#     group_label: "Payment Information"
#     label: "Payment code"
#     description: "Payment code from OLR enrollments table"
#   }

#   dimension: payment_isbn13 {
#     type: string
#     sql: ${TABLE}."PAYMENT_ISBN13"::string ;;
#     group_label: "Payment Information"
#     label: "Payment ISBN13"
#     description: "Payment ISBN13 from OLR enrollments table"
#   }

#   dimension: pk {
#     primary_key: yes
#     hidden: yes
#   }

#   dimension: olr_activation_key {
#     type: string
#     sql: ${TABLE}."ACTIVATION_CODE" ;;
#     description: "OLR Activation code"

#   }

#   dimension: olr_course_key {
#     type: string
#     sql: ${TABLE}."OLR_COURSE_KEY" ;;
#     alias: [captured_key]
#     description: "OLR user course key"
#   }

#   dimension: current_course {
#     type: yesno
#     hidden: no
#     description: "Course end date is in the future"
#   }

#   dimension_group: course_start {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       month_name,
#       year,
#       day_of_week,
#       week_of_year,
#       day_of_year
#       ]
#     sql: ${TABLE}."COURSE_START_DATE"
#     ;;
#   }

#   dimension_group: course_end {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       month_name,
#       year,
#       day_of_week,
#       week_of_year,
#       day_of_year
#       ]
#     sql: ${TABLE}."COURSE_END_DATE"
#       ;;
#   }

#   dimension_group: activation {
#     sql: ${TABLE}.activation_date ;;
#     label: "Activation"
#     description: "Date on which user activated course"
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       month_name,
#       year,
#       day_of_week,
#       week_of_year,
#       day_of_year
#       ]
#   }

#   dimension: activation_fiscal_year {
#     sql: left(date_trunc(year,dateadd(month,9,CONVERT_TIMEZONE('UTC',${activation_date}))),4) ;;
#     group_label: "Activation Date"
#     label: "Fiscal Year"
#   }

#   dimension: product_type {
#     type: string
#     description: "can be filtered on to differentiate between MT,WA,SAM,etc."
#     sql: ${TABLE}."PRODUCT_TYPE" ;;
#   }

#   dimension: olr_enrollment_key {
#     type: string
#     sql: ${TABLE}."OLR_ENROLLMENT_KEY" ;;
#     hidden: yes
#   }

#   dimension: enrolled {
#     group_label: "Enrolled?"
#     description: "OLR enrollment has occurred Y/N"
#     type: yesno
#     sql: ${TABLE}.enrolled_bool  ;;
#     hidden: no
#   }

#   dimension: enrolled_current {
#     label: "Currently enrolled"
#     group_label: "Enrolled?"
#     description: "Enrolled on a course with a future end date"
#     type: yesno
#     sql: ${enrolled} and ${current_course}  ;;
#     hidden: no
#   }

#   dimension: enrolled_desc {
#     group_label: "Enrolled?"
#     label: "Enrolled (Description)"
#     description: "Enrolled / Not Enrolled"
#     type: string
#     sql: CASE WHEN ${enrolled} THEN 'Enrolled' ELSE 'Not enrolled' END  ;;
#     hidden: no
#   }

#   dimension: activated {
#     group_label: "Activated?"
#     description: "Course has been activated Y/N"
#     type: yesno
#     sql: coalesce(TRY_CAST(${TABLE}.activated AS BOOLEAN),false)  ;;
#     hidden: no
#   }

#   dimension: activated_current {
#     label: "Currently activated"
#     group_label: "Activated?"
#     description: "Activated on a course with a future end date"
#     type: yesno
#     sql: ${activated} and ${current_course}  ;;
#     hidden: no
#   }

#   dimension: activated_desc {
#     group_label: "Activated?"
#     description: "Activated / Not Activated"
#     label: "Activated (Description)"
#     type: string
#     sql: CASE WHEN ${activated} THEN 'Activated' ELSE 'Not activated' END  ;;
#     hidden: no
#   }

#   dimension: net_price_enrolled {
#     description: "Value of product, only populated if user is enrolled"
#     label: "$ value of enrolled courses"
#     type: number
#     sql: ${TABLE}."NET_PRICE_ENROLLED" ;;
#     value_format: "$0.00"
#   }

#   dimension: net_price {
#     description: "Value of product regardless of paid status"
#     label: "$ value of course"
#     type: number
#     sql: ${TABLE}.net_price ;;
#     value_format: "$0.00"
#   }

#   measure: net_price_paid {
#     label: "Total $ value of all paid courses"
#     type: sum
#     sql: case when ${paid} then ${net_price} end ;;
#     value_format: "$0.00"
#   }

#   measure: net_price_paid_current {
#     label: "Total $ value of all paid active courses"
#     type: sum
#     sql: case when ${paid} and ${current_course} then ${net_price} end ;;
#     value_format: "$0.00"
#   }

#   dimension: cu_price {
#     sql: 120 ;;
#     hidden: yes
#   }

#   dimension: overpayment {
#     case: {
#         when:{
#           sql:${net_price_enrolled} > 120 and not ${cu_flag};;
#           label: "Overpaid (a'la carte)"
#           }
#         when:{
#           sql:not ${activated};;
#           label: "No payment"
#         }
#         else: "Bought CU"
#       }
#       description: "Overpaid = user has enrolled in >$120 in courses and is not CU subscribed"
#   }

#   measure: distinct_ala_cart_purchase {
#     label:  "# of a la carte purchases (distinct)"
#     type: count_distinct
#     sql: CASE WHEN NOT ${TABLE}.cu_flag AND (${activated} or ${paid}) THEN HASH(${user_sso_guid}, ${isbn}) END;;
#     description: "Count of distinct products activated by non-CU subscribers"
#   }

#   dimension: has_ala_cart_purchase_current {
#     label:  "Has current a la carte purchase"
#     type: yesno
#     sql: NOT ${TABLE}.cu_flag AND (${activated} or ${paid}) AND ${current_course};;
#     description: "Count of distinct courseware products activated by non-CU subscribers for courses with a future end date"
#   }

#   measure: distinct_ala_cart_purchase_current {
#     label:  "# of current a la carte purchases (distinct)"
#     type: count_distinct
#     sql: CASE WHEN NOT ${TABLE}.cu_flag AND (${activated} or ${paid}) AND ${current_course} THEN HASH(${user_sso_guid}, ${isbn}) END;;
#     description: "Count of distinct courseware products activated by non-CU subscribers for courses with a future end date"
#   }

#   dimension: cu_subscription_id {
#     group_label: "Subscription"
#     type: string
#     sql: ${TABLE}.cu_subscription_id;;
#     label: "CU Subscription ID"
#     description: "Unique contract ID for Cengage Unlimited Subscription"
#     hidden: no
#     alias: [cu_contract_id]
#   }

# #   dimension: cui_flag {
# #     type: string
# #     # the CUI field is incorrectly named - needs to be switched to just CU
# #     sql: ${TABLE}.cui_flag;;
# #     hidden: no
# #     label: "CU Flag"
# #     description: "Flag to identify Cengage Unlimited Subscriptions"
# #   }


#   dimension: cu_flag {
#     group_label: "Subscription"
#     type: yesno
#     label: "CU Flag"
#     description: "Cengage Unlimited subscribed (non-trial) Y/N"
# #     hidden: no
#   }

#   dimension: cu_flag_desc {
#     group_label: "Subscription"
#     type: string
#     sql: CASE WHEN ${cu_flag} THEN 'Paid by subscription' WHEN ${activated} THEN 'Paid direct' ELSE 'Not paid' END;;
#     label: "CU Flag (Description)"
#     description: "Paid by subscription / Paid direct / Not paid"
# #     hidden: no
#   }

#   dimension: activation_code {
#     type: string
#     sql: ${TABLE}."ACTIVATION_CODE" ;;
#     hidden: yes
#   }

#   measure: ala_cart_purchases {
#     group_label: "Activations"
#     label: "# Non-CU activations"
#     type: sum
#     sql: CASE WHEN NOT ${cu_flag} AND ${activated} THEN 1 END;;
#     description: "Total # of activations from non-CU subscribers (all time)"
#   }

#   measure: cu_purchase {
#     group_label: "Activations"
#     label: "# CU activations"
#     type: sum
#     sql: CASE WHEN ${cu_flag} AND ${activated} THEN 1 END;;
#     description: "Total # of activations from CU subscribers (all time)"
#   }

#   measure: no_enrollments {
#     group_label: "Enrollments"
#     label: "# Enrollments"
#     type: count_distinct
#     sql: CASE WHEN ${enrolled} THEN ${pk} END  ;;
#     description: "Total # of enrollments (all time)"
#   }

#   measure: no_paid_enrollments {
#     group_label: "Enrollments"
#     label: "# Paid enrollments"
#     type: count_distinct
#     sql: CASE WHEN ${enrolled} AND ${paid} THEN ${pk} END  ;;
#     description: "Total # of paid enrollments (all time)"
#   }

#   measure: no_activated {
#     group_label: "Activations"
#     label: "# Activations"
#     type: count_distinct
#     sql: CASE WHEN ${activated} THEN ${pk} END  ;;
#     description: "Total # of activations (all time)"
#   }

#   measure: no_courses_with_activations {
#     group_label: "Activations"
#     label: "# Courses with activations"
#     type: count_distinct
#     sql: CASE WHEN ${activated} THEN ${olr_course_key} END  ;;
#     description: "Total # of distinct courses (by course key) with activations (all time)"
#   }

#   measure: enrolled_courses {
#     group_label: "Enrollments"
#     label: "# Users with Enrolled Courses"
#     description: "Number of users with an enrolled course"
#     type: count_distinct
#     sql: case when ${enrolled} then ${user_sso_guid} end;;
#     value_format_name: decimal_0
#   }

#   measure: enrollments_minus_activations {
#     group_label: "Enrollments"
#     label: "# Unpaid Enrollments"
#     type: number
#     sql: greatest(${no_enrollments} -  ${no_paid_enrollments}, 0) ;;
#     description: "Total # of non-activated enrollments (all time)"
#   }

#   measure: current_course_sections {
#     group_label: ""
#     label: "# Currently active courses"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} THEN ${olr_course_key} END   ;;
#     drill_fields: [marketing_fields*]
#     description: "Distinct count of courses (by course key) that have not yet ended"
#   }

#   measure: current_enrollments {
#     group_label: "Enrollments"
#     label: "# Current enrollments"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} AND ${enrolled} THEN ${pk} END   ;;
#     drill_fields: [marketing_fields*]
#     description: "Count of distinct course enrollments for courses that have not yet ended"
#   }

#   measure: current_paid_enrollments {
#     group_label: "Enrollments"
#     label: "# Current paid enrollments"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} AND ${enrolled} AND ${paid} THEN ${pk} END   ;;
#     drill_fields: [marketing_fields*]
#     description: "Count of distinct paid course enrollments on courses that have not yet ended"
#   }

#   measure: current_activations {
#     group_label: "Activations"
#     label: "# Current activations"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} AND ${activated} THEN ${pk} END   ;;
#     drill_fields: [marketing_fields*]
#     description: "Count of distinct course activations on courses that have not yet ended"
#   }

#   measure: current_activations_non_cu {
#     group_label: "Activations"
#     label: "# Current Non CU activations"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} AND ${activated} AND NOT ${cu_flag} THEN ${pk} END   ;;
#     description: "Count of distinct course activations that have not yet ended from non-CU users"
#     drill_fields: [marketing_fields*]
#   }


#   measure: current_activations_cu {
#     group_label: "Activations"
#     label: "# Current CU activations"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} AND ${activated} AND ${cu_flag} THEN ${pk} END   ;;
#     description: "Count of distinct course activations that have not yet ended from CU users"
#     drill_fields: [marketing_fields*]
#   }

#   measure: current_not_activated_enrollments {
#     group_label: "Activations"
#     label: "# Current not activated"
#     type: number
#     sql: ${current_enrollments} - ${current_activations}   ;;
#     drill_fields: [marketing_fields*]
#     description: "Count of distinct non-activated course enrollments that have not yet ended"
#   }

#   measure: current_students {
#     group_label: "Enrollments"
#     label: "# Current students"
#     type: count_distinct
#     sql: CASE WHEN ${current_course} THEN ${user_sso_guid} END   ;;
#     drill_fields: [marketing_fields*]
#     description: "Distinct count of students enrolled in courses that have not ended"
#   }

#   measure: student_course_list {
#     # group_label: "Course Lists"
#     type: string
#     sql: CASE
#           WHEN COUNT(DISTINCT ${olr_course_key}) > 10 THEN ' More than 10 courses... '
#           ELSE
#           LISTAGG(DISTINCT CASE WHEN ${current_course} THEN ${course_info.course_name} END, ', ')
#             WITHIN GROUP (ORDER BY CASE WHEN ${current_course} THEN ${course_info.course_name} END)
#         END ;;
#     description: "List of Active Course Names"
#   }

#   measure: student_course_list_extended {
#     group_label: "Course Lists"
#     label: "Student Course List (with dates)"
#     type: string
#     sql: CASE
#           WHEN COUNT(DISTINCT ${olr_course_key}) > 10 THEN ' More than 10 courses... '
#           ELSE
#           LISTAGG(DISTINCT CASE WHEN ${current_course} THEN ${course_info.course_name} || ' (' || TO_CHAR(${course_start_raw}, 'mon-yy') || ' - ' || TO_CHAR(${course_end_raw}, 'mon-yy') || ')' END, ', ')
#             WITHIN GROUP (ORDER BY CASE WHEN ${current_course} THEN ${course_info.course_name} || ' (' || TO_CHAR(${course_start_raw}, 'mon-yy') || ' - ' || TO_CHAR(${course_end_raw}, 'mon-yy') || ')' END)
#           END ;;
#     description: "List of student courses (including dates)"
#   }

#   measure: student_cu_course_list {
#     group_label: "Course Lists"
#     type: string
#     sql: LISTAGG(DISTINCT case when ${cu_flag} then ${isbn} end, ', ')
#             WITHIN GROUP (ORDER BY case when ${cu_flag} then ${isbn} end);;
#     description: "List of student CU course ISBNs"
#   }

#   measure: student_non_cu_course_list {
#     group_label: "Course Lists"
#     type: string
#     sql: LISTAGG(DISTINCT case when not ${cu_flag} then ${isbn} end, ', ')
#       WITHIN GROUP (ORDER BY case when not ${cu_flag} then ${isbn} end);;
#     description: "List of student non-CU course ISBNs"
#   }

#   dimension_group: enrollment {
#     label: "Enrollment"
#     description: "Date on which user enrolled into a course"
#     type: time
#     timeframes: [raw, date, week, month, year]
#     sql: ${TABLE}.enrollment_date ;;
#   }

#   measure: user_course_count {
#     hidden: yes
#     type: count_distinct
#     sql: hash(${user_sso_guid}, ${olr_course_key}) ;;
#   }

#   measure: user_count {
#     hidden: yes
#     type: count_distinct
#     sql: ${user_sso_guid} ;;
#   }

#   measure: courses_per_student {
#     type: number
#     label: "# Courses per Student"
#     #required_fields: [learner_profile.count]
#     #sql: ${user_course_count} / ${learner_profile.count}  ;;
#     sql: ${user_course_count} / NULLIF(${user_count}, 0)  ;;
#     value_format_name: decimal_1
#     description: "Total unique course enrollments divided by total number of distinct users"
#   }

#   measure: count {
#     type: count
#     label: "# User Courses"
#     description: "# of user course records (distinct user guid + olr course key combinations)"
#   }

#   measure: course_sections {
#     group_label: ""
#     label: "# Courses"
#     type: count_distinct
#     sql: ${olr_course_key} ;;
#     drill_fields: [marketing_fields*]
#     description: "Distinct count of courses (by course key)"
#   }

#   measure: students_per_course {
#     type: number
#     label: "# Students per Course"
#     sql: ${user_count} / NULLIF(${course_sections}, 0)  ;;
#     value_format_name: decimal_1
#     description: "Total number of distinct users divided by total unique courses (by course key)"
#   }


# #   measure: courses_used_per_student {
# #     type: number
# #     label: "# courses used per Student"
# #     #required_fields: [learner_profile.count]
# #     #sql: ${user_course_count} / ${learner_profile.count}  ;;
# #     sql:  ${guid_course_used.user_courses_used} /${user_count} ;;
# #     value_format_name: decimal_2
# #   }
# #




# }
