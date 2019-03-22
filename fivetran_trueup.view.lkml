view: fivetran_trueup {
  sql_table_name: UPLOADS.TRUEUP_ALL.FIVETRAN_TRUEUP ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
    hidden:  yes
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
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    hidden:  yes
  }

  dimension: _row {
    type: string
    sql: ${TABLE}."_ROW" ;;
    hidden:  yes
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  dimension: cu_guid {
    type: string
    sql: ${TABLE}."CU_GUID" ;;
  }

  dimension: cu_isbn {
    type: string
    sql: ${TABLE}."CU_ISBN" ;;
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}."ENTITY_ID" ;;
  }

  dimension: expiration_date {
    type: string
    sql: ${TABLE}."EXPIRATION_DATE" ;;
  }

  dimension: license {
    type: string
    sql: ${TABLE}."LICENSE" ;;
  }

  dimension: license_created {
    type: string
    sql: ${TABLE}."LICENSE_CREATED" ;;
  }

  dimension: license_isbn {
    type: string
    sql: ${TABLE}."LICENSE_ISBN" ;;
  }

  dimension: license_updated {
    type: string
    sql: ${TABLE}."LICENSE_UPDATED" ;;
  }

  dimension: saws_entity_name {
    type: string
    sql: ${TABLE}."SAWS_ENTITY_NAME" ;;
  }

  dimension: seat_guid {
    type: string
    sql: ${TABLE}."SEAT_GUID" ;;
  }

  dimension: seat_used_date {
    type: string
    sql: ${TABLE}."SEAT_USED_DATE" ;;
  }

  dimension: start_date {
    type: string
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: student_entity {
    type: string
    sql: ${TABLE}."STUDENT_ENTITY" ;;
  }

  dimension: student_institution {
    type: string
    sql: ${TABLE}."STUDENT_INSTITUTION" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [saws_entity_name]
  }

  measure: count_of_unique_contract_ids {
    type: count_distinct
    sql: ${contract_id} ;;
  }

  measure: count_of_unique_seat_guids {
    type: count_distinct
    sql: ${seat_guid} ;;
  }

}
