view: unique_cities_per_user_per_week {
  derived_table: {
    sql:  WITH
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

      SELECT
        user_sso_guid
        ,DATE_TRUNC('week', local_time) AS week
        ,COUNT(DISTINCT city) AS distinct_cities
      FROM cities
      WHERE user_sso_guid NOT IN (SELECT DISTINCT user_sso_guid FROM unlimited.excluded_users)
      GROUP BY user_sso_guid, week
       ;;
  }

  dimension: user_sso_guid {
    type: string
    primary_key: yes
  }

  dimension: week {
    type: date_week
  }

  dimension: distinct_cities {
    type: number
  }

  dimension: distinct_cities_buckets{
    type:  tier
    tiers: [ 2, 4, 6, 8, 10]
    style:  integer
    sql:  ${distinct_cities} ;;
  }


  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }


 }
