# view: covid19_trial_shutoff_schedule {
#   sql_table_name: UPLOADS.IPM_STUDENT_MESSAGING.IPM_DATA ;;

#   view_label: "** COVID19 Shutoff Schedule"

#   dimension: entity_no {
#     type: number
#     sql: ${TABLE}.entity ;;
#     hidden: yes
#     primary_key: yes
#   }

#   dimension_group: date_cu_trial_will_be_shut_off_ok_for_student_message {
#     type: time
#     timeframes: [date, week, month]
#   }

# }
