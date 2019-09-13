view: late_activators_removals {
  sql_table_name: strategy.late_cu_course_activators.late_activations_removals ;;

  dimension: user_sso_guid { type:string sql:${TABLE}.merged_guid;;}
  dimension: context_id {type:string}
  dimension: course_key {}
  dimension: activation_date {type:date sql:${TABLE}.actv_dt;;}
  dimension: subscription_end_date {type:date sql:${TABLE}.subscription_end_dt;;}

  dimension_group: _ldts {
    group_label: "Generated"
    label: "Generated"
    type: time
    timeframes: [raw, date]
  }
  dimension: course_name {
    label: "Course Name"
  }
  dimension: institution_nm {
    label: "Institution Name"
  }

  measure: count {
    label: "# Records"
    type: count
  }

  measure: user_count {
    label: "# Students"
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }
}

view: late_activators_messages {
  extends: [late_activators_removals]
  sql_table_name: strategy.late_cu_course_activators.late_activations_all_messages ;;

  dimension: lookup {primary_key: yes hidden:yes}
  dimension: promo_code {}

  dimension: email_msg_type{ type:string
    sql: ${TABLE}.message_type ;;
    }
  dimension: ipm_msg_type{ type:string
    sql: ${TABLE}.ipm_type ;;
    }


}
