explore: course_faculty {
  hidden:yes
}

explore: course_primary_instructor {
  hidden:yes
}

view: course_primary_instructor {
  extends: [course_faculty]
  label: "Course Section Details"
  derived_table: {
    sql:
    SELECT * FROM ${course_faculty.SQL_TABLE_NAME}
    WHERE is_primary_instructor
    ;;
  }

  dimension_group: date_user_added_to_course {hidden: yes }
  dimension: role {hidden: yes}

  dimension: email {
    group_label: "Primary Instructor"
    label: "Primary instructor Email"
    description: "Primary Instructor Email"
  }

  dimension: name {
    group_label: "Primary Instructor"
    label: "Primary instructor Name"
    description: "Primary Instructor Name"
  }

  dimension: guid {
    group_label: "Primary Instructor"
    label: "Primary Instructor GUID"
    description: "Primary instructor GUID"
  }

  dimension: new_or_returning {
    group_label: "Primary Instructor"
    label: "Primary Instructor New / Returning"
    description: "Value representing whether the primary instructor is new to Cengage or has taught a course before"
  }

  measure: faculty_count {hidden: yes}

}

view: course_faculty {
  label: "Course Section Faculty Members"
  derived_table: {
    sql:
      WITH ci AS (
        SELECT DISTINCT
               COALESCE(sc.course_key, hc.context_id)                                          AS course_identifier
             , se.enrollment_date                                                              AS date_user_added_to_course
             , ROW_NUMBER() OVER (
            PARTITION BY course_identifier, se.access_role
            ORDER BY COALESCE(se.enrollment_date, '1970-01-01')
            )                                                                                  AS enrollment_order
             , enrollment_order = 1 AND se.access_role = 'INSTRUCTOR'                          AS is_primary_instructor
             , COALESCE(su.linked_guid, hu.uid)                                                AS guid
             , ms.snapshot_id
             , ms.org_id
             , MIN(sc.begin_date) OVER (PARTITION BY guid)                                     AS first_course_begin_date
             , DATEDIFF(WEEK, first_course_begin_date, sc.begin_date) <= 12                    AS is_new_customer
             , DATEDIFF(WEEK, first_course_begin_date, sc.begin_date) > 12                     AS is_returning_customer
             , sup.email                                                                       AS email
             , sup.first_name || ' ' || sup.last_name                                          AS name
             , se.access_role                                                                  AS role
             , LEAD(course_identifier) OVER (PARTITION BY guid ORDER BY sc.begin_date) IS NULL AS is_first_course_section
             , COALESCE(sui.internal, FALSE)                                                   AS is_internal_user
               --, COALESCE(suicb.internal, FALSE)                                                 AS is_course_creator_internal
             , HASH(course_identifier, guid)                                                   AS pk
        FROM prod.datavault.link_user_coursesection luc
             INNER JOIN prod.datavault.sat_enrollment se ON luc.hub_enrollment_key = se.hub_enrollment_key AND se._latest
             INNER JOIN prod.datavault.sat_coursesection sc
                        ON luc.hub_coursesection_key = sc.hub_coursesection_key AND sc._latest
             INNER JOIN prod.datavault.hub_coursesection hc ON hc.hub_coursesection_key = luc.hub_coursesection_key
             INNER JOIN prod.datavault.hub_user hu ON luc.hub_user_key = hu.hub_user_key
             INNER JOIN prod.datavault.sat_user_v2 su ON luc.hub_user_key = su.hub_user_key AND su._latest
             INNER JOIN prod.datavault.sat_user_pii_v2 sup ON luc.hub_user_key = sup.hub_user_key AND sup._latest
             LEFT JOIN prod.datavault.sat_user_internal sui ON luc.hub_user_key = sui.hub_user_key AND sui.internal
            -- the following yields no results, we need another way to identify DSS created courses
            --LEFT JOIN prod.datavault.hub_user hucb ON sc.course_created_by_guid = hucb.uid
            --LEFT JOIN prod.datavault.sat_user_internal suicb ON hucb.hub_user_key = suicb.hub_user_key AND suicb.internal
             LEFT JOIN (
            SELECT o.external_id, s.id AS snapshot_id, s.org_id
            FROM mindtap.prod_nb.org o
                 INNER JOIN mindtap.prod_nb.snapshot s ON o.id = s.org_id
        ) ms ON sc.course_key = ms.external_id
        WHERE se.access_role != 'STUDENT'
          AND sui.internal IS NULL
      )
       , stats AS (
        SELECT course_identifier
             , COUNT(CASE WHEN role = 'INSTRUCTOR' THEN 1 END)   AS instructor_count
             , COUNT(CASE WHEN role = 'COINSTRUCTOR' THEN 1 END) AS coinstructor_count
             , COUNT(CASE WHEN role = 'TA' THEN 1 END)           AS ta_count
        FROM ci
        GROUP BY 1
      )
      SELECT *
      FROM ci
           JOIN stats USING (course_identifier)
      ;;

      persist_for: "24 hours"
    }

    set: marketing_fields {fields:[email,is_new_customer,guid]}

    dimension: pk {
      primary_key: yes
      hidden: yes
    }

    dimension: course_identifier {
      type: string
      hidden: yes
    }

    dimension_group: date_user_added_to_course {
      label: "Faculty Added to Course"
      type: time
    }

    dimension: email {
      label: "Faculty Email"
      description: "Please use this Email ID to identify the faculty members linked to a course."
      type: string
      alias: [instructoremail]
    }

  dimension: name {
    label: "Faculty Name"
    description: "Please use this Name to identify the faculty members linked to a course."
    type: string
    alias: [instructorname]
  }

    dimension: role {
      description: "Type of faculty linked to course section (Instructor, TA, Co-instructor)"
      label: "Faculty Role"
      case: {
        when: {label: "Instructor" sql:${TABLE}.role = 'INSTRUCTOR';;}
        when: {label: "Co-Instructor" sql:${TABLE}.role = 'COINSTRUCTOR';;}
        when: {label: "Teaching Assistant" sql:${TABLE}.role = 'TA';;}
        else: "Other"
      }
    }

    dimension: org_id {
      group_label: "MindTap Ids"
      label: "Org ID"
      type: string
      sql: ${TABLE}.ORG_ID ;;
      hidden: yes
    }

    dimension: snapshot_id {
      group_label: "MindTap Ids"
      label: "Snapshot ID"
      type: string
      sql: ${TABLE}.SNAPSHOT_ID ;;
      hidden: yes
    }

    dimension: guid {
      label: "Faculty GUID"
      description: "May be multiple instructor GUID for adjunct prof. etc."
      type: string
      alias: [instructor_guid]
    }

    dimension: new_or_returning {
      label: "Course Section Faculty New / Returning"
      type: string
      description: "Value representing whether the faculty member is new to Cengage or has taught a course before"
      case: {
        when: {label: "New to Cengage" sql:${TABLE}.is_first_course_section;;}
        else: "Returning"
      }
    }

    dimension: is_new_customer {
      description: "Instructor's first term is the current term"
      label: "Course Section Has New Faculty"
      type: yesno
      hidden: yes
    }

    dimension: is_returning_customer {
      description: "Instructor first term is not the current term and instructor has course in the current term"
      label: "Course Section Has Returning Instructor"
      type: yesno
      hidden: yes
    }

    dimension: instructor_count {
      view_label: "Course Section Details"
      group_label: "Faculty Staff Counts"
      label: "# Course Section Instructors"
      description: "Unique count of instructor guids on related course sections"
      type: number
      value_format_name: decimal_0
      hidden: no
    }

    dimension: instructor_count_tier {
      view_label: "Course Section Details"
      group_label: "Faculty Staff Counts"
      label: "# Course Section Instructors (Buckets)"
      description: "Unique count of instructor guids on related course sections"
      type: tier
      tiers: [1, 2, 3, 5]
      style: integer
      sql: ${instructor_count} ;;
      value_format_name: decimal_0
      hidden: no
    }

    dimension: coinstructor_count {
      view_label: "Course Section Details"
      group_label: "Faculty Staff Counts"
      label: "# Course Section Co-Instructors"
      description: "Unique count of Co-instructor guids on related course sections"
      type: number
      value_format_name: decimal_0
      hidden: no
    }

    dimension: coinstructor_count_tier {
      view_label: "Course Section Details"
      group_label: "Faculty Staff Counts"
      label: "# Course Section Co-Instructors (Buckets)"
      description: "Unique count of instructor guids on related course sections"
      type: tier
      tiers: [1, 2, 3, 5]
      style: integer
      sql: ${coinstructor_count} ;;
      value_format_name: decimal_0
      hidden: no
    }

    dimension: ta_count {
      view_label: "Course Section Details"
      group_label: "Faculty Staff Counts"
      label: "# Course Section Teaching Assistants"
      description: "Unique count of Co-instructor guids on related course sections"
      type: number
      value_format_name: decimal_0
      hidden: no
    }

    dimension: ta_count_tier {
      view_label: "Course Section Details"
      group_label: "Faculty Staff Counts"
      label: "# Course Section Teaching Assistants (Buckets)"
      description: "Unique count of instructor guids on related course sections"
      type: tier
      tiers: [1, 2, 3, 5]
      style: integer
      sql: ${ta_count} ;;
      value_format_name: decimal_0
      hidden: no
    }

    measure: faculty_count {
      type: count_distinct
      label: "# Faculty Linked to Course Section(s)"
      description: "This counts the total unique number of faculty (guids) that have been linked to any course section in your result set"
      sql: ${guid} ;;
      hidden: no

    }

  }
