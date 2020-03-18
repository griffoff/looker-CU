include: "//core/access_grants_file.view"
explore: cu_user_info {label: "CU User Info"}

view: cu_user_info {

#   filter: internal_user_flag_filter {
#     default_value: "No"
#     type: string
#     sql: CASE WHEN ${TABLE}.internal THEN 'Yes' ELSE 'No' END ;;
#   }

  derived_table: {
    publish_as_db_view: yes
    sql:
          WITH hub_sat_latest
          AS (
            SELECT
                h.hub_user_key,h._ldts, sa.rsrc_timestamp
                ,h.uid as user_sso_guid,sa.linked_guid,coalesce(sa.linked_guid,h.uid) as merged_guid
                ,COALESCE(p.email, merged_guid) as party_identifier
                ,p.email
                ,p.first_name
                ,p.last_name
                ,MAX(
                    IFF(TRY_CAST(p.birth_year AS INT) < 1900 OR TRY_CAST(p.birth_year AS INT) >= YEAR(DATEADD(YEAR, -4, CURRENT_DATE()))
                      ,NULL
                      ,NULLIF(TRY_CAST(p.birth_year AS INT), 0)
                    )
                  ) OVER (PARTITION BY party_identifier) AS birth_year
                ,sa.instructor,sa.k12, sa.region
                ,COUNT(NULLIF(sa.instructor, 0)) OVER (PARTITION BY party_identifier) >= 1 AS instructor_by_party
                ,LAST_VALUE(sa.k12) OVER (PARTITION BY party_identifier ORDER BY sa.rsrc_timestamp) AS k12_latest
                ,COUNT(NULLIF(sa.k12, 0)) OVER (PARTITION BY party_identifier) >= 1 as k12_by_party
                ,COUNT(CASE WHEN sa.region = 'USA' THEN 1 END ) OVER (PARTITION BY party_identifier) >= 1 AS usa_by_party
                ,COUNT(CASE WHEN COALESCE(sa.region, '') != 'USA' THEN 1 END ) OVER (PARTITION BY party_identifier) >= 1 AS non_usa_by_party
                --,ARRAY_AGG(DISTINCT NULLIF(sa.region, '')) WITHIN GROUP (ORDER BY NULLIF(sa.region, '')) OVER (PARTITION BY party_identifier) AS all_regions_by_party
                ,COALESCE(usmar.opt_out, 'true') AS marketing_opt_out
                ,COUNT(CASE WHEN marketing_opt_out = 'true' THEN 1 END) OVER (PARTITION BY party_identifier) >= 1 as opt_out_by_party
            FROM prod.datavault.hub_user h
            INNER JOIN prod.datavault.sat_user sa
                        ON h.hub_user_key = sa.hub_user_key
                        AND sa.active
            LEFT JOIN prod.datavault.sat_user_pii p
                        ON h.hub_user_key = p.hub_user_key
                        AND p.active
            LEFT JOIN prod.datavault.sat_user_marketing usmar
                        ON h.hub_user_key = usmar.hub_user_key
                        AND usmar.active
          )
          ,latest_institution as (
            SELECT linkins.hub_user_key, linkins.hub_institution_key, ROW_NUMBER() OVER (PARTITION BY linkins.hub_user_key ORDER BY _ldts DESC ) = 1 as latest
            FROM prod.datavault.link_user_institution linkins
          )
          SELECT DISTINCT
              hs.*
              ,hubin.institution_id

              ,usint.internal
              ,COALESCE(bl.flag,'N') AS entity_flag
          FROM hub_sat_latest hs
          LEFT JOIN latest_institution linkins
              ON hs.hub_user_key = linkins.hub_user_key -- 2486955
              AND linkins.latest
          LEFT JOIN prod.datavault.hub_institution hubin
               ON linkins.hub_institution_key = hubin.hub_institution_key
          LEFT JOIN prod.datavault.sat_user_internal usint ON hs.hub_user_key = usint.hub_user_key
                                                          AND usint.active
          LEFT JOIN (select distinct entity_id,flag  from UPLOADS.CU.ENTITY_BLACKLIST) bl
               ON hubin.institution_id::STRING = bl.entity_id
  ;;

  sql_trigger_value: select count(*) from prod.datavault.sat_user ;;
  }


  measure: count {
    label: "# Users"
    type: count
    drill_fields: [detail*]
    hidden: no
#     hidden: yes
    description: "Count of users, non-distinct"
  }

  measure: users {
    type: count_distinct
    sql: ${merged_guid} ;;
    drill_fields: [detail*]
    description: "Count of distinct users by merged GUID"
#     hidden: yes
  }



  dimension: instructor {
    type: string
    sql: ${TABLE}."INSTRUCTOR" ;;
    hidden: yes
  }

  dimension: is_instructor {
    label: "Is Instructor"
    type: yesno
    sql: ${TABLE}."INSTRUCTOR" = 'true';;
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
    description: "Average user age (inc. students, instructors, etc.)"
  }

  measure: age_min {
    group_label: "Age"
    label: "Minimum Age"
    type: min
    sql: ${age} ;;
    value_format: "0.0"
    description: "Youngest user age (inc. students, instructors, etc.)"
  }

  measure: age_max {
    group_label: "Age"
    label: "Maximum Age"
    type: max
    sql: ${age} ;;
    value_format: "0.0"
    description: "Oldest user age (inc. students, instructors, etc.)"
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
    type: yesno
    label: "IPM Blacklist Institution"
    sql: ${TABLE}.entity_flag ILIKE 'Y%' ;;
    description: "This flag is Yes for users that attend institutions that do NOT allow their student's to recieve IPMs. This means these institutions appear on IPM suppression lists which are lists of institutions (typically IA or CUI institutions) who have requested that their students do NOT receive in-platform messages (IPMs) related to CU upsell or conversion. This list is driven by a google sheet that can be found in the value of this field."
    link: {
        label: "IPM suppression list google sheet"
        url: "https://docs.google.com/spreadsheets/d/1GWByyBwWhMX-aXEzYqeHe_p-wCRsiwCMMPn_SyrzpWk/edit#gid=0"
    }
  }

  dimension: k12_user {
    label: "Is K12 User"
    description: "Data field to identify K12 customer"
    type: yesno
    sql: ${TABLE}.k12 ;;
  }

  dimension: k12_by_party {
    group_label: "Party flags"
    label: "Has K12 User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with a K12 flag"
    type: yesno
  }

  dimension: k12_latest {
    group_label: "Party flags"
    label: "Latest Record Is K12"
    description: "Indicates whether this user's latest record (matched by email or merged guid, sorted by change timestamp) has a K12 flag"
    type: yesno
  }

  dimension: instructor_by_party {
    group_label: "Party flags"
    label: "Has Instructor User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with an Instructor flag"
    type: yesno
  }

  dimension: non_usa_by_party {
    group_label: "Party flags"
    label: "Has Non-USA User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with a non-USA region"
    type: yesno
  }

  dimension: opt_out_by_party {
    group_label: "Party flags"
    label: "Has Opt-Out User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with an Opt-out flag"
    type: yesno
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
    description: "User email address"
  }

  dimension: first_name {
    group_label: "User Info - PII"
    type: string
    sql: InitCap(${TABLE}."FIRST_NAME");;
    required_access_grants: [can_view_CU_pii_data]
    description: "User first name"
  }

  dimension: last_name {
    group_label: "User Info - PII"
    type: string
    sql: InitCap(${TABLE}."LAST_NAME") ;;
    required_access_grants: [can_view_CU_pii_data]
    description: "User last name"
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

  dimension: us_hed_marketing_allowed {
    label: "Marketing allowed - US HED"
    description: "
    none of the following are found in any matching user records (matched by email address or merged guid if email is missing)
      - opt out flags
      - instructor flags
      - k12 flags
      - non-USA regions
    "
    view_label: "** RECOMMENDED FILTERS **"
    type: yesno
    sql: NOT ${opt_out_by_party} AND NOT ${k12_by_party} AND NOT ${instructor_by_party} AND NOT ${non_usa_by_party};;
  }

  dimension: region {
    group_label: "User Info - PII"
    description: "User country / region"
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
    sql: ${TABLE}."USER_SSO_GUID" ;;
    hidden: yes
  }

  dimension: merged_guid {
    type: string
    label: "User SSO Guid"
    description: "Primary User SSO Guid (not shadow guid)"
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
