

view: student_activities_20190226 {
  derived_table: {
    sql: SELECT * FROM uploads.cu.percent_students_20190226
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

  dimension: discipline_x {
    type: string
    sql: ${TABLE}."DISCIPLINE_X" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    primary_key: yes
  }

  dimension: graded_x {
    type: number
    sql: ${TABLE}."GRADED_X" ;;
  }

  dimension: nonscorable_x {
    type: number
    sql: ${TABLE}."NONSCORABLE_X" ;;
  }

  dimension: practice_x {
    type: number
    sql: ${TABLE}."PRACTICE_X" ;;
  }

  dimension: unassigned_x {
    type: number
    sql: ${TABLE}."UNASSIGNED_X" ;;
  }

  dimension: discipline_y {
    type: string
    sql: ${TABLE}."DISCIPLINE_Y" ;;
  }

  dimension: graded_y {
    type: number
    sql: ${TABLE}."GRADED_Y" ;;
  }

  dimension: nonscorable_y {
    type: number
    sql: ${TABLE}."NONSCORABLE_Y" ;;
  }

  dimension: practice_y {
    type: number
    sql: ${TABLE}."PRACTICE_Y" ;;
  }

  dimension: unassigned_y {
    type: number
    sql: ${TABLE}."UNASSIGNED_Y" ;;
  }

  dimension: graded_ {
    type: number
    sql: COALESCE((${TABLE}."GRADED_X" / NULLIF(${TABLE}."GRADED_Y", 0)), 0) ;;
  }

  dimension: graded_percent_tiers {
    type: tier
    sql:  ${graded_} ;;
    tiers: [0.25, 0.50, 0.75]
    style: relational
    value_format_name: percent_0
  }

  dimension: non_scorable_percent_tiers {
    type: tier
    sql:   ${non_scorable_} ;;
    tiers: [0.25, 0.50, 0.75]
    style: relational
    value_format_name: percent_0
  }

  dimension: non_scorable_ {
    type: number
    sql: COALESCE( (${TABLE}."NONSCORABLE_X" / NULLIF(${TABLE}."NONSCORABLE_Y", 0)), 0) ;;
  }

  dimension: practice_ {
    type: number
    sql: COALESCE(((${TABLE}."PRACTICE_X" / NULLIF(${TABLE}."PRACTICE_Y", 0))), 0) ;;
  }

  dimension: pratice_percent_tiers {
    type: tier
    sql:   ${practice_} ;;
    tiers: [0.25, 0.50, 0.75]
    style: relational
    value_format_name: percent_0
  }

  dimension: unassigned_ {
    type: number
    sql: COALESCE((${TABLE}."UNASSIGNED_X" / NULLIF(${TABLE}."UNASSIGNED_Y", 0)), 0) ;;
  }

  dimension: unassigned_percent_tiers {
    type: tier
    sql:   ${unassigned_} ;;
    tiers: [0.25, 0.50, 0.75]
    style: relational
    value_format_name: percent_0
  }

  measure: user_counts {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  set: detail {
    fields: [
      _file,
      _line,
      discipline_x,
      course_key,
      user_sso_guid,
      graded_x,
      nonscorable_x,
      practice_x,
      unassigned_x,
      discipline_y,
      graded_y,
      nonscorable_y,
      practice_y,
      unassigned_y,
      graded_,
      non_scorable_,
      practice_,
      unassigned_
    ]
  }
}
