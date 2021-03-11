include: "./course_info.view"
include: "./product_info.view"
include: "./institution_info.view"
# include: "./course_instructor.view"

explore: user_products {
  from: user_products
  view_name: user_products
  view_label: "Product Details By User"
  extends: [course_info, institution_info, product_info]
  hidden:yes

  join: product_info {
    view_label: "Product Details"
    sql_on: ${user_products.isbn13} = ${product_info.isbn13} ;;
    relationship: many_to_one
  }

  join: product_discipline_rank {
    view_label: "Product Details"
  }

  join: institution_info {
    sql_on: ${user_products.institution_id} = ${institution_info.institution_id} ;;
    relationship: many_to_one
    view_label: "Product Institution Details"
  }

  join: gateway_institution {
    view_label: "Product Institution Details"
  }

  join: course_info {
    sql_on: ${user_products.course_key} = ${course_info.course_identifier} ;;
    relationship: many_to_one
  }

}

view: user_products {
  view_label: "Product Details By User"

  sql_table_name: prod.cu_user_analysis.user_products ;;

dimension: merged_guid {
  sql: ${TABLE}.user_sso_guid ;;
  hidden:yes
}

dimension: isbn13 {
  sql: ${TABLE}.isbn ;;
  hidden: yes
}

dimension: institution_id {hidden:yes}

dimension: academic_term {hidden:yes}

dimension: course_key {hidden:yes}

dimension: courseware_product {
  type: yesno
  description: "User's added product is associated with a course key"
  sql: ${course_key} is not null  ;;
}

dimension_group: enrollment_date {
  label: "Enrollment"
  type:time
  timeframes: [time,date,week,month,year,raw,fiscal_year]
  hidden:no
}

dimension_group: provision_date {
  label: "Provision"
  type:time
  timeframes: [time,date,week,month,year,raw,fiscal_year]
  hidden:no
  description: "Date user provisioned the product."
}

  dimension_group: provision_expiration_date {
    label: "Provision Expiration"
    type:time
    timeframes: [time,date,week,month,year,raw,fiscal_year]
    hidden:no
    description: "Expiration date of access to provisioned product."
  }

dimension_group: activation_date {
  label: "Activation"
  type:time
  timeframes: [time,date,week,month,month_name,day_of_year,year,raw,fiscal_year]
  hidden:no
  description: "Date user activated the product."
}

dimension_group: serial_number_consumed_date {
  label: "Serial Number Consumed"
  type:time
  timeframes: [time,date,week,month,year,raw,fiscal_year]
  hidden:no
  description: "Date user consumed a serial number for the product."
}

dimension_group: serial_number_consumed_expiration_date {
  label: "Serial Number Consumed Expiration"
  type:time
  timeframes: [time,date,week,month,year,raw,fiscal_year]
  hidden:no
  description: "Expiration date of access gained though a consumed serial number."
}

dimension: paid_flag {
  type: yesno
  description: "User paid for the product."
  alias: [paid]
}

dimension: cu_flag {
  group_label: "Subscription"
  label: "CU"
  type: yesno
  description: "Usage of the product is associated with a CU subscription."
}

dimension: cu_flag_desc {
  group_label: "Subscription"
  type: string
  sql: CASE WHEN ${cu_flag} THEN 'Paid by subscription' WHEN ${activated} THEN 'Paid direct' ELSE 'Not paid' END;;
  label: "CU (Description)"
  description: "Paid by subscription / Paid direct / Not paid"
}

dimension_group: _effective_from {
  hidden: yes
  type:time
  timeframes: [date,raw,time]
}
dimension_group: _effective_to {
  hidden: yes
  type:time
  timeframes: [date,raw,time]
}

dimension: _last_modified {type:date_time hidden:yes}

dimension: pk {
  sql: hash(${TABLE}.user_sso_guid,${TABLE}.isbn,${TABLE}.institution_id,${TABLE}.academic_term,${TABLE}.course_key) ;;
  primary_key:yes
  hidden:yes
}

dimension_group: added {
  type: time
  timeframes: [raw,time,date,week,month,year,fiscal_year]
  sql: nullif(least(coalesce(${enrollment_date_raw},'9999-01-01'),coalesce(${provision_date_raw},'9999-01-01'),coalesce(${activation_date_raw},'9999-01-01'),coalesce(${serial_number_consumed_date_raw},'9999-01-01')),'9999-01-01');;
  description: "Minimum of enrollment, provision, activation, and serial number consumed dates for user and product in a term."
}

dimension: grace_period_flag {
  type: yesno
  sql: coalesce(${course_info.grace_period_end_date_raw} > current_date AND NOT ${paid_flag},FALSE)  ;;
  description: "Course grace period is active and user has not paid"
  group_label: "Grace Period"
}

  dimension: grace_period_description {
    type: string
    group_label: "Grace Period"
    sql: CASE
      WHEN ${course_info.grace_period_end_date_raw} IS NULL THEN 'No Grace Period'
      WHEN ${paid_flag} THEN 'Paid'
      WHEN ${grace_period_flag} THEN 'In Grace Period'
      ELSE 'Unpaid, Grace period expired'
    END ;;
    label: "Grace Period (Description)"
    description: "No Grace Period / In Grace Period / Paid / Unpaid, Grace period expired"
  }

  dimension_group: week_in_course {
    label: "Time in course"
    type: duration
    sql_start: case when ${course_key} is not null then ${added_raw} end ;;
    sql_end: case when ${course_key} is not null then LEAST(dateadd(week,16,${added_raw}), CURRENT_DATE()) end ;;
    intervals: [week]
    description: "The difference in weeks from the user's added date for a course to the current date (max of 16 weeks from when the user added the course)"
  }

  dimension: current_course {
    type: yesno
    hidden: yes
    description: "Course end date is in the future"
    sql: ${course_info.active} ;;
  }

  dimension: is_current_provision {
    type: yesno
    sql: current_date between ${provision_date_raw} and coalesce(${provision_expiration_date_raw},current_date) ;;
    hidden: yes
  }

  dimension: is_current_serial_number {
    type: yesno
    sql: current_date between ${serial_number_consumed_date_raw} and coalesce(${serial_number_consumed_expiration_date_raw},current_date) ;;
    hidden: yes
  }

  dimension: is_access_current {
    type: yesno
    sql: coalesce(${current_course} or ${is_current_provision} or ${is_current_serial_number},false)  ;;
    description: "User currently has access to the added product (future course end date, future provision expiration date, or future serial number expiration date)"
  }

  dimension_group: paid {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      month_name,
      year,
      week_of_year,
      day_of_year
    ]
    sql: case when ${paid_flag} then ${added_date} end ;;
    label: "Approximate Paid"
    # group_label: "Payment Information"
    description: "Activation date or enrollment date / course start date when paid flag is true"
    hidden: yes
  }

  dimension: paid_current {
    type: yesno
    sql:(${paid_flag}) and ${current_course};;
    group_label: "Payment Information"
    label: "Paid Current"
    description: "paid_in_full flag from OLR enrollments table OR activation record for the user_sso_guid and context_id pair AND course has future end date"
  }

  dimension: unpaid_current {
    type: yesno
    sql:(NOT ${paid_flag}) and ${current_course};;
    group_label: "Payment Information"
    label: "Unpaid Current"
    description: "No paid flag or activation AND course has future end date"
  }

  dimension: enrolled {
    group_label: "Enrolled?"
    description: "OLR enrollment has occurred Y/N"
    type: yesno
    sql: ${enrollment_date_raw} IS NOT NULL  ;;
    hidden: no
  }

  dimension: enrolled_current {
    label: "Currently enrolled"
    group_label: "Enrolled?"
    description: "Enrolled on a course with a future end date"
    type: yesno
    sql: ${enrolled} and ${current_course}  ;;
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
    sql: ${activation_date_raw} IS NOT NULL  ;;
    hidden: no
  }

  dimension: activated_current {
    label: "Currently activated"
    group_label: "Activated?"
    description: "Activated on a course with a future end date"
    type: yesno
    sql: ${activated} and ${current_course}  ;;
    hidden: no
  }

  measure: course_section_count {
    label: "# Course Sections"
    type: count_distinct
    sql: ${course_key} ;;
    description: "Distinct count of course sections (by course key)"
    alias: [course_sections]
    hidden: yes
  }

  measure: course_section_with_activations_count {
    group_label: "Activations"
    label: "# Courses with activations"
    type: count_distinct
    sql: CASE WHEN ${activated} THEN ${course_key} END  ;;
    description: "Total # of distinct courses (by course key) with activations (all time)"
    alias: [no_courses_with_activations]
  }

  measure: enrollment_count {
    group_label: "Enrollments"
    label: "# Enrollments"
    type: count_distinct
    sql: CASE WHEN ${enrolled} THEN ${pk} END  ;;
    description: "Total # of enrollments (all time)"
    alias: [no_enrollments]
  }

  measure: paid_enrollment_count {
    group_label: "Enrollments"
    label: "# Paid enrollments"
    type: count_distinct
    sql: CASE WHEN ${enrolled} AND ${paid_flag} THEN ${pk} END  ;;
    description: "Total # of paid enrollments (all time)"
    alias: [no_paid_enrollments]
  }

  measure: enrolled_current_count {
    group_label: "Enrollments"
    label: "# Current enrollments"
    type: count_distinct
    sql: CASE WHEN ${current_course} AND ${enrolled} THEN ${pk} END   ;;
    description: "Count of distinct course enrollments for courses that have not yet ended"
    alias: [current_enrollments]
  }

  measure: paid_enrolled_current_count {
    group_label: "Enrollments"
    label: "# Current paid enrollments"
    type: count_distinct
    sql: CASE WHEN ${current_course} AND ${enrolled} AND ${paid_flag} THEN ${pk} END   ;;
    description: "Count of distinct paid course enrollments on courses that have not yet ended"
    alias: [current_paid_enrollments]
  }

  measure: activated_count {
    group_label: "Activations"
    label: "# Activations"
    type: count_distinct
    sql: CASE WHEN ${activated} THEN ${pk} END  ;;
    description: "Total # of activations (all time)"
    alias: [no_activated]
  }

  measure: activated_current_count {
    group_label: "Activations"
    label: "# Current activations"
    type: count_distinct
    sql: CASE WHEN ${current_course} AND ${activated} THEN ${pk} END   ;;
    description: "Count of distinct course activations on courses that have not yet ended"
  }

  measure: paid_current_count {
    group_label: "Payment Information"
    label: "# Current Paid Courses"
    type: count_distinct
    sql: CASE WHEN ${current_course} AND (${paid_flag}) THEN ${pk} END   ;;
    description: "Count of distinct paid user courses (guid+coursekey combo) that have not yet ended"
  }

  measure: count_distinct_user  {
    type:  count_distinct
    hidden:  yes
    sql: ${merged_guid} ;;
  }
  measure: distinct_user_provisioned_product {
    type: count_distinct
    hidden:  yes
    sql: hash(${merged_guid}, ${isbn13}, ${provision_date_time}) ;;
  }

  measure: average_user_provisioned_product {
    type:  number
    label: "Average # of Provisioned Products"
    sql: ${distinct_user_provisioned_product}/NULLIF(${count_distinct_user},0) ;;
    value_format_name: decimal_2
    description: "Provides average number of products provisioned by all users based on filter criteria."
  }

  measure: provisioned_product_count {
    type:  count_distinct
    label: "# Provisioned Products"
    sql: CASE WHEN ${provision_date_raw} IS NOT NULL THEN ${pk} END ;;
    value_format_name: decimal_2
    description: "Number of products provisioned by all users based on filter criteria."
  }

  measure: total_value_provisioned  {
    type: sum
    sql: case when ${paid_flag} then ${product_info.list_price} end ;;
    value_format_name: usd
  }

  measure: user_course_count {
    type: count_distinct
    sql: hash(${merged_guid},${course_key}) ;;
    hidden: yes
  }

  measure:  user_count {
    type: count_distinct
    sql: ${merged_guid} ;;
    hidden: yes
  }

  measure: course_count {
    type: count_distinct
    sql: ${course_key} ;;
    hidden: yes
  }

  measure: courses_per_user {
    type: number
    label: "# Courses per User"
    #required_fields: [learner_profile.count]
    #sql: ${user_course_count} / ${learner_profile.count}  ;;
    sql: ${user_course_count} / NULLIF(${user_count}, 0)  ;;
    value_format_name: decimal_1
    description: "Total unique user-course interactions divided by total number of distinct users"
  }

  measure: users_per_course {
    type: number
    sql: ${user_count} / NULLIF(${course_count}, 0) ;;
    label: "# Users per Course"
    value_format_name: decimal_1
    description: "Total unique users divided by total number of distinct courses"
  }

  measure: count_paid {
    type: count_distinct
    sql: case when ${paid_flag} then ${pk} end ;;
    label: "# Paid Products Added"
    description: "Measured as combinations of user, ISBN, course key, and term where the user has paid for the product."
  }

  measure: distinct_ala_cart_purchase_current {
    label:  "# Current a la carte purchases"
    type: count_distinct
    sql: case when ${paid_flag} and (not ${cu_flag}) and (${course_info.active} or ${is_current_provision} or ${is_current_serial_number}) then ${pk} end ;;
    description: "Count of distinct paid products added, not paid via CU, where the user currently has access."
  }

  measure: user_cu_course_list {
    label: "List of CU courses"
    # group_label: "Course Lists"
    type: string
    sql: LISTAGG(DISTINCT case when ${cu_flag} and ${course_key} is not null then ${isbn13} end, ', ')
      WITHIN GROUP (ORDER BY case when ${cu_flag} and ${course_key} is not null then ${isbn13} end);;
    description: "List of user CU course ISBNs"
  }

  measure: user_product_list {
    type: string
    sql: LISTAGG(DISTINCT ${isbn13}, ', ')
      WITHIN GROUP (ORDER BY ${isbn13});;
    description: "List of user product ISBNs"
  }

  measure: cu_purchase {
    label: "# Paid CU Products Added"
    type: count_distinct
    sql: CASE WHEN ${cu_flag} AND ${paid_flag} THEN ${pk} END;;
    description: "Total # of products added paid via CU"
  }

  measure: count {
    type: count
    label: "# Products Added"
    description: "Measured as combinations of user, ISBN, course key, and term."
  }

}
