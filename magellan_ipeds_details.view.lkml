view: magellan_ipeds_details {
  derived_table: {
    sql: Select * from uploads.magellan_uploads.ipeds_details
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
    hidden: yes
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
    hidden: yes
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}."ENTITY_NO" ;;
    hidden: yes
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: ipeds_id_ {
    type: number
    sql: ${TABLE}."IPEDS_ID_" ;;
  }

  dimension: ipeds_name {
    type: string
    sql: ${TABLE}."IPEDS_NAME" ;;
  }

  dimension: ipeds_book_supplies_fee {
    type: number
    sql: ${TABLE}."IPEDS_BOOK_SUPPLIES_FEE" ;;
  }

  dimension: ipeds_zip {
    type: string
    sql: ${TABLE}."IPEDS_ZIP" ;;
  }

  dimension: ipeds_of_students_receiving_aid {
    type: string
    sql: ${TABLE}."IPEDS_OF_STUDENTS_RECEIVING_AID" ;;
  }

  dimension: ipeds_total_financial_dollars {
    type: string
    sql: ${TABLE}."IPEDS_TOTAL_FINANCIAL_DOLLARS" ;;
  }

  dimension: ipeds_average_financial_aid_dollars {
    type: string
    sql: ${TABLE}."IPEDS_AVERAGE_FINANCIAL_AID_DOLLARS" ;;
  }

  dimension: account_type_2_4_ {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE_2_4_" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    hidden: yes
  }

  set: detail {
    fields: [
      _file,
      _line,
      entity_no,
      institution_nm,
      ipeds_id_,
      ipeds_name,
      ipeds_book_supplies_fee,
      ipeds_zip,
      ipeds_of_students_receiving_aid,
      ipeds_total_financial_dollars,
      ipeds_average_financial_aid_dollars,
      account_type_2_4_,
      _fivetran_synced_time
    ]
  }
}
