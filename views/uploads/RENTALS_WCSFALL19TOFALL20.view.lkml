explore: rentals_wcsfall19tofall20 {label:"Rentals Fall 19 to Fall 20"}
view: rentals_wcsfall19tofall20 {
  derived_table: {
    sql:
      with rentals as (
        select
          isbn::string as isbn
          , date_of_purchase as date_of_purchase
          , uid as customer_guid
          , rental_plan
        from "UPLOADS"."RENTALS"."WCSFALL19TOFALL20" r
        left join prod.DATAVAULT.SAT_USER_PII_V2 sp on sp.EMAIL = r.LOGONID
        left join prod.DATAVAULT.HUB_USER hu on hu.HUB_USER_KEY = sp.HUB_USER_KEY
        union
        select
          rental_isbn::string
          , placed_on_date_time::date
          , customer_guid
          , rental_plan
        from "UPLOADS"."RENTALS"."SAPRENTALSFALL20"
      )
      , rentals_plus as (
      select distinct
        coalesce(su.LINKED_GUID, hu.UID) as merged_guid
        , r.isbn::string as isbn
        , r.date_of_purchase
        , r.rental_plan
        , ss.subscription_start
        , ss.subscription_end
        , ss.cancelled_time
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
        , hi.institution_id
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
        where ss._latest and ss.SUBSCRIPTION_PLAN_ID <> 'Read-Only'
      ) ss on ss.merged_guid = coalesce(su.LINKED_GUID, hu.UID) and r.date_of_purchase::date between ss.SUBSCRIPTION_START::date and coalesce(ss.cancelled_time::date, ss.SUBSCRIPTION_END::date)
-- get product info joined on rental isbn
      left join prod.STG_CLTS.PRODUCTS pr on pr.ISBN13 = r.isbn
-- get user institution
      left join (
        select distinct
          coalesce(su.LINKED_GUID, hu.UID) as merged_guid
          , lui.hub_institution_key
          , sui._ldts as _effective_from
          , lead(sui._ldts) over(partition by merged_guid order by sui._ldts) as _effective_to
        from prod.DATAVAULT.LINK_USER_INSTITUTION lui
        inner join prod.DATAVAULT.SAT_USER_INSTITUTION sui on lui.LINK_USER_INSTITUTION_KEY = sui.LINK_USER_INSTITUTION_KEY
        inner join prod.datavault.hub_user hu on hu.hub_user_key = lui.hub_user_key
        inner join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
      ) lui on lui.merged_guid = coalesce(su.LINKED_GUID, hu.UID) and (r.date_of_purchase between lui._effective_from and coalesce(lui._effective_to,current_date))
      left join prod.DATAVAULT.HUB_INSTITUTION hi on hi.HUB_INSTITUTION_KEY = lui.HUB_INSTITUTION_KEY
-- join to institution info on product institution, else user institution
      left join prod.DATAVAULT.SAT_INSTITUTION_SAWS si on si.HUB_INSTITUTION_KEY = hi.HUB_INSTITUTION_KEY and si._LATEST
    )
    , rentals_plus_plus as (
      select *
        , lag(date_of_purchase) over(partition by merged_guid, isbn, subscription_plan_id order by date_of_purchase) as last_purchase_date_isbn
        , iff(date_of_purchase >= '2020-08-01' and coalesce(datediff(d,last_purchase_date_isbn,date_of_purchase),2) > 1,1,0) as new_rental_fall_2020
      from rentals_plus
    )
    select *
      , sum(new_rental_fall_2020) over(partition by merged_guid, subscription_plan_id) as user_rentals_sub_plan_fall_2020
    from rentals_plus_plus
    ;;
    persist_for: "8 hours"
  }

  # rentals
  dimension: merged_guid {view_label:"Rentals"}

  # dimension: _file {label:"_file" view_label:"Rentals"}

  # dimension: _line {label:"_line" view_label:"Rentals"}

  # dimension: orderid {type: string view_label:"Rentals"}

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

  # dimension: status {view_label:"Rentals"}

  # dimension: _fivetran_synced {label:"_fivetran_synced" type:date_time view_label:"Rentals"}

  dimension: user_rentals_sub_plan_fall_2020 {
    type: number
    view_label: "Rentals"
  }

  dimension: rental_plan {
    type: string
    view_label: "Rentals"
  }

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

  dimension: cancelled_time {
    type: date_time
    view_label:"Subscription"
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
      then 'CUI Institution'
      else 'Non-CUI Institution' end
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
    sql: concat(${merged_guid},${isbn}) ;;
    label: "# of Products Rented"
    view_label:"Rentals"
  }

  measure: rentals_per_student {
    type: number
    sql: count(distinct concat(${merged_guid},${isbn})) / nullif(count(distinct ${merged_guid}),0) ;;
    label: "# of Rentals Per User"
    view_label:"Rentals"
  }











}
