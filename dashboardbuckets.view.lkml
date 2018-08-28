view: dashboardbuckets {
  derived_table: {
    sql:
      WITH action_items AS (
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
          UNION
          SELECT 0 AS count ,'Other' AS action_name )

          ,unique_users AS (
          SELECT
            DISTINCT userssoguid
          FROM prod.raw_ga.ga_dashboarddata
          WHERE userssoguid IS NOT NULL)

          ,user_action_combinations AS (
          SELECT
            ai.action_name
            ,ai.count
            ,uu.userssoguid
          FROM action_items ai
          CROSS JOIN unique_users uu
          )

          ,gmt_actions AS (
          SELECT
            userssoguid
            ,CASE
                WHEN eventaction LIKE 'Calls To Action (CTAs)' AND eventlabel LIKE 'Add To My Content Position%' THEN 'Added Content To Dashboard'
                WHEN eventaction LIKE 'Search Term%'  THEN 'Searched Items With Results'
                WHEN eventaction LIKE 'Calls To Action (CTAs)' AND LOWER(eventlabel) LIKE 'dashboard%ebook%' THEN 'ebook launched'
                WHEN eventaction LIKE 'Dashboard Course Launched Name%' THEN 'courseware launched'
                WHEN eventaction LIKE 'Explore Catalog%' THEN 'catalog explored'
                WHEN eventaction LIKE 'Rent From Chegg%'  THEN 'Rented from Chegg'
                WHEN  eventaction LIKE 'Exclusive Partner Clicked' THEN 'One month Chegg clicks'
                WHEN eventaction LIKE 'Search Bar No%'  THEN 'No Results Search'
                WHEN eventaction LIKE 'Support Clicked' THEN 'Support Clicked'
                WHEN eventaction LIKE '%FAQ%' THEN 'FAQ Clicked'
                WHEN eventaction LIKE 'Calls To Action (CTAs)' AND eventlabel LIKE 'Buy Now Button Click' THEN 'Clicked on UPGRADE (yellow banner)'
                WHEN eventcategory LIKE 'Course Key Registration' THEN 'Course Key Registration'
                WHEN eventcategory LIKE 'Access Code Registration' THEN 'Access Code Registration'
                WHEN eventcategory LIKE 'Videos' AND eventaction LIKE 'Meet Cengage Unlimited' THEN 'CU videos viewed'
                ELSE 'Other' END AS actions
          FROM prod.raw_ga.ga_dashboarddata )


          SELECT
            auc.userssoguid
            ,action_name
            ,SUM(CASE WHEN auc.action_name = gmt.actions THEN 1 ELSE 0 END) AS action_count
          FROM user_action_combinations auc
          LEFT OUTER JOIN gmt_actions gmt
          ON auc.userssoguid = gmt.userssoguid
          AND auc.action_name = gmt.actions
          GROUP BY 1, 2
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: userssoguid {
    type: string
    sql: ${TABLE}."USERSSOGUID" ;;
  }

  dimension: action_name {
    type: string
    sql: ${TABLE}."ACTION_NAME" ;;
  }

  dimension: action_count {
    type: number
    sql: ${TABLE}."ACTION_COUNT" ;;
  }

  dimension: count_click_buckets {
    label: "Ga Dashboard Clicks by Action Buckets"
    type:  tier
    tiers: [1, 2, 5, 8, 11]
    style:  integer
    sql:  ${action_count} ;;
  }

  measure: count_users {
    type:  count_distinct
    sql: ${userssoguid} ;;

  }


  set: detail {
    fields: [userssoguid, action_name, action_count]
  }
}
