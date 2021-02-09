view: kpi_user_counts_wide {



  parameter: exact_counts {
    view_label: "Filters"
    description: "Approximate counts may be off by up to ~2%, but with significantly reduced query run-time."
    type: unquoted
    allowed_value: {
      label: "Exact Counts"
      value: "true"
    }
    allowed_value: {
      label: "Approximate Counts"
      value: "false"
    }
    default_value: "false"
  }

derived_table: {
  sql:
  select *
    , NULL AS userbase_digital_user_guid_ly
    , NULL AS userbase_paid_user_guid_ly
    , NULL AS userbase_paid_courseware_guid_ly
    , NULL AS userbase_paid_ebook_only_guid_ly
    , NULL AS userbase_full_access_cu_only_guid_ly
    , NULL AS userbase_trial_access_cu_only_guid_ly
    , NULL AS userbase_full_access_cu_etextbook_only_guid_ly
    , NULL AS userbase_trial_access_cu_etextbook_only_guid_ly
    , NULL AS all_instructors_active_course_guid_ly
    , NULL AS all_courseware_guid_ly
    , NULL AS all_ebook_guid_ly
    , NULL AS all_paid_ebook_guid_ly
    , NULL AS all_full_access_cu_guid_ly
    , NULL AS all_trial_access_cu_guid_ly
    , NULL AS all_full_access_cu_etextbook_guid_ly
    , NULL AS all_trial_access_cu_etextbook_guid_ly
    , NULL AS all_active_user_guid_ly
    , NULL AS all_paid_active_user_guid_ly
    , NULL AS payment_cui_guid_ly
    , NULL AS payment_ia_guid_ly
    , NULL AS payment_direct_purchase_guid_ly
    , date AS date_ty
    , NULL AS date_ly
  from prod.looker_scratch.kpi_user_counts
  where {% condition dim_date_to_date.date_range %} date {% endcondition %}

  {% if kpi_user_counts.userbase_digital_user_guid_ly._in_query
    or kpi_user_counts.userbase_digital_user_guid_approx_ly._in_query
    or kpi_user_counts.userbase_paid_user_guid_ly._in_query
    or kpi_user_counts.userbase_paid_courseware_guid_ly._in_query
    or kpi_user_counts.userbase_paid_ebook_only_guid_ly._in_query
    or kpi_user_counts.userbase_full_access_cu_only_guid_ly._in_query
    or kpi_user_counts.userbase_trial_access_cu_only_guid_ly._in_query
    or kpi_user_counts.userbase_full_access_cu_etextbook_only_guid_ly._in_query
    or kpi_user_counts.userbase_trial_access_cu_etextbook_only_guid_ly._in_query
    or kpi_user_counts.all_instructors_active_course_guid_ly._in_query
    or kpi_user_counts.all_courseware_guid_ly._in_query
    or kpi_user_counts.all_ebook_guid_ly._in_query
    or kpi_user_counts.all_paid_ebook_guid_ly._in_query
    or kpi_user_counts.all_full_access_cu_guid_ly._in_query
    or kpi_user_counts.all_trial_access_cu_guid_ly._in_query
    or kpi_user_counts.all_full_access_cu_etextbook_guid_ly._in_query
    or kpi_user_counts.all_trial_access_cu_etextbook_guid_ly._in_query
    or kpi_user_counts.all_active_user_guid_ly._in_query
    or kpi_user_counts.all_paid_active_user_guid_ly._in_query
    or kpi_user_counts.payment_cui_guid_ly._in_query
    or kpi_user_counts.payment_ia_guid_ly._in_query
    or kpi_user_counts.payment_direct_purchase_guid_ly._in_query
    or yru_ly.yru._in_query %}

  union all
  select
    DATEADD(day, -{% parameter dim_date_to_date.offset %}, dateadd(year, 1, date)) AS date
    , user_sso_guid
    , region
    , organization
    , platform
    , user_type

    , NULL AS userbase_digital_user_guid
    , NULL AS userbase_paid_user_guid
    , NULL AS userbase_paid_courseware_guid
    , NULL AS userbase_paid_ebook_only_guid
    , NULL AS userbase_full_access_cu_only_guid
    , NULL AS userbase_trial_access_cu_only_guid
    , NULL AS userbase_full_access_cu_etextbook_only_guid
    , NULL AS userbase_trial_access_cu_etextbook_only_guid
    , NULL AS all_instructors_active_course_guid
    , NULL AS all_courseware_guid
    , NULL AS all_ebook_guid
    , NULL AS all_paid_ebook_guid
    , NULL AS all_full_access_cu_guid
    , NULL AS all_trial_access_cu_guid
    , NULL AS all_full_access_cu_etextbook_guid
    , NULL AS all_trial_access_cu_etextbook_guid
    , NULL AS all_active_user_guid
    , NULL AS all_paid_active_user_guid
    , NULL AS payment_cui_guid
    , NULL AS payment_ia_guid
    , NULL AS payment_direct_purchase_guid

    , userbase_digital_user_guid AS userbase_digital_user_guid_ly
    , userbase_paid_user_guid AS userbase_paid_user_guid_ly
    , userbase_paid_courseware_guid AS userbase_paid_courseware_guid_ly
    , userbase_paid_ebook_only_guid AS userbase_paid_ebook_only_guid_ly
    , userbase_full_access_cu_only_guid AS userbase_full_access_cu_only_guid_ly
    , userbase_trial_access_cu_only_guid AS userbase_trial_access_cu_only_guid_ly
    , userbase_full_access_cu_etextbook_only_guid AS userbase_full_access_cu_etextbook_only_guid_ly
    , userbase_trial_access_cu_etextbook_only_guid AS userbase_trial_access_cu_etextbook_only_guid_ly
    , all_instructors_active_course_guid AS all_instructors_active_course_guid_ly
    , all_courseware_guid AS all_courseware_guid_ly
    , all_ebook_guid AS all_ebook_guid_ly
    , all_paid_ebook_guid AS all_paid_ebook_guid_ly
    , all_full_access_cu_guid AS all_full_access_cu_guid_ly
    , all_trial_access_cu_guid AS all_trial_access_cu_guid_ly
    , all_full_access_cu_etextbook_guid AS all_full_access_cu_etextbook_guid_ly
    , all_trial_access_cu_etextbook_guid AS all_trial_access_cu_etextbook_guid_ly
    , all_active_user_guid AS all_active_user_guid_ly
    , all_paid_active_user_guid AS all_paid_active_user_guid_ly
    , payment_cui_guid AS payment_cui_guid_ly
    , payment_ia_guid AS payment_ia_guid_ly
    , payment_direct_purchase_guid AS payment_direct_purchase_guid_ly
    , NULL as date_ty
    , k.date as date_ly

  from prod.looker_scratch.kpi_user_counts k
  where {% condition dim_date_to_date.date_range %} DATEADD(day, -{% parameter dim_date_to_date.offset %}, dateadd(year, 1, date)) {% endcondition %}

  {% endif %}


  ;;


}


  dimension_group: date {
    label: "Calendar"
    type:time
    timeframes: [raw,date,week,month,year]
    hidden: yes
  }

  dimension_group: date_ty {
    label: "Calendar"
    type:time
    timeframes: [raw,date,week,month,year]
    hidden: yes
  }

  dimension_group: date_ly {
    label: "Calendar"
    type:time
    timeframes: [raw,date,week,month,year]
    hidden: yes
  }

  dimension: region {view_label:"Filters"}

  dimension: organization {view_label:"Filters"}

  dimension: platform {view_label:"Filters"}

  dimension: user_type {view_label:"Filters"}

  dimension: user_sso_guid {hidden: yes}

  measure: userbase_digital_user_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.userbase_digital_user_guid);;
    label: "# Digital Student Users"
  }

  measure: userbase_digital_user_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.userbase_digital_user_guid_ly);;
    label: "# Digital Student Users" view_label:"User Counts - Prior Year"
  }

  measure: userbase_paid_user_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.userbase_paid_user_guid);;
    label: "# Paid Digital Student Users"
  }

  measure: userbase_paid_user_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.userbase_paid_user_guid_ly);;
    label: "# Paid Digital Student Users" view_label:"User Counts - Prior Year"
  }

  measure: userbase_paid_courseware_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.userbase_paid_courseware_guid);;
    label: "# Paid Courseware Student Users"
    }

  measure: userbase_paid_courseware_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.userbase_paid_courseware_guid_ly);;
    label: "# Paid Courseware Student Users" view_label:"User Counts - Prior Year"
  }


  measure: userbase_paid_ebook_only_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid is null
    then ${TABLE}.userbase_paid_ebook_only_guid end);;

    label: "# Paid eBook ONLY Student Users"
  }

  measure: userbase_paid_ebook_only_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid_ly is null
    then ${TABLE}.userbase_paid_ebook_only_guid_ly end);;
    label: "# Paid eBook ONLY Student Users"
    view_label:"User Counts - Prior Year"
  }

  measure: userbase_full_access_cu_only_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid is null
      and ${TABLE}.all_paid_ebook_guid is null
    then ${TABLE}.userbase_full_access_cu_only_guid end);;
    label: "# Paid CU ONLY Student Users (no provisions)"
  }

  measure: userbase_full_access_cu_only_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid_ly is null
      and ${TABLE}.all_paid_ebook_guid_ly is null
    then ${TABLE}.userbase_full_access_cu_only_guid_ly end);;
    label: "# Paid CU ONLY Student Users (no provisions)"
    view_label:"User Counts - Prior Year"
  }

  measure: userbase_full_access_cu_etextbook_only_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid is null
      and ${TABLE}.all_paid_ebook_guid is null
      and ${TABLE}.all_full_access_cu_guid is null
    then ${TABLE}.userbase_full_access_cu_etextbook_only_guid end);;
    label: "# Paid CU eTextbook ONLY Student Users (no provisions)"
  }

  measure: userbase_full_access_cu_etextbook_only_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid_ly is null
      and ${TABLE}.all_paid_ebook_guid_ly is null
      and ${TABLE}.all_full_access_cu_guid_ly is null
    then ${TABLE}.userbase_full_access_cu_etextbook_only_guid_ly end);;
    label: "# Paid CU eTextbook ONLY Student Users (no provisions)"
    view_label:"User Counts - Prior Year"
  }

  measure: userbase_trial_access_cu_only_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid is null
      and ${TABLE}.all_paid_ebook_guid is null
      and ${TABLE}.all_full_access_cu_guid is null
      and ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
    then ${TABLE}.userbase_trial_access_cu_only_guid end);;
    label: "# Trial CU ONLY Student Users"
  }

  measure: userbase_trial_access_cu_only_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid_ly is null
      and ${TABLE}.all_paid_ebook_guid_ly is null
      and ${TABLE}.all_full_access_cu_guid_ly is null
      and ${TABLE}.all_full_access_cu_etextbook_guid_ly IS NULL
    then ${TABLE}.userbase_trial_access_cu_only_guid_ly end);;
    label: "# Trial CU ONLY Student Users"
    view_label:"User Counts - Prior Year"
  }

  measure: userbase_trial_access_cu_etextbook_only_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid is null
      and ${TABLE}.all_paid_ebook_guid is null
      and ${TABLE}.all_full_access_cu_guid is null
      and ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
      and ${TABLE}.all_trial_access_cu_guid is null
    then ${TABLE}.userbase_trial_access_cu_etextbook_only_guid end);;
    label: "# Trial CU eTextbook ONLY Student Users"
  }

  measure: userbase_trial_access_cu_etextbook_only_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
    case when ${TABLE}.userbase_paid_courseware_guid_ly is null
      and ${TABLE}.all_paid_ebook_guid_ly is null
      and ${TABLE}.all_full_access_cu_guid_ly is null
      and ${TABLE}.all_full_access_cu_etextbook_guid_ly IS NULL
      and ${TABLE}.all_trial_access_cu_guid_ly is null
    then ${TABLE}.userbase_trial_access_cu_etextbook_only_guid_ly end);;
    label: "# Trial CU eTextbook ONLY Student Users"
    view_label:"User Counts - Prior Year"
  }

  measure: all_courseware_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_courseware_guid);;
    label: "# Total Courseware Student Users"
  }

  measure: all_courseware_guid_ly  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_courseware_guid_ly);;
    label: "# Total Courseware Student Users"
    view_label:"User Counts - Prior Year"
  }

  measure: all_ebook_guid  {
    type: number
    sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_ebook_guid);;
    label: "# Total eBook Student Users"
  }
