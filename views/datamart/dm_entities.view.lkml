view: dm_entities {
  sql_table_name: DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_ENTITIES ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
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
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension_group: added_dt {
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
    sql: ${TABLE}."ADDED_DT" ;;
  }

  dimension_group: changed_dt {
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
    sql: ${TABLE}."CHANGED_DT" ;;
  }

  dimension: city_nm {
    type: string
    sql: ${TABLE}."CITY_NM" ;;
  }

  dimension: country_cd {
    type: string
    sql: ${TABLE}."COUNTRY_CD" ;;
  }

  dimension: country_de {
    type: string
    sql: ${TABLE}."COUNTRY_DE" ;;
  }

  dimension: county_nm {
    type: string
    sql: ${TABLE}."COUNTY_NM" ;;
  }

  dimension: cust_no {
    type: number
    sql: ${TABLE}."CUST_NO" ;;
  }

  dimension: district_nm {
    type: string
    sql: ${TABLE}."DISTRICT_NM" ;;
  }

  dimension: enrollment_no {
    type: number
    sql: ${TABLE}."ENROLLMENT_NO" ;;
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}."ENTITY_NO" ;;
  }

  dimension: entity_status {
    type: string
    sql: ${TABLE}."ENTITY_STATUS" ;;
  }

  dimension_group: entity_status_dt {
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
    sql: ${TABLE}."ENTITY_STATUS_DT" ;;
  }

  dimension: est_enrollment {
    type: number
    sql: ${TABLE}."EST_ENROLLMENT" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: mag_acct_id {
    type: string
    sql: ${TABLE}."MAG_ACCT_ID" ;;
  }

  dimension: mdr_no {
    type: string
    sql: ${TABLE}."MDR_NO" ;;
  }

  dimension: mdr_pop_served {
    type: number
    sql: ${TABLE}."MDR_POP_SERVED" ;;
  }

  dimension: mkt_seg_maj_cd {
    type: string
    sql: ${TABLE}."MKT_SEG_MAJ_CD" ;;
  }

  dimension: mkt_seg_maj_de {
    type: string
    sql: ${TABLE}."MKT_SEG_MAJ_DE" ;;
  }

  dimension: mkt_seg_min_cd {
    type: number
    sql: ${TABLE}."MKT_SEG_MIN_CD" ;;
  }

  dimension: mkt_seg_min_de {
    type: string
    sql: ${TABLE}."MKT_SEG_MIN_DE" ;;
  }

  dimension: postal_code {
    type: number
    sql: ${TABLE}."POSTAL_CODE" ;;
  }

  dimension: previous_id {
    type: string
    sql: ${TABLE}."PREVIOUS_ID" ;;
  }

  dimension: state_cd {
    type: string
    sql: ${TABLE}."STATE_CD" ;;
  }

  dimension: state_de {
    type: string
    sql: ${TABLE}."STATE_DE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
