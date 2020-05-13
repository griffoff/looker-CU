explore: daily_paid_users {hidden:no}
view: daily_paid_users {
  derived_table: {
# derived table w/ date, paid user count, paid student count, paid instructor count
# from dim_date left join user_courses left join subscriptions
# where date between course activation and course end
# or date between subsc start and subscr end
    sql:
      SELECT date
      ,count(distinct case when paid_flag = true then user_sso_guid end) as paid_user_count
      ,count(distinct case when content_type = 'Courseware' and paid_content_rank = 1 then user_sso_guid end) as paid_courseware_users
      ,count(distinct case when content_type = 'eBook' and paid_content_rank = 1 then user_sso_guid end) as paid_ebook_users
      ,count(distinct case when content_type = 'Full Access CU Subscription' and paid_content_rank = 1 then user_sso_guid end) as paid_cu_users
      ,count(distinct case when content_type = 'Trial CU Subscription' then user_sso_guid end) as trial_cu_users
      FROM ${guid_date_paid.SQL_TABLE_NAME}
      WHERE date BETWEEN '2018-01-01' AND CURRENT_DATE()
      GROUP BY 1
      ;;

      persist_for: "24 hours"
    }

    dimension: date {
      hidden:  yes
      type: date
      primary_key: yes}

  dimension: max_date {
    hidden: yes
    type: date
    sql: (SELECT MAX(date) FROM ${guid_date_paid.SQL_TABLE_NAME});;
  }

    measure: paid_user_count {
      group_label: "Paid Users"
      label: "# Paid Student Users"
      description: "# Users with an active paid course, paid ebook access, or a full access CU subscription (if more than one day is included in filter, this shows the average over the chosen period)"
      type: number
      sql: AVG(${TABLE}.paid_user_count) ;;
      value_format_name: decimal_0
    }

  measure: paid_courseware_users {
    group_label: "Paid Users"
    label: "# Paid Courseware Student Users"
    description: "# Users with an active paid course (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.paid_courseware_users) ;;
    value_format_name: decimal_0
  }

  measure: paid_ebook_users {
    group_label: "Paid Users"
    label: "# Paid eBook Only Student Users"
    description: "# Users with paid ebook access but no active paid course (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.paid_ebook_users) ;;
    value_format_name: decimal_0
  }

  measure: paid_cu_users {
    group_label: "Paid Users"
    label: "# Paid CU Student Users, no provisions"
    description: "# Users with full access CU subscription but no active paid course or ebook access (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.paid_cu_users) ;;
    value_format_name: decimal_0
  }

  measure: trial_cu_users {
    group_label: "Paid Users"
    label: "# Trial CU Student Users, no provisions (unpaid)"
    description: "# Users with trial access CU subscription but no active paid course or ebook access (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.trial_cu_users) ;;
    value_format_name: decimal_0
    hidden: yes
  }
}
