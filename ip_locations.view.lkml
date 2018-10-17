view: ip_locations {
  sql_table_name: UNLIMITED.IP_LOCATIONS ;;

  dimension: details {
    type: string
    sql: ${TABLE}."DETAILS" ;;
  }

  dimension: lon {
    type: string
    sql: ${TABLE}."DETAILS":lon ;;

  }

  dimension: lat {
    type: string
    sql: ${TABLE}."DETAILS":lat ;;

  }


  dimension_group: effective_from {
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
    sql: ${TABLE}."EFFECTIVE_FROM" ;;
  }

  dimension_group: effective_to {
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
    sql: ${TABLE}."EFFECTIVE_TO" ;;
  }

  dimension: ip_address {
    type: string
    sql: ${TABLE}."IP_ADDRESS" ;;
  }

  dimension_group: ldts {
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
    sql: ${TABLE}."LDTS" ;;
  }

  dimension: rsrc {
    type: string
    sql: ${TABLE}."RSRC" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
