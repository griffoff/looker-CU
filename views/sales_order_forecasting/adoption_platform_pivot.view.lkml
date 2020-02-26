view: adoption_platform_pivot {
  derived_table: {
    sql: SELECT * FROM strategy.adoption_pivot.pfmt_adoptionpivot
      ;;
  }

  measure: count {
    type: count
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

  dimension: product_family_code {
    type: string
    sql: ${TABLE}."PRODUCT_FAMILY_CODE" ;;
  }

  dimension: product_family_description {
    type: string
    sql: ${TABLE}."PRODUCT_FAMILY_DESCRIPTION" ;;
  }

  dimension: product_division {
    type: number
    sql: ${TABLE}."PRODUCT_DIVISION" ;;
  }

  dimension: product_group {
    type: string
    sql: ${TABLE}."PRODUCT_GROUP" ;;
  }

  dimension: product_group_description {
    type: string
    sql: ${TABLE}."PRODUCT_GROUP_DESCRIPTION" ;;
  }

  dimension: subject_major {
    type: string
    sql: ${TABLE}."SUBJECT_MAJOR" ;;
  }

  dimension: subject_major_description {
    type: string
    sql: ${TABLE}."SUBJECT_MAJOR_DESCRIPTION" ;;
  }

  dimension: subject_minor {
    type: string
    sql: ${TABLE}."SUBJECT_MINOR" ;;
  }

  dimension: subject_minor_description {
    type: string
    sql: ${TABLE}."SUBJECT_MINOR_DESCRIPTION" ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}."DISCIPLINE" ;;
  }

  dimension: discipline_description {
    type: string
    sql: ${TABLE}."DISCIPLINE_DESCRIPTION" ;;
  }

  dimension: family_status {
    type: string
    sql: ${TABLE}."FAMILY_STATUS" ;;
  }

  dimension: family_status_description {
    type: string
    sql: ${TABLE}."FAMILY_STATUS_DESCRIPTION" ;;
  }

  dimension: course_code {
    type: string
    sql: ${TABLE}."COURSE_CODE" ;;
  }

  dimension: course_code_description {
    type: string
    sql: ${TABLE}."COURSE_CODE_DESCRIPTION" ;;
  }

  dimension: product_manager {
    type: string
    sql: ${TABLE}."PRODUCT_MANAGER" ;;
  }

  dimension: product_manager_description {
    type: string
    sql: ${TABLE}."PRODUCT_MANAGER_DESCRIPTION" ;;
  }

  dimension: vice_president_product_management {
    type: string
    sql: ${TABLE}."VICE_PRESIDENT_PRODUCT_MANAGEMENT" ;;
  }

  dimension: vice_president_description {
    type: string
    sql: ${TABLE}."VICE_PRESIDENT_DESCRIPTION" ;;
  }

  dimension: product_director {
    type: string
    sql: ${TABLE}."PRODUCT_DIRECTOR" ;;
  }

  dimension: product_director_description {
    type: string
    sql: ${TABLE}."PRODUCT_DIRECTOR_DESCRIPTION" ;;
  }

  dimension: current_selling_edition {
    type: string
    sql: ${TABLE}."CURRENT_SELLING_EDITION" ;;
  }

  dimension: hyperion_product_family {
    type: string
    sql: ${TABLE}."HYPERION_PRODUCT_FAMILY" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      _file,
      _line,
      product_family_code,
      product_family_description,
      product_division,
      product_group,
      product_group_description,
      subject_major,
      subject_major_description,
      subject_minor,
      subject_minor_description,
      discipline,
      discipline_description,
      family_status,
      family_status_description,
      course_code,
      course_code_description,
      product_manager,
      product_manager_description,
      vice_president_product_management,
      vice_president_description,
      product_director,
      product_director_description,
      current_selling_edition,
      hyperion_product_family,
      _fivetran_synced_time
    ]
  }
}
