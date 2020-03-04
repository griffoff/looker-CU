view: cu_product_category {
  derived_table: {
    sql: Select * from UPLOADS.CU.CU_PRODUCTS_CATEGORY
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: _fivetran_deleted {
    type: string
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
    hidden: yes
  }

  dimension: isbn_13 {
    type: number
    sql: ${TABLE}."ISBN_13" ;;
  }

  dimension: author {
    type: string
    sql: ${TABLE}."AUTHOR" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: edition {
    type: number
    sql: ${TABLE}."EDITION" ;;
  }

  dimension: pub_co {
    type: string
    sql: ${TABLE}."PUB_CO" ;;
  }

  dimension: prd_grp {
    type: string
    sql: ${TABLE}."PRD_GRP" ;;
  }

  dimension: pfc {
    type: string
    sql: ${TABLE}."PFC" ;;
  }

  dimension: rghts {
    type: number
    sql: ${TABLE}."RGHTS" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: cy {
    type: number
    sql: ${TABLE}."CY" ;;
  }

  dimension: custom {
    type: string
    sql: ${TABLE}."CUSTOM" ;;
  }

  dimension: tpc {
    type: string
    sql: ${TABLE}."TPC" ;;
  }

  dimension: duration {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }

  dimension: section_code_concat {
    type: string
    sql: ${TABLE}."SECTION_CODE_CONCAT" ;;
  }

  dimension: discipline_concat {
    type: string
    sql: ${TABLE}."DISCIPLINE_CONCAT" ;;
  }

  dimension: subject_code_concat {
    type: string
    sql: ${TABLE}."SUBJECT_CODE_CONCAT" ;;
  }

  dimension: topic_code_concat {
    type: string
    sql: ${TABLE}."TOPIC_CODE_CONCAT" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      _row,
      _fivetran_deleted,
      isbn_13,
      author,
      title,
      edition,
      pub_co,
      prd_grp,
      pfc,
      rghts,
      status,
      cy,
      custom,
      tpc,
      duration,
      section_code_concat,
      discipline_concat,
      subject_code_concat,
      topic_code_concat,
      _fivetran_synced_time
    ]
  }
}
