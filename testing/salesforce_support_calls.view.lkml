include: "//cube/dim_institution.view"
include: "/views/cu_user_analysis/gateway_institution.view"
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

}

view: salesforce_support_calls {
  sql_table_name: UPLOADS."SUPPORT"."FALL19TOFALL20SUPPORT"
    ;;

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

  measure: count {
    type: count
    drill_fields: [account_name]
  }
}
