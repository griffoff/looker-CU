explore: user_products {hidden:yes}
view: user_products {
  derived_table: {
    create_process: {
      sql_step:
        create table if not exists prod.looker_scratch.user_products
          (
          user_sso_guid                   varchar,
          isbn                            varchar,
          institution_id                  varchar,
          academic_term                   varchar,
          course_key                      varchar,

          enrollment_date                 timestamp_ntz,
          provision_date                  timestamp_ntz,
          activation_date                 timestamp_ntz,
          serial_number_consumed_date     timestamp_ntz,

          paid_flag                       boolean,
          cu_flag                         boolean,
          _effective_from                 timestamp_ntz,
          _effective_to                   timestamp_ntz
          )
      ;;
      sql_step:
      SET max_date = (SELECT coalesce(max(greatest(up.ACTIVATION_DATE,up.ENROLLMENT_DATE,up.PROVISION_DATE,up.SERIAL_NUMBER_CONSUMED_DATE)),to_timestamp(0)) FROM prod.looker_scratch.user_products up)
       -- save current timestamp
      -- use last run date
      ;;

      # remove deleted records where ldts between last run and current timestamp

      # merge from enrollments
      sql_step:
        merge into prod.looker_scratch.user_products uc
          using (
            select
              coalesce(su.linked_guid,hu.uid) as merged_guid
              , coalesce(sc.IAC_ISBN,lci.ISBN13,se.self_study_isbn13,se.payment_isbn13) as isbn13
              , dd.gov_ay_term_full as academic_term
              , coalesce(sc.COURSE_KEY,hc.context_id) as course_key
              , hi.institution_id
              , max(coalesce(try_cast(se.paid_in_full as boolean),false)) as paid_flag
              , min(se.ENROLLMENT_DATE::timestamp_ntz) as enrollment_date
            from prod.DATAVAULT.SAT_ENROLLMENT se
            inner join BPL_MART.prod.dim_date dd on dd.date_value = dateadd(d,14,se.ENROLLMENT_DATE::date)
            inner join prod.DATAVAULT.LINK_USER_COURSESECTION luc on luc.HUB_ENROLLMENT_KEY = se.HUB_ENROLLMENT_KEY
            inner join prod.DATAVAULT.SAT_USER_COURSESECTION_EFFECTIVITY suce on suce.LINK_USER_COURSESECTION_KEY = luc.LINK_USER_COURSESECTION_KEY and suce._EFFECTIVE
            inner join prod.DATAVAULT.hub_user hu on hu.HUB_USER_KEY = luc.HUB_USER_KEY
            inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
            inner join prod.DATAVAULT.HUB_COURSESECTION hc on hc.HUB_COURSESECTION_KEY = luc.HUB_COURSESECTION_KEY
            left join prod.DATAVAULT.SAT_COURSESECTION sc on sc.HUB_COURSESECTION_KEY = luc.HUB_COURSESECTION_KEY and sc._latest
            left join prod.DATAVAULT.HUB_INSTITUTION hi on hi.INSTITUTION_ID = sc.INSTITUTION_ID and hi.INSTITUTION_ID <> 'NOT FOUND'
            left join (
              select lci.HUB_COURSESECTION_KEY, last_value(hi.ISBN13) IGNORE NULLS OVER(PARTITION BY lci.HUB_COURSESECTION_KEY order by lci._LDTS DESC, hi._LDTS DESC, hi.ISBN13 DESC) AS isbn13
              from prod.datavault.link_coursesection_isbn lci
              inner join prod.datavault.hub_isbn hi on hi.hub_isbn_key = lci.hub_isbn_key
            ) lci on lci.hub_coursesection_key = luc.hub_coursesection_key
            left join prod.datavault.hub_enterpriselicense el on el.enterprise_license = hc.context_id
            where se._LATEST
              and se._ldts > $max_date
              and el.enterprise_license is null
              and coalesce(coalesce(sc.IAC_ISBN,lci.ISBN13,se.self_study_isbn13,se.payment_isbn13),coalesce(sc.COURSE_KEY,hc.context_id)) is not null
            group by 1,2,3,4,5
          ) pp
        on uc.user_sso_guid = pp.merged_guid and coalesce(uc.isbn = pp.ISBN13,TRUE) and coalesce(uc.course_key = pp.course_key,TRUE) and coalesce(uc.institution_id = pp.institution_id,TRUE)
          and uc.academic_term = pp.academic_term
        when matched then update
          set
            uc.isbn = coalesce(uc.isbn,pp.isbn13)
            , uc.course_key = coalesce(uc.course_key,pp.course_key)
            , uc.institution_id = coalesce(uc.institution_id,pp.institution_id)
            , uc.enrollment_date = coalesce(least(pp.enrollment_date,uc.enrollment_date),pp.enrollment_date,uc.enrollment_date)
            , uc.paid_flag = uc.paid_flag or pp.paid_flag
            , uc._effective_from = coalesce(least(pp.enrollment_date,uc._effective_from),pp.enrollment_date,uc._effective_from)
        when not matched then insert -- and ldts between last run and current timestamp
          (
          user_sso_guid   ,
          isbn            ,
          course_key      ,
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
          , pp.course_key
          , pp.institution_id
          , pp.academic_term
          , pp.enrollment_date
          , pp.paid_flag
          , false
          , pp.enrollment_date
          )
      ;;
      # merge from provisioned product
      sql_step:
        merge into prod.looker_scratch.user_products uc
          using (
            select
              coalesce(su.linked_guid,hu.uid) as merged_guid
              , coalesce(sc.IAC_ISBN,lci.isbn13,hi.ISBN13) as isbn13
              , coalesce(sc.COURSE_KEY,hc.CONTEXT_ID) as course_key
              , coalesce(hin2.INSTITUTION_ID,hin1.INSTITUTION_ID) as institution_id
              , dd.gov_ay_term_full as academic_term
              , min(spp.DATE_ADDED::timestamp_ntz) as provision_date
              , max(
                coalesce(
                  coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) ilike 'Full-Access%' or coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) = 'CU-ETextBook-120'
                  , false)
              ) as cu_flag
            from prod.DATAVAULT.SAT_PROVISIONED_PRODUCT_V2 spp
            left join prod.DATAVAULT.HUB_INSTITUTION hin1 on hin1.INSTITUTION_ID = spp.INSTITUTION_ID and hin1.INSTITUTION_ID <> 'NOT FOUND'
            inner join BPL_MART.prod.dim_date dd on dd.date_value = dateadd(d,14,spp.DATE_ADDED::date)
            inner join prod.DATAVAULT.LINK_USER_PROVISIONEDPRODUCT lup on lup.HUB_PROVISIONED_PRODUCT_KEY = spp.HUB_PROVISIONED_PRODUCT_KEY
            inner join prod.DATAVAULT.HUB_USER hu on hu.HUB_USER_KEY = lup.HUB_USER_KEY
            inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
            left join prod.DATAVAULT.HUB_COURSESECTION hc on hc.CONTEXT_ID = spp.CONTEXT_ID
            left join prod.DATAVAULT.SAT_COURSESECTION sc on sc.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY and sc._LATEST
            left join prod.DATAVAULT.HUB_INSTITUTION hin2 on hin2.INSTITUTION_ID = sc.INSTITUTION_ID and hin2.INSTITUTION_ID <> 'NOT FOUND'
            left join (
              select lci.HUB_COURSESECTION_KEY, last_value(hi.ISBN13) IGNORE NULLS OVER(PARTITION BY lci.HUB_COURSESECTION_KEY order by lci._LDTS DESC, hi._LDTS DESC, hi.ISBN13 DESC) AS isbn13
              from prod.datavault.link_coursesection_isbn lci
              inner join prod.datavault.hub_isbn hi on hi.hub_isbn_key = lci.hub_isbn_key
            ) lci on lci.hub_coursesection_key = hc.hub_coursesection_key
            inner join prod.datavault.link_product_provisionedproduct lpp on spp.hub_provisioned_product_key = lpp.hub_provisioned_product_key
            left join (
              select *
              from prod.DATAVAULT.LINK_PRODUCT_ISBN lpi
              inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie on spie.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie._EFFECTIVE
            ) lpi on lpi.HUB_PRODUCT_KEY = lpp.HUB_PRODUCT_KEY
            left join prod.DATAVAULT.HUB_ISBN hi on hi.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
            left join (
              select *
              from prod.DATAVAULT.LINK_PROVISIONEDPRODUCT_SUBSCRIPTION lps
              inner join prod.DATAVAULT.SAT_PROVISIONEDPRODUCT_SUBSCRIPTION_EFFECTIVITY spse on spse.LINK_PROVISIONEDPRODUCT_SUBSCRIPTION_KEY = lps.LINK_PROVISIONEDPRODUCT_SUBSCRIPTION_KEY
              and spse._EFFECTIVE
            ) lps on lps.HUB_PROVISIONED_PRODUCT_KEY = spp.HUB_PROVISIONED_PRODUCT_KEY
            left join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP sss on sss.HUB_SUBSCRIPTION_KEY = lps.HUB_SUBSCRIPTION_KEY and sss._latest
            left join prod.DATAVAULT.SAT_SUBSCRIPTION_BP ssb on ssb.HUB_SUBSCRIPTION_KEY = lps.HUB_SUBSCRIPTION_KEY and ssb._LATEST
            left join prod.datavault.hub_enterpriselicense el on el.enterprise_license = spp.context_id
            where spp._LATEST
              and spp._ldts > $max_date
              and el.enterprise_license is null
              and coalesce(coalesce(sc.IAC_ISBN,lci.isbn13,hi.ISBN13),coalesce(sc.COURSE_KEY,hc.CONTEXT_ID)) is not null
            group by 1,2,3,4,5
          ) pp
        on uc.user_sso_guid = pp.merged_guid and coalesce(uc.isbn = pp.ISBN13,TRUE) and coalesce(uc.institution_id = pp.INSTITUTION_ID,TRUE) and coalesce(uc.course_key = pp.course_key,TRUE)
          and uc.academic_term = pp.academic_term
        when matched then update
          set
            uc.isbn = coalesce(uc.isbn,pp.isbn13)
            , uc.institution_id = coalesce(uc.institution_id,pp.institution_id)
            , uc.course_key = coalesce(uc.course_key,pp.course_key)
            , uc.provision_date = coalesce(least(pp.provision_date, uc.provision_date), pp.provision_date, uc.provision_date)
            , uc.cu_flag = uc.cu_flag or pp.cu_flag
            , uc.paid_flag = uc.paid_flag or pp.cu_flag
            , uc._effective_from = coalesce(least(pp.provision_date, uc._effective_from), pp.provision_date, uc._effective_from )
        when not matched then insert
        (
          user_sso_guid   ,
          isbn            ,
          institution_id  ,
          academic_term   ,
          course_key      ,
          provision_date  ,
          paid_flag       ,
          cu_flag         ,
          _effective_from
        )
        values
        (
          pp.merged_guid
          , pp.ISBN13
          , pp.INSTITUTION_ID
          , pp.academic_term
          , pp.course_key
          , pp.provision_date
          , pp.cu_flag
          , pp.cu_flag
          , pp.provision_date
        )
      ;;
      # merge from activations
      sql_step:
        merge into prod.looker_scratch.user_products uc
          using (
            select
              coalesce(su.LINKED_GUID,hu.uid) as merged_guid
              , coalesce(sc.IAC_ISBN,lci.isbn13,hi.ISBN13) as isbn13
              , coalesce(hin2.INSTITUTION_ID,lia.INSTITUTION_ID) as institution_id
              , coalesce(sc.course_key,lca.context_id) as course_key
              , dd.gov_ay_term_full as academic_term
              , max(
                coalesce(
                  coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) ilike 'Full-Access%' or coalesce(sss.SUBSCRIPTION_PLAN_ID,ssb.SUBSCRIPTION_STATE) = 'CU-ETextBook-120'
                  , false)
              ) as cu_flag
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
              select distinct lca.HUB_ACTIVATION_KEY, lca.HUB_COURSESECTION_KEY, hc.CONTEXT_ID
              from prod.DATAVAULT.LINK_COURSESECTION_ACTIVATION lca
              inner join prod.DATAVAULT.LSAT_COURSESECTION_ACTIVATION_EFFECTIVITY lcae on lcae.LINK_COURSESECTION_ACTIVATION_KEY = lca.LINK_COURSESECTION_ACTIVATION_KEY and lcae._EFFECTIVE
              inner join prod.DATAVAULT.HUB_COURSESECTION hc on hc.HUB_COURSESECTION_KEY = lca.HUB_COURSESECTION_KEY
            ) lca on lca.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY
            left join (
              select lci.HUB_COURSESECTION_KEY, last_value(hi.ISBN13) IGNORE NULLS OVER(PARTITION BY lci.HUB_COURSESECTION_KEY order by lci._LDTS DESC, hi._LDTS DESC, hi.ISBN13 DESC) AS isbn13
              from prod.datavault.link_coursesection_isbn lci
              inner join prod.datavault.hub_isbn hi on hi.hub_isbn_key = lci.hub_isbn_key
            ) lci on lci.hub_coursesection_key = lca.hub_coursesection_key
            left join prod.DATAVAULT.SAT_COURSESECTION sc on sc.HUB_COURSESECTION_KEY = lca.HUB_COURSESECTION_KEY
            left join prod.DATAVAULT.HUB_INSTITUTION hin2 on hin2.INSTITUTION_ID = sc.INSTITUTION_ID and hin2.INSTITUTION_ID <> 'NOT FOUND'
            left join (
              select *
              from prod.DATAVAULT.LINK_INSTITUTION_ACTIVATION lia
              inner join prod.DATAVAULT.LSAT_INSTITUTION_ACTIVATION_EFFECTIVITY liae on liae.LINK_INSTITUTION_ACTIVATION_KEY = lia.LINK_INSTITUTION_ACTIVATION_KEY and liae._EFFECTIVE
              inner join prod.DATAVAULT.HUB_INSTITUTION hin on hin.HUB_INSTITUTION_KEY = lia.HUB_INSTITUTION_KEY
            ) lia on lia.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY and lia.INSTITUTION_ID <> 'NOT FOUND'
            left join (
              select *
              from prod.DATAVAULT.LINK_SUBSCRIPTION_ACTIVATION lsa
              inner join prod.DATAVAULT.LSAT_SUBSCRIPTION_ACTIVATION_EFFECTIVITY lsae on lsae.LINK_SUBSCRIPTION_ACTIVATION_KEY = lsa.LINK_SUBSCRIPTION_ACTIVATION_KEY and lsae._EFFECTIVE
            ) lsa on lsa.HUB_ACTIVATION_KEY = sa.HUB_ACTIVATION_KEY
            left join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP sss on sss.HUB_SUBSCRIPTION_KEY = lsa.HUB_SUBSCRIPTION_KEY and sss._latest
            left join prod.DATAVAULT.SAT_SUBSCRIPTION_BP ssb on ssb.HUB_SUBSCRIPTION_KEY = lsa.HUB_SUBSCRIPTION_KEY and ssb._LATEST
            left join prod.datavault.hub_enterpriselicense el on el.enterprise_license = lca.context_id
            where sa._LATEST
              and sa._ldts > $max_date
              and el.HUB_ENTERPRISELICENSE_KEY is null
              and coalesce(coalesce(sc.IAC_ISBN,lci.isbn13,hi.ISBN13),coalesce(sc.course_key,lca.context_id)) is not null
            group by 1,2,3,4,5
          ) pp
          on uc.user_sso_guid = pp.merged_guid and coalesce(uc.isbn = pp.ISBN13,TRUE) and coalesce(uc.course_key = pp.course_key,TRUE) and coalesce(uc.institution_id = pp.INSTITUTION_ID,TRUE)
            and uc.academic_term = pp.academic_term
          when matched then update
            set
              uc.isbn = coalesce(uc.isbn,pp.isbn13)
              , uc.course_key = coalesce(uc.course_key,pp.course_key)
              , uc.institution_id = coalesce(uc.institution_id,pp.institution_id)
              , uc.activation_date = coalesce(least(pp.activation_date, uc.activation_date), pp.activation_date, uc.activation_date)
              , uc.cu_flag = uc.cu_flag or pp.cu_flag
              , uc.paid_flag = true
              , uc._effective_from = coalesce(least(pp.activation_date, uc._effective_from), pp.activation_date, uc._effective_from )
          when not matched then insert
          (
            user_sso_guid   ,
            isbn            ,
            institution_id  ,
            academic_term   ,
            course_key      ,
            activation_date ,
            paid_flag       ,
            cu_flag         ,
            _effective_from
          )
          values
          (
            pp.merged_guid
            , pp.ISBN13
            , pp.INSTITUTION_ID
            , pp.academic_term
            , pp.course_key
            , pp.activation_date
            , true
            , pp.cu_flag
            , pp.activation_date
          )
      ;;
      # merge from serial numbers
      sql_step:
        merge into prod.looker_scratch.user_products uc
          using (
            select
              coalesce(su.LINKED_GUID,hu.uid) as merged_guid
              , hi.ISBN13 as isbn13
              , hin1.INSTITUTION_ID
              , dd.gov_ay_term_full as academic_term
              , min(ssn.REGISTRATION_DATE::timestamp_ntz) as serial_number_consumed_date
            from prod.DATAVAULT.SAT_SERIAL_NUMBER_CONSUMED ssn
            inner join BPL_MART.prod.dim_date dd on dd.date_value = dateadd(d,14,ssn.registration_date::date)
            inner join prod.DATAVAULT.LINK_SERIALNUMBER_USER lsu on lsu.HUB_SERIALNUMBER_KEY = ssn.HUB_SERIALNUMBER_KEY
            inner join prod.DATAVAULT.HUB_USER hu on hu.HUB_USER_KEY = lsu.HUB_USER_KEY
            inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
            left join prod.DATAVAULT.HUB_INSTITUTION hin1 on hin1.INSTITUTION_ID = ssn.INSTITUTION_ID and hin1.INSTITUTION_ID <> 'NOT FOUND'
            left join prod.DATAVAULT.HUB_PRODUCT hp1 on hp1.PID = ssn.PRODUCT_ID
            left join (
              select *
              from prod.DATAVAULT.LINK_SERIALNUMBER_PRODUCT lsp
              inner join prod.DATAVAULT.SAT_SERIALNUMBER_PRODUCT_EFFECTIVITY sspe on sspe.LINK_SERIALNUMBER_PRODUCT_KEY = lsp.LINK_SERIALNUMBER_PRODUCT_KEY and sspe._EFFECTIVE
            ) lsp on lsp.HUB_SERIALNUMBER_KEY = ssn.HUB_SERIALNUMBER_KEY
            inner join (
              select *
              from prod.DATAVAULT.LINK_PRODUCT_ISBN lpi
              inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie on spie.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie._EFFECTIVE
            ) lpi on lpi.HUB_PRODUCT_KEY = coalesce(hp1.HUB_PRODUCT_KEY, lsp.HUB_PRODUCT_KEY)
            inner join prod.DATAVAULT.HUB_ISBN hi on hi.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
            where ssn._LATEST
              and ssn._ldts > $max_date
              and hi.isbn13 is not null
            group by 1,2,3,4
          ) pp
        on uc.user_sso_guid = pp.merged_guid and uc.isbn = pp.ISBN13 and coalesce(uc.institution_id = pp.INSTITUTION_ID,TRUE) and uc.academic_term = pp.academic_term
        when matched then update
          set
            uc.institution_id = coalesce(uc.institution_id,pp.institution_id)
            , uc.serial_number_consumed_date = coalesce(least(pp.serial_number_consumed_date, uc.serial_number_consumed_date), pp.serial_number_consumed_date, uc.serial_number_consumed_date)
            , uc.paid_flag = true
            , uc._effective_from = coalesce(least(pp.serial_number_consumed_date, uc._effective_from), pp.serial_number_consumed_date, uc._effective_from )
        when not matched then insert
        (
          user_sso_guid   ,
          isbn            ,
          institution_id  ,
          academic_term   ,
          serial_number_consumed_date ,
          paid_flag       ,
          cu_flag ,
          _effective_from
        )
        values
        (
          pp.merged_guid
          , pp.ISBN13
          , pp.INSTITUTION_ID
          , pp.academic_term
          , pp.serial_number_consumed_date
          , true
          , false
          , pp.serial_number_consumed_date
        )
      ;;
      # fill in institution_id from course/user
      # sql_step:
      #   merge into prod.looker_scratch.user_products uc
      #     using (
      #       select distinct
      #         coalesce(sc.COURSE_KEY,hc.CONTEXT_ID) as course_key
      #         , last_value(coalesce(hi.INSTITUTION_ID,hi2.INSTITUTION_ID)) IGNORE NULLS OVER(PARTITION BY coalesce(sc.COURSE_KEY,hc.CONTEXT_ID) ORDER BY sc._ldts,lci._LDTS,hi2._LDTS,hi2.INSTITUTION_ID) as institution_id
      #       from prod.datavault.hub_coursesection hc
      #       left join prod.DATAVAULT.SAT_COURSESECTION sc on sc.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY and sc._LATEST
      #       left join prod.DATAVAULT.HUB_INSTITUTION hi on hi.INSTITUTION_ID = sc.INSTITUTION_ID and hi.INSTITUTION_ID <> 'NOT FOUND'
      #       left join prod.DATAVAULT.LINK_COURSESECTION_INSTITUTION lci on lci.HUB_COURSESECTION_KEY = hc.HUB_COURSESECTION_KEY
      #       left join prod.DATAVAULT.HUB_INSTITUTION hi2 on hi2.HUB_INSTITUTION_KEY = lci.HUB_INSTITUTION_KEY and hi.INSTITUTION_ID <> 'NOT FOUND'
      #     ) pp
      #   on uc.course_key = pp.course_key
      #   when matched then update
      #     set
      #       uc.institution_id = coalesce(uc.institution_id,pp.institution_id)
      # ;;
      # sql_step:
      #   merge into prod.looker_scratch.user_products uc
      #     using (
      #       select distinct
      #         coalesce(su.LINKED_GUID,hu.uid) as merged_guid
      #         , hi.INSTITUTION_ID
      #       from prod.DATAVAULT.hub_user hu
      #       inner join prod.DATAVAULT.sat_user_v2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY
      #       inner join prod.DATAVAULT.LINK_USER_INSTITUTION lui on lui.HUB_USER_KEY = hu.HUB_USER_KEY
      #       inner join prod.DATAVAULT.SAT_USER_INSTITUTION sui on sui.LINK_USER_INSTITUTION_KEY = lui.LINK_USER_INSTITUTION_KEY and sui.ACTIVE
      #       inner join prod.DATAVAULT.HUB_INSTITUTION hi on hi.HUB_INSTITUTION_KEY = lui.HUB_INSTITUTION_KEY
      #     ) pp
      #   on uc.user_sso_guid = pp.merged_guid
      #   when matched then update
      #     set
      #       uc.institution_id = coalesce(uc.institution_id,pp.institution_id)
      # ;;
      # set effective_to dates
      sql_step:
      merge into prod.looker_scratch.user_products uc
        using (
          select
          up.USER_SSO_GUID
          , up.INSTITUTION_ID
          , up.ISBN
          , up.ACADEMIC_TERM
          , up._EFFECTIVE_FROM
          , lead(up._effective_from) over(partition by up.USER_SSO_GUID,up.INSTITUTION_ID,up.ISBN order by up._EFFECTIVE_FROM) as _effective_to
          , lag(up._effective_from) over(partition by up.USER_SSO_GUID,up.INSTITUTION_ID,up.ISBN order by up._EFFECTIVE_FROM) as _effective_from_prev
          from prod.looker_scratch.user_products up
        ) pp
      on uc.user_sso_guid = pp.USER_SSO_GUID and uc.isbn = pp.ISBN and uc.institution_id = pp.INSTITUTION_ID and uc.academic_term = pp.academic_term
      when matched then update
        set
          uc._effective_to = pp._effective_to
          , uc._effective_from = case when pp._effective_from_prev is null then null else uc._effective_from end
    ;;
    sql_step:
      create or replace table ${SQL_TABLE_NAME}
      clone prod.looker_scratch.user_products
    ;;
  }
  persist_for: "8 hours"
}

dimension: merged_guid {
  sql: ${TABLE}.user_sso_guid ;;
  hidden:yes
}

dimension: isbn13 {
  sql: ${TABLE}.isbn ;;
}

dimension: institution_id {hidden:yes}

dimension: academic_term {hidden:yes}

dimension: enrollment_date {
  type:date_time
  hidden:yes
}

dimension: provision_date {
  type:date_time
  hidden:yes
}

dimension: activation_date {
  type:date_time
  hidden:yes
}

dimension: serial_number_consumed_date {
  type:date_time
  hidden:yes
}

dimension: paid_flag {
  type: yesno
}

dimension: cu_flag {
  type: yesno
}

dimension_group: _effective_from {
  hidden: yes
  type:time
  timeframes: [date,raw,time]
}
dimension_group: _effective_to {
  hidden: yes
  type:time
  timeframes: [date,raw,time]
}

dimension: pk {
  sql: hash(${TABLE}.user_sso_guid,${TABLE}.isbn,${TABLE}.institution_id,${TABLE}.academic_term) ;;
  primary_key:yes
  hidden:yes
}

dimension_group: added {
  type: time
  timeframes: [raw,time,date,week,month,year]
  sql: ${TABLE}._effective_from ;;
}
}
