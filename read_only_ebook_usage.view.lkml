explore: read_only_ebook_usage {}

view: read_only_ebook_usage {
  derived_table: {
    sql: SELECT * FROM zpg.read_only_ebook_actions
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid_merged} ;;
  }

  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
    primary_key: yes
  }

  dimension: downloaded_ebook {
    type: number
    sql: ${TABLE}."DOWNLOADED_EBOOK" ;;
  }

  dimension: printed_ebook {
    type: number
    sql: ${TABLE}."PRINTED_EBOOK" ;;
  }

  dimension: viewed_ebook {
    type: number
    sql: ${TABLE}."VIEWED_EBOOK" ;;
  }

  dimension: bookmarked_ebook {
    type: number
    sql: ${TABLE}."BOOKMARKED_EBOOK" ;;
  }

  dimension: highlighted_ebook {
    type: number
    sql: ${TABLE}."HIGHLIGHTED_EBOOK" ;;
  }

  dimension: launched_ebook {
    type: number
    sql: ${TABLE}."LAUNCHED_EBOOK" ;;
  }

  dimension: total_ebook_actions {
    type: number
    sql: ${TABLE}."TOTAL_EBOOK_ACTIONS" ;;
  }

  dimension: total_ebook_actions_tiers {
    type: tier
    sql: ${total_ebook_actions} ;;
    style: integer
    tiers: [10, 50, 100, 200, 300]
  }

  dimension: launched_ebook_tiers {
    type: tier
    sql: ${launched_ebook} ;;
    style: integer
    tiers: [10, 50, 100, 200, 300]
  }



  set: detail {
    fields: [
      user_sso_guid_merged,
      downloaded_ebook,
      printed_ebook,
      viewed_ebook,
      bookmarked_ebook,
      highlighted_ebook,
      launched_ebook,
      total_ebook_actions
    ]
  }
}
