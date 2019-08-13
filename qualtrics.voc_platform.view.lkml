view: qualtrics_voc_platform {
  sql_table_name: UPLOADS.QUALTRICS.VOC_PLATFORM ;;

  dimension_group: _fivetran_synced {
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
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: action_set {
    type: string
    sql: ${TABLE}."ACTION_SET" ;;
  }

  dimension: course_context_id {
    type: string
    sql: ${TABLE}."COURSE_CONTEXT_ID" ;;
  }

  dimension: course_institution {
    type: string
    sql: ${TABLE}."COURSE_INSTITUTION" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension_group: current {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CURRENT" ;;
  }

  dimension: currenturl {
    type: string
    sql: ${TABLE}."CURRENTURL" ;;
  }

  dimension: device {
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  dimension: difference {
    type: string
    sql: ${TABLE}."DIFFERENCE" ;;
  }

  dimension: distribution_channel {
    type: string
    sql: ${TABLE}."DISTRIBUTION_CHANNEL" ;;
  }

  dimension: duration_in_seconds_ {
    type: number
    sql: ${TABLE}."DURATION_IN_SECONDS_" ;;
  }

  dimension_group: end {
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: external_reference {
    type: string
    sql: ${TABLE}."EXTERNAL_REFERENCE" ;;
  }

  dimension: finished {
    type: yesno
    sql: ${TABLE}."FINISHED" ;;
  }

  dimension: iac_isbn {
    type: string
    sql: ${TABLE}."IAC_ISBN" ;;
  }

  dimension: ipaddress {
    type: string
    sql: ${TABLE}."IPADDRESS" ;;
  }

  dimension: length {
    type: string
    sql: ${TABLE}."LENGTH" ;;
  }

  dimension: location_latitude {
    type: number
    sql: ${TABLE}."LOCATION_LATITUDE" ;;
  }

  dimension: location_longitude {
    type: number
    sql: ${TABLE}."LOCATION_LONGITUDE" ;;
  }

  dimension: overall_satisfaction {
    type: string
    sql: ${TABLE}."OVERALL_SATISFACTION" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}."PRODUCT" ;;
  }

  dimension: progress {
    type: number
    sql: ${TABLE}."PROGRESS" ;;
  }

  dimension: q_10 {
    type: string
    sql: ${TABLE}."Q_10" ;;
  }

  dimension: q_10_sentiment {
    type: string
    sql: ${TABLE}."Q_10_SENTIMENT" ;;
  }

  dimension: q_10_sentiment_polarity {
    type: number
    sql: ${TABLE}."Q_10_SENTIMENT_POLARITY" ;;
  }

  dimension: q_10_sentiment_score {
    type: number
    sql: ${TABLE}."Q_10_SENTIMENT_SCORE" ;;
  }

  dimension: q_10_topics {
    type: string
    sql: ${TABLE}."Q_10_TOPICS" ;;
  }

  dimension: q_11 {
    type: string
    sql: ${TABLE}."Q_11" ;;
  }

  dimension: q_1_a {
    label: "Q1a) Mindtap Satisfaction"
    description: "How satisfied are you with MindTap on a scale of 1 to 10"
    type: string
    sql: ${TABLE}."Q_1_A" ;;
  }

  dimension: q_1_b {
    type: string
    sql: ${TABLE}."Q_1_B" ;;
  }

  dimension: q_1_b_sentiment {
    type: string
    sql: ${TABLE}."Q_1_B_SENTIMENT" ;;
  }

  dimension: q_1_b_sentiment_polarity {
    type: number
    sql: ${TABLE}."Q_1_B_SENTIMENT_POLARITY" ;;
  }

  dimension: q_1_b_sentiment_score {
    type: number
    sql: ${TABLE}."Q_1_B_SENTIMENT_SCORE" ;;
  }

  dimension: q_1_b_topics {
    type: string
    sql: ${TABLE}."Q_1_B_TOPICS" ;;
  }

  dimension: q_2_a {
    type: string
    sql: ${TABLE}."Q_2_A" ;;
  }

  dimension: q_3_a {
    type: string
    sql: ${TABLE}."Q_3_A" ;;
  }

  dimension: q_4 {
    type: string
    sql: ${TABLE}."Q_4" ;;
  }

  dimension: q_5_a {
    type: string
    sql: ${TABLE}."Q_5_A" ;;
  }

  dimension: q_6_a {
    type: string
    sql: ${TABLE}."Q_6_A" ;;
  }

  dimension: q_7_a {
    type: string
    sql: ${TABLE}."Q_7_A" ;;
  }

  dimension: q_8 {
    type: string
    sql: ${TABLE}."Q_8" ;;
  }

  dimension: q_9_1 {
    type: string
    sql: ${TABLE}."Q_9_1" ;;
  }

  dimension: q_9_1_sentiment {
    type: string
    sql: ${TABLE}."Q_9_1_SENTIMENT" ;;
  }

  dimension: q_9_1_sentiment_polarity {
    type: number
    sql: ${TABLE}."Q_9_1_SENTIMENT_POLARITY" ;;
  }

  dimension: q_9_1_sentiment_score {
    type: number
    sql: ${TABLE}."Q_9_1_SENTIMENT_SCORE" ;;
  }

  dimension: q_9_1_topics {
    type: string
    sql: ${TABLE}."Q_9_1_TOPICS" ;;
  }

  dimension: q_9_2 {
    type: string
    sql: ${TABLE}."Q_9_2" ;;
  }

  dimension: q_9_3 {
    type: string
    sql: ${TABLE}."Q_9_3" ;;
  }

  dimension: recipient_email {
    type: string
    sql: ${TABLE}."RECIPIENT_EMAIL" ;;
  }

  dimension: recipient_first_name {
    type: string
    sql: ${TABLE}."RECIPIENT_FIRST_NAME" ;;
  }

  dimension: recipient_last_name {
    type: string
    sql: ${TABLE}."RECIPIENT_LAST_NAME" ;;
  }

  dimension_group: recorded {
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
    sql: ${TABLE}."RECORDED_DATE" ;;
  }

  dimension: response_id {
    type: string
    sql: ${TABLE}."RESPONSE_ID" ;;
  }

  dimension: section {
    type: string
    sql: ${TABLE}."SECTION" ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: textbook_author {
    type: string
    sql: ${TABLE}."TEXTBOOK_AUTHOR" ;;
  }

  dimension: textbook_discipline {
    type: string
    sql: ${TABLE}."TEXTBOOK_DISCIPLINE" ;;
  }

  dimension: textbook_edition {
    type: string
    sql: ${TABLE}."TEXTBOOK_EDITION" ;;
  }

  dimension: textbook_isbn {
    type: string
    sql: ${TABLE}."TEXTBOOK_ISBN" ;;
  }

  dimension: textbook_title {
    type: string
    sql: ${TABLE}."TEXTBOOK_TITLE" ;;
  }

  dimension: to_s {
    type: string
    sql: ${TABLE}."TO_S" ;;
  }

  dimension: user_agent {
    type: string
    sql: ${TABLE}."USER_AGENT" ;;
  }

  dimension: user_language {
    type: string
    sql: ${TABLE}."USER_LANGUAGE" ;;
  }

  dimension: user_ssoguid {
    type: string
    sql: ${TABLE}."USER_SSOGUID" ;;
  }

  dimension: user_type {
    type: string
    sql: ${TABLE}."USER_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [recipient_last_name, recipient_first_name]
  }
}
