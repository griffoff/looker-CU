explore: date_user_type_count {}
view: date_user_type_count {
  derived_table: {
    sql:
      SELECT date, 'Registered Student Users' AS user_type, students AS user_count
      FROM PROD.LOOKER_SCRATCH.yru
      UNION ALL
      SELECT date, 'Registered Instructor Users' AS user_type, instructors AS user_count
      FROM PROD.LOOKER_SCRATCH.yru
      UNION ALL
      SELECT date, 'Digital Student Users' AS user_type, digital_users AS user_count
      FROM ${daily_digital_users.SQL_TABLE_NAME}
      UNION ALL
      SELECT date, 'Instructors with Active Digital Course' AS user_type, courseware_instructors AS user_count
      FROM ${daily_digital_users.SQL_TABLE_NAME}
      UNION ALL
      SELECT date, 'Paid Student Users' AS user_type, paid_user_count AS user_count
      FROM ${daily_paid_users.SQL_TABLE_NAME}
      UNION ALL
      SELECT date, 'Paid Courseware Student Users' AS user_type, paid_courseware_users AS user_count
      FROM ${daily_paid_users.SQL_TABLE_NAME}
      UNION ALL
      SELECT date, 'Paid eBook Only Student Users' AS user_type, paid_ebook_users AS user_count
      FROM ${daily_paid_users.SQL_TABLE_NAME}
      UNION ALL
      SELECT date, 'Full Access CU Users, no provisions' AS user_type, paid_cu_users AS user_count
      FROM ${daily_paid_users.SQL_TABLE_NAME}
      ;;

      persist_for: "24 hours"
    }

    dimension: date {
      hidden:  yes
      type: date}

    dimension: max_date {
      hidden: yes
      type: date
#       sql: (SELECT MAX(dateadd(d,-1,date)) FROM ${date_user_type_count.SQL_TABLE_NAME});;
      sql: (SELECT MAX(date) FROM ${date_user_type_count.SQL_TABLE_NAME});;
    }

    dimension: user_type {
      group_label: "Visualization Dimensions"
      description: "REGISTERED USERS: Event or account modification in the past year
       _____ DIGITAL STUDENT USERS: Access to course, ebook, or CU (trial inc.)
       _____ PAID STUDENT USERS: Access to course, ebook, or CU (no trials)
       _____ PAID COURSEWARE: Paid access to an active course
       _____ PAID EBOOK ONLY: Paid access to ebook, but no active courses
       _____ FULL ACCESS CU USERS, NO PROVISIONS: Full access CU, but no active courses or ebook access
       _____ INSTRUCTORS WITH ACTIVE DIGITAL COURSE: Course has students enrolled, past start date, and future end date"
      type:string
      hidden: no
      }

    dimension: user_count {
      group_label: "Visualization Dimensions"
      description: "For visualization only. Use with Date & User Type to show table breakdown for Current Student and Instructor Users"
      type:number
      hidden: no
      }

      measure: average_user_count {
        group_label: "Visualization Dimensions"
        type: average
        sql: ${user_count};;
        value_format_name: decimal_0

      }

 }
