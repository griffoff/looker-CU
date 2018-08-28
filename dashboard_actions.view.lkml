view: dashboard_actions {
  derived_table: {
    sql:
    SELECT 0 AS count ,'Added Content To Dashboard' AS action_name
    UNION
    SELECT 0 AS count ,'Searched Items With Results' AS action_name
    UNION
    SELECT 0 AS count ,'No Results Search' AS action_name
    UNION
    SELECT 0 AS count ,'ebook launched' AS action_name
    UNION
    SELECT 0 AS count ,'courseware launched' AS action_name
    UNION
    SELECT 0 AS count , 'catalog explored' AS action_name
    UNION
    SELECT 0 AS count ,'Rented from Chegg' AS action_name
    UNION
    SELECT 0 AS count ,'One month Chegg clicks' AS action_name
    UNION
    SELECT 0 AS count ,'Support Clicked' AS action_name
    UNION
    SELECT 0 AS count ,'FAQ Clicked' AS action_name
    UNION
    SELECT 0 AS count ,'Clicked on UPGRADE (yellow banner)' AS action_name
    UNION
    SELECT 0 AS count ,'Course Key Registration' AS action_name
    UNION
    SELECT 0 AS count ,'Access Code Registration' AS action_name
    UNION
    SELECT 0 AS count ,'CU videos viewed' AS action_name

  ;;
  }
dimension: count {
  type: number
}

dimension: action_name {
  type: string
}

}
