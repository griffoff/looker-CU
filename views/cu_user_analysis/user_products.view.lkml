explore: user_products {hidden:yes}
view: user_products {
sql_table_name: prod.cu_user_analysis.user_products ;;

dimension: merged_guid {
  sql: ${TABLE}.user_sso_guid ;;
  hidden:yes
}

dimension: isbn13 {
  sql: ${TABLE}.isbn ;;
}

dimension: institution_id {hidden:yes}

dimension: academic_term {hidden:yes}

dimension: course_key {hidden:yes}

dimension: enrollment_date {
  type:date_time
  hidden:yes
}

dimension: provision_date {
  type:date_time
  hidden:yes
}

dimension: activation_date {
  type:date_time
  hidden:yes
}

dimension: serial_number_consumed_date {
  type:date_time
  hidden:yes
}

dimension: paid_flag {
  type: yesno
}

dimension: cu_flag {
  type: yesno
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
  timeframes: [raw,time,date,week,month,year]
  sql: least(coalesce(${enrollment_date},'9999-01-01'),coalesce(${provision_date},'9999-01-01'),coalesce(${activation_date},'9999-01-01'),coalesce(${serial_number_consumed_date},'9999-01-01'));;
}
}