measure: all_ebook_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_ebook_guid_ly);;
  label: "# Total eBook Student Users"
  view_label:"User Counts - Prior Year"
}

measure: all_paid_ebook_guid  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_paid_ebook_guid);;
  label: "# Total Paid eBook Student Users"
}
measure: all_paid_ebook_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_paid_ebook_guid_ly);;
  label: "# Total Paid eBook Student Users"
  view_label:"User Counts - Prior Year"
}

measure: all_full_access_cu_guid  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_full_access_cu_guid);;
  label: "# Total Full Access CU Subscribers"
}
measure: all_full_access_cu_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_full_access_cu_guid_ly);;
  label: "# Total Full Access CU Subscribers"
  view_label:"User Counts - Prior Year"
}

measure: all_trial_access_cu_guid  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_trial_access_cu_guid);;
  label: "# Total Trial Access CU Subscribers"
}
measure: all_trial_access_cu_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_trial_access_cu_guid_ly);;
  label: "# Total Trial Access CU Subscribers"
  view_label:"User Counts - Prior Year"
}

measure: all_full_access_cu_etextbook_guid  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_full_access_cu_etextbook_guid);;
  label: "# Total Full Access CU eTextbook Subscribers"
}
measure: all_full_access_cu_etextbook_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_full_access_cu_etextbook_guid_ly);;
  label: "# Total Full Access CU eTextbook Subscribers"
  view_label:"User Counts - Prior Year"
}

