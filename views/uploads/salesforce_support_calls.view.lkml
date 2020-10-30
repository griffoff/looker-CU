include: "//cube/dim_institution.view"
include: "/views/cu_user_analysis/*.view"
explore: salesforce_support_calls {
  join: dim_institution {
    sql_on: ${salesforce_support_calls.account_entitynumber_c}::STRING = ${dim_institution.entity_no}::STRING ;;
    relationship: many_to_one
  }
  join: gateway_institution {
    view_label: "Institution"
    sql_on: ${dim_institution.entity_no}::STRING = ${gateway_institution.entity_no};;
    relationship: many_to_one
  }
  join: user_products {
    view_label: "User Products"
    sql_on: ${user_products.merged_guid} = ${salesforce_support_calls.merged_guid} and ${salesforce_support_calls.created_raw}::date between ${user_products.added_raw}::date and coalesce(${user_products.expiration_raw},current_date)::date;;
    relationship: many_to_many
  }
  join: stg_clts_products {
    view_label: "Product Details"
    sql_on: ${stg_clts_products.isbn13} = ${user_products.isbn13} ;;
    relationship: many_to_one
  }
  join: sap_subscriptions {
    view_label: "Subscription"
    sql_on: ${salesforce_support_calls.merged_guid} = ${sap_subscriptions.merged_guid} and ${salesforce_support_calls.created_raw} between ${sap_subscriptions.subscription_start_raw} and coalesce(${sap_subscriptions.cancelled_raw},${sap_subscriptions.subscription_end_raw}) ;;
    relationship: many_to_many
  }

}

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
