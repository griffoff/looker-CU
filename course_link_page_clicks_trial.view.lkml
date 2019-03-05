explore:  course_link_page_clicks_trial {}

view: course_link_page_clicks_trial {
  derived_table: {
    sql: SELECT
                  r.user_sso_guid_merged
                  ,DATEDIFF('day',r.subscription_start, e.event_time) AS day_in_trial
                  ,Count(distinct case when event_action ilike '%course page%' THEN event_id else null END) as Register_PAC
                  ,Count(distinct case when event_name ilike 'back to Cu Home Page' THEN event_id else null END) as Explored_myHome
                  ,COUNT(distinct case when event_action ilike 'unlimited%'  and event_data:event_label ilike 'true%' THEN event_id else NULL END ) as Clicked_Buy_CU
                  ,COUNT(distinct case when event_action ilike 'unlimited%'  and event_data:event_label ilike 'false%' THEN event_id else NULL END ) as Clicked_A_La_Carte
                  ,COUNT(distinct case when event_name ilike '%UPGRADE%' THEN event_id else NULL end) as clicked_on_Upgrade
                  ,COUNT(distinct case when event_name ilike 'continue to course' THEN event_id else NULL end) as checked_out_courseware
                  ,COUNT(distinct case when event_name ilike '%chegg%' OR event_name ilike 'Study Resource Clicked' THEN event_id else NULL end) as partner_clicked
                  ,COUNT(distinct case when event_name ilike 'ebook launched' THEN event_id else NULL end) as ebooks_launched
                  ,COUNT(distinct case when event_name ilike 'courseware launched' THEN event_id else NULL end) as courseware_launched
                  ,COUNT(DISTINCT CASE WHEN product_platform ILIKE 'cu dashboard' THEN event_id END) AS all_events
              FROM zpg.raw_subscription_event_merged_erroneous_removed r
              LEFT JOIN zpg.all_events e
                  ON r.user_sso_guid_merged = e.user_sso_guid
                  AND e.event_time >= r.subscription_start
                  AND e.event_time <= r.subscription_end
              WHERE r.subscription_state = 'trial_access'
              GROUP BY 1, 2
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

  dimension: day_in_trial {
    type: number
    sql: ${TABLE}."DAY_IN_TRIAL" ;;
  }

  dimension: register_pac {
    type: number
    sql: ${TABLE}."REGISTER_PAC" ;;
  }

  measure: register_pac_m {
    label: "register pac"
    type: sum
    sql: ${register_pac} ;;
  }

  dimension: explored_myhome {
    type: number
    sql: ${TABLE}."EXPLORED_MYHOME" ;;
  }

  measure: explored_myhome_m {
    label: "explored myhome"
    type: sum
    sql: ${TABLE}."EXPLORED_MYHOME" ;;
  }

  dimension: clicked_buy_cu {
    type: number
    sql: ${TABLE}."CLICKED_BUY_CU" ;;
  }

  measure: clicked_buy_cu_m {
    label: "clicked buy cu"
    type: sum
    sql: ${TABLE}."CLICKED_BUY_CU" ;;
  }

  dimension: clicked_a_la_carte {
    type: number
    sql: ${TABLE}."CLICKED_A_LA_CARTE" ;;
  }

  measure: clicked_a_la_carte_m {
    label: "clicked a la carte"
    type: sum
    sql: ${TABLE}."CLICKED_A_LA_CARTE" ;;
  }

  dimension: clicked_on_upgrade {
    type: number
    sql: ${TABLE}."CLICKED_ON_UPGRADE" ;;
  }

  measure: clicked_on_upgrade_m {
    label: "clicked on upgrade"
    type: sum
    sql: ${TABLE}."CLICKED_ON_UPGRADE" ;;
  }

  dimension: checked_out_courseware {
    type: number
    sql: ${TABLE}."CHECKED_OUT_COURSEWARE" ;;
  }

  measure: checked_out_courseware_m {
    label: "checked out courseware"
    type: sum
    sql: ${TABLE}."CHECKED_OUT_COURSEWARE" ;;
  }

  dimension: partner_clicked {
    type: number
    sql: ${TABLE}."PARTNER_CLICKED" ;;
  }

  measure: partner_clicked_m {
    label: "Clicked on Partner links"
    type: sum
    sql: ${TABLE}."PARTNER_CLICKED" ;;
  }

  dimension: ebooks_launched {
    type: number
    sql: ${TABLE}."EBOOKS_LAUNCHED" ;;
  }

  measure: ebooks_launched_m {
    label: "Ebooks Launched"
    type: sum
    sql: ${TABLE}."EBOOKS_LAUNCHED" ;;
  }

  dimension: courseware_launched {
    type: number
    sql: ${TABLE}."COURSEWARE_LAUNCHED" ;;
  }

  measure: courseware_launched_m {
    label: "Courseware Launched"
    type: sum
    sql: ${TABLE}."COURSEWARE_LAUNCHED" ;;
  }


  dimension: all_events {
    type: number
    sql: ${TABLE}."ALL_EVENTS" ;;
  }

  measure: all_events_m {
    type: sum
    label: "Other events"
    sql: ${TABLE}."ALL_EVENTS" - (checked_out_courseware + clicked_on_upgrade
    + clicked_buy_cu + explored_myhome + register_pac + partner_clicked + courseware_launched
    + ebooks_launched);;
  }

  set: detail {
    fields: [
      user_sso_guid_merged,
      day_in_trial,
      register_pac,
      explored_myhome,
      clicked_buy_cu,
      clicked_a_la_carte,
      clicked_on_upgrade,
      checked_out_courseware,
      all_events
    ]
  }
}
