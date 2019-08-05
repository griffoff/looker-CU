include: "//cube/additional_info.course_section_facts.view.lkml"
include: "//core/common.lkml"
view: user_courses {
  view_label: "User Courses"
#   sql_table_name: prod.cu_user_analysis.user_courses ;;
derived_table: {
  sql: Select *, case when (cu_contract_id IS NOT NULL AND cu_contract_id <> 'TRIAL') OR cui_flag = 'Y' THEN 'yes' ELSE 'no' end as cu_flag
        from prod.cu_user_analysis.user_courses  ;;
}

  set: marketing_fields {
    fields: [user_courses.net_price_enrolled, user_courses.amount_to_upgrade_tiers, user_courses.ala_cart_purchases, user_courses.distinct_ala_cart_purchase
      , user_courses.cu_contract_id, user_courses.cui_flag, user_courses.no_enrollments, user_courses.cu_flag, user_courses.cu_purchase, user_courses.activations_minus_a_la_carte,
      user_courses.enrollments_minus_activations, user_courses_dev.net_price_enrolled, user_courses_dev.amount_to_upgrade_tiers, user_courses_dev.ala_cart_purchases, user_courses_dev.distinct_ala_cart_purchase
      , user_courses_dev.cu_contract_id, user_courses_dev.cui_flag, user_courses_dev.no_enrollments, user_courses_dev.cu_flag, user_courses_dev.cu_purchase,no_activated]
  }

  dimension: net_price_enrolled {
    label: "$ value of enrolled courses"
    type: number
    sql: ${TABLE}."NET_PRICE_ENROLLED" ;;
  }

  measure: distinct_ala_cart_purchase {
    label:  "# of a la carte purchases (distinct)"
    type: count_distinct
    sql: CASE WHEN ${TABLE}.cu_flag = 'no' THEN ${isbn} END;;
  }

  dimension: cu_contract_id {
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
#     type: yesno
#     sql: (${cu_contract_id} IS NOT NULL AND ${cu_contract_id} <> 'TRIAL') OR ${cui_flag} = 'Y' ;;
#     label: "CU Flag"
#     hidden: no
  }

  measure: ala_cart_purchases {
    label: "# of a la carte activations"
    type: sum
    sql: CASE WHEN ${cu_flag} = 'No' THEN 1 END;;
  }

  measure: cu_purchase {
    label: "# of a CU activations"
    type: sum
    sql: CASE WHEN ${cu_flag} = 'Yes' THEN 1 END;;
  }

  measure: enrollments_minus_activations {
    label: "# of enrollments not activated"
    type: number
    sql: ${no_enrollments} -  ${course_section_facts.total_noofactivations} ;;
  }

#   measure: activations_minus_a_la_carte {
#     label: "Activations minus a la carte"
#     type: number
#     sql: ${course_section_facts.total_noofactivations} - ${ala_cart_purchases} ;;
#     hidden: yes
#   }

  dimension: isbn {
    type: string
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

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: instructor_guid {
    type: string
    sql: ${TABLE}."instructor_guid" ;;
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
    type: date
  }

  dimension: course_end_date {
    type: date
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
    type: yesno
    sql: ${TABLE}.enrolled = 'True'  ;;
    hidden: no
  }

  dimension: activated {
    type: yesno
    sql: ${TABLE}.activated = 'True'  ;;
    hidden: no
  }


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

  measure: no_enrollments {
    label: "# enrollments"
    type: sum
    sql: CASE WHEN ${enrolled} THEN 1 ELSE 0 END  ;;
  }

  measure: no_activated {
    label: "# activated"
    type: sum
    sql: CASE WHEN ${activated} THEN 1 ELSE 0 END  ;;
  }

  dimension: enrollment_date {
    label: "Date on which user enrolled into a course"
    type: date
  }

  measure: enrolled_courses {
    label: "# Users with Enrolled Courses"
    description: "Number of users with an enrolled course"
    type: count_distinct
    sql: case when ${olr_enrollment_key} is not null then ${user_sso_guid} end;;
    value_format_name: decimal_0
  }

}
