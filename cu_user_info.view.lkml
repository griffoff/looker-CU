explore: cu_user_info {label: "CU User Info"}

view: cu_user_info {

  derived_table: {
    sql: WITH raw AS (
          SELECT
            COALESCE(linked_guid,user_sso_guid) as primary_guid
            ,user_sso_guid as partner_guid
            ,event_time
              ,email
             ,first_name
              ,last_name
              ,tl_institution_id
              ,tl_institution_name
              ,marketing_opt_out
              ,k12_user
          FROM IAM.PROD.USER_MUTATION
        )
      , temp_table as (SELECT
         *
          ,primary_guid as merged_guid
          ,LEAD(event_time) OVER (PARTITION BY primary_guid ORDER BY event_time ASC) IS NULL AS latest
      FROM raw
      ), old_tab as (
        Select distinct merged_guid,bl.entity_id,coalesce(bl.flag,'N') as entity_flag from UPLOADS.CU.CU_USER_INFO cu
       LEFT JOIN UPLOADS.CU.ENTITY_BLACKLIST bl
       ON bl.entity_id::STRING = cu.entity_id::STRING
      ) select t.*,o.entity_id,coalesce(entity_flag,'N') as entity_flag from temp_table t
        LEFT JOIN old_tab o
        ON t.merged_guid=o.merged_guid
        where t.latest
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: primary_guid {
    type: string
    sql: ${TABLE}."PRIMARY_GUID" ;;
    hidden: yes
  }

  dimension: entity_flag {
    label: "Entity Blacklist"
    sql: ${TABLE}.entity_flag ;;
  }

  dimension: k12_user {
    label: "K12 User"
    description: "Data field to identify K12 customer"
    type: yesno
    sql: ${TABLE}.k12_user ;;
  }


  dimension: partner_guid {
    type: string
    sql: ${TABLE}."PARTNER_GUID" ;;
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
  }

  dimension: first_name {
    group_label: "User Info - PII"
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    group_label: "User Info - PII"
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: marketing_opt_out {
    type: string
    sql: ${TABLE}."MARKETING_OPT_OUT" ;;
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}."TL_INSTITUTION_ID" ;;
    hidden: yes
  }

  dimension: tl_institution_name {
    type: string
    sql: ${TABLE}."TL_INSTITUTION_NAME" ;;
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