measure: all_trial_access_cu_etextbook_guid  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_trial_access_cu_etextbook_guid);;
  label: "# Total Trial Access CU eTextbook Subscribers"
}
measure: all_trial_access_cu_etextbook_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_trial_access_cu_etextbook_guid_ly);;
  label: "# Total Trial Access CU eTextbook Subscribers"
  view_label:"User Counts - Prior Year"
}

measure: all_instructors_active_course_guid  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_instructors_active_course_guid);;
  label: "# Instructors With Active Digital Course"
}
measure: all_instructors_active_course_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_instructors_active_course_guid_ly);;
  label: "# Instructors With Active Digital Course"
  view_label:"User Counts - Prior Year"
}

measure: all_active_user_guid  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_active_user_guid);;
  label: "# Total Active Users"
}
measure: all_active_user_guid_ly  {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_active_user_guid_ly);;
  label: "# Total Active Users"
  view_label:"User Counts - Prior Year"
}


measure: all_paid_active_user_guid {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_paid_active_user_guid);;
  label: "# Total Paid Active Users"
}

measure: all_paid_active_user_guid_ly {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %} ${TABLE}.all_paid_active_user_guid_ly);;
  label: "# Total Paid Active Users"
  view_label:"User Counts - Prior Year"
}

measure: all_active_instructor_with_active_course_guid {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.all_instructors_active_course_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END);;
  label: "# Total Active Instructors (Active Course)"
}

