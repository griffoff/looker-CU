view: device_changes {
  derived_table: {
    sql:
    SELECT
      user_sso_guid
      ,DATE_TRUNC('week', local_time) as week
      ,COUNT (DISTINCT device) AS unique_devices
    FROM unlimited.raw_fair_use_logins
    GROUP BY 1, 2;;

    }

    dimension: user_sso_guid {}
    dimension: week {}
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
