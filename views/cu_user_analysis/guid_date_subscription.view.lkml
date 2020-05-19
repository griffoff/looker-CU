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
        , CASE WHEN COUNTRY_CD = 'US' THEN 'USA' WHEN COUNTRY_CD IS NOT NULL THEN COUNTRY_CD ELSE 'Other' END AS region
        , 'Other' AS platform
        , CASE WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
          WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
          ELSE 'Other' END AS organization
        FROM ${dim_date.SQL_TABLE_NAME} dim_date
        INNER JOIN sub_users ON dim_date.datevalue BETWEEN subscription_start AND subscription_end
        INNER JOIN prod.datavault.hub_user hu ON sub_users.user_guid = hu.UID
        LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal
        LEFT JOIN prod.datavault.sat_user ON hu.UID = sat_user.linked_guid AND sat_user.active
        INNER JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
        INNER JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key AND sui.active
        INNER JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
        LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
        WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
        AND ui.hub_user_key IS NULL
          ;;
      persist_for: "24 hours"
    }

    dimension: user_sso_guid {
      type: string
    }

    dimension: date {
      type: date
    }

    dimension: content_type {
      type: string
    }

  dimension: user_type {
    type: string
  }

  dimension: region {
    type: string
  }

  dimension: platform {
    type: string
  }

  dimension: organization {
    type: string
  }

  }
