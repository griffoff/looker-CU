view: parsed_ehp_tweets {
  derived_table: {
    sql: select _row, publishers_,
      SPLIT_PART(SPLIT_PART(tablename.description, ' ', numbers.n+1), ' ', -1) as parsed_description
      from (
      SELECT
        p0.n
        + p1.n*2
        + p2.n * POWER(2,2)
        + p3.n * POWER(2,3)
        + p4.n * POWER(2,4)
        + p5.n * POWER(2,5)
        + p6.n * POWER(2,6)
        + p7.n * POWER(2,7)
        as n
      FROM
        (SELECT 0 as n UNION SELECT 1) p0,
        (SELECT 0 as n UNION SELECT 1) p1,
        (SELECT 0 as n UNION SELECT 1) p2,
        (SELECT 0 as n UNION SELECT 1) p3,
        (SELECT 0 as n UNION SELECT 1) p4,
        (SELECT 0 as n UNION SELECT 1) p5,
        (SELECT 0 as n UNION SELECT 1) p6,
        (SELECT 0 as n UNION SELECT 1) p7
      ) as numbers
      INNER JOIN (
        SELECT _row, publishers_, tweet_ as description
        FROM UPLOADS.EHP.TWEETS
      ) as tablename
      on LENGTH(tablename.description) - LENGTH(REPLACE(tablename.description, ' ', '')) >= numbers.n
      order by _row, n
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _row {
    label: "row"
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: publishers_ {
    type: string
    sql: ${TABLE}."PUBLISHERS_" ;;
    hidden: yes
  }

  dimension: parsed_description {
    type: string
    sql: ${TABLE}."PARSED_DESCRIPTION" ;;
  }

  set: detail {
    fields: [_row, publishers_, parsed_description]
  }
}
