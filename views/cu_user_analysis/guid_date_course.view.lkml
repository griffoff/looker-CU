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
    FROM prod.stg_clts.activations_non_olr non_olr
    left join wa_match on non_olr.unique_user_id = cast(wa_match.id as STRING)
    left join prod.unlimited.vw_partner_to_primary_user_guid guids
      ON (case when "#SOURCE" = 'SAM2010' then unique_user_id when "#SOURCE" = 'WebAssign' then coalesce(wa_guid, "#SOURCE" || UNIQUE_USER_ID) else "#SOURCE" || UNIQUE_USER_ID end) = guids.partner_guid
    LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON non_olr.actv_isbn = PRODUCT.isbn13
    WHERE actv_dt >= '2018-08-01'
      AND actv_user_type = 'student'
      AND actv_trial_purchase not in ('Duplicate', 'Trial', 'Continued Enrollment')
      AND print_digital_config_cd in ('020','021','025','023')
    )

    ,activations_non_olr AS (
    SELECT DISTINCT merged_guid AS user_sso_guid
    , actv_dt AS course_start
    , DATEADD(W,20,actv_dt) AS course_end
    , actv_dt AS activation_date
    FROM non_olr
    )

    ,activations_olr AS (
    SELECT PRODUCT.PRINT_DIGITAL_CONFIG_CD as content_code
         , product.PRINT_DIGITAL_CONFIG_DE as content_descr
         ,product.DIVISION_CD
         , coalesce(m.PRIMARY_GUID,a.USER_GUID) AS merged_guid
         , a.*
    FROM prod.STG_CLTS.ACTIVATIONS_OLR a
    LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid m on a.USER_GUID = m.PARTNER_GUID
    LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON a.actv_isbn = PRODUCT.isbn13
    )

    ,activations_olr_no_context_id AS (
    SELECT DISTINCT merged_guid AS user_sso_guid
      , actv_dt AS course_start
      , DATEADD(W,20,actv_dt) AS course_end
      , actv_dt AS activation_date
    FROM activations_olr
    WHERE CONTEXT_ID IS NULL
      AND ACTV_DT > '01-Aug-2018'
      AND lower(actv_user_type) = 'student'
      AND PLATFORM NOT IN ('MindTap Reader','Cengage Unlimited')
      AND ACTV_TRIAL_PURCHASE NOT IN ('Trial','Duplicate')
      AND content_code IN ('020','021','025','023')
      AND code_source <> 'Locker'
    )

    ,course_users AS (
    SELECT DISTINCT user_sso_guid, course_key, instructor_guid, u.context_id
    ,LEAST(COALESCE(course_start_date, enrollment_date, actv_dt)
          ,COALESCE(actv_dt, enrollment_date, course_start_date)
          ,COALESCE(enrollment_date, course_start_date, actv_dt))::date AS course_start
    ,LEAST(COALESCE(datediff(w,course_start_date,course_end_date),20),52) AS course_length
    ,LEAST(COALESCE(course_end_date,'2100-12-31'),DATEADD(w,course_length,course_start))::date AS course_end
    , COALESCE(LEAST(actv_dt, DATEADD(D, 1 / 2 * course_length, course_start), DATEADD(D, 60, course_start)),DATEADD(D, 14, course_start)) AS unpaid_access_end
    , actv_dt as activation_date
    FROM prod.cu_user_analysis.user_courses u
    LEFT JOIN activations_olr a ON u.user_sso_guid = a.merged_guid AND u.context_id = a.context_id
    )
    ,course_instructors AS (
    SELECT coalesce(hu.uid, s.linked_guid, course.instructor_guid) as user_sso_guid
    , course_key, min(course_start) as course_start, max(course_end) as course_end
    FROM course_users course
    left join prod.datavault.hub_coursesection h on course.context_id = h.context_id
    left join prod.datavault.link_user_coursesection l on h.hub_coursesection_key = l.hub_coursesection_key
    inner join prod.datavault.sat_user s on l.hub_user_key = s.hub_user_key and s.active and s.instructor
    inner join prod.datavault.hub_user hu on s.HUB_USER_KEY = hu.HUB_USER_KEY
    GROUP BY 1,2
    )
    ,all_users AS (
    SELECT user_sso_guid, course_start, course_end, 'Student' AS user_type, activation_date, NULL AS unpaid_access_end, 'Activations Non-OLR' AS source
    FROM activations_non_olr
    UNION
    SELECT user_sso_guid, course_start, course_end, 'Student' AS user_type, activation_date, NULL AS unpaid_access_end, 'Activations OLR' AS source
    FROM activations_olr_no_context_id

    UNION
    SELECT user_sso_guid, course_start, course_end,'Student' AS user_type, activation_date, unpaid_access_end, 'User Courses' AS source
    FROM course_users
    UNION
    SELECT user_sso_guid, course_start, course_end, 'Instructor' AS user_type, NULL AS activation_date, NULL AS unpaid_access_end, 'User Courses' AS source
    FROM course_instructors
    )
    SELECT dim_date.datevalue as date, user_sso_guid, 'Courseware' AS content_type, user_type, source
      , CASE WHEN dim_date.datevalue >= activation_date THEN TRUE ELSE FALSE END AS paid_flag
      , CASE WHEN activation_date IS NULL AND dim_date.datevalue > unpaid_access_end THEN TRUE ELSE FALSE END AS expired_access_flag
    FROM ${dim_date.SQL_TABLE_NAME} dim_date
    LEFT JOIN all_users ON dim_date.datevalue BETWEEN course_start AND course_end

    INNER JOIN prod.datavault.hub_user hu on all_users.user_sso_guid = hu.uid
    LEFT JOIN prod.datavault.sat_user_internal ui on hu.hub_user_key = ui.hub_user_key and ui.active and ui.internal

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

  dimension: paid_flag {
    type: yesno
    sql: ${TABLE}.paid_flag ;;
  }

  dimension: expired_access_flag {
    type: yesno
    sql: ${TABLE}.expired_access_flag ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }

}
