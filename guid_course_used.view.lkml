view: guid_course_used{
    derived_table: {
      explore_source: guid_course_date_active {
        column: number_of_course_use_events {}
        column: course_key {}
        column: user_sso_guid {}
        filters: {
          field: guid_course_date_active.number_of_course_use_events
          value: ">0"
        }
      }
    }
    dimension: number_course_used_events {
      type: number
    }
    dimension: course_key {}

    dimension: course_used {
      type: yesno
      sql: ${user_sso_guid} IS NOT NULL ;;
    }

    dimension: user_sso_guid {
      label: "Guid Course Date Active User SSO GUID"
    }

    measure: courses_used {
      label: "Total courses used"
      type: count_distinct
      sql: ${course_key} ;;
    }

  measure: user_courses_used {
    label: "Total user + courses used"
    description: "Distinct number of user/course combinations"
    type: count_distinct
    sql: ${course_key} || ${user_sso_guid} ;;
  }

  }
