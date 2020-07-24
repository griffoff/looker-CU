include: "//cube/additional_info.course_section_facts.view.lkml"
include: "//core/common.lkml"
view: user_courses {
  view_label: "User Courses"
#   sql_table_name: prod.cu_user_analysis.user_courses ;;
derived_table: {
  sql: Select *, (cu_subscription_id IS NOT NULL AND cu_subscription_id <> 'TRIAL') OR cui_flag = 'Y' as cu_flag
        from prod.cu_user_analysis.user_courses  ;;
}

  set: marketing_fields {
    fields: [user_courses.net_price_enrolled, user_courses.amount_to_upgrade_tiers, user_courses.ala_cart_purchases, user_courses.distinct_ala_cart_purchase
      , user_courses.cu_subscription_id, user_courses.cui_flag, user_courses.no_enrollments, user_courses.cu_flag, user_courses.cu_purchase, user_courses.activations_minus_a_la_carte,
      user_courses.enrollments_minus_activations, user_courses_dev.net_price_enrolled, user_courses_dev.amount_to_upgrade_tiers, user_courses_dev.ala_cart_purchases, user_courses_dev.distinct_ala_cart_purchase
      , user_courses_dev.cu_subscription_id, user_courses_dev.cui_flag, user_courses_dev.no_enrollments, user_courses_dev.cu_flag, user_courses_dev.cu_purchase,no_activated
      ,current_enrollments,current_activations,current_students,current_activations_cu,current_activations_non_cu, current_not_activated_enrollments,current_course_sections]
  }

  dimension: isbn {
    type: string
    description: "OLR course ISBN"
  }

  dimension: grace_period_flag {
    group_label: "Grace Period?"
    type: yesno
    sql: ${TABLE}."GRACE_PERIOD_FLAG" = 'Yes';;
    label: "In grace period"
    description: "User has enrolled on a course but not activated and enrollment date was in the last 14 days"
  }

  dimension: grace_period_description {
    type: string
    group_label: "Grace Period?"
    sql: CASE WHEN ${activated} THEN 'Paid' WHEN ${grace_period_flag} THEN 'In Grace Period' ELSE 'Unpaid, Grace period expired' END ;;
    label: "In grace period (Description)"
    description: "In Grace Period / Paid / Unpaid, Grace period expired"
  }

  dimension: amount_to_upgrade_tiers {
    view_label: "Learner Profile"
    type: string
    sql: CASE
            WHEN ${net_price_enrolled} = 0 THEN '$0'
            WHEN ${net_price_enrolled} < 10 THEN '$0.01-$9.99'
            WHEN ${net_price_enrolled} < 20 THEN '$10.00-$19.99'
            WHEN ${net_price_enrolled} < 30 THEN '$20.00-$29.99'
            WHEN ${net_price_enrolled} < 40 THEN '$30.00-$39.99'
            WHEN ${net_price_enrolled} < 50 THEN '$40.00-$49.99'
            ELSE 'over $50.00'
            END
            ;;
    hidden:  yes
  }

  dimension_group: week_in_course {
    label: "Time in course"
    type: duration
    sql_start: ${course_start_date} ;;
    sql_end: CURRENT_DATE() ;;
    intervals: [week]
    description: "The difference in weeks from the course start date to the current date."
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    hidden: yes
  }

  dimension: instructor_guid {
    type: string
    sql: ${TABLE}."INSTRUCTOR_GUID" ;;
    description: "Course instructor GUID"
  }

  dimension: entity_id {
    type: string
    description: "Institution/school ID#"
    sql: ${TABLE}."ENTITY_ID"::string ;;
  }

  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
    group_label: "Payment Information"
    label: "Paid"
    description: "paid_in_full flag from OLR enrollments table OR activation record for the user_sso_guid and context_id pair"
  }

  dimension: paid_in_full {
    type: yesno
    hidden: yes
    sql: ${TABLE}."PAID_IN_FULL" = 'true' ;;
    group_label: "Payment Information"
    label: "Paid in full"
    description: "paid_in_full flag from OLR enrollments table"
  }

  dimension: payment_code {
    type: string
    sql: ${TABLE}."PAYMENT_CODE"::string ;;
    group_label: "Payment Information"
    label: "Payment code"
    description: "Payment code from OLR enrollments table"
  }

  dimension: payment_isbn13 {
    type: string
    sql: ${TABLE}."PAYMENT_ISBN13"::string ;;
    group_label: "Payment Information"
    label: "Payment ISBN13"
    description: "Payment ISBN13 from OLR enrollments table"
  }




