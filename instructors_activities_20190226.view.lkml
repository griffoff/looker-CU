explore: instructors_activities_20190226 {}

view: instructors_activities_20190226 {
  derived_table: {
    sql: SELECT * FROM uploads.cu.percent_instructors_20190226
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: user_count {
    type: count_distinct
    drill_fields: [detail*]
    sql: ${user_sso_guid};;
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: activity_app_category {
    type: string
    sql: ${TABLE}."ACTIVITY_APP_CATEGORY" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
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

#   dimension: activity_app_category_y {
#     type: string
#     sql: ${TABLE}."ACTIVITY_APP_CATEGORY_Y" ;;
#   }

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
    sql:   ${TABLE}."NON_SCORABLE_" ;;
    tiers: [25, 50, 75]
    style: integer
  }

  dimension: non_scorable_ {
    type: number
    sql: (${TABLE}."NON_SCORABLE_")*100 ;;
  }

  dimension: practice_ {
    type: number
    sql: (${TABLE}."PRACTICE_")*100 ;;
  }

  dimension: pratice_percent_tiers {
    type: tier
    sql:   ${TABLE}."PRACTICE_" ;;
    tiers: [25, 50, 75]
    style: integer
  }

  dimension: unassigned_ {
    type: number
    sql: (${TABLE}."UNASSIGNED_")*100 ;;
  }

  dimension: unassigned_percent_tiers {
    type: tier
    sql:   ${TABLE}."UNASSIGNED_" ;;
    tiers: [25, 50, 75]
    style: integer
  }



  set: detail {
    fields: [
      _file,
      _line,
      course_key,
      user_sso_guid,
      graded_x,
      nonscorable_x,
      practice_x,
      unassigned_x,
      activity_app_category,
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
