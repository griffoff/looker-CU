explore: mindtap_search_analysis {}

view: mindtap_search_analysis {
  derived_table: {
    sql: SELECT * FROM dev.zkc.mt_search_features
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  }

  dimension: excluded_user {
    type: number
    sql: ${TABLE}."EXCLUDED_USER" ;;
  }

  dimension: coretextisbn {
    type: number
    sql: ${TABLE}."CORETEXTISBN" ;;
  }

  dimension: time {
    type: string
    sql: ${TABLE}."TIME" ;;
  }

  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  dimension: short_title {
    type: string
    sql: ${TABLE}."SHORT_TITLE" ;;
  }

  dimension: subject_matter {
    type: string
    sql: ${TABLE}."SUBJECT_MATTER" ;;
  }

  dimension: number_of_characters {
    type: number
    sql: ${TABLE}."NUMBER_OF_CHARACTERS" ;;
  }

  dimension: contains_single_quote {
    type: string
    sql: ${TABLE}."CONTAINS_SINGLE_QUOTE" ;;
  }

  dimension: contains_double_quote {
    type: string
    sql: ${TABLE}."CONTAINS_DOUBLE_QUOTE" ;;
  }

  dimension: copy_paste_search {
    type: number
    sql: ${TABLE}."COPY_PASTE_SEARCH" ;;
  }

  dimension: contains_ch {
    type: string
    sql: ${TABLE}."CONTAINS_CH" ;;
  }

  dimension: contains_chapter {
    type: string
    sql: ${TABLE}."CONTAINS_CHAPTER" ;;
  }

  dimension: is_just_an_integer {
    type: number
    sql: ${TABLE}."IS_JUST_AN_INTEGER" ;;
  }

  dimension: contains_appendix {
    type: string
    sql: ${TABLE}."CONTAINS_APPENDIX" ;;
  }

  dimension: contains_page {
    type: string
    sql: ${TABLE}."CONTAINS_PAGE" ;;
  }

  dimension: contains_quiz {
    type: string
    sql: ${TABLE}."CONTAINS_QUIZ" ;;
  }

  dimension: contains_learnit {
    type: string
    sql: ${TABLE}."CONTAINS_LEARNIT" ;;
  }

  dimension: navigation_search {
    type: number
    sql: ${TABLE}."NAVIGATION_SEARCH" ;;
  }

  dimension: contains_ {
    type: string
    sql: ${TABLE}."contains_?" ;;
  }

  dimension: contains_what {
    type: string
    sql: ${TABLE}."CONTAINS_WHAT" ;;
  }

  dimension: contains_why {
    type: string
    sql: ${TABLE}."CONTAINS_WHY" ;;
  }

  dimension: contains_who {
    type: string
    sql: ${TABLE}."CONTAINS_WHO" ;;
  }

  dimension: contains_where {
    type: string
    sql: ${TABLE}."CONTAINS_WHERE" ;;
  }

  dimension: contains_when {
    type: string
    sql: ${TABLE}."CONTAINS_WHEN" ;;
  }

  dimension: contains_if {
    type: string
    sql: ${TABLE}."CONTAINS_IF" ;;
  }

  dimension: questionmark_or_questionword {
    type: number
    sql: ${TABLE}."QUESTIONMARK_OR_QUESTIONWORD" ;;
  }

  dimension: non_question_nor_nav_nor_cp_search {
    type: number
    sql: ${TABLE}."NON_QUESTION_NOR_NAV_NOR_CP_SEARCH" ;;
  }

  measure: search_count {
    type: count
  }

  measure: unqiue_users {
    type: count_distinct
    sql: ${user_sso_guid_merged} ;;
  }

  measure: copy_paste_searches {
    type: sum
    sql:  CASE WHEN ${copy_paste_search} = TRUE THEN 1 END ;;
  }

  measure: navigation_searches {
    type: sum
    sql: CASE WHEN navigation_search = TRUE THEN 1 END ;;
  }

  measure: questions {
    type: sum
    sql: CASE WHEN questionmark_or_questionword = TRUE THEN 1 END ;;
  }

  measure: non_question_nor_nav_nor_cp_searches {
    type: sum
    sql: CASE WHEN non_question_nor_nav_nor_cp_search = TRUE THEN 1 END ;;
  }

  set: detail {
    fields: [
      user_sso_guid_merged,
      excluded_user,
      coretextisbn,
      time,
      search,
      short_title,
      subject_matter,
      number_of_characters,
      contains_single_quote,
      contains_double_quote,
      copy_paste_search,
      contains_ch,
      contains_chapter,
      is_just_an_integer,
      contains_appendix,
      contains_page,
      contains_quiz,
      contains_learnit,
      navigation_search,
      contains_,
      contains_what,
      contains_why,
      contains_who,
      contains_where,
      contains_when,
      contains_if,
      questionmark_or_questionword,
      non_question_nor_nav_nor_cp_search
    ]
  }
}
