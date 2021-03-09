include: "./live_subscription_status.view"

explore: user_facts {hidden:yes}
view: user_facts {

  view_label: "User Details"

  derived_table: {
    sql:
      WITH product_usage AS (
        SELECT
          up.user_sso_guid
          , up.platform_last_added
          , up.section_product_type_last_added
          , COUNT(DISTINCT CASE WHEN up.paid_flag AND (up.active_course OR up.active_provision OR up.active_serial_number) THEN up.pk END) AS current_paid_products
          , COUNT(DISTINCT CASE WHEN (NOT up.paid_flag) AND (up.active_course OR up.active_provision OR up.active_serial_number) THEN up.pk END) AS current_unpaid_products
          , COUNT(DISTINCT CASE WHEN up.paid_flag AND (current_date BETWEEN up.begin_date AND up.end_date) THEN up.course_identifier END) AS current_paid_courses
          , COUNT(DISTINCT CASE WHEN (NOT up.paid_flag) AND (current_date BETWEEN up.begin_date AND up.end_date) THEN up.course_identifier END) AS current_unpaid_courses
          , COUNT(DISTINCT CASE WHEN up.paid_flag
                                AND up.is_ebook_product
                                AND (current_date BETWEEN up.provision_date AND COALESCE(up.provision_expiration_date,CURRENT_DATE))
                                AND up.course_key IS NULL
                              THEN HASH(up.user_sso_guid,up.isbn,up.academic_term) END
            ) AS current_paid_standalone_ebook_provisions
          , COUNT(DISTINCT CASE WHEN (NOT up.paid_flag)
                                AND up.is_ebook_product
                                AND (current_date BETWEEN up.provision_date AND COALESCE(up.provision_expiration_date,CURRENT_DATE))
                                AND up.course_key IS NULL
                              THEN HASH(up.user_sso_guid,up.isbn,up.academic_term) END
            ) AS current_unpaid_standalone_ebook_provisions
        FROM (
          SELECT DISTINCT up.*, ci.begin_date, ci.end_date, ci.course_identifier, pi.is_ebook_product
          , CURRENT_DATE BETWEEN ci.begin_date AND COALESCE(ci.end_date,CURRENT_DATE) AS active_course
          , CURRENT_DATE BETWEEN up.provision_date AND COALESCE(up.provision_expiration_date,CURRENT_DATE) AS active_provision
          , CURRENT_DATE BETWEEN up.serial_number_consumed_date AND COALESCE(up.serial_number_consumed_expiration_date,CURRENT_DATE) AS active_serial_number
          , HASH(up.user_sso_guid,up.isbn,up.institution_id,up.academic_term,up.course_key) AS pk
          , LEAST(COALESCE(enrollment_date,'9999-01-01'),COALESCE(provision_date,'9999-01-01'),COALESCE(activation_date,'9999-01-01'),COALESCE(serial_number_consumed_date,'9999-01-01')) AS added_date
          , LAST_VALUE(pi.platform) IGNORE NULLS OVER(PARTITION BY up.user_sso_guid ORDER BY added_date) AS platform_last_added
          , LAST_VALUE(ci.section_product_type) IGNORE NULLS OVER(PARTITION BY up.user_sso_guid ORDER BY added_date) AS section_product_type_last_added
          FROM ${user_products.SQL_TABLE_NAME} up
          LEFT JOIN ${course_info.SQL_TABLE_NAME} ci ON ci.course_identifier = up.course_key
          LEFT JOIN ${product_info.SQL_TABLE_NAME} pi ON pi.isbn13 = up.isbn
        ) up
        GROUP BY 1,2,3
      )
      , sessions AS (
        SELECT
          s.user_sso_guid
          , MIN(SESSION_START) AS first_session
          , MAX(SESSION_START) AS latest_session
        FROM prod.cu_user_analysis.all_sessions s
        GROUP BY 1
      )
      SELECT DISTINCT
        hu.uid AS user_sso_guid
        , first_session
        , latest_session
        , platform_last_added
        , section_product_type_last_added
        , coalesce(pu.current_paid_products,0) as current_paid_products
        , coalesce(pu.current_unpaid_products,0) as current_unpaid_products
        , coalesce(pu.current_paid_courses,0) as current_paid_courses
        , coalesce(pu.current_unpaid_courses,0) as current_unpaid_courses
        , coalesce(pu.current_paid_standalone_ebook_provisions,0) as current_paid_standalone_ebook_provisions
        , coalesce(pu.current_unpaid_standalone_ebook_provisions,0) as current_unpaid_standalone_ebook_provisions
      FROM prod.datavault.hub_user hu
      INNER JOIN prod.datavault.sat_user_v2 su ON su.hub_user_key = hu.hub_user_key AND su._latest AND su.linked_guid IS NULL
      LEFT JOIN sessions s ON s.user_sso_guid = hu.uid
      LEFT JOIN product_usage pu on pu.user_sso_guid = hu.uid
      ;;
    persist_for: "8 hours"
  }

  dimension: user_sso_guid {
    primary_key: yes
    hidden: yes
  }

  dimension_group: first_session {
    type: time
    timeframes: [raw, time, date, week, month, year]
    description: "Timestamp of users first session"
  }

  dimension_group: latest_session {
    type: time
    timeframes: [raw, time, date, week, month, year]
    description: "Timestamp of users most recent session"
  }

  dimension: current_paid_courses {
    group_label: "Current Product Usage Facts"
    type: number
  }

  dimension: current_unpaid_courses {
    group_label: "Current Product Usage Facts"
    type: number
  }

  dimension: current_paid_standalone_ebook_provisions {
    group_label: "Current Product Usage Facts"
    type: number
  }

  dimension: current_total_standalone_ebook_provisions {
    group_label: "Current Product Usage Facts"
    type: number
    sql: ${current_paid_standalone_ebook_provisions} + ${current_unpaid_standalone_ebook_provisions} ;;
    description: "Paid + Unpaid"
  }

  dimension: current_unpaid_standalone_ebook_provisions {
    group_label: "Current Product Usage Facts"
    type: number
  }

  dimension: current_paid_products {
    group_label: "Current Product Usage Facts"
    type: number
  }

  dimension: current_unpaid_products {
    group_label: "Current Product Usage Facts"
    type: number
  }

  dimension: platform_last_added {
    group_label: "Current Product Usage Facts"
    description: "Platform of the user's most recently added product."
  }

  dimension: section_product_type_last_added {
    group_label: "Current Product Usage Facts"
    description: "Section product type of the user's most recently added course."
  }



}
