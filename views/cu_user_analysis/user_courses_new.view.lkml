explore: user_courses_new {hidden:yes}
view: user_courses_new {
  derived_table: {
    create_process: {
      sql_step:
        create table if not exists zandbox.delderfield.user_courses_new
        (
          user_sso_guid   varchar,
          isbn            varchar,
          context_id      varchar,
          institution_id  varchar,
          academic_term   varchar,

          enrollment_date timestamp_ntz,
          provision_date  timestamp_ntz,
          activation_date timestamp_ntz,

          paid_flag       boolean,
          cu_flag         boolean,
          _effective_from timestamp_ntz,
          _effective_to   timestamp_ntz
        )
      ;;
      # merge from enrollments
      sql_step:
        merge into zandbox.delderfield.user_courses_new uc
          using (
            select
              coalesce(su.linked_guid,hu.uid) as merged_guid
              , coalesce(hi.ISBN13,'UNKNOWN') as isbn13
              , hc.CONTEXT_ID
              , coalesce(hin1.INSTITUTION_ID,hin2.INSTITUTION_ID,'UNKNOWN') as institution_id
              , dd.gov_ay_term_full as academic_term
              , max(coalesce(try_cast(se.paid_in_full as boolean),false)) as paid_flag
              , min(se.ENROLLMENT_DATE::timestamp_ntz) as enrollment_date
            from prod.DATAVAULT.SAT_ENROLLMENT se
            inner join BPL_MART.prod.dim_date dd on dd.date_value = dateadd(d,14,se.ENROLLMENT_DATE::date)
            inner join prod.DATAVAULT.LINK_USER_COURSESECTION luc on luc.HUB_ENROLLMENT_KEY = se.HUB_ENROLLMENT_KEY
            inner join prod.DATAVAULT.SAT_USER_COURSESECTION_EFFECTIVITY suce on suce.LINK_USER_COURSESECTION_KEY = luc.LINK_USER_COURSESECTION_KEY and suce._EFFECTIVE
            inner join prod.DATAVAULT.hub_user hu on hu.HUB_USER_KEY = luc.HUB_USER_KEY
            inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
            left join (
              select *
              from prod.DATAVAULT.LINK_USER_INSTITUTION lui
              inner join prod.DATAVAULT.SAT_USER_INSTITUTION sui on sui.LINK_USER_INSTITUTION_KEY = lui.LINK_USER_INSTITUTION_KEY and sui.ACTIVE
            ) lui on lui.HUB_USER_KEY = hu.HUB_USER_KEY
            left join prod.DATAVAULT.HUB_INSTITUTION hin2 on hin2.HUB_INSTITUTION_KEY = lui.HUB_INSTITUTION_KEY
            inner join prod.DATAVAULT.HUB_COURSESECTION hc on hc.HUB_COURSESECTION_KEY = luc.HUB_COURSESECTION_KEY
            left join prod.DATAVAULT.SAT_COURSESECTION sc on sc.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY and sc._LATEST
            left join prod.DATAVAULT.HUB_INSTITUTION hin1 on hin1.INSTITUTION_ID = sc.INSTITUTION_ID
            left join prod.datavault.link_coursesection_isbn lci on lci.hub_coursesection_key = hc.hub_coursesection_key
            left join prod.DATAVAULT.LINK_COURSESECTION_SECTIONCOMPONENT lcs on lcs.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY
            left join prod.DATAVAULT.LINK_SECTIONCOMPONENT_PRODUCT lsp on lsp.HUB_SECTIONCOMPONENT_KEY = lcs.HUB_SECTIONCOMPONENT_KEY
            left join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = lsp.HUB_PRODUCT_KEY
            left join prod.datavault.hub_isbn hi on hi.hub_isbn_key = coalesce(lci.hub_isbn_key,lpi.HUB_ISBN_KEY)
            left join prod.datavault.hub_enterpriselicense el on el.enterprise_license = hc.context_id
            where se._LATEST
              and el.enterprise_license is null
            group by 1,2,3,4,5
          ) pp
        on uc.user_sso_guid = pp.merged_guid and uc.isbn = pp.ISBN13 and uc.context_id = pp.CONTEXT_ID and uc.institution_id = pp.INSTITUTION_ID and uc.academic_term = pp.academic_term
        when matched then update
          set
            uc.enrollment_date = coalesce(least(pp.enrollment_date, uc.enrollment_date),pp.enrollment_date, uc.enrollment_date)
            , uc.paid_flag = uc.paid_flag or pp.paid_flag
            , uc._effective_from = coalesce(least(pp.enrollment_date, uc._effective_from),pp.enrollment_date, uc._effective_from)
        when not matched then insert
          (
          user_sso_guid   ,
          isbn            ,
          context_id      ,
          institution_id  ,
          academic_term   ,
          enrollment_date ,
          paid_flag       ,
          cu_flag         ,
          _effective_from
          )
        values
          (
          pp.merged_guid
          , pp.ISBN13
          , pp.CONTEXT_ID
          , pp.INSTITUTION_ID
          , pp.academic_term
          , pp.enrollment_date
          , pp.paid_flag
          , false
          , pp.enrollment_date
          )
      ;;
      # merge from provisioned product
      sql_step:
        merge into zandbox.delderfield.user_courses_new uc
            using (
              select
                coalesce(su.linked_guid,hu.uid) as merged_guid
                , hi.ISBN13
                , spp.CONTEXT_ID
                , coalesce(hin1.INSTITUTION_ID, hin2.INSTITUTION_ID, hin3.institution_id,'UNKNOWN') as institution_id
                , dd.gov_ay_term_full as academic_term
                , min(spp.DATE_ADDED::timestamp_ntz) as provision_date
                , max(coalesce(
                  coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) ilike 'Full-Access%' or coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) = 'CU-ETextBook-120'
                  , false)
                ) as cu_flag
              from prod.DATAVAULT.SAT_PROVISIONED_PRODUCT_V2 spp
              left join prod.DATAVAULT.HUB_INSTITUTION hin1 on hin1.INSTITUTION_ID = spp.INSTITUTION_ID
              inner join BPL_MART.prod.dim_date dd on dd.date_value = dateadd(d,14,spp.DATE_ADDED::date)
              inner join prod.DATAVAULT.LINK_USER_PROVISIONEDPRODUCT lup on lup.HUB_PROVISIONED_PRODUCT_KEY = spp.HUB_PROVISIONED_PRODUCT_KEY
              inner join prod.DATAVAULT.HUB_USER hu on hu.HUB_USER_KEY = lup.HUB_USER_KEY
              inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
              left join (
                select *
                from prod.DATAVAULT.LINK_USER_INSTITUTION lui
                   inner join prod.DATAVAULT.SAT_USER_INSTITUTION sui on sui.LINK_USER_INSTITUTION_KEY = lui.LINK_USER_INSTITUTION_KEY and sui.ACTIVE
              ) lui on lui.HUB_USER_KEY = hu.HUB_USER_KEY
              left join prod.DATAVAULT.HUB_INSTITUTION hin3 on hin3.HUB_INSTITUTION_KEY = lui.HUB_INSTITUTION_KEY
              inner join prod.DATAVAULT.HUB_COURSESECTION hc on hc.CONTEXT_ID = spp.CONTEXT_ID
              left join prod.DATAVAULT.SAT_COURSESECTION sc on sc.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY and sc._LATEST
              left join prod.DATAVAULT.HUB_INSTITUTION hin2 on hin2.INSTITUTION_ID = sc.INSTITUTION_ID
              inner join prod.datavault.link_product_provisionedproduct lpp on spp.hub_provisioned_product_key = lpp.hub_provisioned_product_key
              inner join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = lpp.HUB_PRODUCT_KEY
              inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie on spie.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie._EFFECTIVE
              left join (
                select *
                from prod.DATAVAULT.LINK_PROVISIONEDPRODUCT_SUBSCRIPTION lps
                inner join prod.DATAVAULT.SAT_PROVISIONEDPRODUCT_SUBSCRIPTION_EFFECTIVITY spse on spse.LINK_PROVISIONEDPRODUCT_SUBSCRIPTION_KEY = lps.LINK_PROVISIONEDPRODUCT_SUBSCRIPTION_KEY
                and spse._EFFECTIVE
              ) lps on lps.HUB_PROVISIONED_PRODUCT_KEY = spp.HUB_PROVISIONED_PRODUCT_KEY
              inner join prod.DATAVAULT.HUB_ISBN hi on hi.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
              left join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP sss on sss.HUB_SUBSCRIPTION_KEY = lps.HUB_SUBSCRIPTION_KEY and sss._latest
              left join prod.DATAVAULT.SAT_SUBSCRIPTION_BP ssb on ssb.HUB_SUBSCRIPTION_KEY = lps.HUB_SUBSCRIPTION_KEY and ssb._LATEST
              left join prod.datavault.hub_enterpriselicense el on el.enterprise_license = spp.context_id
              where spp._LATEST
                and el.enterprise_license is null
                and spp.CONTEXT_ID is not null
              group by 1,2,3,4,5
            ) pp
            on uc.user_sso_guid = pp.merged_guid and uc.isbn = pp.ISBN13 and uc.context_id = pp.CONTEXT_ID and uc.institution_id = pp.INSTITUTION_ID and uc.academic_term = pp.academic_term
            when matched then update
              set
                uc.provision_date = coalesce(least(pp.provision_date, uc.provision_date), pp.provision_date, uc.provision_date)
                , uc.cu_flag = uc.cu_flag or pp.cu_flag
                , uc.paid_flag = uc.paid_flag or pp.cu_flag
                , uc._effective_from = coalesce(least(pp.provision_date, uc._effective_from), pp.provision_date, uc._effective_from )
            when not matched then insert
              (
              user_sso_guid   ,
              isbn            ,
              context_id      ,
              institution_id  ,
              academic_term   ,
              provision_date  ,
              paid_flag       ,
              cu_flag         ,
              _effective_from
              )
            values
              (
              pp.merged_guid
              , pp.ISBN13
              , pp.CONTEXT_ID
              , pp.INSTITUTION_ID
              , pp.academic_term
              , pp.provision_date
              , pp.cu_flag
              , pp.cu_flag
              , pp.provision_date
              )
      ;;
      # merge from activations
      sql_step:
        merge into zandbox.delderfield.user_courses_new uc
          using (
            select
              coalesce(su.LINKED_GUID,hu.uid) as merged_guid
              , hi.ISBN13
              , lca.CONTEXT_ID
              , lia.INSTITUTION_ID
              , dd.gov_ay_term_full as academic_term
              , max(coalesce(
                coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) ilike 'Full-Access%' or coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) = 'CU-ETextBook-120'
                , false
              )) as cu_flag
              , min(sa.ACTIVATION_DATE::timestamp_ntz) as activation_date
            from prod.DATAVAULT.SAT_ACTIVATION sa
            inner join BPL_MART.prod.dim_date dd on dd.date_value = dateadd(d,14,sa.ACTIVATION_DATE::date)
            inner join prod.DATAVAULT.LINK_USER_ACTIVATION lua on lua.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY
            inner join prod.DATAVAULT.LSAT_USER_ACTIVATION_EFFECTIVITY luae on luae.LINK_USER_ACTIVATION_KEY = lua.LINK_USER_ACTIVATION_KEY and luae._EFFECTIVE
            inner join prod.DATAVAULT.hub_user hu on hu.HUB_USER_KEY = lua.HUB_USER_KEY
            inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
            inner join prod.DATAVAULT.LINK_PRODUCT_ACTIVATION lpa on lpa.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY
            inner join prod.DATAVAULT.LSAT_PRODUCT_ACTIVATION_EFFECTIVITY lpae on lpae.LINK_PRODUCT_ACTIVATION_KEY = lpa.LINK_PRODUCT_ACTIVATION_KEY and lpae._EFFECTIVE
            inner join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = lpa.HUB_PRODUCT_KEY
            inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie on spie.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie._EFFECTIVE
            inner join prod.DATAVAULT.hub_isbn hi on hi.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
            left join (
              select *
              from prod.DATAVAULT.LINK_COURSESECTION_ACTIVATION lca
              inner join prod.DATAVAULT.LSAT_COURSESECTION_ACTIVATION_EFFECTIVITY lcae on lcae.LINK_COURSESECTION_ACTIVATION_KEY = lca.LINK_COURSESECTION_ACTIVATION_KEY and lcae._EFFECTIVE
              inner join prod.DATAVAULT.HUB_COURSESECTION hc on hc.HUB_COURSESECTION_KEY = lca.HUB_COURSESECTION_KEY
            ) lca on lca.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY
            left join (
              select *
              from prod.DATAVAULT.LINK_INSTITUTION_ACTIVATION lia
              inner join prod.DATAVAULT.LSAT_INSTITUTION_ACTIVATION_EFFECTIVITY liae on liae.LINK_INSTITUTION_ACTIVATION_KEY = lia.LINK_INSTITUTION_ACTIVATION_KEY and liae._EFFECTIVE
              inner join prod.DATAVAULT.HUB_INSTITUTION hin on hin.HUB_INSTITUTION_KEY = lia.HUB_INSTITUTION_KEY
            ) lia on lia.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY
            left join (
              select * --distinct lsa.*, sss.SUBSCRIPTION_PLAN_ID, ssb.SUBSCRIPTION_STATE
              from prod.DATAVAULT.LINK_SUBSCRIPTION_ACTIVATION lsa
              inner join prod.DATAVAULT.LSAT_SUBSCRIPTION_ACTIVATION_EFFECTIVITY lsae on lsae.LINK_SUBSCRIPTION_ACTIVATION_KEY = lsa.LINK_SUBSCRIPTION_ACTIVATION_KEY and lsae._EFFECTIVE
            ) lsa on lsa.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY
            left join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP sss on sss.HUB_SUBSCRIPTION_KEY = lsa.HUB_SUBSCRIPTION_KEY and sss._latest
            left join prod.DATAVAULT.SAT_SUBSCRIPTION_BP ssb on ssb.HUB_SUBSCRIPTION_KEY = lsa.HUB_SUBSCRIPTION_KEY and ssb._LATEST
            left join prod.datavault.hub_enterpriselicense el on el.enterprise_license = lca.context_id
            where sa._LATEST
              and el.HUB_ENTERPRISELICENSE_KEY is null
              and lca.CONTEXT_ID is not null
            group by 1,2,3,4,5
          ) pp
          on uc.user_sso_guid = pp.merged_guid and uc.isbn = pp.ISBN13 and uc.context_id = pp.CONTEXT_ID and uc.institution_id = pp.INSTITUTION_ID and uc.academic_term = pp.academic_term
          when matched then update
            set
              uc.activation_date = coalesce(least(pp.activation_date, uc.activation_date), pp.activation_date, uc.activation_date)
              , uc.cu_flag = uc.cu_flag or pp.cu_flag
              , uc.paid_flag = true
              , uc._effective_from = coalesce(least(pp.activation_date, uc._effective_from), pp.activation_date, uc._effective_from )
          when not matched then insert
          (
            user_sso_guid   ,
            isbn            ,
            context_id      ,
            institution_id  ,
            academic_term   ,
            activation_date ,
            paid_flag       ,
            cu_flag         ,
            _effective_from
          )
          values
          (
            pp.merged_guid
            , pp.ISBN13
            , pp.CONTEXT_ID
            , pp.INSTITUTION_ID
            , pp.academic_term
            , pp.activation_date
            , true
            , pp.cu_flag
            , pp.activation_date
          )
      ;;
      # set effective_to dates
      sql_step:
        merge into zandbox.delderfield.user_courses_new uc
          using (
            select
              up.USER_SSO_GUID
              , up.INSTITUTION_ID
              , up.ISBN
              , up.CONTEXT_ID
              , up.ACADEMIC_TERM
              , up._EFFECTIVE_FROM
              , lead(up._effective_from) over(partition by up.USER_SSO_GUID,up.INSTITUTION_ID,up.ISBN,up.CONTEXT_ID order by up._EFFECTIVE_FROM) as _effective_to
            from zandbox.delderfield.user_courses_new up
          ) pp
        on uc.user_sso_guid = pp.USER_SSO_GUID and uc.isbn = pp.ISBN and uc.institution_id = pp.INSTITUTION_ID and uc.academic_term = pp.academic_term and uc.context_id = pp.CONTEXT_ID
        when matched then update
          set
            uc._effective_to = pp._effective_to ;
      ;;
      sql_step:
        create or replace table ${SQL_TABLE_NAME} CLONE zandbox.delderfield.user_courses_new
      ;;
    }
    persist_for: "8 hours"
  }

dimension: user_sso_guid {}
dimension: isbn {}
dimension: context_id {}
dimension: institution_id {}
dimension: academic_term {}
dimension: enrollment_date {type:date_time}
dimension: provision_date {type:date_time}
dimension: activation_date {type:date_time}
dimension: paid_flag {type:yesno}
dimension: cu_flag {type:yesno}

dimension: pk {
  hidden: yes
  primary_key: yes
  sql: hash(${TABLE}.user_sso_guid,${TABLE}.isbn,${TABLE}.context_id,${TABLE}.institution_id,${TABLE}.academic_term ;;
}

dimension_group: _effective_from {
  type:time
  timeframes: [date,raw,time]
}
dimension_group: _effective_to {
  type:time
  timeframes: [date,raw,time]
}

}
