view: indicators {
  derived_table: {
    sql:
    SELECT
      0 AS indicator_id,
      'No indicators' AS indicator_name
    UNION
    SELECT
      1 AS indicator_id,
      'Multiple IPs within 30 min period' AS indicator_name
    UNION
    SELECT
       2 AS indicator_id,
      'Multiple devices within 30 min period' AS indicator_name
    UNION
    SELECT
       3 AS indicator_id,
      'Over 500 prints per day' AS indicator_name
    UNION
    SELECT
       4 AS indicator_id,
       'Over 10 downloads per day' AS indicator_name ;;
  }
dimension: indicator_id {}
dimension: indicator_name {}

}
