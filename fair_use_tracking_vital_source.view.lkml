view: fair_use_tracking_vitalsource {
    derived_table: {
      sql:
          WITH multiple_prints AS (
          SELECT
            user_sso_guid AS guid,
            DATE_TRUNC(day, event_time) AS day,
            COUNT(CASE WHEN event_action = 'Printed' THEN 1 END) AS prints,
            COUNT(CASE WHEN event_action = 'Downloaded' THEN 1 END) AS downloads,
          3 AS indicator_id
          FROM unlimited.raw_vitalsource_event
          GROUP BY 1, 2
          ORDER BY 2 DESC
       )


       SELECT * FROM multiple_prints;;

        persist_for: "24 hours"
      }

      dimension: guid {}
      dimension: day {}
      dimension: prints {}
      dimension: print_ranges {
        type:  tier
        tiers: [ 100, 200, 300, 400, 500]
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


      measure: user_count {
        type: count_distinct
        sql: ${guid} ;;
      }



}
