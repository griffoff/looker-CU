explore: active_subscription_states {}

view: active_subscription_states {
  derived_table: {
    sql:
    WITH active_subs AS (
      SELECT
        user_sso_guid
        ,DATEADD(DAY, t.i, effective_from::DATE) AS active_date
        ,subscription_state
        ,HASH(user_sso_guid, active_date) AS pk
        ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid, active_date ORDER BY CASE subscription_state WHEN 'full_access' THEN 0 ELSE 1 END) AS r
      FROM ${raw_subscription_event.SQL_TABLE_NAME} e
      INNER JOIN ${tally.SQL_TABLE_NAME} t ON i <= DATEDIFF(DAY, effective_from::DATE, LEAST(effective_to::DATE, CURRENT_DATE()))
    )
    SELECT *
    FROM active_subs
    WHERE r = 1
    ;;
  }

  dimension: pk {primary_key:yes hidden:yes}

  dimension: user_sso_guid {

  }

  dimension_group: active_date {
    type: time
    label: ""
    timeframes: [date, week, month, year, fiscal_year, fiscal_quarter, fiscal_quarter_of_year, fiscal_month_num]
  }

  dimension: subscription_state {

  }

  measure: subscribers {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }
}
