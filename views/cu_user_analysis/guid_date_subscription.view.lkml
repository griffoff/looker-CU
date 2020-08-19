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
          AND (ss.SUBSCRIPTION_PLAN_ID ILIKE 'CU-ETextBook%'
                   OR ss.SUBSCRIPTION_PLAN_ID ILIKE 'CU-Trial%'
                   OR ss.SUBSCRIPTION_PLAN_ID ILIKE 'Full-Access%'
                   OR ss.SUBSCRIPTION_PLAN_ID = 'Limited-Access-180'
                   OR ss.SUBSCRIPTION_PLAN_ID = 'Trial')
          AND ss._LATEST
        LEFT JOIN prod.datavault.sat_subscription_bp bp ON hs.hub_subscription_key = bp.hub_subscription_key
          AND bp.SUBSCRIPTION_STATE IN ('full_access','trial_access')
        WHERE user_guid IS NOT NULL
        )
        SELECT DISTINCT dim_date.datevalue as date
        , COALESCE(linked_guid,sub_users.user_guid) AS user_sso_guid
        , subscription_type
        , CASE
            WHEN subscription_type ILIKE 'CU-ETextBook-Trial%' THEN 'CU eTextbook Trial'
            WHEN subscription_type ILIKE 'CU-ETextBook%' THEN 'CU eTextbook Full Access'
            WHEN subscription_type ILIKE 'trial%' THEN 'CU Trial'
            WHEN subscription_type ILIKE 'CU-Trial%' THEN 'CU Trial'
            ELSE 'CU Full Access'
            END AS content_type
        , CASE WHEN (instructor = false OR instructor IS NULL) THEN 'Student' ELSE 'Instructor' END as user_type
        , CASE WHEN COUNTRY_CD = 'US' THEN 'USA' WHEN COUNTRY_CD IS NOT NULL THEN COUNTRY_CD ELSE 'Other' END AS region
        , 'CU Subscription' AS platform
        , CASE WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
          WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
          ELSE 'Other' END AS organization
        FROM ${dim_date.SQL_TABLE_NAME} dim_date
        INNER JOIN sub_users ON dim_date.datevalue BETWEEN subscription_start AND subscription_end
        LEFT JOIN prod.datavault.hub_user hu ON sub_users.user_guid = hu.UID
        LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
        LEFT JOIN prod.datavault.SAT_USER_V2 su ON hu.hub_user_key = su.hub_user_key AND su._LATEST
        LEFT JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
        LEFT JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key and sui.active
        LEFT JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
        LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
        WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
        AND ui.hub_user_key IS NULL
        ORDER BY date
          ;;
      datagroup_trigger: daily_refresh
    }

    dimension: user_sso_guid {
      hidden: yes
      type: string
    }


  dimension_group: date {
    label: "Calendar"
    type:time
    timeframes: [raw,date,week,month,year]
    hidden: no
  }

    dimension: content_type {
      view_label: "Filters"
      type: string
      hidden:  yes
    }

    dimension: subscription_type {}

  dimension: subscription_length {
    case: {
      when: {label:"4 Month" sql: ${TABLE}.subscription_type ILIKE '%120%';;}
      when: {label:"6 Month" sql: ${TABLE}.subscription_type ILIKE '%180%';;}
      when: {label:"12 Month" sql: ${TABLE}.subscription_type ILIKE '%365%';;}
      when: {label:"24 Month" sql: ${TABLE}.subscription_type ILIKE '%730%';;}
      when: {label:"Trial" sql: ${TABLE}.subscription_type ILIKE '%trial%';;}
      else: "Other"

    }
  }

  dimension: user_type {
    hidden: yes
    type: string
  }

  dimension: region {
    view_label: "Filters"
    type: string
  }

  dimension: platform {
    view_label: "Filters"
    type: string
  }

  dimension: organization {
    view_label: "Filters"
    type: string

  }

  measure: full_access_user_count {
    group_label: "CU Subscribers"
    label: "# Full Access CU Subscribers"
    description: "# Full Access CU Subscribers"
    type: count_distinct
    sql:  CASE WHEN ${content_type} = 'CU Full Access' THEN ${user_sso_guid} END;;
  }

  measure: cu_extextbook_user_count {
    group_label: "CU Subscribers"
    label: "# CU eTextbook Full Access Subscribers"
    description: "# Full Access CU eTextbook Subscribers"
    type: count_distinct
    sql:  CASE WHEN ${content_type} = 'CU eTextbook Full Access' THEN ${user_sso_guid} END;;
  }

  measure: trial_access_user_count {
    group_label: "CU Subscribers"
    label: "# Trial Access CU Subscribers"
    description: "# Trial Access CU Subscribers"
    type: count_distinct
    sql:  CASE WHEN ${content_type} = 'CU Trial' THEN ${user_sso_guid} END;;
  }

  measure: cu_etextbook_trial_user_count {
    group_label: "CU Subscribers"
    label: "# CU eTextbook Trial Access Subscribers"
    description: "# Trial Access CU eTextbook Subscribers"
    type: count_distinct
    sql:  CASE WHEN ${content_type} = 'CU eTextbook Trial' THEN ${user_sso_guid} END;;
  }

  }
