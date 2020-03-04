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

  dimension: cu_expiration_date {
    type: date
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

  dimension: cu_activated_date {
    type: date
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

  dimension_group: seat_used {
    type: time
    timeframes: [time, date]
    sql: ${TABLE}."SEAT_USED_DATE";;
  }

  measure: distinct_CU_enrollments_during_full_access_period {
    label: "Distinct CU Enrollments During Full Access Period"
    type: count_distinct
    sql: CASE WHEN ${seat_used_date} >= ${cu_activated_date}
    and ${seat_used_date} < ${cu_expiration_date}
    and ${contract_id} is not null
    and ${contract_id} != 'TRIAL'
    THEN ${cu_guid}
    END ;;
  }

  measure: distinct_trial_students {
    type: count_distinct
    sql: CASE WHEN ${contract_id} = 'TRIAL'
          THEN ${cu_guid}
          END ;;
  }

  measure: sum__of_full_access_and_trial {
    type: count_distinct
    sql: CASE WHEN ${seat_used_date} >= ${cu_activated_date}
    and ${seat_used_date} < ${cu_expiration_date}
    and ${contract_id} is not null
    or ${contract_id} = 'TRIAL'
    THEN ${cu_guid}
    END ;;
  }

  measure: enrollment_within_30_days{
    label: "Enrollment Within 30 Days Prior To CU Activation"
    type: count_distinct
    sql: CASE WHEN ${seat_used_date} < ${cu_activated_date}
    and ${seat_used_date} > DATEADD('day', -30, ${cu_activated_date})
    and ${contract_id} is not null
    and ${contract_id} != 'TRIAL'
    THEN ${cu_guid}
    END ;;
  }

}
