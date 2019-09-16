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
            h.hub_user_key,h._ldts,h.uid as user_sso_guid,sa.linked_guid,coalesce(sa.linked_guid,h.uid) as merged_guid, sa.instructor,sa.k12
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
    sql: ${TABLE}."FIRST_NAME" ;;
    required_access_grants: [can_view_CU_pii_data]
  }

  dimension: last_name {
    group_label: "User Info - PII"
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
    required_access_grants: [can_view_CU_pii_data]
  }

  dimension: marketing_opt_out {
    type: string
    sql: ${TABLE}."MARKETING_OPT_OUT" ;;
  }

  dimension: marketing_allowed {
    label: "Marketing allowed"
    view_label: "** RECOMMENDED FILTERS **"
    type: yesno
    sql: ${marketing_opt_out} = 'false' OR  ${marketing_opt_out} IS NULL;;
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
#   sql_table_name: UPLOADS.CU.CU_USER_INFO ;;
#   derived_table: {
#     sql: Select cu.*,coalesce(bl.flag,'N') from UPLOADS.CU.CU_USER_INFO cu
#       LEFT JOIN UPLOADS.CU.ENTITY_BLACKLIST bl
#       ON bl.entity_id::STRING = cu.entity_id::STRING;;
#   }
#
#   dimension_group: cu_end_sso {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."CU_END_SSO" ;;
#     hidden: yes
#   }
#
#   filter: blacklist_flag {
#     label: "Entity Blacklist"
#     default_value: "N"
#   }
#
#   dimension_group: cu_start_sso {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}."CU_START_SSO" ;;
#     hidden: yes
#   }
#
#   dimension: cu_state_sso {
#     type: string
#     sql: ${TABLE}."CU_STATE_SSO" ;;
#     hidden: yes
#   }
#
#   dimension: email {
#     group_label: "User Info - PII"
#     type: string
#     sql:
#     CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
#     ${TABLE}.email
#     ELSE
#     MD5(${TABLE}.email || 'salt')
#     END ;;
#     html:
#     {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
#     {{ value }}
#     {% else %}
#     [Masked]
#     {% endif %}  ;;
#   }
#
#   dimension: entity_id {
#     type: number
#     sql: ${TABLE}."ENTITY_ID" ;;
#     hidden: yes
#   }
#
#   dimension: entity_name {
#     group_label: "User Info"
#     type: string
#     sql: ${TABLE}."ENTITY_NAME" ;;
#   }
#
#   dimension: first_name {
#     group_label: "User Info - PII"
#     type: string
#     sql: CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
#     ${TABLE}."FIRST_NAME"
#     ELSE
#     MD5(${TABLE}."FIRST_NAME" || 'salt')
#     END ;;
#     html:
#     {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
#     {{ value }}
#     {% else %}
#     [Masked]
#     {% endif %}  ;;
#   }
#
#   dimension: guid {
#     group_label: "User Info - PII"
#     type: string
#     sql: ${TABLE}."MERGED_GUID" ;;
#   }
#
#   dimension: merged_guid {
#     group_label: "PII"
#     type: string
#     hidden: yes
#   }
#
#   dimension: last_name {
#     group_label: "User Info - PII"
#     type: string
#     sql: CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
#     ${TABLE}."LAST_NAME"
#     ELSE
#     MD5(${TABLE}."LAST_NAME" || 'salt')
#     END ;;
#     html:
#     {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
#     {{ value }}
#     {% else %}
#     [Masked]
#     {% endif %}  ;;
#   }
#
#   dimension: original_guid {
#     group_label: "User Info - PII"
#     type: string
#     sql: ${TABLE}."GUID" ;;
#     hidden: yes
#   }
#
#   dimension: no_contact_user {
#     type: string
#     sql: ${TABLE}."NO_CONTACT_USER" ;;
#   }
#
#   dimension: opt_out {
#     type: string
#     sql: ${TABLE}."OPT_OUT" ;;
#   }
#
#   dimension: provided_paid {
#     type: string
#     sql: ${TABLE}."PROVIDED_PAID" ;;
#     hidden: yes
#   }
#
#   dimension: provided_status {
#     type: string
#     sql: ${TABLE}."PROVIDED_STATUS" ;;
#     hidden: yes
#   }
#
#   dimension: user_region {
#     type: string
#     sql: ${TABLE}."USER_REGION" ;;
#     hidden: yes
#   }
#
#   dimension: user_type {
#     type: string
#     sql: ${TABLE}."USER_TYPE" ;;
#     hidden: yes
#   }

#   measure: count {
#     type: count
#     drill_fields: [first_name, last_name, entity_name]
#   }
}
