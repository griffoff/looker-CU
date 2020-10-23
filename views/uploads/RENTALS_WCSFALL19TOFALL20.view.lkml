explore: rentals_wcsfall19tofall20 {}
view: rentals_wcsfall19tofall20 {
  derived_table: {
    sql:
      select distinct
        coalesce(su.LINKED_GUID, hu.UID) as merged_guid
        , r._file
        , r._line
        , r.orderid::string as orderid
        , r.isbn::string as isbn
        , r.duration
        , r.date_of_purchase
        , r.logonid
        , r.total
        , r.discount
        , r.rental_plan
        , r.promocode
        , r.status
        , r._fivetran_synced
        , ss.subscription_start
        , ss.subscription_end
        , ss.subscription_state
        , ss.subscription_plan_id
        , p.date_added
        , p.expiration_DATE
        , p.product_id
        , p.order_number::string as order_number
        , hisbn.isbn13::string as isbn13
        , pr.short_title
        , pr.title
        , si.name
        , si."TYPE"
        , si.iso_country
        , hi.institution_id
      from "UPLOADS"."RENTALS"."WCSFALL19TOFALL20" r
      left join prod.DATAVAULT.SAT_USER_PII_V2 sp on sp.EMAIL = r.LOGONID and sp._LATEST
      left join prod.DATAVAULT.HUB_USER hu on hu.HUB_USER_KEY = sp.HUB_USER_KEY
      left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
      left join prod.DATAVAULT.SAT_SUBSCRIPTION_SAP ss on ss.CURRENT_GUID = coalesce(su.LINKED_GUID, hu.UID) and r.date_of_purchase::date between ss.SUBSCRIPTION_START::date and ss.SUBSCRIPTION_END::date
        and r.date_of_purchase::date between ss._EFFECTIVE_FROM::date and coalesce(ss._EFFECTIVE_TO::date, current_date)
        AND ss.SUBSCRIPTION_STATE <> 'Cancelled'
      left join (
        select sp._rsrc,
          sp._EFFECTIVE_FROM,
          sp._EFFECTIVE_TO,
          sp._LATEST,
          sp.USER_SSO_GUID,
          sp.DATE_ADDED,
          sp.EXPIRATION_DATE,
          sp.INSTITUTION_ID,
          sp.PRODUCT_ID,
          sp.ORDER_NUMBER,
          lpp.HUB_PRODUCT_KEY
        from prod.DATAVAULT.SAT_PROVISIONED_PRODUCT_V2 sp
        left join prod.DATAVAULT.LINK_PRODUCT_PROVISIONEDPRODUCT lpp on lpp.HUB_PROVISIONED_PRODUCT_KEY = sp.HUB_PROVISIONED_PRODUCT_KEY
        union all
        select sn._rsrc,
          sn._EFFECTIVE_FROM,
          sn._EFFECTIVE_TO,
          sn._LATEST,
          sn.USER_SSO_GUID,
          sn.REGISTRATION_DATE,
          dateadd(d, sn.SUBSCRIPTION_LENGTH_IN_DAYS, sn.REGISTRATION_DATE),
          sn.INSTITUTION_ID,
          sn.PRODUCT_ID,
          sn.ORDER_NUMBER,
          lsp.HUB_PRODUCT_KEY
        from prod.DATAVAULT.SAT_SERIAL_NUMBER_CONSUMED sn
        left join prod.DATAVAULT.LINK_SERIALNUMBER_PRODUCT lsp on lsp.HUB_SERIALNUMBER_KEY = sn.HUB_SERIALNUMBER_KEY
      ) p on p.USER_SSO_GUID = coalesce(su.LINKED_GUID, hu.UID) and r.date_of_purchase::date between p.DATE_ADDED::date and p.EXPIRATION_DATE::date
        and r.date_of_purchase::date between p._EFFECTIVE_FROM::date and coalesce(p._EFFECTIVE_TO, current_date)::date
      left join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = p.HUB_PRODUCT_KEY
      left join prod.DATAVAULT.HUB_ISBN hisbn on hisbn.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
      left join prod.STG_CLTS.PRODUCTS pr on pr.ISBN13 = hisbn.ISBN13
      left join prod.DATAVAULT.HUB_INSTITUTION hi on p.INSTITUTION_ID = hi.INSTITUTION_ID
      left join prod.DATAVAULT.LINK_USER_INSTITUTION lui on lui.HUB_USER_KEY = hu.HUB_USER_KEY
      left join prod.DATAVAULT.SAT_INSTITUTION_SAWS si on si.HUB_INSTITUTION_KEY = coalesce(hi.HUB_INSTITUTION_KEY,lui.HUB_INSTITUTION_KEY) and si._LATEST
    ;;
    persist_for: "8 hours"
  }

  # rentals
  dimension: merged_guid {view_label:"Rentals"}

  dimension: _file {label:"_file" view_label:"Rentals"}

  dimension: _line {label:"_line" view_label:"Rentals"}

  dimension: orderid {type: string view_label:"Rentals"}

  dimension: isbn {
    type: string
    view_label:"Rentals"
  }

  dimension: duration {view_label:"Rentals"}

  dimension_group: purchase {
    sql: ${TABLE}.date_of_purchase ;;
    type:time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
    view_label:"Rentals"
    group_label: "Purchase"
  }

  dimension: logonid {view_label:"Rentals"}

  dimension: total {type:number view_label:"Rentals"}

  dimension: discount {type:number view_label:"Rentals"}

  dimension: rental_plan {view_label:"Rentals"}

  dimension: promocode {view_label:"Rentals"}

  dimension: status {view_label:"Rentals"}

  dimension: _fivetran_synced {label:"_fivetran_synced" type:date_time view_label:"Rentals"}

  # subscription
  dimension_group: subscription_start {
    sql: ${TABLE}.subscription_start ;;
    type:time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
    view_label:"Subscription"
    group_label: "Subscription Start"
  }
  dimension_group: subscription_end {
    sql: ${TABLE}.subscription_end ;;
    type:time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
    view_label:"Subscription"
    group_label: "Subscription End"
  }
  dimension: subscription_state {view_label:"Subscription"}

  dimension: subscription_plan_id {view_label:"Subscription"}

  # products
  dimension_group: added {
    sql: ${TABLE}.date_added ;;
    type:time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
    view_label:"Provisioned Products"
    group_label: "Added"
  }

  dimension_group: expiration {
    sql: ${TABLE}.expiration_DATE ;;
    type:time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
    view_label:"Provisioned Products"
    group_label: "Expiration"
  }

  dimension: product_id {view_label:"Provisioned Products"}

  dimension: order_number {type: string view_label:"Provisioned Products"}

  dimension: isbn13 {
    type: string
    view_label:"Provisioned Products"
  }

  dimension: short_title {view_label:"Provisioned Products"}

  dimension: title {view_label:"Provisioned Products"}

  # institution
  dimension: name {view_label:"Institution"}

  dimension: type {sql: "TYPE";; view_label:"Institution"}

  dimension: iso_country {
    label: "Country"
    view_label:"Institution"
  }

  dimension: institution_id {type: string view_label:"Institution"}

  measure: renters {
    type: count_distinct
    sql: ${merged_guid} ;;
    label: "# of Rental Users"
  }

  measure: provisioned_products {
    type: count_distinct
    sql: concat(${merged_guid}, ${isbn13}) ;;
    label: "# of Products Provisioned"
  }

  measure: rentals {
    type: count_distinct
    sql: concat(${merged_guid},${isbn},${orderid}) ;;
    label: "# of Products Rented"
  }












}
