explore: course_instructor {hidden:yes}
view: course_instructor {
  label: "Course Section Details"
  derived_table: {
    sql:
        select distinct
        coalesce(sc.course_key,hc.context_id) as course_identifier
        ,coalesce(su.linked_guid, hu.uid) as guid
        ,ms.snapshot_id
        ,ms.org_id
        ,datediff(week, min(sc.begin_date) over(partition by guid), sc.begin_date) <= 12 as is_new_customer
        ,datediff(week, min(sc.begin_date) over(partition by guid), sc.begin_date) > 12 as is_returning_customer
        ,sup.email as instructoremail
        ,se.access_role as role
        ,lead(course_identifier) over(partition by guid order by sc.begin_date) is null as first_course_section
        ,hash(course_identifier, guid) as pk
    from prod.datavault.link_user_coursesection luc
    inner join prod.datavault.sat_enrollment se on luc.hub_enrollment_key = se.hub_enrollment_key and se._latest
    inner join prod.datavault.sat_coursesection sc on luc.hub_coursesection_key = sc.hub_coursesection_key
    inner join prod.datavault.hub_coursesection hc on hc.hub_coursesection_key = luc.hub_coursesection_key
    inner join prod.datavault.hub_user hu on luc.hub_user_key = hu.hub_user_key
    inner join prod.datavault.sat_user_v2 su on luc.hub_user_key = su.hub_user_key and su._latest
    inner join prod.datavault.sat_user_pii_v2 sup on luc.hub_user_key = sup.hub_user_key and sup._latest
    left join (
        select o.external_id, s.id as snapshot_id, s.org_id
        from mindtap.prod_nb.org o
        inner join mindtap.prod_nb.snapshot s on o.id = s.org_id
            ) ms on sc.course_key = ms.external_id
    where se.access_role != 'STUDENT'
    ;;

      persist_for: "24 hours"
    }

    set: marketing_fields {fields:[instructoremail,is_new_customer,instructor_guid]}

    dimension: pk {
      primary_key: yes
      hidden: yes
    }

    dimension: course_identifier {
      type: string
      hidden: yes
    }

    dimension: instructoremail {
      group_label: "Instructor(s)"
      label: "Instructor Email"
      description: "Please use this Email ID to identify the instructor linked to a course. We do not have an instructor name field yet"
      type: string
      sql: ${TABLE}.INSTRUCTOREMAIL ;;
    }

#   dimension: instructorid {
#     label: "Instructor ID"
#     type: string
#     sql: ${TABLE}.INSTRUCTORID ;;
#     hidden: yes
#   }

    dimension: org_id {
      label: "Org ID"
      type: string
      sql: ${TABLE}.ORG_ID ;;
      hidden: yes
    }

    dimension: role {
      group_label: "Instructor(s)"
      description: "Type of instructor on course (instructor, TA, co-instructor)"
      label: "Course Instructor Role"
      type: string
      sql: ${TABLE}.ROLE ;;
    }

    dimension: snapshot_id {
      label: "Snapshot ID"
      type: string
      sql: ${TABLE}.SNAPSHOT_ID ;;
      hidden: yes
    }

    dimension: instructor_guid {
      label: "Instructor GUID"
      group_label: "Instructor(s)"
      description: "May be multiple instructor GUID for adjunct prof. etc."
      type: string
      sql: ${TABLE}."GUID" ;;
    }

    dimension: new_or_returning {
      label: "Course Section Instructor New / Returning"
      type: string
      description: "Value representing whether the instructor is new to Cengage or returning"
      group_label: "Instructor(s)"
      sql: CASE WHEN ${TABLE}.first_course_section THEN 'New to Cengage' ELSE 'Returning' END ;;
    }

    dimension: is_new_customer {
      group_label: "Instructor(s)"
      description: "Instructor's first term is the current term"
      label: "Course Section Has New Instructor"
      type: yesno
      sql:  ${TABLE}."IS_NEW_CUSTOMER" = 1 ;;
    }

    dimension: is_returning_customer {
      group_label: "Instructor(s)"
      description: "Instructor first term is not the current term and instructor has course in the current term"
      label: "Course Section Has Returning Instructor"
      type: yesno
      sql:  ${TABLE}."IS_RETURNING_CUSTOMER" = 1 ;;
    }

    measure: instructor_count {
      label: "# Course Section Instructors"
      description: "Unique count of instructor guids on related course sections"
      hidden: no
      type: count_distinct
      sql: ${instructor_guid} ;;
    }

    measure: count {
      label: "# Instructors on course"
      hidden: yes
      type: count
      drill_fields: []
    }
  }