view: weeks_above_threshhold_devices {
    derived_table: {
      sql:
         WITH unique_devices_per_week AS
          (SELECT
            user_sso_guid
            ,DATE_TRUNC('week', local_time) as week
            ,COUNT (DISTINCT device) AS unique_devices
          FROM unlimited.raw_fair_use_logins
          WHERE user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.clts_excluded_users)
          GROUP BY 1, 2)

          SELECT
            unique_devices_per_week.user_sso_guid
            ,3 AS threshhold_devices
            ,COUNT(week) AS weeks_above_threshhold
          FROM unique_devices_per_week
          WHERE unique_devices > threshhold_devices
          GROUP BY 1;;
      }

      dimension: user_sso_guid {}
      dimension: weeks_above_threshhold {}

      dimension: weeks_above_threshhold_tiers {
        type:  tier
        tiers: [ 2, 4, 6, 8, 10]
        style:  integer
        sql:  ${weeks_above_threshhold} ;;
      }


      measure: user_count {
        type: count_distinct
        sql: ${user_sso_guid} ;;
      }


    }
