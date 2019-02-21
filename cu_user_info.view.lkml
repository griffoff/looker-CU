explore: cu_user_info {label: "CU User Info"}

view: cu_user_info {
#   sql_table_name: UPLOADS.CU.CU_USER_INFO ;;
  derived_table: {
    sql: Select cu.*,coalesce(bl.flag,'N') from UPLOADS.CU.CU_USER_INFO cu
      LEFT JOIN UPLOADS.CU.ENTITY_BLACKLIST bl
      ON bl.entity_id::STRING = cu.entity_id::STRING;;
  }

  dimension_group: cu_end_sso {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CU_END_SSO" ;;
    hidden: yes
  }

  filter: blacklist_flag {
    label: "Entity Blacklist"
    default_value: "N"
  }

  dimension_group: cu_start_sso {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CU_START_SSO" ;;
    hidden: yes
  }

  dimension: cu_state_sso {
    type: string
    sql: ${TABLE}."CU_STATE_SSO" ;;
    hidden: yes
  }

  dimension: email {
    group_label: "User Info - PII"
    type: string
    sql:
    CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
    ${TABLE}.email
    ELSE
    MD5(${TABLE}.email || 'salt')
    END ;;
    html:
    {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
    {{ value }}
    {% else %}
    [Masked]
    {% endif %}  ;;
  }

  dimension: entity_id {
    type: number
    sql: ${TABLE}."ENTITY_ID" ;;
    hidden: yes
  }

  dimension: entity_name {
    group_label: "User Info"
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
  }

  dimension: first_name {
    group_label: "User Info - PII"
    type: string
    sql: CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
    ${TABLE}."FIRST_NAME"
    ELSE
    MD5(${TABLE}."FIRST_NAME" || 'salt')
    END ;;
    html:
    {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
    {{ value }}
    {% else %}
    [Masked]
    {% endif %}  ;;
  }

  dimension: guid {
    group_label: "User Info - PII"
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: merged_guid {
    group_label: "PII"
    type: string
    hidden: yes
  }

  dimension: last_name {
    group_label: "User Info - PII"
    type: string
    sql: CASE WHEN '{{ _user_attributes["pii_visibility_enabled"] }}' = 'yes' THEN
    ${TABLE}."LAST_NAME"
    ELSE
    MD5(${TABLE}."LAST_NAME" || 'salt')
    END ;;
    html:
    {% if _user_attributes["pii_visibility_enabled"]  == 'yes' %}
    {{ value }}
    {% else %}
    [Masked]
    {% endif %}  ;;
  }

  dimension: original_guid {
    group_label: "User Info - PII"
    type: string
    sql: ${TABLE}."GUID" ;;
    hidden: yes
  }

  dimension: no_contact_user {
    type: string
    sql: ${TABLE}."NO_CONTACT_USER" ;;
  }

  dimension: opt_out {
    type: string
    sql: ${TABLE}."OPT_OUT" ;;
  }

  dimension: provided_paid {
    type: string
    sql: ${TABLE}."PROVIDED_PAID" ;;
    hidden: yes
  }

  dimension: provided_status {
    type: string
    sql: ${TABLE}."PROVIDED_STATUS" ;;
    hidden: yes
  }

  dimension: user_region {
    type: string
    sql: ${TABLE}."USER_REGION" ;;
    hidden: yes
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
    hidden: yes
  }

#   measure: count {
#     type: count
#     drill_fields: [first_name, last_name, entity_name]
#   }
}