#   dimension: is_new_customer {
#     group_label: "Instructor"
#     label: "Is New Instructor"
#     type: string
#     sql:  ${TABLE}."IS_NEW_CUSTOMER" ;;
#   }
#
#   dimension: is_returning_customer {
#     group_label: "Instructor"
#     label: "Is Returning Instructor"
#     type: string
#     sql:  ${TABLE}."IS_RETURNING_CUSTOMER" ;;
#   }

  dimension: pk {
    sql: HASH(${user_sso_guid}, ${olr_course_key}) ;;
    primary_key: yes
    hidden: yes
  }

  dimension: olr_activation_key {
    type: string
    sql: ${TABLE}."ACTIVATION_CODE" ;;
    description: "OLR Activation code"

  }

  dimension: olr_course_key {
    type: string
    sql: ${TABLE}."OLR_COURSE_KEY" ;;
    alias: [captured_key]
    description: "OLR user course key"
  }

  dimension: course_start_date {
    type: date_raw
    sql: ${TABLE}."COURSE_START_DATE"
    ;;
  }

  dimension: course_end_date {
    type: date_raw
  }

  dimension: product_type {
    type: string
    description: "can be filtered on to differentiate between MT,WA,SAM,etc."
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: olr_enrollment_key {
    type: string
    sql: ${TABLE}."OLR_ENROLLMENT_KEY" ;;
    hidden: yes
  }

  dimension: enrolled {
    group_label: "Enrolled?"
    description: "OLR enrollment has occurred Y/N"
    type: yesno
    sql: ${TABLE}.enrolled = 'True'  ;;
    hidden: no
  }

  dimension: enrolled_current {
    label: "Currently enrolled"
    group_label: "Enrolled?"
    description: "Enrolled on a course with a future end date"
    type: yesno
    sql: ${TABLE}.enrolled::BOOLEAN and ${course_end_date} > CURRENT_DATE()  ;;
    hidden: no
  }

  dimension: enrolled_desc {
    group_label: "Enrolled?"
    label: "Enrolled (Description)"
    description: "Enrolled / Not Enrolled"
    type: string
    sql: CASE WHEN ${enrolled} THEN 'Enrolled' ELSE 'Not enrolled' END  ;;
    hidden: no
  }

  dimension: activated {
    group_label: "Activated?"
    description: "Course has been activated Y/N"
    type: yesno
    sql: ${TABLE}.activated = 'True'  ;;
    hidden: no
  }

  dimension: activated_current {
    label: "Currently activated"
    group_label: "Activated?"
    description: "Activated on a course with a future end date"
    type: yesno
    sql: ${TABLE}.activated::BOOLEAN and ${course_end_date} > CURRENT_DATE()  ;;
    hidden: no
  }

  dimension: activated_desc {
    group_label: "Activated?"
    description: "Activated / Not Activated"
    label: "Activated (Description)"
    type: string
    sql: CASE WHEN ${activated} THEN 'Activated' ELSE 'Not activated' END  ;;
    hidden: no
  }

  dimension: net_price_enrolled {
    description: "Value of product, only populated if user is enrolled"
    label: "$ value of enrolled courses"
    type: number
    sql: ${TABLE}."NET_PRICE_ENROLLED" ;;
  }

  dimension: cu_price {
    sql: 120 ;;
    hidden: yes
  }

  dimension: overpayment {
    case: {
        when:{
          sql:${net_price_enrolled} > 120 and not ${cu_flag};;
          label: "Overpaid (a'la carte)"
          }
        when:{
          sql:not ${activated};;
          label: "No payment"
        }
        else: "Bought CU"
      }
      description: "Overpaid = user has enrolled in >$120 in courses and is not CU subscribed"
  }

  measure: distinct_ala_cart_purchase {
    label:  "# of a la carte purchases (distinct)"
    type: count_distinct
    sql: CASE WHEN NOT ${TABLE}.cu_flag AND ${activated} THEN HASH(${user_sso_guid}, ${isbn}) END;;
    description: "Count of distinct products activated by non-CU subscribers"
  }

  dimension: has_ala_cart_purchase_current {
    label:  "Has current a la carte purchase"
    type: yesno
    sql: NOT ${TABLE}.cu_flag AND ${activated} AND ${course_end_date} > CURRENT_DATE();;
    description: "Count of distinct courseware products activated by non-CU subscribers for courses with a future end date"
  }

  measure: distinct_ala_cart_purchase_current {
    label:  "# of current a la carte purchases (distinct)"
    type: count_distinct
    sql: CASE WHEN NOT ${TABLE}.cu_flag AND ${activated} AND ${course_end_date} > CURRENT_DATE() THEN HASH(${user_sso_guid}, ${isbn}) END;;
    description: "Count of distinct courseware products activated by non-CU subscribers for courses with a future end date"
  }

  dimension: cu_subscription_id {
    group_label: "Subscription"
    type: string
    sql: ${TABLE}.cu_subscription_id;;
    label: "CU Subscription ID"
    description: "Unique contract ID for Cengage Unlimited Subscription"
    hidden: no
    alias: [cu_contract_id]
  }

#   dimension: cui_flag {
#     type: string
#     # the CUI field is incorrectly named - needs to be switched to just CU
#     sql: ${TABLE}.cui_flag;;
#     hidden: no
#     label: "CU Flag"
#     description: "Flag to identify Cengage Unlimited Subscriptions"
#   }


  dimension: cu_flag {
    group_label: "Subscription"
     type: yesno
     label: "CU Flag"
    description: "Cengage Unlimited subscribed (non-trial) Y/N"
#     hidden: no
  }

  dimension: cu_flag_desc {
    group_label: "Subscription"
    type: string
    sql: CASE WHEN ${cu_flag} THEN 'Paid by subscription' WHEN ${activated} THEN 'Paid direct' ELSE 'Not paid' END;;
    label: "CU Flag (Description)"
    description: "Paid by subscription / Paid direct / Not paid"
#     hidden: no
  }

  dimension: activation_code {
    type: string
    sql: ${TABLE}."ACTIVATION_CODE" ;;
    hidden: yes
  }

  measure: ala_cart_purchases {
    group_label: "Activations"
    label: "# Non-CU activations"
    type: sum
    sql: CASE WHEN NOT ${cu_flag} AND ${activated} THEN 1 END;;
    description: "Total # of activations from non-CU subscribers (all time)"
  }

  measure: cu_purchase {
    group_label: "Activations"
    label: "# CU activations"
    type: sum
    sql: CASE WHEN ${cu_flag} AND ${activated} THEN 1 END;;
    description: "Total # of activations from CU subscribers (all time)"
  }

  measure: no_enrollments {
    group_label: "Enrollments"
    label: "# Enrollments"
    type: count_distinct
    sql: CASE WHEN ${enrolled} THEN ${pk} END  ;;
    description: "Total # of enrollments (all time)"
  }

  measure: no_paid_enrollments {
    group_label: "Enrollments"
    label: "# Paid enrollments"
    type: count_distinct
    sql: CASE WHEN ${enrolled} AND ${paid} THEN ${pk} END  ;;
    description: "Total # of paid enrollments (all time)"
  }

  measure: no_activated {
    group_label: "Activations"
    label: "# Activations"
    type: count_distinct
    sql: CASE WHEN ${activated} THEN ${pk} END  ;;
    description: "Total # of activations (all time)"
  }

  measure: no_courses_with_activations {
    group_label: "Activations"
    label: "# Courses with activations"
    type: count_distinct
    sql: CASE WHEN ${activated} THEN ${olr_course_key} END  ;;
    description: "Total # of distinct courses (by course key) with activations (all time)"
  }

  measure: enrolled_courses {
    group_label: "Enrollments"
    label: "# Users with Enrolled Courses"
    description: "Number of users with an enrolled course"
    type: count_distinct
    sql: case when ${enrolled} then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }

  measure: enrollments_minus_activations {
    group_label: "Enrollments"
    label: "# Unpaid Enrollments"
    type: number
    sql: greatest(${no_enrollments} -  ${no_paid_enrollments}, 0) ;;
    description: "Total # of non-activated enrollments (all time)"
  }

  measure: current_course_sections {
    group_label: ""
    label: "# Currently active courses"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() THEN ${olr_course_key} END   ;;
    drill_fields: [marketing_fields*]
    description: "Distinct count of courses (by course key) that have not yet ended"
  }

  measure: current_enrollments {
    group_label: "Enrollments"
    label: "# Current enrollments"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${enrolled} THEN ${pk} END   ;;
    drill_fields: [marketing_fields*]
    description: "Count of distinct course enrollments for courses that have not yet ended"
  }

  measure: current_paid_enrollments {
    group_label: "Enrollments"
    label: "# Current paid enrollments"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${enrolled} AND ${paid} THEN ${pk} END   ;;
    drill_fields: [marketing_fields*]
    description: "Count of distinct paid course enrollments on courses that have not yet ended"
  }

  measure: current_activations {
    group_label: "Activations"
    label: "# Current activations"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${activated} THEN ${pk} END   ;;
    drill_fields: [marketing_fields*]
    description: "Count of distinct course activations on courses that have not yet ended"
  }

  measure: current_activations_non_cu {
    group_label: "Activations"
    label: "# Current Non CU activations"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${activated} AND NOT ${cu_flag} THEN ${pk} END   ;;
    description: "Count of distinct course activations that have not yet ended from non-CU users"
    drill_fields: [marketing_fields*]
  }


  measure: current_activations_cu {
    group_label: "Activations"
    label: "# Current CU activations"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${activated} AND ${cu_flag} THEN ${pk} END   ;;
    description: "Count of distinct course activations that have not yet ended from CU users"
    drill_fields: [marketing_fields*]
  }

  measure: current_not_activated_enrollments {
    group_label: "Activations"
    label: "# Current not activated"
    type: number
    sql: ${current_enrollments} - ${current_activations}   ;;
    drill_fields: [marketing_fields*]
    description: "Count of distinct non-activated course enrollments that have not yet ended"
  }

  measure: current_students {
    group_label: "Enrollments"
    label: "# Current students"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() THEN ${user_sso_guid} END   ;;
    drill_fields: [marketing_fields*]
    description: "Distinct count of students enrolled in courses that have not ended"
  }

  measure: student_course_list {
    type: string
    sql: LISTAGG(DISTINCT ${dim_course.coursename}, ', ') ;;
    description: "List of student courses"
  }

  dimension: enrollment_date {
    label: "Enrollment Date"
    description: "Date on which user enrolled into a course"
    type: date
  }

  measure: user_course_count {
    hidden: yes
    type: count_distinct
    sql: hash(${user_sso_guid}, ${olr_course_key}) ;;
  }

  measure: user_count {
    hidden: yes
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  measure: courses_per_student {
    type: number
    label: "# Courses per Student"
    #required_fields: [learner_profile.count]
    #sql: ${user_course_count} / ${learner_profile.count}  ;;
    sql: ${user_course_count} / NULLIF(${user_count}, 0)  ;;
    value_format_name: decimal_1
    description: "Total unique course enrollments divided by total number of distinct users"
  }

#   measure: courses_used_per_student {
#     type: number
#     label: "# courses used per Student"
#     #required_fields: [learner_profile.count]
#     #sql: ${user_course_count} / ${learner_profile.count}  ;;
#     sql:  ${guid_course_used.user_courses_used} /${user_count} ;;
#     value_format_name: decimal_2
#   }
#


}
