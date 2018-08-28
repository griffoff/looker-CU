view: device_changes {
  derived_table: {
    sql:
    WITH devices AS(
    SELECT
      user_sso_guid
      ,DATE_TRUNC('week', local_time) as week
      ,COUNT (DISTINCT device) AS unique_devices
    FROM unlimited.raw_fair_use_logins
    GROUP BY 1, 2 )


        SELECT
          *
        FROM devices
        WHERE user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.clts_excluded_users) ;;

    }

    dimension: user_sso_guid {}
    dimension: week {
      type: date_week
    }
    dimension: unique_devices {}

  dimension: unique_device_tiers {
    type:  tier
    tiers: [ 2, 4, 6, 8, 10]
    style:  integer
    sql:  ${unique_devices} ;;
  }


  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }


    }
