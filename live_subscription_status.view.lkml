view: live_subscription_status {
  derived_table: {
    sql:
      WITH state AS (
        SELECT
            e.*
            ,COALESCE(m.primary_guid, e.user_sso_guid) AS merged_guid
            ,REPLACE(INITCAP(subscription_state), '_', ' ') as subscription_status
            ,LAG(subscription_status) over(partition by user_sso_guid order by local_time) as prior_status
            ,LEAD(subscription_status) over(partition by user_sso_guid order by local_time) as next_status
            ,next_status IS NULL as latest
        FROM unlimited.raw_Subscription_event e
        LEFT JOIN unlimited.sso_merged_guids m on e.user_sso_guid = m.shadow_guid
      )
      SELECT *
      FROM state
      WHERE latest
      ;;
  }

  dimension: user_sso_guid {
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: yes
 }

  dimension: prior_status {}
  dimension: subscription_status {}
  dimension_group: subscription_start {
    type: time
    timeframes: [raw, date, month, year]
  }
  dimension_group: subscription_end {
    type: time
    timeframes: [raw, date, month, year]
  }
  dimension_group: local_time {
    label: "Last Updated"
    type: time
    timeframes: [raw, date, month, year]
  }
  dimension: contract_id {}


}
