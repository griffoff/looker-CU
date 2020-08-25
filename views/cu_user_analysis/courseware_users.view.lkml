explore: courseware_users {}
view: courseware_users {

    derived_table: {
      sql:
        with wa_match as (
          select distinct wa_users.id
            , wa_users.sso_guid ,array_to_string(array_slice(wa_emails.guids, 0, 1),'') as wa_email_guid --for email-based guid take first instance (as is decscending date ordered) of guid assocaited from email from pete's match to the user mutation table
            , coalesce(wa_users.sso_guid, wa_email_guid) as wa_guid  --first take sso_guid listed in webassign users table, then take guid associated with email from Pete's match to IAM.user_mutation table
          from WebAssign.wa_app_v4net.users wa_users
          left join strategy.graded_analysis.wa_match wa_emails on wa_users.email = wa_emails.email --may want to update to a more official place - from Pete

        )
        , activations_non_olr AS (
          SELECT DISTINCT
            case when "#SOURCE" = 'SAM2010' then unique_user_id when "#SOURCE" = 'WebAssign' then coalesce(wa_guid, 'Non-OLR-' || "#SOURCE" || UNIQUE_USER_ID) else 'Non-OLR-' || "#SOURCE" || UNIQUE_USER_ID end AS non_olr_guid
            , coalesce(su.LINKED_GUID, hu.UID, non_olr_guid) as merged_guid
            , actv_dt AS activation_date
            , actv_dt AS course_start
            , DATEADD(W,16,actv_dt) AS course_end
            , non_olr.platform
            , case when actv_user_type = 'student' then 'Student' else 'Instructor' end as user_type
            , coalesce(try_cast(CU_FLG as boolean),false) as cu_flg
            , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
            , CASE
                WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
                WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
                ELSE 'Other'
              END AS organization
            , concat(ACTV_ENTITY_ID, product.PROD_FAMILY_CD) as adoption_key
          FROM prod.stg_clts.activations_non_olr non_olr
          LEFT JOIN wa_match on non_olr.unique_user_id = cast(wa_match.id as STRING)
          LEFT JOIN prod.DATAVAULT.HUB_USER hu
            ON (case when "#SOURCE" = 'SAM2010' then unique_user_id when "#SOURCE" = 'WebAssign' then coalesce(wa_guid, "#SOURCE" || UNIQUE_USER_ID) else "#SOURCE" || UNIQUE_USER_ID end) = hu.uid
          LEFT JOIN prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
          LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
          LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON non_olr.actv_isbn = PRODUCT.isbn13
          LEFT JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
          LEFT JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key and sui.active
          LEFT JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
          LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
          WHERE actv_dt >= '2017-07-01'
            AND actv_trial_purchase not in ('Duplicate', 'Trial', 'Continued Enrollment')
            AND print_digital_config_cd in ('020','021','025','023')
            AND ui.hub_user_key IS NULL
        )
        , activations_olr AS (
          SELECT PRODUCT.PRINT_DIGITAL_CONFIG_CD as content_code
            , coalesce(su.LINKED_GUID, a.USER_GUID) AS merged_guid
            , a.actv_dt
            , a.platform
            , a.context_id
            , case when actv_user_type = 'student' then 'Student' else 'Instructor' end as user_type
            , a.actv_trial_purchase
            , a.code_source
            , coalesce(try_cast(CU_FLG as boolean),false) as cu_flg
            , CASE WHEN e.country_cd = 'US' THEN 'USA' WHEN e.country_cd IS NOT NULL THEN e.country_cd ELSE 'Other' END AS region
            , CASE
                WHEN e.mkt_seg_maj_cd = 'PSE' AND e.mkt_seg_min_cd in ('056','060') THEN 'Career'
                WHEN e.mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
                ELSE 'Other'
              END AS organization
            , concat(ACTV_ENTITY_ID, product.PROD_FAMILY_CD) as adoption_key
          FROM prod.STG_CLTS.ACTIVATIONS_OLR a
          LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON a.actv_isbn = PRODUCT.isbn13
          LEFT JOIN prod.datavault.hub_user hu ON a.USER_GUID = hu.UID
          LEFT JOIN prod.datavault.SAT_USER_V2 su ON hu.hub_user_key = su.hub_user_key AND su._LATEST
          LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
          LEFT JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
          LEFT JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key and sui.active
          LEFT JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
          LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
          WHERE ui.hub_user_key IS NULL
        )
        ,activations_olr_no_context_id AS (
          SELECT DISTINCT merged_guid
            , actv_dt AS course_start
            , DATEADD(W,16,actv_dt) AS course_end
            , actv_dt AS activation_date
            , cu_flg
            , platform
            , region
            , organization
            , user_type
            , adoption_key
          FROM activations_olr
          WHERE CONTEXT_ID IS NULL
            AND ACTV_DT > '2017-07-01'
            AND PLATFORM NOT IN ('MindTap Reader','Cengage Unlimited')
            AND ACTV_TRIAL_PURCHASE NOT IN ('Trial','Duplicate')
            AND content_code IN ('020','021','025','023')
            AND coalesce(code_source,'') <> 'Locker'
        )
        ,course_users AS (
          SELECT DISTINCT coalesce(su.LINKED_GUID,u.USER_SSO_GUID) as merged_guid
            , course_key
            , instructor_guid
            , case when su.INSTRUCTOR then 'Instructor' else 'Student' end as user_type
            , u.context_id
            , (cu_subscription_id IS NOT NULL AND cu_subscription_id <> 'TRIAL' AND hs.SUBSCRIPTION_ID is not null and coalesce(ss.subscription_plan_id,'') not ilike '%trial%') OR coalesce(cui_flag,'N') = 'Y' as cu_flg
            , COURSE_START_DATE as csd
            , LEAST(COALESCE(actv_dt, enrollment_date, course_start_date)
            , COALESCE(enrollment_date, actv_dt, course_start_date))::date AS csm
            , COURSE_END_DATE as ced
            , datediff(w,csd,ced) + 1 as cl
            , datediff(w,csm,ced) + 1 as clm
            , case
                  when clm < 16 then clm
                --when ced is null then 16
                --when csd is null then iff(csm < ced,clm,16)
                --when ced <= csd and ced <= csm then 16
                --when ced > csm then iff(csd <= csm or csd >= ced,clm,cl)
                --when ced > csd then iff(csm >= ced,cl,clm)
                else 16
              end as course_length_mod
            , iff(course_length_mod > 80,16,course_length_mod) as course_length
            , iff(csm is null,DATEADD(w,-course_length_mod,ced),csm) as course_start
            , DATEADD(w,course_length,course_start)::date AS course_end
            , COALESCE(LEAST(actv_dt, DATEADD(D, 1 / 2 * course_length, course_start), DATEADD(D, 60, course_start)),DATEADD(D, 14, course_start)) AS unpaid_access_end
            , actv_dt as activation_date
            , CASE WHEN u.context_id LIKE 'GWMTP%' THEN 'Middle Product' WHEN p.platform IS NOT NULL THEN p.platform ELSE 'Other' END AS platform
            , CASE WHEN COUNTRY_CD = 'US' THEN 'USA' WHEN COUNTRY_CD IS NOT NULL THEN COUNTRY_CD ELSE 'Other' END AS region
            , CASE
                WHEN mkt_seg_maj_cd = 'PSE' AND mkt_seg_min_cd in ('056','060') THEN 'Career'
                WHEN mkt_seg_maj_cd = 'PSE' THEN 'Higher Ed'
                ELSE 'Other'
              END AS organization
            , concat(u.entity_id, p.PROD_FAMILY_CD) as adoption_key
          FROM prod.cu_user_analysis.user_courses u
          LEFT JOIN activations_olr a ON u.user_sso_guid = a.merged_guid AND u.context_id = a.context_id
          LEFT JOIN prod.datavault.hub_user hu ON u.user_sso_guid = hu.UID
          LEFT JOIN prod.datavault.SAT_USER_V2 su ON hu.hub_user_key = su.hub_user_key AND su._LATEST
          LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.internal
          LEFT JOIN prod.datavault.link_user_institution lui ON hu.hub_user_key = lui.hub_user_key
          LEFT JOIN prod.datavault.sat_user_institution sui ON lui.link_user_institution_key = sui.link_user_institution_key and sui.active
          LEFT JOIN prod.datavault.hub_institution hi ON lui.hub_institution_key = hi.hub_institution_key
          LEFT JOIN prod.STG_CLTS.ENTITIES e ON hi.institution_id = e.ENTITY_NO
          LEFT JOIN prod.stg_clts.products p ON u.isbn = p.isbn13
          left join prod.DATAVAULT.HUB_SUBSCRIPTION hs on hs.SUBSCRIPTION_ID = u.CU_SUBSCRIPTION_ID
          left join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP ss on ss.HUB_SUBSCRIPTION_KEY = hs.HUB_SUBSCRIPTION_KEY and ss._LATEST
          WHERE ui.hub_user_key IS NULL
        )
        ,course_instructors AS (
          SELECT DISTINCT coalesce(s.linked_guid, hu.uid, course.instructor_guid) as merged_guid
            , course_key, course.platform, course.region, course.organization, course.adoption_key, course.course_start, course.course_end
            FROM (
              SELECT instructor_guid, context_id, course_key, platform, region, organization, adoption_key, min(course_start) as course_start, max(course_end) as course_end
              FROM course_users
              WHERE instructor_guid is not null
              GROUP BY 1, 2, 3, 4, 5, 6, 7
                  ) course
            LEFT JOIN prod.datavault.hub_coursesection h on course.context_id = h.context_id
            LEFT JOIN prod.datavault.link_user_coursesection l on h.hub_coursesection_key = l.hub_coursesection_key
            LEFT JOIN prod.datavault.SAT_USER_V2 s on l.hub_user_key = s.hub_user_key and s._LATEST and s.instructor
            LEFT JOIN prod.datavault.hub_user hu on s.HUB_USER_KEY = hu.HUB_USER_KEY
        )
        SELECT merged_guid as user_sso_guid, course_start, course_end, user_type, activation_date, NULL AS unpaid_access_end, 'Activations Non-OLR' AS source, platform, region, organization, adoption_key, cu_flg
        FROM activations_non_olr
        UNION ALL
        SELECT merged_guid, course_start, course_end, user_type, activation_date, NULL AS unpaid_access_end, 'Activations OLR' AS source, platform, region, organization, adoption_key, cu_flg
        FROM activations_olr_no_context_id
        UNION ALL
        SELECT merged_guid, course_start, course_end, user_type, activation_date, unpaid_access_end, 'User Courses' AS source, platform, region, organization, adoption_key, cu_flg
        FROM course_users
        UNION ALL
        SELECT merged_guid, course_start, course_end, 'Instructor' AS user_type, NULL AS activation_date, NULL AS unpaid_access_end, 'User Courses' AS source, platform, region, organization, adoption_key, 'N' AS cu_flg
        FROM course_instructors
    ;;
      datagroup_trigger: daily_refresh
    }

  dimension: user_sso_guid {type: string}
  dimension: course_start {type: date_raw}
  dimension: course_end {type: date_raw}
  dimension: user_type {type: string}
  dimension: activation_date {type: date_raw}
  dimension: unpaid_access_end {type: date_raw}
  dimension: source {type: string}
  dimension: platform {type: string}
  dimension: region {type: string}
  dimension: organization {type: string}
  dimension: adoption_key {type: string}
  dimension: cu_flg {type: string}

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }




  }
