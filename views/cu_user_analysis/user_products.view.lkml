explore: user_products {hidden:yes}
view: user_products {
  derived_table: {
    sql:
      select distinct
        coalesce(su.linked_guid,hu.uid) as merged_guid
        , spp.hub_provisioned_product_key as pk
        , spp.DATE_ADDED
        , spp.EXPIRATION_DATE
        , spp.CONTEXT_ID
        , spp.PRODUCT_ID
        , spp.USER_TYPE
        , spp.INSTITUTION_ID
        , spp.region
        , hi.ISBN13
      from prod.DATAVAULT.SAT_PROVISIONED_PRODUCT_V2 spp
      inner join prod.DATAVAULT.HUB_USER hu on hu.uid = spp.USER_SSO_GUID
      inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
      inner join prod.DATAVAULT.HUB_PRODUCT hp on hp.PID = spp.PRODUCT_ID
      inner join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = hp.HUB_PRODUCT_KEY
      inner join prod.DATAVAULT.HUB_ISBN hi on hi.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
      inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie on spie.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie._EFFECTIVE
      where spp._LATEST
      union
      select distinct
        coalesce(su.LINKED_GUID,hu.uid) as merged_guid
        , ssn.hub_serialnumber_key as pk
        , ssn.REGISTRATION_DATE
        , dateadd(d,ssn.SUBSCRIPTION_LENGTH_IN_DAYS,ssn.REGISTRATION_DATE) as expiration_date
        , null as context_id
        , ssn.PRODUCT_ID
        , ssn.USER_TYPE
        , ssn.INSTITUTION_ID
        , ssn.region
        , hi.ISBN13
      from prod.DATAVAULT.SAT_SERIAL_NUMBER_CONSUMED ssn
      inner join prod.DATAVAULT.HUB_USER hu on hu.uid = ssn.USER_SSO_GUID
      inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
      left join prod.DATAVAULT.HUB_PRODUCT hp1 on hp1.PID = ssn.PRODUCT_ID
      left join prod.DATAVAULT.LINK_SERIALNUMBER_PRODUCT lsp on lsp.HUB_SERIALNUMBER_KEY = ssn.HUB_SERIALNUMBER_KEY
      inner join prod.DATAVAULT.SAT_SERIALNUMBER_PRODUCT_EFFECTIVITY sspe on sspe.LINK_SERIALNUMBER_PRODUCT_KEY = lsp.LINK_SERIALNUMBER_PRODUCT_KEY and sspe._EFFECTIVE
      inner join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = coalesce(hp1.HUB_PRODUCT_KEY, lsp.HUB_PRODUCT_KEY)
      inner join prod.DATAVAULT.HUB_ISBN hi on hi.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
      inner join prod.DATAVAULT.HUB_PRODUCT hp on hp.HUB_PRODUCT_KEY = lpi.HUB_PRODUCT_KEY
      inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie on spie.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie._EFFECTIVE
      where ssn._LATEST
    ;;
    persist_for: "8 hours"
  }

  dimension: merged_guid {hidden:yes}

  dimension: pk {primary_key:yes hidden:yes}

  dimension_group: added {
    type: time
    timeframes: [raw,time,date,week,month,year]
    sql: ${TABLE}.date_added ;;
  }

  dimension_group: expiration {
    type: time
    timeframes: [raw,time,date,week,month,year]
    sql: ${TABLE}.expiration_date ;;
  }

  dimension: context_id {hidden:yes}
  dimension: product_id {}
  dimension: user_type {hidden:yes}
  dimension: institution_id {hidden:yes}
  dimension: region {hidden:yes}
  dimension: isbn13 {}


}
