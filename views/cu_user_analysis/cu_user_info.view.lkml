include: "//core/access_grants_file.view"
explore: cu_user_info {
  label: "CU User Info" hidden:yes
}

view: cu_user_info {

  label: "User Information"

#   filter: internal_user_flag_filter {
#     default_value: "No"
#     type: string
#     sql: CASE WHEN ${TABLE}.internal THEN 'Yes' ELSE 'No' END ;;
#   }

  derived_table: {
    publish_as_db_view: yes
    sql:
     WITH party AS (
          SELECT hu.hub_user_key
               , COALESCE(su.linked_guid, hu.uid) AS merged_guid
               , COUNT(DISTINCT sup.email) OVER (PARTITION BY merged_guid) = 1 as single_email
               , CASE
                     WHEN single_email
                         THEN LAST_VALUE(sup.email)
                                         OVER (PARTITION BY merged_guid ORDER BY CASE WHEN sup.email IS NOT NULL THEN 0 ELSE 1 END, sup._effective_from)
                     ELSE merged_guid END         AS party_identifier
               , CASE
                     WHEN NOT single_email THEN email
                     ElSE MAX(email) OVER(PARTITION BY merged_guid)
                    END                           AS merged_guid_email
          FROM prod.datavault.hub_user hu
                   LEFT JOIN prod.datavault.sat_user_v2 su ON hu.hub_user_key = su.hub_user_key AND su._latest
                   LEFT JOIN prod.datavault.sat_user_pii_v2 sup ON hu.hub_user_key = sup.hub_user_key AND sup._latest
      )
         , hub_sat_latest AS (
          SELECT h.hub_user_key
               , h._ldts
               , sa.rsrc_timestamp
               , h.uid                                                                                                                     AS user_sso_guid
               , sa.linked_guid
               , coalesce(sa.linked_guid, h.uid)                                                                                           AS merged_guid
               , party.party_identifier
               , party.merged_guid_email                                                                                                   AS email
               , p.first_name
               , p.last_name
               , MAX(
                  IFF(TRY_CAST(p.birth_year AS INT) < 1900 OR
                      TRY_CAST(p.birth_year AS INT) >= YEAR(DATEADD(YEAR, -4, CURRENT_DATE()))
                      , NULL
                      , NULLIF(TRY_CAST(p.birth_year AS INT), 0)
                      )
              )
                  OVER (PARTITION BY party_identifier)                                                                                     AS birth_year
               , sa.instructor
               , sa.k12
               , sa.region
               , CASE WHEN sa.account_type = 'linkedgateway' THEN 'false' ELSE COALESCE(usmar.opt_out, 'true') END                         AS marketing_opt_out
               , COUNT(NULLIF(sa.instructor, 0)) OVER (PARTITION BY party_identifier) >=
                 1                                                                                                                         AS instructor_by_party
               , LAST_VALUE(sa.k12)
                            OVER (PARTITION BY party_identifier ORDER BY sa.rsrc_timestamp)                                                AS k12_latest
               , COUNT(NULLIF(sa.k12, 0)) OVER (PARTITION BY party_identifier) >= 1                                                        AS k12_by_party
               , COUNT(CASE WHEN sa.region = 'USA' THEN 1 END) OVER (PARTITION BY party_identifier) >= 1
              AND COUNT(CASE WHEN COALESCE(sa.country, LEFT(sa.region, 2), '') = 'US' THEN 1 END)
                        OVER (PARTITION BY party_identifier) >=
                  1                                                                                                                        AS usa_by_party
               , COUNT(CASE WHEN COALESCE(sa.region, '') != 'USA' THEN 1 END) OVER (PARTITION BY party_identifier) >= 1
              OR COUNT(CASE WHEN COALESCE(sa.country, LEFT(sa.region, 2), '') != 'US' THEN 1 END)
                       OVER (PARTITION BY party_identifier) >=
                 1                                                                                                                         AS non_usa_by_party
               --,ARRAY_AGG(DISTINCT NULLIF(sa.region, '')) WITHIN GROUP (ORDER BY NULLIF(sa.region, '')) OVER (PARTITION BY party_identifier) AS all_regions_by_party
               , COUNT(CASE WHEN marketing_opt_out = 'true' THEN 1 END) OVER (PARTITION BY party_identifier) >=
                 1                                                                                                                         AS opt_out_by_party
               --found multiple linked accounts - use this to take only the latest one
               , LEAD(p.rsrc_timestamp)
                      OVER (PARTITION BY merged_guid ORDER BY CASE WHEN linked_guid IS NULL THEN 0 ELSE 1 END, sa._effective_from) IS NULL AS latest_linked_account
          FROM prod.datavault.hub_user h
                   INNER JOIN party ON h.hub_user_key = party.hub_user_key
                   INNER JOIN prod.datavault.sat_user_v2 sa
                              ON h.hub_user_key = sa.hub_user_key
                                  AND sa._latest
                   LEFT JOIN prod.datavault.sat_user_pii_v2 p
                             ON h.hub_user_key = p.hub_user_key
                                 AND p._latest
                   LEFT JOIN prod.datavault.sat_user_marketing_v2 usmar
                             ON h.hub_user_key = usmar.hub_user_key
                                 AND usmar._latest
      )
         , latest_institution AS (
          SELECT linkins.hub_user_key,
                 linkins.hub_institution_key,
                 ROW_NUMBER() OVER (PARTITION BY linkins.hub_user_key ORDER BY _ldts DESC ) = 1 AS latest
          FROM prod.datavault.link_user_institution linkins
      )
      SELECT hs.*
           , hubin.institution_id
           , satin.name               AS institution_name
           , usint.internal
           , COALESCE(bl.flag, FALSE) AS entity_flag
      FROM hub_sat_latest hs
               LEFT JOIN latest_institution linkins
                         ON hs.hub_user_key = linkins.hub_user_key -- 2486955
                             AND linkins.latest
               LEFT JOIN prod.datavault.hub_institution hubin
                         ON linkins.hub_institution_key = hubin.hub_institution_key
               LEFT JOIN prod.datavault.sat_institution_saws satin
                         ON hubin.hub_institution_key = satin.hub_institution_key
                             AND satin._latest
               LEFT JOIN prod.datavault.sat_user_internal usint ON hs.hub_user_key = usint.hub_user_key
          AND usint.active
               LEFT JOIN (SELECT entity_id,
                                 CAST(flag AS BOOLEAN)                                                         AS flag,
                                 ROW_NUMBER() OVER (PARTITION BY entity_id ORDER BY _fivetran_synced DESC) = 1 AS latest
                          FROM uploads.cu.entity_blacklist) bl
                         ON hubin.institution_id::STRING = bl.entity_id
                             AND bl.latest
      WHERE hs.latest_linked_account
  ;;

  sql_trigger_value: select count(*) from prod.datavault.sat_user_v2 ;;
  }

  measure: count {
    label: "# User Accounts"
    type: count
    drill_fields: [detail*]
    hidden: yes
    description: "Count of all user accounts, primary and secondary"
  }

  measure: users {
    label: "# Students"
    type: count_distinct
    sql: case when ${instructor_by_party}=false then ${merged_guid} end ;;
    drill_fields: [detail*]
    description: "Count of primary student user accounts"
  }

  measure: instructor_count {
    label: "# Instructors"
    type: count_distinct
    sql: case when ${instructor_by_party}=true then ${merged_guid} end ;;
    drill_fields: [detail*]
    description: "Count of primary instructor user accounts"
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
    description: "User birth year"
  }

  dimension: age {
    group_label: "Age"
    type: number
    sql: YEAR(CURRENT_DATE()) - ${birth_year} ;;
    description: "User age"
  }

  dimension: age_tiers {
    group_label: "Age"
    label: "Age (buckets)"
    type: tier
    tiers: [20, 25, 30, 35, 40, 45, 50, 55, 60]
    style: integer
    sql: ${age} ;;
    description: "User age (buckets)"
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
    sql: ${TABLE}.entity_flag ;;
    description: "This flag is Yes for users that attend institutions that do NOT allow their student's to receive IPMs. This means these institutions appear on IPM suppression lists which are lists of institutions (typically IA or CUI institutions) who have requested that their students do NOT receive in-platform messages (IPMs) related to CU upsell or conversion. This list is driven by a google sheet that can be found in the value of this field."
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
    description: "None of the following are found in any matching user records (matched by email address or merged guid if email is missing)
    - opt out flags
    - instructor flags
    - k12 flags
    - non-USA regions"
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
    hidden: no
  }

  dimension: institution_name {}

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
      institution_name,
      tl_institution_name,
      latest,
      user_sso_guid,
      merged_guid
    ]
  }

}
