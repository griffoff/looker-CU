include: "./live_subscription_status.view"
include: "./institution_info.view"

explore: user_profile {
  view_label: "User Details"
  hidden:yes

  always_filter: {
    filters: [user_profile.is_real_user: "Yes"]
  }

  join: live_subscription_status {
    sql_on:  ${user_profile.user_sso_guid} = ${live_subscription_status.merged_guid}  ;;
    relationship: one_to_one
  }

  join: user_institution_info {
    from: institution_info
    view_label: "User Institution Details"
    sql_on: ${user_profile.institution_id} = ${user_institution_info.institution_id} ;;
    relationship: many_to_one
  }
}

view: user_profile {
  derived_table: {
    sql:
      WITH party AS (
        SELECT
          hu.hub_user_key
          , COALESCE(su.linked_guid, hu.uid) AS merged_guid
          , COUNT(DISTINCT sup.email) OVER (PARTITION BY merged_guid) = 1 AS single_email
          , CASE
            WHEN single_email
            THEN LAST_VALUE(sup.email) IGNORE NULLS OVER (PARTITION BY merged_guid ORDER BY sup._effective_from)
            ELSE merged_guid
          END AS party_identifier
          , CASE
            WHEN NOT single_email
            THEN email
            ElSE MAX(email) OVER (PARTITION BY merged_guid)
          END AS merged_guid_email
        FROM prod.datavault.hub_user hu
        LEFT JOIN prod.datavault.sat_user_v2 su ON hu.hub_user_key = su.hub_user_key AND su._latest
        LEFT JOIN prod.datavault.sat_user_pii_v2 sup ON hu.hub_user_key = sup.hub_user_key AND sup._latest
      )
      , party_flags AS (
        SELECT
          hu.uid AS user_sso_guid
          , su.linked_guid
          , account_type
          , instructor
          , MAX(INSTRUCTOR) OVER (PARTITION BY p.party_identifier) AS instructor_by_party
          , COALESCE(k12, FALSE) AS k12_flag
          , MAX(k12_flag) OVER (PARTITION BY p.party_identifier) AS k12_by_party
          , country
          , NULLIF(TRIM(region), '') AS user_region
          , COALESCE(country <> 'US' OR user_region <> 'USA', FALSE) AS non_usa_flag
          , MAX(non_usa_flag) OVER (PARTITION BY p.party_identifier) AS non_usa_by_party
          , NULLIF(TRIM(user_timezone), '') AS user_timezone
          , COALESCE(sui.internal, FALSE) AS internal
          , lui.institution_id
          , COALESCE(bl.flag, FALSE) AS entity_blacklist_flag
          , sup.first_name
          , sup.last_name
          , p.merged_guid_email AS email
          , MAX(
            CASE
              WHEN try_cast(sup.birth_year AS INTEGER) BETWEEN '1900' AND YEAR(DATEADD(YEAR, -4, CURRENT_DATE))
              THEN try_cast(sup.BIRTH_YEAR AS INTEGER)
            END
          ) OVER (PARTITION BY party_identifier) AS birth_year
          , sup.postal_code
          , CASE WHEN account_type = 'linkedgateway' THEN FALSE ELSE COALESCE(sum.opt_out, TRUE) END AS marketing_opt_out
          , MAX(marketing_opt_out) OVER (PARTITION BY p.party_identifier) AS marketing_opt_out_by_party
        FROM prod.datavault.hub_user hu
        INNER JOIN party p ON p.hub_user_key = hu.hub_user_key
        INNER JOIN prod.datavault.sat_user_v2 su ON su.hub_user_key = hu.hub_user_key AND su._latest
        LEFT JOIN prod.datavault.sat_user_internal sui ON sui.hub_user_key = hu.hub_user_key AND sui.active
        LEFT JOIN prod.datavault.sat_user_pii_v2 sup ON sup.hub_user_key = hu.hub_user_key AND sup._latest
        LEFT JOIN (
          SELECT lui.hub_user_key, hi.institution_id
          FROM prod.datavault.link_user_institution lui
          INNER JOIN prod.datavault.sat_user_institution sui ON sui.link_user_institution_key = lui.link_user_institution_key AND sui.active
          INNER JOIN prod.datavault.hub_institution hi ON hi.hub_institution_key = lui.hub_institution_key
          INNER JOIN prod.datavault.sat_institution_saws sis ON sis.hub_institution_key = hi.hub_institution_key
        ) lui ON lui.hub_user_key = hu.hub_user_key
        LEFT JOIN (
          SELECT entity_id
          , CAST(flag AS BOOLEAN) AS flag
          , ROW_NUMBER() OVER (PARTITION BY entity_id ORDER BY _fivetran_synced DESC) = 1 AS latest
          FROM uploads.cu.entity_blacklist
        ) bl ON lui.institution_id = bl.entity_id AND bl.latest
        LEFT JOIN prod.datavault.sat_user_marketing_v2 sum ON sum.hub_user_key = hu.hub_user_key AND sum._latest
      )
      SELECT
      p.*
        , ARRAY_AGG(DISTINCT lg.uid) AS shadow_guids
        , MIN(SESSION_START) AS first_session
        , MAX(SESSION_START) AS latest_session
      FROM party_flags p
      LEFT JOIN (
        SELECT DISTINCT uid, linked_guid
        FROM prod.datavault.hub_user hu
        INNER JOIN prod.datavault.sat_user_v2 su ON su.hub_user_key = hu.hub_user_key
      ) lg ON lg.linked_guid = p.user_sso_guid
      LEFT JOIN prod.cu_user_analysis.all_sessions s ON s.user_sso_guid = p.user_sso_guid
      LEFT JOIN prod.cu_user_analysis.lp_control_group lcg on lcg.user_sso_guid = p.user_sso_guid
      WHERE p.linked_guid IS NULL
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22
    ;;

    sql_trigger_value: select count(*) from prod.datavault.sat_user_v2 ;;
  }

  dimension: user_sso_guid {
    primary_key: yes
    description:"Primary account guid (not shadow guid)"
    }

  dimension: account_type {hidden:yes}

  dimension: is_instructor {
    type: yesno
    description: "User account is currently flagged as an instructor"
    group_label: "User Flags"
    sql: ${TABLE}.instructor ;;
    alias: [instructor]
    }

  dimension: is_instructor_by_party {
    group_label: "Party flags"
    label: "Has Instructor User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with an Instructor flag"
    type: yesno
    hidden: yes
    alias: [instructor_by_party]
    sql: ${TABLE}.instructor_by_party ;;
    }

  dimension: is_k12 {
    type: yesno
    description: "User account is currently flagged as a K12 customer"
    group_label: "User Flags"
    alias: [k12_user, k12_flag]
    sql: ${TABLE}.k12_flag ;;
    }

  dimension: is_k12_by_party {
    group_label: "Party flags"
    label: "Has K12 User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with a K12 flag"
    type: yesno
    hidden: yes
    alias: [k12_by_party]
    sql: ${TABLE}.k12_by_party ;;
    }

  dimension: country {
    group_label: "User Info - PII"
    description: "User country"
  }

  dimension: user_region {
    group_label: "User Info - PII"
    description: "User region"
  }

  dimension: is_non_usa {
    type: yesno
    description: "User account currently has a non-USA country or region"
    group_label: "User Flags"
    alias: [non_usa_flag]
    sql: ${TABLE}.non_usa_flag ;;
    }

  dimension: is_non_usa_by_party {
    group_label: "Party flags"
    label: "Has Non-USA User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with a non-USA country or region"
    type: yesno
    hidden: yes
    alias: [non_usa_by_party]
    sql: ${TABLE}.non_usa_by_party ;;
    }

  dimension: user_timezone {
    group_label: "User Info - PII"
    description: "User local timezone"
    hidden: yes
  }

  dimension: is_internal {
    type: yesno
    hidden: yes
    alias: [internal, internal_user_flag]
    sql: ${TABLE}.internal ;;
  }

  dimension: is_real_user {
    view_label: "** RECOMMENDED FILTERS **"
    description: "Users who are not flagged as internal (e.g. QA)"
    label: "Real User Flag"
    type: yesno
    sql: NOT ${TABLE}.internal;;
    alias: [real_user_flag]
  }

  dimension: institution_id {
    description: "Entity ID of user home institution"
    hidden: yes
  }

  dimension: is_entity_blacklisted {
    type: yesno
    label: "Is IPM Blacklist Institution User"
    description: "This flag is Yes for users that attend institutions that do NOT allow their student's to receive IPMs. This means these institutions appear on IPM suppression lists which are lists of institutions (typically IA or CUI institutions) who have requested that their students do NOT receive in-platform messages (IPMs) related to CU upsell or conversion. This list is driven by a google sheet that can be found in the value of this field."
    link: {
      label: "IPM suppression list google sheet"
      url: "https://docs.google.com/spreadsheets/d/1GWByyBwWhMX-aXEzYqeHe_p-wCRsiwCMMPn_SyrzpWk/edit#gid=0"
    }
    group_label: "User Flags"
    alias: [entity_blacklist_flag]
    sql: ${TABLE}.entity_blacklist_flag ;;
  }

  dimension: first_name {
    group_label: "User Info - PII"
    type: string
    sql: InitCap(${TABLE}.first_name);;
    required_access_grants: [can_view_CU_pii_data]
    description: "User first name"
  }

  dimension: last_name {
    group_label: "User Info - PII"
    type: string
    sql: InitCap(${TABLE}.last_name) ;;
    required_access_grants: [can_view_CU_pii_data]
    description: "User last name"
  }

  dimension: email {
    group_label: "User Info - PII"
    type: string
    required_access_grants: [can_view_CU_pii_data]
    description: "User email address"
  }

    dimension: birth_year {
      group_label: "Age"
      label: "Birth Year"
      type: number
      value_format: "0000"
      description: "User birth year"
      hidden: yes
    }

    dimension: age {
      group_label: "Age"
      type: number
      sql: YEAR(CURRENT_DATE()) - ${birth_year} ;;
      description: "User age"
      hidden: no
    }

    dimension: age_tiers {
      group_label: "Age"
      label: "Age (buckets)"
      type: tier
      tiers: [20, 25, 30, 35, 40, 45, 50, 55, 60]
      style: integer
      sql: ${age} ;;
      description: "User age (buckets)"
      hidden: no
    }

  dimension: postal_code {
    group_label: "User Info - PII"
    description: "User postal code"
    hidden: yes
  }

  dimension: marketing_opt_out {
    type: yesno
    hidden:yes
  }

  dimension: marketing_opt_out_by_party {
    group_label: "Party flags"
    label: "Has Opt-Out User Record"
    description: "Indicates whether this user has any other record (matched by email or merged guid) with an Opt-out flag"
    type: yesno
    hidden: yes
    }

  dimension: is_marketing_allowed {
    label: "Marketing allowed"
    description: "Based on the opt out flag - if it is set to false or null then marketing is allowed"
    view_label: "** RECOMMENDED FILTERS **"
    type: yesno
    sql: NOT ${TABLE}.marketing_opt_out;;
    alias: [marketing_allowed]
  }

  dimension: shadow_guids {
    description: "Array containing any non-primary guids for the user"
  }

  dimension_group: first_session {
    type: time
    timeframes: [raw, time, date, week, month, year]
    description: "Timestamp of users first session"
  }

  dimension_group: latest_session {
    type: time
    timeframes: [raw, time, date, week, month, year]
    description: "Timestamp of users most recent session"
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
    sql: NOT ${marketing_opt_out_by_party}AND NOT ${is_k12_by_party} AND NOT ${is_instructor_by_party} AND NOT ${is_non_usa_by_party};;
  }

  dimension: control_flag_1 {
    type: number
    label: "Control flag 1"
    hidden: yes
    group_label: "Marketing control flags"
    description: "Control flag used to conduct control/treatment testing for marketing campaigns"
    sql: ${TABLE}."CONTROL_FLAG_1";;
  }

  dimension: email_control_flag {
    type: string
    label: "Control flag Email"
    group_label: "Marketing control flags"
    description: "Control flag used to conduct control/treatment testing for marketing campaigns"
    sql:
          CASE
              WHEN ${TABLE}."CONTROL_FLAG_1" < 85 THEN 'Usage and conversion'
              WHEN ${TABLE}."CONTROL_FLAG_1" BETWEEN 85 AND 90 THEN 'Conversion only'
              WHEN ${TABLE}."CONTROL_FLAG_1" BETWEEN 90 and 95 THEN  'Usage only'
              WHEN ${TABLE}."CONTROL_FLAG_1" BETWEEN 95 and 100 THEN 'Hold Out'
              WHEN ${TABLE}."CONTROL_FLAG_1" = 999 THEN 'pre control/test tracking'
              ELSE 'No group' END
            ;;
  }



  dimension: control_flag_2 {
    type: number
    label: "Control flag 2"
    group_label: "Marketing control flags"
    description: "Control flag used to conduct control/treatment testing for marketing campaigns"
    sql: ${TABLE}."CONTROL_FLAG_2";;
    hidden: yes
  }

  dimension: ipm_control_flag {
    type: string
    label: "Control flag IPM"
    group_label: "Marketing control flags"
    description: "Control flag used to conduct control/treatment testing for marketing campaigns"
    sql:
          CASE
              WHEN ${TABLE}."CONTROL_FLAG_2" < 85 THEN 'Usage and conversion'
              WHEN ${TABLE}."CONTROL_FLAG_2" BETWEEN 85 AND 90 THEN 'Conversion only'
              WHEN ${TABLE}."CONTROL_FLAG_2" BETWEEN 90 and 95 THEN  'Usage only'
              WHEN ${TABLE}."CONTROL_FLAG_2" BETWEEN 95 and 100 THEN 'Hold Out'
              WHEN ${TABLE}."CONTROL_FLAG_2" = 999 THEN 'pre control/test tracking'
              ELSE 'No group' END
    ;;
  }


  dimension: control_flag_3 {
    type: number
    label: "Randomization flag"
    group_label: "Marketing control flags"
    description: "Control flag used to conduct control/treatment testing for marketing campaigns"
    sql: ${TABLE}."CONTROL_FLAG_3";;
    hidden: no
  }

  dimension: control_flag_4 {
    type: number
    label: "Control flag 4"
    group_label: "Marketing control flags"
    description: "Control flag used to conduct control/treatment testing for marketing campaigns"
    sql: ${TABLE}."CONTROL_FLAG_4";;
    hidden: yes
  }

  dimension: control_flag_5 {
    type: number
    label: "Control flag 5"
    group_label: "Marketing control flags"
    description: "Control flag used to conduct control/treatment testing for marketing campaigns"
    sql: ${TABLE}."CONTROL_FLAG_5";;
    hidden: yes
  }

  measure: count {
    label: "# Users"
    type: count
    description: "Count of primary user accounts, instructors and students"
    drill_fields: [detail*]
  }

  measure: student_count {
    label: "# Students"
    type: count_distinct
    sql: case when not ${TABLE}.instructor_by_party then ${TABLE}.user_sso_guid end;;
    description: "Count of primary student user accounts"
    drill_fields: [detail*]
  }

  measure: instructor_count {
    label: "# Instructors"
    type: count_distinct
    sql: case when ${TABLE}.instructor_by_party then ${TABLE}.user_sso_guid end;;
    description: "Count of primary instructor user accounts"
    drill_fields: [detail*]
  }

  measure: age_average {
    group_label: "Age"
    label: "Average Age"
    type: average
    sql: ${age} ;;
    value_format: "0.0"
    description: "Average user age (inc. students, instructors, etc.)"
  }

  set: detail {
    fields: [
      user_sso_guid,
      is_instructor,
      is_k12,
      country,
      user_region,
      institution_id,
      first_session_time,
      latest_session_time
    ]
  }

}
