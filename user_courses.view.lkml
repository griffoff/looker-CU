include: "//cube/additional_info.course_section_facts.view.lkml"
include: "//core/common.lkml"
view: user_courses {
  view_label: "User Courses"
#   sql_table_name: prod.cu_user_analysis.user_courses ;;
derived_table: {
  sql: Select *, (cu_contract_id IS NOT NULL AND cu_contract_id <> 'TRIAL') OR cui_flag = 'Y' as cu_flag
        from prod.cu_user_analysis.user_courses  ;;
}

  set: marketing_fields {
    fields: [user_courses.net_price_enrolled, user_courses.amount_to_upgrade_tiers, user_courses.ala_cart_purchases, user_courses.distinct_ala_cart_purchase
      , user_courses.cu_contract_id, user_courses.cui_flag, user_courses.no_enrollments, user_courses.cu_flag, user_courses.cu_purchase, user_courses.activations_minus_a_la_carte,
      user_courses.enrollments_minus_activations, user_courses_dev.net_price_enrolled, user_courses_dev.amount_to_upgrade_tiers, user_courses_dev.ala_cart_purchases, user_courses_dev.distinct_ala_cart_purchase
      , user_courses_dev.cu_contract_id, user_courses_dev.cui_flag, user_courses_dev.no_enrollments, user_courses_dev.cu_flag, user_courses_dev.cu_purchase,no_activated
      ,current_enrollments,current_activations,current_students,current_activations_cu,current_activations_non_cu, current_not_activated_enrollments,current_course_sections]
  }

  dimension: isbn {
    type: string
  }

  dimension: grace_period_flag {
    group_label: "Grace Period?"
    type: yesno
    sql: ${TABLE}."GRACE_PERIOD_FLAG" = 'Yes';;
    description: "User has enrolled on a course but not activated andenrollment date was in the last 14 days"
    label: "In grace period"
  }

  dimension: grace_period_description {
    type: string
    group_label: "Grace Period?"
    sql: CASE WHEN ${activated} THEN 'Paid' WHEN ${grace_period_flag} THEN 'In Grace Period' ELSE 'Unpaid, Grace period expired' END ;;
    description: "User has enrolled on a course but not activated andenrollment date was in the last 14 days"
    label: "In grace period (Description)"
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


  dimension: captured_key {
    type: string
    sql: ${TABLE}."CAPTURED_KEY" ;;
    hidden: yes
  }

  dimension_group: week_in_course {
    label: "Time in course"
    description: "The difference in weeks from the course start date to the current date."
    type: duration
    sql_start: ${course_start_date} ;;
    sql_end: CURRENT_DATE() ;;
    intervals: [week]
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    hidden: yes
  }

  dimension: instructor_guid {
    type: string
    sql: ${TABLE}."instructor_guid" ;;
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}."entity_id" ;;
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
    sql: HASH(${user_sso_guid}, ${captured_key}) ;;
    primary_key: yes
    hidden: yes
  }

  dimension: olr_activation_key {
    type: string
    sql: ${TABLE}."OLR_ACTIVATION_KEY" ;;
  }

  dimension: olr_course_key {
    type: string
    sql: ${TABLE}."OLR_COURSE_KEY" ;;
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
    type: yesno
    sql: ${TABLE}.enrolled = 'True'  ;;
    hidden: no
  }

  dimension: enrolled_desc {
    group_label: "Enrolled?"
    label: "Enrolled (Description)"
    type: string
    sql: CASE WHEN ${enrolled} THEN 'Enrolled' ELSE 'Not enrolled' END  ;;
    hidden: no
  }

  dimension: activated {
    group_label: "Activated?"
    type: yesno
    sql: ${TABLE}.activated = 'True'  ;;
    hidden: no
  }

  dimension: activated_desc {
    group_label: "Activated?"
    label: "Activated (Description)"
    type: string
    sql: CASE WHEN ${activated} THEN 'Activated' ELSE 'Not activated' END  ;;
    hidden: no
  }

  dimension: net_price_enrolled {
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
  }

  measure: distinct_ala_cart_purchase {
    label:  "# of a la carte purchases (distinct)"
    type: count_distinct
    sql: CASE WHEN NOT ${TABLE}.cu_flag AND ${activated} THEN ${isbn} END;;
  }

  dimension: cu_contract_id {
    group_label: "Subscription"
    type: string
    sql: ${TABLE}.cu_contract_id;;
    label: "CU Contract ID"
    description: "Unique contract ID for Cengage Unlimited Subscription"
    hidden: no
  }

  dimension: cui_flag {
    type: string
    sql: ${TABLE}.cui_flag;;
    hidden: no
    label: "CUI Flag"
    description: "Flag to identify Cengage Unlimited Institutional Subscription"
  }


  dimension: cu_flag {
    group_label: "Subscription"
     type: yesno
#     sql: (${cu_contract_id} IS NOT NULL AND ${cu_contract_id} <> 'TRIAL') OR ${cui_flag} = 'Y' ;;
     label: "CU Flag"
#     hidden: no
  }

  dimension: cu_flag_desc {
    group_label: "Subscription"
    type: string
    sql: CASE WHEN ${cu_flag} THEN 'Paid by subscription' WHEN ${activated} THEN 'Paid direct' ELSE 'Not paid' END;;
#     sql: (${cu_contract_id} IS NOT NULL AND ${cu_contract_id} <> 'TRIAL') OR ${cui_flag} = 'Y' ;;
    label: "CU Flag (Description)"
#     hidden: no
  }

  dimension: activation_code {
    type: string
    sql: ${TABLE}."ACTIVATION_CODE" ;;
    hidden: yes
  }

  measure: ala_cart_purchases {
    group_label: "Lifetime metrics"
    label: "# of a la carte activations"
    type: sum
    sql: CASE WHEN NOT ${cu_flag} AND ${activated} THEN 1 END;;
  }

  measure: cu_purchase {
    group_label: "Lifetime metrics"
    label: "# of CU activations"
    type: sum
    sql: CASE WHEN ${cu_flag} AND ${activated} THEN 1 END;;
  }

  measure: no_enrollments {
    group_label: "Lifetime metrics"
    label: "# enrollments"
    type: sum
    sql: CASE WHEN ${enrolled} THEN 1 ELSE 0 END  ;;
  }

  measure: no_activated {
    group_label: "Lifetime metrics"
    label: "# activations"
    type: sum
    sql: CASE WHEN ${activated} THEN 1 ELSE 0 END  ;;
  }

  measure: no_courses_with_activations {
    group_label: "Lifetime metrics"
    label: "# courses with activations"
    type: count_distinct
    sql: CASE WHEN ${activated} THEN ${olr_course_key} END  ;;
  }

  measure: enrolled_courses {
    group_label: "Lifetime metrics"
    label: "# Users with Enrolled Courses"
    description: "Number of users with an enrolled course"
    type: count_distinct
    sql: case when ${enrolled} then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }

  measure: enrollments_minus_activations {
    group_label: "Lifetime metrics"
    label: "# of enrollments not activated"
    type: number
    sql: greatest(${no_enrollments} -  ${no_activated}, 0) ;;
  }

  measure: current_course_sections {
    group_label: "Active courses metrics"
    label: "# of current courses"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() THEN ${olr_course_key} END   ;;
    drill_fields: [marketing_fields*]
  }

  measure: current_enrollments {
    group_label: "Active courses metrics"
    label: "# of current enrollments"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${enrolled} THEN ${pk} END   ;;
    drill_fields: [marketing_fields*]
  }

  measure: current_activations {
    group_label: "Active courses metrics"
    label: "# of current activations"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${activated} THEN ${pk} END   ;;
    drill_fields: [marketing_fields*]
  }

  measure: current_activations_non_cu {
    group_label: "Active courses metrics"
    label: "# of current Non CU activations"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${activated} AND NOT ${cu_flag} THEN ${pk} END   ;;
    drill_fields: [marketing_fields*]
  }


  measure: current_activations_cu {
    group_label: "Active courses metrics"
    label: "# of current CU activations"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() AND ${activated} AND ${cu_flag} THEN ${pk} END   ;;
    drill_fields: [marketing_fields*]
  }

  measure: current_not_activated_enrollments {
    group_label: "Active courses metrics"
    label: "# of current not activated"
    type: number
    sql: ${current_enrollments} - ${current_activations}   ;;
    drill_fields: [marketing_fields*]
  }

  measure: current_students {
    group_label: "Active courses metrics"
    label: "# of current students"
    type: count_distinct
    sql: CASE WHEN ${course_end_date} > CURRENT_TIMESTAMP() THEN ${user_sso_guid} END   ;;
    drill_fields: [marketing_fields*]
  }

#   measure: activations_minus_a_la_carte {
#     label: "Activations minus a la carte"
#     type: number
#     sql: ${course_section_facts.total_noofactivations} - ${ala_cart_purchases} ;;
#     hidden: yes
#   }



#   dimension: cui_flag {
#     type: yesno
#     sql: ${TABLE}.cu_flag;;
#     hidden: no
#   }
#
#   dimension: cu_contract_id {
#     type: yesno
#     sql: ${TABLE}.cu_contract_id;;
#     hidden: no
#   }


  dimension: enrollment_date {
    label: "Date on which user enrolled into a course"
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
