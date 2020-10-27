explore: rentals_wcsfall19tofall20 {label:"Rentals Fall 19 to Fall 20"}
view: rentals_wcsfall19tofall20 {
  derived_table: {
    sql:
      with rentals as (
        select
          orderid:: string as orderid
          , isbn::string as isbn
          , date_of_purchase
          , uid as customer_guid
          , status
        from "UPLOADS"."RENTALS"."WCSFALL19TOFALL20" r
        left join prod.DATAVAULT.SAT_USER_PII_V2 sp on sp.EMAIL = r.LOGONID
        left join prod.DATAVAULT.HUB_USER hu on hu.HUB_USER_KEY = sp.HUB_USER_KEY
        union
        select
          rental_contract_id::string
          , rental_isbn::string
          , placed_on_date_time
          , customer_guid
          , current_rental_status
        from "UPLOADS"."RENTALS"."SAPRENTALSFALL20"
      )
      select distinct
        coalesce(su.LINKED_GUID, hu.UID) as merged_guid
        , r.orderid::string as orderid
        , r.isbn::string as isbn
        , r.date_of_purchase
        , r.status
        , ss.subscription_start
        , ss.subscription_end
        , ss.subscription_state
        , ss.subscription_plan_id
        , pr.ISBN13 as isbn13
        , pr.short_title
        , pr.title
        , pr.all_authors_nm
        , pr.edition
        , pr.prod_family_cd
        , pr.prod_family_de
        , si.name
        , si."TYPE"
        , si.iso_country
        , coalesce(p.INSTITUTION_ID, hi.institution_id) as institution_id
      from rentals r
-- get merged guid
      left join prod.DATAVAULT.HUB_USER hu on r.customer_guid = hu.uid
      left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
-- get subscription info joined on merged guid
      left join (
        select
          ss.*
          , coalesce(su.LINKED_GUID, hu.UID) as merged_guid
        from prod.DATAVAULT.SAT_SUBSCRIPTION_SAP ss
        left join prod.datavault.hub_user hu on hu.uid = ss.current_guid
        left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
        where ss.SUBSCRIPTION_STATE in ('Active')
      ) ss on ss.merged_guid = coalesce(su.LINKED_GUID, hu.UID) and r.date_of_purchase::date between ss.SUBSCRIPTION_START::date and ss.SUBSCRIPTION_END::date
-- get product info joined on rental isbn
      left join prod.STG_CLTS.PRODUCTS pr on pr.ISBN13 = r.isbn
-- try to join to provisioned products on rental isbn and merged_guid
      left join (
        select sp._rsrc,
          sp._EFFECTIVE_FROM,
          sp._EFFECTIVE_TO,
          sp._LATEST,
          coalesce(su.LINKED_GUID, hu.UID) as merged_guid,
          sp.DATE_ADDED,
          sp.EXPIRATION_DATE,
          sp.INSTITUTION_ID,
          sp.PRODUCT_ID,
          sp.ORDER_NUMBER,
          lpp.HUB_PRODUCT_KEY,
          hisbn.ISBN13,
          hi.HUB_INSTITUTION_KEY
        from prod.DATAVAULT.SAT_PROVISIONED_PRODUCT_V2 sp
        left join prod.datavault.hub_user hu on hu.uid = sp.user_sso_guid
        left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
        left join prod.DATAVAULT.LINK_PRODUCT_PROVISIONEDPRODUCT lpp on lpp.HUB_PROVISIONED_PRODUCT_KEY = sp.HUB_PROVISIONED_PRODUCT_KEY
        left join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = lpp.HUB_PRODUCT_KEY
        left join prod.DATAVAULT.HUB_ISBN hisbn on hisbn.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
        left join prod.DATAVAULT.HUB_INSTITUTION hi on sp.INSTITUTION_ID = hi.INSTITUTION_ID
        union
        select sn._rsrc,
          sn._EFFECTIVE_FROM,
          sn._EFFECTIVE_TO,
          sn._LATEST,
          coalesce(su.LINKED_GUID, hu.UID) as merged_guid,
          sn.REGISTRATION_DATE,
          dateadd(d, sn.SUBSCRIPTION_LENGTH_IN_DAYS, sn.REGISTRATION_DATE),
          sn.INSTITUTION_ID,
          sn.PRODUCT_ID,
          sn.ORDER_NUMBER,
          lsp.HUB_PRODUCT_KEY,
          hisbn.ISBN13,
          hi.HUB_INSTITUTION_KEY
        from prod.DATAVAULT.SAT_SERIAL_NUMBER_CONSUMED sn
        left join prod.datavault.hub_user hu on hu.uid = sn.user_sso_guid
        left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
        left join prod.DATAVAULT.LINK_SERIALNUMBER_PRODUCT lsp on lsp.HUB_SERIALNUMBER_KEY = sn.HUB_SERIALNUMBER_KEY
        left join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_PRODUCT_KEY = lsp.HUB_PRODUCT_KEY
        left join prod.DATAVAULT.HUB_ISBN hisbn on hisbn.HUB_ISBN_KEY = lpi.HUB_ISBN_KEY
        left join prod.DATAVAULT.HUB_INSTITUTION hi on sn.INSTITUTION_ID = hi.INSTITUTION_ID
      ) p on p.merged_guid = coalesce(su.LINKED_GUID, hu.UID) and r.isbn = p.isbn13
-- get user institution
      left join prod.DATAVAULT.LINK_USER_INSTITUTION lui on lui.HUB_USER_KEY = hu.HUB_USER_KEY
      left join prod.DATAVAULT.HUB_INSTITUTION hi on hi.HUB_INSTITUTION_KEY = lui.HUB_INSTITUTION_KEY
-- join to institution info on product institution, else user institution
      left join prod.DATAVAULT.SAT_INSTITUTION_SAWS si on si.HUB_INSTITUTION_KEY = coalesce(p.hub_institution_key, hi.HUB_INSTITUTION_KEY) and si._LATEST

    /*
      with rentals as (
        select
          orderid
          , isbn
          , date_of_purchase
          , logonid
          , uid as customer_guid
          , status
        from "UPLOADS"."RENTALS"."WCSFALL19TOFALL20" r
        left join prod.DATAVAULT.SAT_USER_PII_V2 sp on sp.EMAIL = r.LOGONID and sp._LATEST
        left join prod.DATAVAULT.HUB_USER hu on hu.HUB_USER_KEY = sp.HUB_USER_KEY
        union all
        select
          rental_contract_id
          , rental_isbn
          , placed_on_date_time
          , null as logonid
          , customer_guid
          , current_rental_status
        from "UPLOADS"."RENTALS"."SAPRENTALSFALL20"
      )
      select distinct
        coalesce(su.LINKED_GUID, hu.UID) as merged_guid
        --, r._file
        --, r._line
        , r.orderid::string as orderid
        , r.isbn::string as isbn
        --, r.duration
        , r.date_of_purchase
        , r.logonid
        --, r.total
        --, r.discount
        --, r.rental_plan
        --, r.promocode
        , r.status
        --, r._fivetran_synced
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
      from rentals r
      left join prod.DATAVAULT.HUB_USER hu on r.customer_guid = hu.uid
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
      */
    ;;
    persist_for: "8 hours"
  }

  # rentals
  dimension: merged_guid {view_label:"Rentals"}

  # dimension: _file {label:"_file" view_label:"Rentals"}

  # dimension: _line {label:"_line" view_label:"Rentals"}

  dimension: orderid {type: string view_label:"Rentals"}

  dimension: isbn {
    type: string
    view_label:"Rentals"
  }

  # dimension: duration {view_label:"Rentals"}

  dimension_group: purchase {
    sql: ${TABLE}.date_of_purchase ;;
    type:time
    timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
    view_label:"Rentals"
    group_label: "Purchase"
  }

  # dimension: logonid {view_label:"Rentals"}

  # dimension: total {type:number view_label:"Rentals"}

  # dimension: discount {type:number view_label:"Rentals"}

  # dimension: rental_plan {view_label:"Rentals"}

  # dimension: promocode {view_label:"Rentals"}

  dimension: status {view_label:"Rentals"}

  # dimension: _fivetran_synced {label:"_fivetran_synced" type:date_time view_label:"Rentals"}

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

  dimension: subscription_plan_id {
    view_label:"Subscription"
    sql: coalesce(${TABLE}.subscription_plan_id, 'No Active Subscription') ;;
    }

  # # products
  # dimension_group: added {
  #   sql: ${TABLE}.date_added ;;
  #   type:time
  #   timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
  #   view_label:"Provisioned Products"
  #   group_label: "Added"
  # }

  # dimension_group: expiration {
  #   sql: ${TABLE}.expiration_DATE ;;
  #   type:time
  #   timeframes: [raw, time,  date, week, month, quarter, year, day_of_week]
  #   view_label:"Provisioned Products"
  #   group_label: "Expiration"
  # }

  # dimension: product_id {view_label:"Provisioned Products"}

  # dimension: order_number {type: string view_label:"Provisioned Products"}

  dimension: isbn13 {
    type: string
    view_label:"Product"
  }

  dimension: short_title {view_label:"Product"}

  dimension: title {view_label:"Product"}

  dimension: all_authors_nm {view_label:"Product"}

  dimension: edition {view_label:"Product"}

  dimension: prod_family_cd {view_label:"Product"}

  dimension: prod_family_de {view_label:"Product"}

  dimension: prod_family_and_edition {
    view_label:"Product"
    sql: concat(${prod_family_de},' - ',${edition}) ;;
    }

  # institution
  dimension: name {view_label:"Institution"}

  dimension: type {sql: "TYPE";; view_label:"Institution"}

  dimension: iso_country {
    label: "Country"
    view_label:"Institution"
  }

  dimension: cui_institution {
    view_label:"Institution"
    sql: case when ${institution_id} in ('5930', '210481', '194025', '204101', '223806', '5557', '210362', '25689699', '26506392', '144400', '5345', '216264', '5562', '4749', '145290', '7193', '24596850'
      , '221125', '222400', '217587', '26133890', '145135', '24804090', '210221', '7167', '7786', '33450830', '5653', '6484', '210302', '6567', '144341', '144343', '25601692', '222685', '144332', '222922'
      , '24346082', '144336', '24795754', '144337', '144342', '144338', '144344', '24773376', '144333', '222477', '144334', '144335', '144340', '4796', '6047', '5289', '144855', '6516', '4806', '5726', '6744'
      , '6419', '226970', '4980', '5517', '7557', '146256', '4400', '144610', '145987', '4814', '25598799', '157989', '144893', '5819', '210625', '6662', '26717562', '210496', '31436473', '6764', '24765622'
      , '144752', '148740', '144219', '155958', '214541', '156255', '158211', '146357', '144221', '6910', '144242', '216185', '6908', '155945', '155981', '216377', '144448', '216015', '144435', '148739'
      , '157214', '144243', '148738', '144225', '23942107', '166180', '220803', '144212', '214766', '216008', '144757', '5091', '6116', '4934', '6727', '4610', '6416', '216161', '6429', '6972', '5835', '4188'
      , '4196', '5839', '7612', '31173354', '4012', '5197', '6771', '97468', '5260', '147283', '6543', '31454812', '31471397', '5464', '5637', '7168', '6521', '148797', '5025', '157130', '214785', '7318'
      , '4084', '31471380', '221762', '6743', '99993239', '6751', '225061', '5207', '6090', '4086', '4656', '144888', '218791', '224516', '144890', '218838', '218784', '25584046', '144891', '144892', '6438'
      , '5209', '225051', '175467', '6093', '5039', '4026', '6015', '164158', '148104', '5897', '164112', '5210', '213268', '5378', '6538', '6022', '157914', '4356', '33457061', '4274', '197262', '5224', '6426'
      , '218322', '5275', '5277', '5279', '5276', '5310', '6132', '5382', '6149', '6350', '6354', '5909', '6228', '7328', '218031', '6845', '6645', '4874', '27299594', '4842', '5713', '6144', '28002121')
      then 'CUI Institution' else 'Non-CUI Institution' end
      ;;
  }

  dimension: institution_id {
    type: string
    view_label:"Institution"
    sql: nullif(nullif(${TABLE}.institution_id,'NOT FOUND'),'') ;;
  }

  measure: renters {
    type: count_distinct
    sql: ${merged_guid} ;;
    label: "# of Rental Users"
    view_label:"Rentals"
  }

  # measure: provisioned_products {
  #   type: count_distinct
  #   sql: concat(${merged_guid}, ${isbn13}) ;;
  #   label: "# of Products Provisioned"
  #   view_label:"Provisioned Products"
  # }

  measure: rentals {
    type: count_distinct
    sql: concat(${merged_guid},${isbn},${orderid}) ;;
    label: "# of Products Rented"
    view_label:"Rentals"
  }

  measure: rentals_per_student {
    type: number
    sql: count(distinct concat(${merged_guid},${isbn},${orderid})) / nullif(count(distinct ${merged_guid}),0) ;;
    label: "# of Rentals Per User"
    view_label:"Rentals"
  }











}
