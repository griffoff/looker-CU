explore: trial_home_awareness_fall_spring_lms {}

view: trial_home_awareness_fall_spring_lms {
  derived_table: {
    sql: WITH trial_users AS
          (
              SELECT
                  r.user_sso_guid_merged
                  ,CASE WHEN r.user_sso_guid_merged <> r.user_sso_guid THEN 'LMS User' ELSE 'Non-LMS User' END AS lms_vs_non_lms_user
                  ,CASE
                      WHEN r.subscription_start < '2018-12-15' AND r.subscription_start > '2018-08-01' THEN 'Fall 2019 user'
                      WHEN r.subscription_start > '2018-12-15' AND r.subscription_start < CURRENT_TIMESTAMP() THEN 'Spring 2019 user'
                      WHEN r.subscription_start < '2018-08-01' THEN 'Before CU user'
                      ELSE 'Unknown' END AS fall_vs_spring_user
                  ,Count(distinct case when event_name ilike 'back to Cu Home Page' THEN user_sso_guid_merged else null END) as Explored_myHome
                  ,COUNT(DISTINCT user_sso_guid_merged) AS all_events
              FROM zpg.raw_subscription_event_merged_erroneous_removed r
              LEFT JOIN zpg.all_events e
                  ON r.user_sso_guid_merged = e.user_sso_guid
                  AND e.event_time >= r.subscription_start
                  AND e.event_time <= r.subscription_end
              WHERE r.subscription_state = 'trial_access'
              GROUP BY 1, 2, 3
          )
          SELECT * FROM trial_users
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }



  dimension: user_sso_guid_merged {
    type: string
    sql: ${TABLE}."USER_SSO_GUID_MERGED" ;;
  }

  dimension: lms_vs_non_lms_user {
    type: string
    sql: ${TABLE}."LMS_VS_NON_LMS_USER" ;;
  }

  dimension: fall_vs_spring_user {
    type: string
    sql: ${TABLE}."FALL_VS_SPRING_USER" ;;
  }

  dimension: explored_myhome {
    type: number
    sql: ${TABLE}."EXPLORED_MYHOME" ;;
  }

  measure: explored_myhome_m {
    label: "Users that clicked 'Explore my home'"
    type: sum
    sql: ${TABLE}."EXPLORED_MYHOME" ;;
  }

  dimension: all_events {

    type: number
    sql: ${TABLE}."ALL_EVENTS" ;;
  }

  measure: all_events_m {
    label: "Users that have not clicked 'Explore my home'"
    type: sum
    sql: ${TABLE}."ALL_EVENTS" - ${explored_myhome} ;;
  }


  set: detail {
    fields: [user_sso_guid_merged, lms_vs_non_lms_user, fall_vs_spring_user, explored_myhome, all_events]
  }
}
