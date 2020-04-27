explore: daily_digital_users {}
view: daily_digital_users {

    derived_table: {
    sql:
      WITH courseware_users AS (
        SELECT *
        FROM ${guid_date_course.SQL_TABLE_NAME}
      )
      ,ebook_users AS (
        SELECT *
        FROM ${guid_date_ebook.SQL_TABLE_NAME} e
        LEFT JOIN courseware_users c ON e.date = c.date AND e.user_sso_guid = c.user_sso_guid
        WHERE c.user_sso_guid IS NULL
      )
      ,cu_only_users AS (
        SELECT *
        FROM ${guid_date_subscription.SQL_TABLE_NAME} s
        LEFT JOIN courseware_users c ON s.date = c.date AND s.user_sso_guid = c.user_sso_guid
        LEFT JOIN ebook_users e ON e.date = s.date AND e.user_sso_guid = s.user_sso_guid
        WHERE c.user_sso_guid IS NULL AND e.user_sso_guid IS NULL
      )
      ,all_users AS (
        SELECT * FROM courseware_users
        UNION
        SELECT * FROM ebook_users
        UNION
        SELECT * FROM cu_only_users
      )

      SELECT date
        ,COUNT(DISTINCT CASE WHEN content_type = 'Courseware' THEN user_sso_guid END) AS courseware_users
        ,COUNT(DISTINCT CASE WHEN content_type = 'eBook' THEN user_sso_guid END) AS ebook_users
        ,COUNT(DISTINCT CASE WHEN content_type = 'Full Access CU Subscription' THEN user_sso_guid END) AS cu_only_users
        ,COUNT(DISTINCT user_sso_guid) AS digital_users
      FROM all_users
      GROUP BY 1
      ;;

      persist_for: "24 hours"
    }

    dimension: date {
      hidden:  no
      type: date
      primary_key: yes}

    measure: courseware_users {
      label: "# Courseware Users"
      description: "# Users enrolled in an active course (if more than one day is included in filter, this shows the average over the chosen period)"
      type: number
      sql: AVG(${TABLE}.courseware_users) ;;
      value_format_name: decimal_0
    }

  measure: ebook_users {
    label: "# eBook Only Users"
    description: "# Users with access to an eBook but not enrolled in a course (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.ebook_users) ;;
    value_format_name: decimal_0
  }

  measure: cu_only_users {
    label: "# CU Users, no provisions"
    description: "# Users with a full access CU subscriptions but not enrolled in a course or with access to an eBook (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.cu_only_users) ;;
    value_format_name: decimal_0
  }

  measure: digital_users {
    label: "# Digital Users"
    description: "# Users enrolled in an active course, with access to an eBook, or with a full access CU subscription and no provisions (if more than one day is included in filter, this shows the average over the chosen period)"
    type: number
    sql: AVG(${TABLE}.digital_users) ;;
    value_format_name: decimal_0
  }


  }
