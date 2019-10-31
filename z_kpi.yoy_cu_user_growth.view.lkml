explore: yoy_cu_user_growth {}

view: yoy_cu_user_growth {
  derived_table: {
    sql: WITH today_active_subscribers AS
      (
      SELECT
        1 AS jk
        ,COUNT(DISTINCT active_subscription_states.user_sso_guid ) AS "active_subscription_states.subscribers"
      FROM LOOKER_SCRATCH.LR$JJS49A9QGNLH0IRQ7PTCB_active_subscription_states AS active_subscription_states
      WHERE ((((active_subscription_states.active_date) >= ((TO_TIMESTAMP(CURRENT_DATE() ))) AND (active_subscription_states.active_date) < ((DATEADD('day', 1, TO_TIMESTAMP(CURRENT_DATE() ))))))) AND ((UPPER(active_subscription_states.subscription_state) = UPPER('full_access')))
      )
      ,active_subscribers_one_year_ago AS
      (
      SELECT
        1 AS jk
        ,COUNT(DISTINCT active_subscription_states.user_sso_guid ) AS "active_subscription_states.subscribers"
      FROM LOOKER_SCRATCH.LR$JJS49A9QGNLH0IRQ7PTCB_active_subscription_states AS active_subscription_states
      WHERE ((((active_subscription_states.active_date) >= ((TO_TIMESTAMP(DATEADD(year, -1, CURRENT_DATE())))) AND (active_subscription_states.active_date) < ((DATEADD('day', 1, TO_TIMESTAMP(DATEADD(year, -1, CURRENT_DATE())))))))) AND ((UPPER(active_subscription_states.subscription_state) = UPPER('full_access')))
      )
      SELECT
          (today."active_subscription_states.subscribers" / year_ago."active_subscription_states.subscribers") * 100 AS CU_user_growth_yoy
      FROM today_active_subscribers today
      JOIN active_subscribers_one_year_ago year_ago
        ON today.jk = year_ago.jk
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: cu_user_growth_yoy_tile {
    type: number
    sql: ${TABLE}."CU_USER_GROWTH_YOY" ;;
    value_format: "0.00\%"
  }

  dimension: cu_user_growth_yoy {
    type: number
    sql: ${TABLE}."CU_USER_GROWTH_YOY" ;;
  }

  set: detail {
    fields: [cu_user_growth_yoy]
  }
}
