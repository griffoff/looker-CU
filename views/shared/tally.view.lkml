view: tally {
  derived_table: {
    sql:
    SELECT SEQ8() AS i
    FROM TABLE(GENERATOR(ROWCOUNT=>10000))
    ;;

    persist_for: "24 hours"
  }
  dimension: i {}

  dimension: j {
    sql: i ;;
    type: number
    hidden: yes
  }
}
