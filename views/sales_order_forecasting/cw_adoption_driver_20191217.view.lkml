view: cw_adoption_driver_20191217 {
  derived_table: {
    sql: SELECT * FROM uploads.cu.courseware_adoption_driver_master_20191217
      ;;
  }

  measure: count {
    label: "join count test"
    type: count
    drill_fields: [detail*]
  }

  measure: count_distinct_ak {
    label: "# adoption keys"
    type: count_distinct
    sql: ${adoption_key} ;;
    drill_fields: [detail*]
  }


  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
  }


  dimension: institution {
    type: string
    sql: ${TABLE}."INSTITUTION" ;;
  }

  dimension: course {
    type: string
    sql: ${TABLE}."COURSE" ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}."DISCIPLINE" ;;
  }

  dimension: discipline_category {
    type: string
    sql: ${TABLE}."DISCIPLINE_CATEGORY" ;;
  }

  dimension: fy_19_account_segment {
    type: string
    sql: ${TABLE}."FY_19_ACCOUNT_SEGMENT" ;;
  }

  dimension: fy_20_account_segment {
    type: string
    sql: ${TABLE}."FY_20_ACCOUNT_SEGMENT" ;;
  }

  dimension: fy_18_fy_19_adoption_transition {
    type: string
    sql: ${TABLE}."FY_18_FY_19_ADOPTION_TRANSITION" ;;
  }

  dimension: fy_19_fy_20_adoption_transition {
    type: string
    sql: ${TABLE}."FY_19_FY_20_ADOPTION_TRANSITION" ;;
  }

  dimension: fy_18_activation_rate {
    type: number
    sql: ${TABLE}."FY_18_ACTIVATION_RATE" ;;
  }

  dimension: fy_18_activation_rate_bucket {
    type: string
    sql: ${TABLE}."FY_18_ACTIVATION_RATE_BUCKET" ;;
  }

  dimension: fy_19_activation_rate {
    type: number
    sql: ${TABLE}."FY_19_ACTIVATION_RATE" ;;
  }

  dimension: fy_19_activation_rate_bucket {
    type: string
    sql: ${TABLE}."FY_19_ACTIVATION_RATE_BUCKET" ;;
  }

  dimension: fy_20_activation_rate {
    type: number
    sql: ${TABLE}."FY_20_ACTIVATION_RATE" ;;
  }

  dimension: fy_20_activation_rate_bucket {
    type: string
    sql: ${TABLE}."FY_20_ACTIVATION_RATE_BUCKET" ;;
  }

  dimension: fy_19_cu_penetration {
    type: number
    sql: ${TABLE}."FY_19_CU_PENETRATION" ;;
  }

  dimension: fy_20_cu_penetration {
    type: number
    sql: ${TABLE}."FY_20_CU_PENETRATION" ;;
  }

  dimension: fy_18_courseware_consumed_units {
    type: number
    sql: ${TABLE}."FY_18_COURSEWARE_CONSUMED_UNITS" ;;
  }

  dimension: fy_18_total_courseware_activations {
    type: number
    sql: ${TABLE}."FY_18_TOTAL_COURSEWARE_ACTIVATIONS" ;;
  }

  dimension: fy_19_courseware_consumed_units {
    type: number
    sql: ${TABLE}."FY_19_COURSEWARE_CONSUMED_UNITS" ;;
  }

  dimension: fy_19_total_courseware_activations {
    type: number
    sql: ${TABLE}."FY_19_TOTAL_COURSEWARE_ACTIVATIONS" ;;
  }

  dimension: fy_19_courseware_activations_within_cu {
    type: number
    sql: ${TABLE}."FY_19_COURSEWARE_ACTIVATIONS_WITHIN_CU" ;;
  }

  dimension: fy_20_courseware_consumed_units {
    type: number
    sql: ${TABLE}."FY_20_COURSEWARE_CONSUMED_UNITS" ;;
  }

  dimension: fy_20_total_courseware_activations {
    type: number
    sql: ${TABLE}."FY_20_TOTAL_COURSEWARE_ACTIVATIONS" ;;
  }

  dimension: fy_20_courseware_activations_within_cu {
    type: number
    sql: ${TABLE}."FY_20_COURSEWARE_ACTIVATIONS_WITHIN_CU" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      _file,
      _line,
      adoption_key,
      institution,
      course,
      discipline,
      discipline_category,
      fy_19_account_segment,
      fy_20_account_segment,
      fy_18_fy_19_adoption_transition,
      fy_19_fy_20_adoption_transition,
      fy_18_activation_rate,
      fy_18_activation_rate_bucket,
      fy_19_activation_rate,
      fy_19_activation_rate_bucket,
      fy_20_activation_rate,
      fy_20_activation_rate_bucket,
      fy_19_cu_penetration,
      fy_20_cu_penetration,
      fy_18_courseware_consumed_units,
      fy_18_total_courseware_activations,
      fy_19_courseware_consumed_units,
      fy_19_total_courseware_activations,
      fy_19_courseware_activations_within_cu,
      fy_20_courseware_consumed_units,
      fy_20_total_courseware_activations,
      fy_20_courseware_activations_within_cu,
      _fivetran_synced_time
    ]
  }
}
