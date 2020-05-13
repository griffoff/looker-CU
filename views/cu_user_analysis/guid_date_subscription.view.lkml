explore: guid_date_subscription {}

view: guid_date_subscription {
    derived_table: {
      sql:
        WITH sub_users AS (
        SELECT
          CASE WHEN ss.subscription_start IS NOT NULL THEN ss.CURRENT_GUID ELSE bp.USER_SSO_GUID END AS user_guid
          , COALESCE(ss.subscription_start, bp._effective_from) AS subscription_start
          , COALESCE(COALESCE(ss.cancelled_time, ss.subscription_end), COALESCE(bp._effective_to, bp.subscription_end)) AS subscription_end
          , CASE WHEN ss.subscription_start IS NOT NULL THEN ss.SUBSCRIPTION_PLAN_ID ELSE bp.SUBSCRIPTION_STATE END AS subscription_type
        FROM prod.datavault.hub_subscription hs
        LEFT JOIN prod.datavault.sat_subscription_sap ss ON hs.hub_subscription_key = ss.hub_subscription_key
          AND (ss.SUBSCRIPTION_PLAN_ID ILIKE 'Full%' OR ss.SUBSCRIPTION_PLAN_ID ILIKE 'Limited%' OR ss.SUBSCRIPTION_PLAN_ID = 'Trial')
          AND ss._LATEST
        LEFT JOIN prod.datavault.sat_subscription_bp bp ON hs.hub_subscription_key = bp.hub_subscription_key
          AND bp.SUBSCRIPTION_STATE IN ('full_access','trial_access')
        WHERE user_guid IS NOT NULL
        )
        SELECT DISTINCT dim_date.datevalue as date
        , COALESCE(linked_guid,sub_users.user_guid) AS user_sso_guid
        , CASE WHEN subscription_type ILIKE 'trial%' THEN 'Trial CU Subscription' ELSE 'Full Access CU Subscription' END AS content_type
        , CASE WHEN (instructor = false OR instructor IS NULL) THEN 'Student' ELSE 'Instructor' END as user_type
        FROM ${dim_date.SQL_TABLE_NAME} dim_date
        INNER JOIN sub_users ON dim_date.datevalue BETWEEN subscription_start AND subscription_end
        INNER JOIN prod.datavault.hub_user ON sub_users.user_guid = hub_user.UID
        LEFT JOIN prod.datavault.sat_user_internal ui on hub_user.hub_user_key = ui.hub_user_key and ui.active and ui.internal
        LEFT JOIN prod.datavault.sat_user ON hub_user.UID = sat_user.linked_guid AND sat_user.active
        WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
        AND ui.hub_user_key IS NULL
          ;;
      persist_for: "24 hours"
    }

    dimension: user_sso_guid {
      type: string
      sql: ${TABLE}.USER_SSO_GUID ;;
    }

    dimension: date {
      type: date
      sql: ${TABLE}.date ;;
    }

    dimension: content_type {
      type: string
      sql: ${TABLE}.content_type ;;
    }

  dimension: user_type {
    type: string
    sql: ${TABLE}.user_type ;;
  }

  }
