explore: daily_cu_subscribers {hidden:yes}
view: daily_cu_subscribers {

    derived_table: {
    sql:
      SELECT date
      ,COUNT(DISTINCT CASE WHEN content_type = 'Full Access CU Subscription' THEN user_sso_guid END) AS cu_subscriber_count
      ,COUNT(DISTINCT CASE WHEN content_type = 'Trial CU Subscription' THEN user_sso_guid END) AS trial_count
      FROM ${guid_date_subscription.SQL_TABLE_NAME}
      WHERE date BETWEEN '2018-01-01' AND CURRENT_DATE()
      GROUP BY 1
      ;;

      persist_for: "24 hours"
    }

    dimension: date {
      hidden: yes
      type: date
      primary_key: yes}

    dimension: max_date {
      hidden: yes
      type: date
      sql: (SELECT MAX(date) FROM ${guid_date_subscription.SQL_TABLE_NAME});;
    }


    measure: paid_cu_users {
      group_label: "CU Subscribers"
      label: "# Full Access CU Subscribers"
      description: "# Full Access CU Subscribers (if more than one day is included in filter, this shows the average over the chosen period)"
      type: number
      sql: AVG(${TABLE}.cu_subscriber_count) ;;
      value_format_name: decimal_0
    }

    measure: trail_cu_user {
      group_label: "CU Subscribers"
      label: "# Trial Access CU Subscribers"
      description: "# Trial Access CU Subscribers (if more than one day is included in filter, this shows the average over the chosen period)"
      type: number
      sql: AVG(${TABLE}.trial_count) ;;
      value_format_name: decimal_0
    }
  }
