view: salesforce_support_calls {
  derived_table: {
    sql:
      select distinct
        coalesce(hu.linked_guid, s.contact_guid_c) as merged_guid
        , "CASE_NUMBER"
        , "CREATED_DATE"
        , "ACCOUNT_NAME"
        , "ACCOUNT_ENTITYNUMBER_C"
        , "PRIMARY_ISSUES_C"
        , "PLATFORM_SERVICES_C"
        , "SECONDARY_ISSUES_C"
        , "IR_CODE_C"
        , "JIRA_TICKET_ID_C"
        , "CLOSED_DATE"
        , "DESCRIPTION"
        , "_FIVETRAN_SYNCED"
        , "CONTACT_GUID_C"
      from UPLOADS."SUPPORT"."FALL19TOFALL20SUPPORT" s
      left join (
        select hu.uid, su.linked_guid
        from prod.datavault.hub_user hu
        inner join prod.datavault.sat_user_v2 su on su.hub_user_key = hu.hub_user_key and su._latest
      ) hu on hu.uid = s.contact_guid_c
      ;;
      persist_for: "8 hours"
  }

  # sql_table_name: UPLOADS."SUPPORT"."FALL19TOFALL20SUPPORT" ;;


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
  }

  dimension: account_entitynumber_c {
    type: number
    sql: ${TABLE}."ACCOUNT_ENTITYNUMBER_C" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: case_number {
    type: number
    sql: ${TABLE}."CASE_NUMBER" ;;
    primary_key: yes
  }

  dimension_group: closed {
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
    sql: CAST(${TABLE}."CLOSED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: created {
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
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: to_resolution {
    type: duration
    intervals: [hour, day, week, month]
    sql_start: ${created_raw} ;;
    sql_end: ${closed_raw} ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: ir_code_c {
    type: string
    sql: ${TABLE}."IR_CODE_C" ;;
  }

  dimension: jira_ticket_id_c {
    type: string
    sql: ${TABLE}."JIRA_TICKET_ID_C" ;;
  }

  dimension: platform_services_c {
    type: string
    sql: ${TABLE}."PLATFORM_SERVICES_C" ;;
  }

  dimension: primary_issues_c {
    type: string
    sql: ${TABLE}."PRIMARY_ISSUES_C" ;;
  }

  dimension: secondary_issues_c {
    type: string
    sql: ${TABLE}."SECONDARY_ISSUES_C" ;;
  }

  dimension: contact_guid_c {
    type: string
    sql: ${TABLE}."CONTACT_GUID_C" ;;
    hidden: yes
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}.merged_guid ;;
  }

  measure: count {
    type: count
    drill_fields: [account_name]
  }
}
