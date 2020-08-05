explore: fiscal_year_user_growth  {}
view: fiscal_year_user_growth {
  derived_table: {
    sql:
    with el as (
      select distinct
        case when CU_ENABLED = true or IAC_ISBN13 in ('0000357700006','0000357700013','0000357700020') then 'CUI' else 'IA' end as license_type
        , array_agg(HUB_ENTERPRISELICENSE_KEY) as license_keys
        , IAC_ISBN13
        , CONVERT_TIMEZONE('UTC',sel.BEGIN_DATE)::date as el_begin_date
        , CONVERT_TIMEZONE('UTC',sel.END_DATE)::date as el_end_date
        , sel.INSTITUTION_ID
        , concat(sel.INSTITUTION_ID,p.PROD_FAMILY_CD) as adoption_key
        from PROD.DATAVAULT.SAT_ENTERPRISELICENSE sel
        left join prod.STG_CLTS.products p on sel.IAC_ISBN13 = p.ISBN13
        where sel._LATEST and not sel.IS_DEMO
        group by license_type, IAC_ISBN13, el_begin_date, el_end_date, INSTITUTION_ID, adoption_key
      )

      , el_prev as (
        select *
          , lag(license_type) over (partition by adoption_key order by el_BEGIN_DATE) as prev_license_type
        from el
      )

      , el_keys as (
        select e.*, lk.value as HUB_ENTERPRISELICENSE_KEY
        from el_prev e
        cross join lateral flatten(license_keys) lk
      )

      , el_users_dv as (
        select distinct
          license_type
          , prev_license_type
          , date_trunc(year,dateadd(month,9,CONVERT_TIMEZONE('UTC',se.ENROLLMENT_DATE))) as el_year
          , sel.INSTITUTION_ID
          , adoption_key
          , coalesce(su.LINKED_GUID,hu.uid) as user_guid
          , su.INSTRUCTOR
        from el_keys sel
        inner join prod.DATAVAULT.LINK_EL_TO_SECTION_MAPPING les on sel.HUB_ENTERPRISELICENSE_KEY = les.HUB_ENTERPRISELICENSE_KEY
        inner join prod.DATAVAULT.LINK_USER_COURSESECTION luc on luc.HUB_COURSESECTION_KEY = les.HUB_COURSESECTION_KEY
        inner join prod.DATAVAULT.SAT_ENROLLMENT se on luc.HUB_ENROLLMENT_KEY = se.HUB_ENROLLMENT_KEY and se._latest
        inner join prod.DATAVAULT.hub_user hu on luc.HUB_USER_KEY = hu.HUB_USER_KEY
        inner join prod.DATAVAULT.SAT_USER_V2 su on hu.HUB_USER_KEY = su.HUB_USER_KEY and su._LATEST
        left join prod.DATAVAULT.SAT_USER_INTERNAL sui on su.HUB_USER_KEY = sui.HUB_USER_KEY and sui.INTERNAL
        where sui.INTERNAL is null
        and (coalesce(try_cast(se.PAID_IN_FULL as boolean),false) or su.instructor)
      )

      , el_users_raw as (
        select distinct
          license_type
          , prev_license_type
          , date_trunc(year,dateadd(month,9,CONVERT_TIMEZONE('UTC',r.LOCAL_TIME))) as el_year
          , sel.INSTITUTION_ID
          , adoption_key
          , coalesce(su.LINKED_GUID,hu.uid) as user_guid
          , su.INSTRUCTOR
        from el_keys sel
        inner join prod.DATAVAULT.LINK_EL_TO_SECTION_MAPPING les on sel.HUB_ENTERPRISELICENSE_KEY = les.HUB_ENTERPRISELICENSE_KEY
        inner join prod.DATAVAULT.LINK_USER_COURSESECTION luc on luc.HUB_COURSESECTION_KEY = les.HUB_COURSESECTION_KEY
        inner join prod.datavault.hub_coursesection hc on hc.HUB_COURSESECTION_KEY = luc.HUB_COURSESECTION_KEY
        inner join prod.DATAVAULT.hub_user hu on luc.HUB_USER_KEY = hu.HUB_USER_KEY
        inner join prod.DATAVAULT.SAT_USER_V2 su on hu.HUB_USER_KEY = su.HUB_USER_KEY and su._LATEST
        left join prod.DATAVAULT.SAT_USER_INTERNAL sui on su.HUB_USER_KEY = sui.HUB_USER_KEY and sui.INTERNAL
        inner join prod.unlimited.raw_olr_enrollment r on r.COURSE_KEY = hc.CONTEXT_ID and r.USER_SSO_GUID = hu.UID and r.LOCAL_TIME between sel.el_begin_date and coalesce(sel.el_end_date,current_date())
        where sui.INTERNAL is null
      )
      , el_users as (
      select * from el_users_dv
      union
      select * from el_users_raw
      )

      ,el_counts as (
        select
          case
            when e.license_type = 'IA' and prev_license_type = 'IA' then 'Existing IA deal'
            when e.license_type = 'IA' and prev_license_type = 'CUI' then 'Downgrade CUI to IA'
            when e.license_type = 'IA' and prev_license_type is null then 'New IA deal'
            when e.license_type = 'CUI' and prev_license_type = 'IA' then 'Upgrade IA to CUI'
            when e.license_type = 'CUI' and prev_license_type = 'CUI' then 'Existing CUI deal'
            when e.license_type = 'CUI' and prev_license_type is null then 'New CUI deal'
          end as user_count_descr
          , e.el_year as fiscal_year
          , e.INSTRUCTOR
          , count(distinct e.user_GUID) as user_count
      from el_users e
      group by e.license_type, e.prev_license_type, e.el_year, e.INSTRUCTOR
      order by e.el_year desc, e.INSTRUCTOR
      )



      , adoptions_dv as (
        select
          coalesce(su.LINKED_GUID,hu.uid) as user_guid
          , su.INSTRUCTOR
          , date_trunc(year,dateadd(month,9,CONVERT_TIMEZONE('UTC',se.enrollment_date))) as course_year
          , concat(hs.INSTITUTION_ID, p.PROD_FAMILY_CD) as adoption_key
        from prod.datavault.HUB_COURSESECTION hc
        left join prod.DATAVAULT.LINK_COURSESECTION_INSTITUTION lcs on lcs.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY
        left join prod.DATAVAULT.HUB_INSTITUTION hs on hs.HUB_INSTITUTION_KEY = lcs.HUB_INSTITUTION_KEY
        left join prod.DATAVAULT.LINK_COURSESECTION_ISBN lci on hc.HUB_COURSESECTION_KEY = lci.HUB_COURSESECTION_KEY
        left join prod.DATAVAULT.HUB_ISBN hi on lci.HUB_ISBN_KEY = hi.HUB_ISBN_KEY
        left join prod.STG_CLTS.products p on hi.ISBN13 = p.ISBN13
        inner join prod.DATAVAULT.LINK_USER_COURSESECTION luc on hc.HUB_COURSESECTION_KEY = luc.HUB_COURSESECTION_KEY
        inner join prod.DATAVAULT.SAT_ENROLLMENT se on luc.HUB_ENROLLMENT_KEY = se.HUB_ENROLLMENT_KEY and se._LATEST
        inner join prod.DATAVAULT.hub_user hu on luc.HUB_USER_KEY = hu.HUB_USER_KEY
        inner join prod.DATAVAULT.SAT_USER_V2 su on hu.HUB_USER_KEY = su.HUB_USER_KEY and su._LATEST
        left join prod.DATAVAULT.SAT_USER_INTERNAL sui on hu.HUB_USER_KEY = sui.HUB_USER_KEY and sui.INTERNAL
        where sui.INTERNAL is null
        and (coalesce(try_cast(se.PAID_IN_FULL as boolean),false) or su.instructor)
        )

      , adoptions_raw as (
      select
        coalesce(su.LINKED_GUID,hu.uid) as user_guid
        , su.INSTRUCTOR
        , date_trunc(year,dateadd(month,9,CONVERT_TIMEZONE('UTC',r.LOCAL_TIME))) as course_year
        , concat(hs.INSTITUTION_ID, p.PROD_FAMILY_CD) as adoption_key
      from prod.datavault.HUB_COURSESECTION hc
      left join prod.DATAVAULT.LINK_COURSESECTION_INSTITUTION lcs on lcs.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY
      left join prod.DATAVAULT.HUB_INSTITUTION hs on hs.HUB_INSTITUTION_KEY = lcs.HUB_INSTITUTION_KEY
      left join prod.DATAVAULT.LINK_COURSESECTION_ISBN lci on hc.HUB_COURSESECTION_KEY = lci.HUB_COURSESECTION_KEY
      left join prod.DATAVAULT.HUB_ISBN hi on lci.HUB_ISBN_KEY = hi.HUB_ISBN_KEY
      left join prod.STG_CLTS.products p on hi.ISBN13 = p.ISBN13
      inner join prod.DATAVAULT.LINK_USER_COURSESECTION luc on hc.HUB_COURSESECTION_KEY = luc.HUB_COURSESECTION_KEY
      inner join prod.DATAVAULT.hub_user hu on luc.HUB_USER_KEY = hu.HUB_USER_KEY
      inner join prod.DATAVAULT.SAT_USER_V2 su on hu.HUB_USER_KEY = su.HUB_USER_KEY and su._LATEST
      left join prod.DATAVAULT.SAT_USER_INTERNAL sui on hu.HUB_USER_KEY = sui.HUB_USER_KEY and sui.INTERNAL
      inner join prod.unlimited.raw_olr_enrollment r on r.COURSE_KEY = hc.CONTEXT_ID and r.USER_SSO_GUID = hu.UID
      inner join prod.stg_clts.activations_olr_v a on a.context_id = hc.context_id and a.user_guid = hu.uid
      where sui.INTERNAL is null
      )

      , adoptions_other as (
      SELECT
        coalesce(su.LINKED_GUID,hu.uid) as user_guid
        , case when lower(actv_user_type) = 'student' then false else true end as instructor
        , date_trunc(year,dateadd(month,9,CONVERT_TIMEZONE('UTC',a.actv_dt))) as course_year
        , concat(ACTV_ENTITY_ID, p.PROD_FAMILY_CD) as adoption_key
      FROM prod.STG_CLTS.ACTIVATIONS_OLR a
      LEFT JOIN PROD.STG_CLTS.PRODUCTS p ON a.actv_isbn = p.isbn13
      INNER JOIN prod.datavault.hub_user hu ON a.USER_GUID = hu.UID
      INNER JOIN prod.datavault.sat_user_v2 su ON hu.hub_user_key = su.hub_user_key AND su._latest
      left join prod.DATAVAULT.SAT_USER_INTERNAL sui on hu.HUB_USER_KEY = sui.HUB_USER_KEY and sui.INTERNAL
      WHERE CONTEXT_ID IS NULL
        AND ACTV_DT > '2017-07-01'
        AND a.PLATFORM NOT IN ('MindTap Reader','Cengage Unlimited')
        AND ACTV_TRIAL_PURCHASE NOT IN ('Trial','Duplicate')
        AND PRINT_DIGITAL_CONFIG_CD IN ('020','021','025','023')
        AND coalesce(code_source,'') <> 'Locker'
        AND sui.INTERNAL is null
      )

      , adoptions as (
      select * from adoptions_dv
      union
      select * from adoptions_raw
      union
      select * from adoptions_other
      )

     ,adoptions_list as (
      select distinct course_year, adoption_key
      from adoptions
    )

    , adoptions_counts as (

    select
         iff(a2.adoption_key is null,'New faculty adoption', 'Existing faculty adoption') as user_count_descr
         , a.course_year as fiscal_year
         , a.INSTRUCTOR
         , count(distinct a.user_GUID) as user_count
    from adoptions a
    left join adoptions_list a2 on dateadd(year,-1,a.course_year) = a2.course_year and a.adoption_key = a2.adoption_key
    left join el_users el on a.user_guid = el.user_guid and a.course_year = el.el_year
    where el.user_guid is null
    group by user_count_descr, a.course_year, a.INSTRUCTOR
    order by a.course_year desc, a.INSTRUCTOR
    )



    , fiscal_year_counts as (
    select * from adoptions_counts
    union
    select * from el_counts
    )

    select ty.user_count_descr, ty.fiscal_year, ty.instructor, ty.user_count, py.user_count as prev_year_user_count, (ty.user_count - py.user_count) as net_change_user_count
    from fiscal_year_counts ty
    left join fiscal_year_counts py on ty.user_count_descr = py.user_count_descr
      and ty.instructor = py.instructor
      and dateadd(y,-1,ty.fiscal_year) = py.fiscal_year


    ;;
  }

  dimension: user_count_descr {}
  dimension: fiscal_year {type:date}
  dimension: instructor {}

  measure: user_count {
    type: sum
  }

  measure: prev_year_user_count {
    type: sum
  }

  measure: net_change_user_count {
    type: sum
  }

  }
