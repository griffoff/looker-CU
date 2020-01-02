include: "//core/access_grants_file.view"
explore: cu_user_info {label: "CU User Info"}

view: cu_user_info {

#   filter: internal_user_flag_filter {
#     default_value: "No"
#     type: string
#     sql: CASE WHEN ${TABLE}.internal THEN 'Yes' ELSE 'No' END ;;
#   }

  derived_table: {
    sql: with hub_sat as (
          Select
            h.hub_user_key,h._ldts,h.uid as user_sso_guid,sa.linked_guid,coalesce(sa.linked_guid,h.uid) as merged_guid, sa.instructor,sa.k12, sa.region
           from PROD.DATAVAULT.HUB_USER h
            INNER JOIN Prod.Datavault.sat_user sa
          on h.hub_user_key = sa.hub_user_key
          )
          ,hub_sat_latest as (
              select row_number () over (partition by merged_guid order by _ldts desc) = 1 as latest,*
            from hub_sat
          )
          ,latest_institution as (
            select linkins.hub_user_key, linkins.hub_institution_key, row_number() over (partition by linkins.hub_user_key order by _ldts desc ) = 1 as latest
            from PROD.DATAVAULT.link_user_institution linkins
          )
          Select distinct hs.*,
              hubin.institution_id,
              usmar.active,
              usmar.opt_out AS marketing_opt_out,
              p.first_name,
              p.last_name,
              p.email,
              usint.internal,
              coalesce(bl.flag,'N') as entity_flag,
              IFF(TRY_CAST(p.birth_year AS INT) < 1900 OR TRY_CAST(p.birth_year AS INT) >= YEAR(DATEADD(YEAR, -4, CURRENT_DATE()))
                ,NULL
                ,NULLIF(TRY_CAST(p.birth_year AS INT), 0)
                ) AS birth_year
          from hub_sat_latest hs
          INNER JOIN PROD.DATAVAULT.SAT_USER_PII p
              ON hs.hub_user_key = p.hub_user_key
              AND p.active
          left join latest_institution linkins
              on hs.hub_user_key = linkins.hub_user_key -- 2486955
              and linkins.latest
          left join PROD.DATAVAULT.HUB_INSTITUTION hubin
               on linkins.hub_institution_key = hubin.hub_institution_key
          left join PROD.DATAVAULT.SAT_USER_MARKETING usmar
              ON hs.hub_user_key = usmar.hub_user_key
              and usmar.active
          --temporary point to raw user classification table
          left join (select distinct user_sso_guid, internal from prod.cu_user_analysis.user_classification_copy) usint
              ON hs.merged_guid = usint.user_sso_guid
          --put this back once DV is showing the correct data
          --left join PROD.DATAVAULT.SAT_USER_INTERNAL usint
          --    ON usint.hub_user_key = hs.hub_user_key
          --    and usint.active
          LEFT JOIN (select distinct entity_id,flag  from UPLOADS.CU.ENTITY_BLACKLIST) bl
               ON hubin.institution_id::STRING = bl.entity_id
          where hs.latest = 1
  ;;

  persist_for: "6 hour"
  }


  measure: count {
    type: count
    drill_fields: [detail*]
    #hidden: yes
  }

  dimension: instructor {
    type: string
    sql: ${TABLE}."INSTRUCTOR" ;;
    hidden: no
  }

  dimension: primary_guid {
    type: string
    sql: ${TABLE}."LINKED_GUID" ;;
    hidden: yes
  }

  dimension: birth_year {
    group_label: "Age"
    label: "Birth Year"
    type: number
    value_format: "0000"
  }

  dimension: age {
    group_label: "Age"
    type: number
    sql: YEAR(CURRENT_DATE()) - ${birth_year} ;;
  }

  measure: age_average {
    group_label: "Age"
    label: "Average Age"
    type: average
    sql: ${age} ;;
    value_format: "0.0"
  }

  measure: age_min {
    group_label: "Age"
    label: "Minimum Age"
    type: min
    sql: ${age} ;;
    value_format: "0.0"
  }

  measure: age_max {
    group_label: "Age"
    label: "Maximum Age"
    type: max
    sql: ${age} ;;
    value_format: "0.0"
  }


  dimension: internal_user_flag {
    view_label: "** RECOMMENDED FILTERS **"
    label: "Internal User Flag"
    type: yesno
    sql: ${TABLE}.internal ;;
    hidden: yes
  }

  dimension: real_user_flag {
    view_label: "** RECOMMENDED FILTERS **"
    description: "Users who are not flagged as internal (e.g. QA)"
    label: "Real User Flag"
    type: yesno
    sql: NOT ${TABLE}.internal OR ${TABLE}.internal IS NULL  ;;
  }


  dimension: entity_flag {
    label: "Entity Blacklist"
    sql: ${TABLE}.entity_flag ;;
  }

  dimension: k12_user {
    label: "K12 User"
    description: "Data field to identify K12 customer"
    type: yesno
    sql: ${TABLE}.k12 ;;
  }


  dimension: partner_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    hidden: yes
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
    hidden: yes
  }

  dimension: email {
    group_label: "User Info - PII"
    type: string
    sql: ${TABLE}."EMAIL" ;;
    required_access_grants: [can_view_CU_pii_data]
  }

  dimension: first_name {
    group_label: "User Info - PII"
    type: string
    sql: InitCap(${TABLE}."FIRST_NAME");;
    required_access_grants: [can_view_CU_pii_data]
  }

  dimension: last_name {
    group_label: "User Info - PII"
    type: string
    sql: InitCap(${TABLE}."LAST_NAME") ;;
    required_access_grants: [can_view_CU_pii_data]
  }

  dimension: marketing_opt_out {
    type: string
    sql: ${TABLE}."MARKETING_OPT_OUT" ;;
    hidden: yes
  }

  dimension: marketing_allowed {
    label: "Marketing allowed"
    description: "Based on the opt out flag - if it is set to false or null then marketing is allowed"
    view_label: "** RECOMMENDED FILTERS **"
    type: yesno
    sql: ${marketing_opt_out} = 'false' OR  ${marketing_opt_out} IS NULL;;
  }

  dimension: region {
    group_label: "User Info - PII"
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}."INSTITUTION_ID" ;;
    hidden: yes
  }

  dimension: tl_institution_name {
    type: string
    sql: ${TABLE}."TL_INSTITUTION_NAME" ;;
    hidden: yes
  }

  dimension: latest {
    type: string
    sql: ${TABLE}."LATEST" ;;
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
    hidden: yes
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
    hidden: yes
  }

  set: detail {
    fields: [
      primary_guid,
      partner_guid,
      event_time_time,
      email,
      first_name,
      last_name,
      entity_id,
      tl_institution_name,
      latest,
      user_sso_guid,
      merged_guid
    ]
  }

}
