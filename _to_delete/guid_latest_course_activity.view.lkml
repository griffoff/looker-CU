# include: "guid_course_date_active.view"

# view: guid_latest_course_activity {
#   derived_table: {
#     explore_source: guid_course_date_active {
#       column: user_sso_guid { field: guid_course_date_active.user_sso_guid }
#       column: course_key { field: guid_course_date_active.course_key }
#       column: date { field: guid_course_date_active.date }
#       filters: {
#         field: guid_course_date_active.latest_by_course
#         value: "Yes"
#       }
#     }

#   }
#   dimension: course_key {hidden:yes}

#   dimension: user_sso_guid {hidden:yes}
#   dimension: date {
#     label: "Latest Date of Activity"
#     description: "Last day user was active in a course"
#   }

#   dimension: active {
#     group_label: "Active"
#     label: "User Active in Course Section Flag"
#     description: "Active users are those who have had some activity on a given course section within the past 7 days"
#     type: yesno
#     sql: ${date} >= DATEADD(day, -7, CURRENT_DATE()) ;;
#   }
#   dimension: active_desc {
#     group_label: "Active"
#     label: "User Active in Course Section (Description)"
#     description: "Active / Inactive In Course Section (activity in past 7 days)"
#     type: string
#     sql: CASE WHEN ${active} THEN 'Active in Course Section' ELSE 'Inactive in Course Section' END ;;

#   }
# }
