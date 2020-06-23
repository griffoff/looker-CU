explore: guid_date_course {hidden:no}

view: guid_date_course {
  derived_table: {
    sql:
      with wa_match as (
      select distinct wa_users.id
        , wa_users.sso_guid ,array_to_string(array_slice(wa_emails.guids, 0, 1),'') as wa_email_guid --for email-based guid take first instance (as is decscending date ordered) of guid assocaited from email from pete's match to the user mutation table
        , coalesce(wa_users.sso_guid, wa_email_guid) as wa_guid  --first take sso_guid listed in webassign users table, then take guid associated with email from Pete's match to IAM.user_mutation table
      from WebAssign.wa_app_v4net.users wa_users
      left join strategy.graded_analysis.wa_match wa_emails on wa_users.email = wa_emails.email --may want to update to a more official place - from Pete
      )
      ,non_olr as (
      SELECT
        case when "#SOURCE" = 'SAM2010' then unique_user_id when "#SOURCE" = 'WebAssign' then coalesce(wa_guid, 'Non-OLR-' || "#SOURCE" || UNIQUE_USER_ID) else 'Non-OLR-' || "#SOURCE" || UNIQUE_USER_ID end AS non_olr_guid
        , coalesce(primary_guid, non_olr_guid) as merged_guid
        , non_olr.actv_dt
        , non_olr.platform
        , cu_flg
      FROM prod.stg_clts.activations_non_olr non_olr
      left join wa_match on non_olr.unique_user_id = cast(wa_match.id as STRING)
      left join prod.unlimited.vw_partner_to_primary_user_guid guids
        ON (case when "#SOURCE" = 'SAM2010' then unique_user_id when "#SOURCE" = 'WebAssign' then coalesce(wa_guid, "#SOURCE" || UNIQUE_USER_ID) else "#SOURCE" || UNIQUE_USER_ID end) = guids.partner_guid
      LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON non_olr.actv_isbn = PRODUCT.isbn13
      WHERE actv_dt >= '2017-07-01'
        AND actv_user_type = 'student'
        AND actv_trial_purchase not in ('Duplicate', 'Trial', 'Continued Enrollment')
        AND print_digital_config_cd in ('020','021','025','023')
      )
      ,activations_non_olr AS (
      SELECT DISTINCT merged_guid AS user_sso_guid
        , actv_dt AS course_start
        , DATEADD(W,16,actv_dt) AS course_end
        , actv_dt AS activation_date
        , cu_flg
        , platform
        , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
        , CASE WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
               WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
               ELSE 'Other' END AS organization
      FROM non_olr
      LEFT JOIN prod.datavault.hub_user hu ON merged_guid = hu.UID
      INNER JOIN prod.datavault.sat_user su ON hu.hub_user_key = su.hub_user_key AND su.active
      INNER JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
      INNER JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key AND sui.active
      INNER JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
      LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
      )
      , activations_olr AS (
      SELECT PRODUCT.PRINT_DIGITAL_CONFIG_CD as content_code
        , coalesce(m.PRIMARY_GUID,a.USER_GUID) AS merged_guid
        , a.actv_dt
        , a.platform
        , a.context_id
        , a.actv_user_type
        , a.actv_trial_purchase
        , a.code_source
        , a.cu_flg
        , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
        , CASE WHEN e.mkt_seg_maj_cd = 'PSE' AND e.mkt_seg_min_cd in ('056','060') THEN 'Career'
                WHEN e.mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
                ELSE 'Other' END AS organization
      FROM prod.STG_CLTS.ACTIVATIONS_OLR a
      LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m on a.USER_GUID = m.PARTNER_GUID
      LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON a.actv_isbn = PRODUCT.isbn13
      LEFT JOIN prod.datavault.hub_user hu ON coalesce(m.PRIMARY_GUID,a.USER_GUID) = hu.UID
      INNER JOIN prod.datavault.sat_user su ON hu.hub_user_key = su.hub_user_key AND su.active
      INNER JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
      INNER JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key AND sui.active
      INNER JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
      LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
      )
      ,activations_olr_no_context_id AS (
      SELECT DISTINCT merged_guid AS user_sso_guid
        , actv_dt AS course_start
        , DATEADD(W,16,actv_dt) AS course_end
        , actv_dt AS activation_date
        , cu_flg
        , platform
        , region
        , organization
      FROM activations_olr
      WHERE CONTEXT_ID IS NULL
      AND ACTV_DT > '2017-07-01'
      AND lower(actv_user_type) = 'student'
      AND PLATFORM NOT IN ('MindTap Reader','Cengage Unlimited')
      AND ACTV_TRIAL_PURCHASE NOT IN ('Trial','Duplicate')
      AND content_code IN ('020','021','025','023')
      AND coalesce(code_source,'') <> 'Locker'
      )
      ,course_users AS (
      SELECT DISTINCT user_sso_guid, course_key, instructor_guid, u.context_id
        , CASE WHEN cu_subscription_id IS NOT NULL THEN 'Y' ELSE 'N' END AS cu_flg
        , COURSE_START_DATE as csd
        , LEAST(COALESCE(actv_dt, enrollment_date, course_start_date)
        , COALESCE(enrollment_date, actv_dt, course_start_date))::date AS csm
        , COURSE_END_DATE as ced
        , datediff(w,csd,ced) + 1 as cl
        , datediff(w,csm,ced) + 1 as clm
        , case
             when ced is null then 16
             when csd is null then iff(csm < ced,clm,16)
             when ced <= csd and ced <= csm then 16
             when ced > csm then iff(csd <= csm or csd >= ced,clm,cl)
             when ced > csd then iff(csm >= ced,cl,clm)
             else 16
        end as course_length_mod
        , iff(course_length_mod > 80,16,course_length_mod) as course_length
        , iff(csm is null,DATEADD(w,-course_length_mod,ced),csm) as course_start
        , DATEADD(w,course_length,course_start)::date AS course_end
        , COALESCE(LEAST(actv_dt, DATEADD(D, 1 / 2 * course_length, course_start), DATEADD(D, 60, course_start)),DATEADD(D, 14, course_start)) AS unpaid_access_end
        , actv_dt as activation_date
        , CASE WHEN p.platform IS NOT NULL THEN p.platform ELSE 'Other' END AS platform
        , CASE WHEN COUNTRY_CD = 'US' THEN 'USA' WHEN COUNTRY_CD IS NOT NULL THEN COUNTRY_CD ELSE 'Other' END AS region
        , CASE WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
               WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
               ELSE 'Other' END AS organization
      FROM prod.cu_user_analysis.user_courses u
      LEFT JOIN activations_olr a ON u.user_sso_guid = a.merged_guid AND u.context_id = a.context_id
      LEFT JOIN prod.datavault.hub_user hu ON u.user_sso_guid = hu.UID
      INNER JOIN prod.datavault.sat_user su ON hu.hub_user_key = su.hub_user_key AND su.active
      INNER JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
      INNER JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key AND sui.active
      INNER JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
      LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
      LEFT JOIN prod.stg_clts.products p ON u.isbn = p.isbn13
      )
      ,course_instructors AS (
      SELECT coalesce(hu.uid, s.linked_guid, course.instructor_guid) as user_sso_guid
        , course_key, course.platform, course.region, organization, min(course_start) as course_start, max(course_end) as course_end
      FROM course_users course
      left join prod.datavault.hub_coursesection h on course.context_id = h.context_id
      left join prod.datavault.link_user_coursesection l on h.hub_coursesection_key = l.hub_coursesection_key
      inner join prod.datavault.sat_user s on l.hub_user_key = s.hub_user_key and s.active and s.instructor
      inner join prod.datavault.hub_user hu on s.HUB_USER_KEY = hu.HUB_USER_KEY
      GROUP BY 1,2,3,4,5
      )
      ,all_users AS (
      SELECT user_sso_guid, course_start, course_end, 'Student' AS user_type, activation_date, NULL AS unpaid_access_end, 'Activations Non-OLR' AS source, platform, region, organization, cu_flg
      FROM activations_non_olr
      UNION ALL
      SELECT user_sso_guid, course_start, course_end, 'Student' AS user_type, activation_date, NULL AS unpaid_access_end, 'Activations OLR' AS source, platform, region, organization, cu_flg
      FROM activations_olr_no_context_id
      UNION ALL
      SELECT user_sso_guid, course_start, course_end,'Student' AS user_type, activation_date, unpaid_access_end, 'User Courses' AS source, platform, region, organization, cu_flg
      FROM course_users
      UNION ALL
      SELECT user_sso_guid, course_start, course_end, 'Instructor' AS user_type, NULL AS activation_date, NULL AS unpaid_access_end, 'User Courses' AS source, platform, region, organization, 'N' AS cu_flg
      FROM course_instructors
      )
      SELECT DISTINCT dim_date.datevalue as date, user_sso_guid, 'Courseware' AS content_type, user_type, platform, region, organization, cu_flg
        , CASE WHEN dim_date.datevalue >= activation_date THEN TRUE ELSE FALSE END AS paid_flag
        , CASE WHEN activation_date IS NULL AND dim_date.datevalue > unpaid_access_end THEN TRUE ELSE FALSE END AS expired_access_flag
      FROM ${dim_date.SQL_TABLE_NAME} dim_date
      LEFT JOIN all_users ON dim_date.datevalue BETWEEN course_start AND course_end
      INNER JOIN prod.datavault.hub_user hu on all_users.user_sso_guid = hu.uid
      LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal
      WHERE dim_date.datevalue BETWEEN '2017-07-01' AND CURRENT_DATE()
        AND ui.hub_user_key IS NULL
      ORDER BY date
    ;;
    datagroup_trigger: daily_refresh
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

  dimension: paid_flag {
    type: yesno
  }

  dimension: expired_access_flag {
    type: yesno
  }

  dimension: cu_flg {}

  dimension: platform {
    type: string
  }

  dimension: region {
    type: string
  }

  dimension: organization {
    type: string
  }

}
