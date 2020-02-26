include: "ipm_browser_event.view"
view: ipm_browser_event_dev {
  extends: [ipm_browser_event]

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
    hidden: yes
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
    hidden: yes
  }

  dimension: click_id {
    type: string
    sql: ${TABLE}."CLICK_ID" ;;
  }

  dimension: click_title {
    type: string
    sql: ${TABLE}."CLICK_TITLE" ;;
  }

  dimension: message_format_version {
    type: string
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: user_platform {
    type: string
    sql: ${TABLE}."USER_PLATFORM" ;;
  }

  dimension: user_platform_environment {
    type: string
    sql: ${TABLE}."USER_PLATFORM_ENVIRONMENT" ;;
  }


}
