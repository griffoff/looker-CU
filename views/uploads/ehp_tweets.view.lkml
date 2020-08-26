view: ehp_tweets {
  sql_table_name: UPLOADS.EHP.TWEETS
    ;;

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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    label: "row"
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: ehp {
    type: string
    sql: ${TABLE}."EHP" ;;
  }

  dimension: publishers_ {
    type: string
    sql: ${TABLE}."PUBLISHERS_" ;;
  }

  dimension: sentiment_ {
    type: string
    sql: ${TABLE}."SENTIMENT_" ;;
  }

  dimension: tweet_ {
    type: string
    sql: ${TABLE}."TWEET_" ;;
  }

  dimension: wk_ {
    type: string
    sql: ${TABLE}."WK_" ;;
  }

  dimension: year_ {
    type: number
    sql: ${TABLE}."YEAR_" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
