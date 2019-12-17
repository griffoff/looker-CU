view: entity_names {
  derived_table: {
    sql: SELECT * FROM strategy.adoption_pivot.entities_adoptionpivot
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}."ENTITY_NO" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: state_cd {
    type: string
    sql: ${TABLE}."STATE_CD" ;;
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  set: detail {
    fields: [
      entity_no,
      institution_nm,
      state_cd,
      _file,
      _fivetran_synced_time,
      _line
    ]
  }
}
