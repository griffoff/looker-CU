view: sso_merged_guids {
  sql_table_name: UNLIMITED.VW_PARTNER_TO_PRIMARY_USER_GUID ;;

  set: guids {fields:[primary_guid, shadow_guid]}

  dimension_group: _ldts {
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
    sql: ${TABLE}."_LDTS" ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: primary_guid {
    type: string
    sql: ${TABLE}."PRIMARY_GUID" ;;
  }

  dimension: shadow_guid {
    type: string
    sql: ${TABLE}."PARTNER_GUID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: primary_guid_count {
    type: count_distinct
    sql: ${primary_guid} ;;
    drill_fields: []
  }

  measure: shadow_guid_count {
    type: count_distinct
    sql: ${shadow_guid} ;;
    drill_fields: []
  }
}
