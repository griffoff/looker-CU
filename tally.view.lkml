view: tally {
  derived_table: {
    sql:
    SELECT SEQ8() AS i
    FROM TABLE(GENERATOR(ROWCOUNT=>10000))
    ;;
  }
  dimension: i {}
}
