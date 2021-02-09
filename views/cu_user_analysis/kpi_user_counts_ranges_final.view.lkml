view: kpi_user_counts_ranges_final {
  sql_table_name: "LOOKER_SCRATCH".kpi_user_counts_ranges
    ;;

  # dimension: date_range_end {type:number}
  # dimension: date_range_start {type:number}

  dimension: date_range_key {hidden:yes}

  dimension_group: date_range_end {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RANGE_END" ;;
    hidden: yes
  }

  dimension_group: date_range_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RANGE_START" ;;
    hidden: yes
  }

  dimension: region {}

  dimension: organization {}

  dimension: platform {}

  dimension: user_type {}

  dimension: user_sso_guid {hidden: yes}

  measure: userbase_digital_user_guid  {type:count_distinct label: "# Digital Student Users"}
  measure: userbase_paid_user_guid  {type:count_distinct label: "# Paid Digital Student Users"}
  measure: userbase_paid_courseware_guid  {type:count_distinct label: "# Paid Courseware Student Users"}

  measure: userbase_paid_ebook_only_guid  {
    type:count_distinct
    sql: case when ${TABLE}.userbase_paid_courseware_guid is null
      then ${TABLE}.userbase_paid_ebook_only_guid end  ;;
    label: "# Paid eBook ONLY Student Users"
  }

  measure: userbase_full_access_cu_only_guid  {
    type:count_distinct
    sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              then ${TABLE}.userbase_full_access_cu_only_guid end;;
    label: "# Paid CU ONLY Student Users (no provisions)"
  }

  measure: userbase_full_access_cu_etextbook_only_guid  {
    type:count_distinct
    sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              and ${TABLE}.all_full_access_cu_guid is null
              then ${TABLE}.userbase_full_access_cu_etextbook_only_guid end;;
    label: "# Paid CU eTextbook ONLY Student Users (no provisions)"
  }

  measure: userbase_trial_access_cu_only_guid  {
    type:count_distinct
    sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              and ${TABLE}.all_full_access_cu_guid is null
              and ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
              then ${TABLE}.userbase_trial_access_cu_only_guid end;;
    label: "# Trial CU ONLY Student Users"
  }


  measure: userbase_trial_access_cu_etextbook_only_guid  {
    type:count_distinct
    sql:  case when ${TABLE}.userbase_paid_courseware_guid is null
              and ${TABLE}.all_paid_ebook_guid is null
              and ${TABLE}.all_full_access_cu_guid is null
              and ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
              and ${TABLE}.all_trial_access_cu_guid is null
              then ${TABLE}.userbase_trial_access_cu_etextbook_only_guid end;;
    label: "# Trial CU eTextbook ONLY Student Users"
  }

  measure: all_courseware_guid  {type:count_distinct label: "# Total Courseware Student Users"}
  measure: all_ebook_guid  {type:count_distinct label: "# Total eBook Student Users"}
  measure: all_paid_ebook_guid  {type:count_distinct label: "# Total Paid eBook Student Users"}
  measure: all_full_access_cu_guid  {type:count_distinct label: "# Total Full Access CU Subscribers"}
  measure: all_trial_access_cu_guid  {type:count_distinct label: "# Total Trial Access CU Subscribers"}
  measure: all_full_access_cu_etextbook_guid  {type:count_distinct label: "# Total Full Access CU eTextbook Subscribers"}
  measure: all_trial_access_cu_etextbook_guid  {type:count_distinct label: "# Total Trial Access CU eTextbook Subscribers"}
  measure: all_instructors_active_course_guid  {type:count_distinct label: "# Instructors With Active Digital Course"}
  measure: all_active_user_guid  {type:count_distinct label: "# Total Active Users"}

  measure: all_paid_active_user_guid {
    type: count_distinct
#   sql: CASE WHEN ${TABLE}.userbase_paid_user_guid IS NOT NULL AND ${TABLE}.all_active_user_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Paid Active Users"
  }

  measure: all_active_instructor_with_active_course_guid {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.all_instructors_active_course_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Active Instructors (Active Course)"
  }


  measure: all_active_instructor {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.user_type = 'Instructor' THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Active Instructors"
  }

  measure: all_active_student {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.user_type = 'Student' THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Active Student Users"
  }

  measure: paid_active_courseware_student {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.userbase_paid_courseware_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END;;
    label: "# Total Paid Active Courseware Student Users"
  }

  measure: paid_a_la_carte_courseware_users {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.all_full_access_cu_guid IS NULL
                AND ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
              THEN ${TABLE}.userbase_paid_courseware_guid END;;
    label: "# Total Paid a la carte Courseware Student Users"
    description: "Paid courseware users with no CU or CUe subscription"
  }

  measure: paid_a_la_carte_ebook_users {
    type: count_distinct
    sql: CASE WHEN ${TABLE}.all_full_access_cu_guid IS NULL
                AND ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
                AND ${TABLE}.userbase_paid_courseware_guid IS NULL
              THEN ${TABLE}.userbase_paid_ebook_only_guid END;;
    label: "# Total Paid a la carte eBook Student Users"
    description: "Paid ebook users with no courseware access and no CU or CUe subscription"
  }

}
