explore: ab_analysis {}

view: ab_analysis {

  #filters
  # - date range: filter split treatment to a certain date range
  filter: treatment_date_range_filter {
    label: "Choose date range to use as the boundary for the treatment events included in the analysis"
    description: "Select a date range within which the treatment events will occur. Conversions/Retention outside of this date range will not be counted."
    type: date
    datatype: date
  }
  # - time between rule being applied and target action
  parameter: target_time_window_mins {
    label: "Choose the maximum number of minutes between the treatment and the target action"
    type: number
    default_value: "30"

  }
  filter: target_action {
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }
  # - rule name?



  derived_table: {
    sql:
      --get all the users who had a treatment decision
      WITH treated_users AS (
        SELECT
          user_sso_guid
          ,event_time
          ,zandbox.pgriffiths.parse_tags(tags) as tags
          ,ROW_NUMBER() OVER (PARTITION BY user_sso_guid ORDER BY event_time) as rule_application_number
        FROM cap_eventing.prod.client_activity_event
        WHERE {% condition treatment_date_range_filter %} event_time {% endcondition %}
        AND UPPER(event_category) = 'SPLITRULES'
        AND UPPER(event_action) = 'LOADRULE'
      )
      ,target_action AS (
        SELECT
          t.user_sso_guid
          ,t.event_time as rule_application_time
          ,t.rule_application_number
          ,t.tags
          ,t.tags:splitRule::STRING as rule_name
          ,t.tags:treatment::STRING as treatment
          ,e.event_time as target_event_time
          ,e.event_name as target_event
        FROM treated_users t
        LEFT JOIN prod.cu_user_analysis.all_events e ON t.user_sso_guid = e.user_sso_guid
                                                    AND e.event_time > t.event_time
                                                    AND e.event_time <= DATEADD(minute, {% parameter target_time_window_mins %}, t.event_time)
        WHERE {% condition target_action %} event_name {% endcondition %}
      )
      SELECT *
      FROM target_action
      ;;
  }

  dimension: user_sso_guid {}
  dimension: rule_name {}
  dimension_group: rule_application_time {type:time}
  dimension: treatment {
    label: "Treatment Applied"
    type: yesno
    sql: ${TABLE}.treatment = 'on' ;;

  }
  dimension_group: target_event_time {type:time}
  dimension: target_event {}
  dimension_group: target_duration {
    type:duration
    sql_start: ${rule_application_time_raw} ;;
    sql_end: ${target_event_time_raw} ;;
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

  measure: count {
    type: count
  }


  }
