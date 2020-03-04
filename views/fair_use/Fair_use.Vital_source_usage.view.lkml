view: fair_use_tracking_vitalsource {
    derived_table: {
      sql:
          WITH multiple_prints AS (
          SELECT
            user_sso_guid AS guid,
            DATE_TRUNC(week, event_time) AS week,
            COUNT(CASE WHEN event_action = 'Printed' THEN 1 END) AS prints,
            COUNT(CASE WHEN event_action = 'Downloaded' THEN 1 END) AS downloads,
            COUNT(CASE WHEN event_action = 'Viewed' THEN 1 END) AS views,
          3 AS indicator_id
          FROM unlimited.raw_vitalsource_event
          WHERE guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users)
          GROUP BY 1, 2
          ORDER BY 2 DESC

       )

      SELECT * FROM multiple_prints;;




        persist_for: "24 hours"
      }

      dimension: guid {}
      dimension: week {
        type: date_week
      }
      dimension: prints {}
      dimension: print_ranges {
        type:  tier
        tiers: [ 2, 5, 10, 20, 30, 100]
        style:  integer
        sql:  ${prints} ;;
        }

      dimension: downloads {}
      dimension: download_tiers {
          type:  tier
          tiers: [ 2, 4, 6, 8, 10]
          style:  integer
          sql:  ${downloads} ;;
        }

  dimension: views {}
  dimension: view_tiers {
    type:  tier
    tiers: [ 10, 20, 30, 40, 50]
    style:  integer
    sql:  ${downloads} ;;
  }


      measure: user_count {
        type: count_distinct
        sql: ${guid} ;;
      }



}
