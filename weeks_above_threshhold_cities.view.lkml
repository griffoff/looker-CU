view: weeks_above_threshhold_cities {
  derived_table: {
    sql:
    WITH
          users_ips AS (
            SELECT
                users.*,
                ip_locations.details
            FROM unlimited.raw_fair_use_logins users
            JOIN unlimited.ip_locations
            ON users.ip_address = ip_locations.ip_address
            WHERE details['lat'] <> ''
            AND details['lon'] <> '')

          ,cities AS (
            SELECT
                *
                ,details['city'] AS city
            FROM users_ips
            )

            ,unique_cities AS (
            SELECT
              user_sso_guid
              ,DATE_TRUNC('week', local_time) AS week
              ,COUNT(DISTINCT city) AS unique_city_count
            FROM cities
            GROUP BY user_sso_guid, week
            )

            SELECT
              user_sso_guid
              ,1 AS threshhold_cities
              ,COUNT(week) AS weeks_above_threshhold_cities
            FROM unique_cities
            WHERE unique_city_count > threshhold_cities
            AND user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.clts_excluded_users)
            GROUP BY user_sso_guid

            ;;
  }


  dimension: user_sso_guid {}
  dimension: weeks_above_threshhold_cities {}

  dimension: weeks_above_threshhold_tiers {
    type:  tier
    tiers: [ 2, 4, 6, 8, 10]
    style:  integer
    sql:  ${weeks_above_threshhold_cities} ;;
  }


  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }


}
