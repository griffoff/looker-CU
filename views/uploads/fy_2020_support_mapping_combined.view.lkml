explore: fy_2020_support_mapping_combined {hidden:yes}
view: fy_2020_support_mapping_combined {
  derived_table: {
    sql:
    select s.*
      , coalesce(su.linked_guid,s.contact_guid) as merged_contact_guid
    from "UPLOADS"."SUPPORT"."FY_2020_SUPPORT_MAPPING_COMBINED" s
    left join prod.datavault.hub_user hu on hu.uid = s.contact_guid
    left join prod.datavault.sat_user_v2 su on su.hub_user_key = hu.hub_user_key and su._latest
    ;;
    persist_for: "8 hours"
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
    hidden: yes
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: case_number {
    type: string
    sql: ${TABLE}."CASE_NUMBER" ;;
    primary_key: yes
  }

  dimension: case_origin {
    type: string
    sql: ${TABLE}."CASE_ORIGIN" ;;
  }

  dimension: case_timer {
    type: string
    sql: ${TABLE}."CASE_TIMER" ;;
  }

  dimension: contact_email {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL" ;;
  }

  dimension: contact_guid {
    type: string
    sql: ${TABLE}."CONTACT_GUID" ;;
    hidden: yes
  }

  dimension: merged_contact_guid {
    type: string
    sql: ${TABLE}."MERGED_CONTACT_GUID" ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_type {
    type: string
    sql: ${TABLE}."CONTACT_TYPE" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: date_time_opened {
    type: string
    sql: ${TABLE}."DATE_TIME_OPENED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: entitynumber {
    type: string
    sql: ${TABLE}."ENTITYNUMBER" ;;
  }

  dimension: ir_code {
    type: string
    sql: ${TABLE}."IR_CODE" ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}."ISBN" ;;
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}."ISSUE_TYPE" ;;
  }

  dimension: jira_description {
    type: string
    sql: ${TABLE}."JIRA_DESCRIPTION" ;;
  }

  dimension: jira_escalated {
    type: number
    sql: ${TABLE}."JIRA_ESCALATED" ;;
  }

  dimension: jira_ticket_id {
    type: string
    sql: ${TABLE}."JIRA_TICKET_ID" ;;
  }

  dimension: lms_subcategory {
    type: string
    sql: ${TABLE}."LMS_SUBCATEGORY" ;;
  }

  dimension: magellan_opportunity_id {
    type: number
    sql: ${TABLE}."MAGELLAN_OPPORTUNITY_ID" ;;
  }

  dimension: persona_type {
    type: string
    sql: ${TABLE}."PERSONA_TYPE" ;;
  }

  dimension: personas {
    type: string
    sql: ${TABLE}."PERSONAS" ;;
  }

  dimension: platform_service {
    type: string
    sql: ${TABLE}."PLATFORM_SERVICE" ;;
  }

  dimension: primary_issue {
    type: string
    sql: ${TABLE}."PRIMARY_ISSUE" ;;
  }

  dimension: purchase_path {
    type: string
    sql: ${TABLE}."PURCHASE_PATH" ;;
  }

  dimension: refund_isbn {
    type: string
    sql: ${TABLE}."REFUND_ISBN" ;;
  }

  dimension: refund_order_number {
    type: string
    sql: ${TABLE}."REFUND_ORDER_NUMBER" ;;
  }

  dimension: was_refund_provided_ {
    type: string
    sql: ${TABLE}."WAS_REFUND_PROVIDED_" ;;
  }

  measure: count {
    type: count
    drill_fields: [contact_name, account_name]
    label: "# Support Cases"
  }
}
