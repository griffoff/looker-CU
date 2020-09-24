view: parsed_ehp_cases {
  derived_table: {
    sql: select _row, date_time_opened, issue_type,
      SPLIT_PART(SPLIT_PART(tablename.description, ' ', numbers.n+1), ' ', -1) as parsed_text
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
        SELECT _row, date_time_opened, issue_type, description as description
        FROM UPLOADS.EHP.CASES
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
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: date_time_opened {
    type: string
    sql: ${TABLE}."DATE_TIME_OPENED" ;;
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}."ISSUE_TYPE" ;;
  }

  dimension: parsed_text {
    type: string
    sql: ${TABLE}."PARSED_TEXT" ;;
  }

  set: detail {
    fields: [_row, date_time_opened, issue_type, parsed_text]
  }
}
