explore: user_products {hidden:yes}
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

measure: count {
  type: count
  label: "# Products Added"
  description: "Measured as combinations of user, ISBN, course key, and term."
}

}
