include: "./course_info.view"
include: "./product_info.view"
include: "./institution_info.view"
include: "./course_instructor.view"

explore: user_products {
  hidden:yes

  join: product_info {
    view_label: "Product"
    sql_on: ${user_products.isbn13} = ${product_info.isbn13} ;;
    relationship: many_to_one
  }

  join: product_institution_info {
    from: institution_info
    view_label: "Product Institution Details"
    sql_on: ${user_products.institution_id} = ${product_institution_info.institution_id} ;;
    relationship: many_to_one
  }

  join: course_info {
    view_label: "Course / Section Details"
    sql_on: ${user_products.course_key} = ${course_info.course_identifier} ;;
    relationship: many_to_one
  }

}

view: user_products {
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
  timeframes: [time,date,month,year,raw,fiscal_year]
  hidden:no
}

dimension_group: provision_date {
  label: "Provision"
  type:time
  timeframes: [time,date,month,year,raw,fiscal_year]
  hidden:no
  description: "Date user provisioned the product."
}

dimension_group: activation_date {
  label: "Activation"
  type:time
  timeframes: [time,date,month,year,raw,fiscal_year]
  hidden:no
  description: "Date user activated the product."
}

dimension_group: serial_number_consumed_date {
  label: "Serial Number Consumed"
  type:time
  timeframes: [time,date,month,year,raw,fiscal_year]
  hidden:no
  description: "Date user consumed a serial number for the product."
}

dimension: paid_flag {
  type: yesno
  description: "User paid for the product."
}

dimension: cu_flag {
  type: yesno
  description: "Usage of the product is associated with a CU subscription."
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
  sql: least(coalesce(${enrollment_date_raw},'9999-01-01'),coalesce(${provision_date_raw},'9999-01-01'),coalesce(${activation_date_raw},'9999-01-01'),coalesce(${serial_number_consumed_date_raw},'9999-01-01'));;
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

  measure: count_distinct_user  {
    type:  count_distinct
    hidden:  yes
    sql: ${merged_guid} ;;
  }
  measure: distinct_user_provisioned_product {
    type: count_distinct
    hidden:  yes
    sql: hash(${merged_guid}, ${isbn13}) ;;
  }

  measure: average_user_provisioned_product {
    type:  number
    label: "Average # of Provisioned Products"
    sql: ${distinct_user_provisioned_product}/NULLIF(${count_distinct_user},0) ;;
    value_format_name: decimal_2
    description: "Provides average number of products provisioned by all users based on filter criteria."
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


  measure: count {
    type: count
    label: "# Products Added"
    description: "Measured as combinations of user, ISBN, course key, and term."
  }

}