measure: all_active_instructor_with_active_course_guid_ly {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.all_instructors_active_course_guid_ly IS NOT NULL THEN ${TABLE}.all_active_user_guid_ly END);;
  label: "# Total Active Instructors (Active Course)"
  view_label:"User Counts - Prior Year"
}

measure: all_active_instructor {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.user_type = 'Instructor' THEN ${TABLE}.all_active_user_guid END);;
  label: "# Total Active Instructors"
}

measure: all_active_instructor_ly {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.user_type = 'Instructor' THEN ${TABLE}.all_active_user_guid_ly END);;
  label: "# Total Active Instructors"
  view_label:"User Counts - Prior Year"
}

measure: all_active_student {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.user_type = 'Student' THEN ${TABLE}.all_active_user_guid END);;
  label: "# Total Active Student Users"
}

measure: all_active_student_ly {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.user_type = 'Student' THEN ${TABLE}.all_active_user_guid_ly END);;
  label: "# Total Active Student Users"
  view_label:"User Counts - Prior Year"
}

measure: paid_active_courseware_student {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.userbase_paid_courseware_guid IS NOT NULL THEN ${TABLE}.all_active_user_guid END);;
  label: "# Total Paid Active Courseware Student Users"
}

measure: paid_active_courseware_student_ly {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.userbase_paid_courseware_guid_ly IS NOT NULL THEN ${TABLE}.all_active_user_guid_ly END);;
  label: "# Total Paid Active Courseware Student Users"
  view_label:"User Counts - Prior Year"
}

measure: paid_a_la_carte_courseware_users {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.all_full_access_cu_guid IS NULL
  AND ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
  THEN ${TABLE}.userbase_paid_courseware_guid END);;
  label: "# Total Paid a la carte Courseware Student Users"
  description: "Paid courseware users with no CU or CUe subscription"
}

measure: paid_a_la_carte_courseware_users_ly {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.all_full_access_cu_guid_ly IS NULL
  AND ${TABLE}.all_full_access_cu_etextbook_guid_ly IS NULL
  THEN ${TABLE}.userbase_paid_courseware_guid_ly END);;
  label: "# Total Paid a la carte Courseware Student Users"
  description: "Paid courseware users with no CU or CUe subscription"
  view_label:"User Counts - Prior Year"
}

measure: paid_a_la_carte_ebook_users {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.all_full_access_cu_guid IS NULL
  AND ${TABLE}.all_full_access_cu_etextbook_guid IS NULL
  AND ${TABLE}.userbase_paid_courseware_guid IS NULL
  THEN ${TABLE}.userbase_paid_ebook_only_guid END);;
  label: "# Total Paid a la carte eBook Student Users"
  description: "Paid ebook users with no courseware access and no CU or CUe subscription"
}

measure: paid_a_la_carte_ebook_users_ly {
  type: number
  sql: {% if exact_counts._parameter_value == 'true' %} COUNT(DISTINCT {% else %} APPROX_COUNT_DISTINCT( {% endif %}
  CASE WHEN ${TABLE}.all_full_access_cu_guid_ly IS NULL
  AND ${TABLE}.all_full_access_cu_etextbook_guid_ly IS NULL
  AND ${TABLE}.userbase_paid_courseware_guid_ly IS NULL
  THEN ${TABLE}.userbase_paid_ebook_only_guid_ly END);;
  label: "# Total Paid a la carte eBook Student Users"
  description: "Paid ebook users with no courseware access and no CU or CUe subscription"
  view_label:"User Counts - Prior Year"
}

}
