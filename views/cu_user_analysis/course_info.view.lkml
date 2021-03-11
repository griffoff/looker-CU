include: "//dm-bpl/dm-shared/*.view"
include: "course_section_usage_facts.view"
include: "product_info.view"
include: "course_faculty.view"
include: "custom_course_key_cohort_filter.view"
include: "gateway_lms_course_sections.view"

explore: course_info {
  from: course_info
  view_name: course_info

  extends: [product_info,institution_info]
  hidden:yes
  view_label: "Course Section Details"

  join: dim_course_start_date  {
    sql_on: ${course_info.begin_date_raw} = ${dim_course_start_date.date_value};;
    relationship: many_to_one
  }

  join: dim_course_end_date  {
    sql_on: ${course_info.begin_date_raw} = ${dim_course_end_date.date_value};;
    relationship: many_to_one
  }

  join: course_primary_instructor {
    sql_on: ${course_info.course_identifier} = ${course_primary_instructor.course_identifier} ;;
    relationship: one_to_many
  }

  join: product_info {
    view_label: "Course Product Details"
    sql_on: ${course_info.iac_isbn} = ${product_info.isbn13} ;;
    relationship: many_to_one
  }

  join: product_discipline_rank {
    view_label: "Course Product Details"
  }

  join: institution_info {
    view_label: "Course Institution Details"
    sql_on: ${course_info.institution_id} = ${institution_info.institution_id} ;;
    relationship: many_to_one
  }

  join: gateway_institution {
    view_label: "Course Institution Details"
  }

  join: course_section_usage_facts {
    sql_on:  ${course_info.course_identifier} = ${course_section_usage_facts.course_key} ;;
    relationship: one_to_one
    view_label: "Course Section Details"
  }

  join: custom_course_key_cohort_filter {
    view_label: "*** Custom Course Key Cohort Filter ***"
    sql_on: ${course_info.course_identifier} = ${custom_course_key_cohort_filter.course_key} ;;
    relationship: many_to_many
  }

  join: gateway_lms_course_sections {
    sql_on: ${course_info.course_identifier} = ${gateway_lms_course_sections.olr_context_id};;
    relationship: one_to_one
    view_label: "Course Section Details"
  }

}

view: course_info_base {
  #extends: [base]
  extension: required
  view_label: "Course Section Details"
  #parameter: label_name {default_value: "Course Section Info"}
  #parameter: label_name_plural {default_value: "Course Sections"}
}

view: dim_course_start_date {
  extends: [course_info_base, dim_date]
  parameter: group_label_name {
    default_value: "Course Start Date"
  }
}

view: dim_course_end_date {
  extends: [course_info_base, dim_date]
  parameter: group_label_name {
    default_value: "Course End Date"
  }
}

view: course_info {
  extends: [course_info_base]

  derived_table: {
    sql:
      WITH el AS (
          SELECT context_id
               , (sel.cu_enabled OR iac_isbn13 IN ('0000357700006', '0000357700013', '0000357700020')) AS cui
               , NOT cui                                                                               AS ia
               , ROW_NUMBER() OVER (PARTITION BY context_id ORDER BY sel.begin_date DESC) = 1          AS latest
          FROM prod.datavault.hub_coursesection hcs
               INNER JOIN prod.datavault.sat_coursesection scs
                          ON hcs.hub_coursesection_key = scs.hub_coursesection_key AND scs._latest
               INNER JOIN prod.datavault.link_coursesection_eltosectionmapping lecsm
                          ON hcs.hub_coursesection_key = lecsm.hub_coursesection_key
               INNER JOIN prod.datavault.link_enterpriselicense_eltosectionmapping lelsm
                          ON lelsm.hub_eltosectionmapping_key = lecsm.hub_eltosectionmapping_key
               INNER JOIN prod.datavault.sat_enterpriselicense sel
                          ON lelsm.hub_enterpriselicense_key = sel.hub_enterpriselicense_key
                              AND sel._latest
                              AND scs.begin_date BETWEEN sel.begin_date AND sel.end_date
               INNER JOIN prod.datavault.sat_eltosectionmapping secsm
                          ON lecsm.hub_eltosectionmapping_key = secsm.hub_eltosectionmapping_key
                              AND secsm._latest
      )
         , lms AS (
          SELECT hcs.hub_coursesection_key
               , COALESCE(scg.lms_type, a.kind)                                                                                  AS lms_type
               , 'v' || NULLIF(scg.lms_version, '')                                                                              AS lms_version
               , scg.integration_type
               , LEAD(1)
                      OVER (PARTITION BY hcs.hub_coursesection_key ORDER BY COALESCE(scg.created_at, a.created_at) DESC) IS NULL AS latest
               , scg.canvas_course_id
               , scg.lms_context_id
               , scg.lis_course_source_id
          FROM prod.datavault.hub_coursesection hcs
               LEFT JOIN prod.datavault.link_coursesectiongateway_coursesection lcsg
                         ON hcs.hub_coursesection_key = lcsg.hub_coursesection_key
               LEFT JOIN prod.datavault.sat_coursesection_gateway scg
                         ON lcsg.hub_coursesectiongateway_key = scg.hub_coursesectiongateway_key AND scg._latest
               LEFT JOIN webassign.wa_app_v4net.sections s ON hcs.context_id = s.olr_context_id
               LEFT JOIN webassign.wa_app_v4net.courses crs ON crs.id = s.course
               LEFT JOIN webassign.wa_app_v4net.schools sch ON sch.id = crs.school
               LEFT JOIN webassign.wa_app_v4net.partner_applications a ON a.school_id = sch.id
          WHERE scg.lms_type IS NOT NULL
             OR a.kind IS NOT NULL
      )
         , impersonation AS (
          SELECT zandbox.pgriffiths.parse_tags(tags)     AS tag_values
               , tag_values:contextId::STRING            AS context_id
               , tag_values:impersonatorUserType::STRING AS impersonator_user_type
               , tag_values:isImpersonated::BOOLEAN      AS is_impersonated
               , tag_values:userType::STRING             AS user_type
              -- there should only be one course creation event, but just to be safe...
               , ROW_NUMBER() OVER (PARTITION BY context_id ORDER BY event_time) = 1 AS first_event
          FROM cap_eventing.prod.client_activity_event AS cafe_eventing_client_activity_event
          WHERE cafe_eventing_client_activity_event.product_platform = 'irc-dashboard'
            AND cafe_eventing_client_activity_event.event_category = 'courseManagement'
            AND cafe_eventing_client_activity_event.event_action = 'courseCreate'
      )
         , course_creation AS (
          SELECT context_id
               , is_impersonated                                                    AS course_creation_is_impersonated
               , impersonator_user_type                                             AS course_creation_impersonator_user_type
               , user_type                                                          AS course_creation_user_type
               , NOT is_impersonated AND user_type IN ('internal', 'sales')         AS course_creation_internal
               , NOT is_impersonated AND user_type NOT IN ('internal', 'sales')     AS course_creation_self_serve
          FROM impersonation
          WHERE first_event
      )
          , enrollments AS (
          SELECT hub_coursesection_key, COUNT(DISTINCT hub_enrollment_key) AS enrollments_count
          FROM prod.datavault.link_user_coursesection luc
          GROUP BY 1
      )
      SELECT DISTINCT
             hcs.context_id
           , scs.course_key
           , COALESCE(scs.course_key, hcs.context_id)                                        AS course_identifier
           , scs.course_name
           , scs.begin_date
           , scs.end_date
           , scs.iac_isbn
           -- , scs.begin_date::DATE <= CURRENT_DATE() AND scs.end_date >= CURRENT_DATE()::DATE AS active
           , COALESCE(CURRENT_DATE BETWEEN scs.begin_date::DATE and COALESCE(scs.end_date,CURRENT_DATE),FALSE) AS active
           , COALESCE(scs.deleted, FALSE)                                                    AS deleted
           , scs.grace_period_end_date
           , scs.created_on
           , scs.is_gateway_course
           , scs.course_created_by_guid                                                      AS course_created_by_user
           , COALESCE(TRY_CAST(scs.course_master AS BOOLEAN), FALSE)                         AS course_master
           , scs.course_cgi
           , scs.section_product_type
           , COALESCE(scs.is_demo, FALSE)                                                    AS is_demo
           , COALESCE(
                     UPPER(DECODE(lms.lms_type, 'BB', 'Blackboard', lms.lms_type))
                 , CASE WHEN scs.is_gateway_course THEN 'UNKNOWN LMS' ELSE 'NOT LMS INTEGRATED' END
                 )                                                                           AS lms_type_all
           , lms_type_all <> 'NOT LMS INTEGRATED'                                            AS is_lms_integrated
           , lms.lms_version
           , lms.canvas_course_id
           , lms.lms_context_id
           , lms.lis_course_source_id
           , COALESCE(
                     lms.integration_type
                 , CASE
                       WHEN lms_type_all = 'UNKNOWN LMS' THEN 'UNKNOWN LMS'
                       WHEN is_lms_integrated THEN 'UNKNOWN INTEGRATION TYPE'
                       ELSE 'NOT LMS INTEGRATED' END
                 )                                                                           AS integration_type
           , lms.lms_type IS NOT NULL AND g.lms_sync_course_scores                           AS mt_lms_sync_course_scores
           , lms.lms_type IS NOT NULL AND g.lms_sync_activity_scores                         AS mt_lms_sync_activity_scores
           , CASE
                 WHEN NOT is_lms_integrated THEN 'N/A'
                 WHEN mt_lms_sync_course_scores THEN 'Course Level'
                 WHEN mt_lms_sync_activity_scores THEN 'Activity Level'
                 WHEN NOT mt_lms_sync_course_scores AND NOT mt_lms_sync_activity_scores THEN 'No score sync'
                 ELSE 'Non Mindtap LMS'
                 END                                                                         AS lms_grade_sync
           , COALESCE(el.cui, FALSE)                                                         AS cui
           , COALESCE(el.ia, FALSE)                                                          AS ia
           , CASE WHEN cui THEN 'CUI' WHEN ia THEN 'IA' ELSE 'No License' END                AS institutional_license_type
           , inst.institution_id
           , course_creation.course_creation_is_impersonated
           , course_creation.course_creation_impersonator_user_type
           , course_creation.course_creation_user_type
           , course_creation.course_creation_internal
           , course_creation.course_creation_self_serve
           , e.enrollments_count
      FROM prod.datavault.hub_coursesection hcs
           LEFT JOIN enrollments e ON hcs.hub_coursesection_key = e.hub_coursesection_key
           LEFT JOIN (
          SELECT DISTINCT
                 sc.*
               , LEAD(1)
                      OVER (PARTITION BY course_key ORDER BY context_id = course_key DESC, _effective_from) IS NULL AS _latest_by_course_key
          FROM prod.datavault.sat_coursesection sc
               INNER JOIN prod.datavault.hub_coursesection hc ON hc.hub_coursesection_key = sc.hub_coursesection_key
      ) scs ON hcs.hub_coursesection_key = scs.hub_coursesection_key AND
               (scs._latest_by_course_key OR (scs.course_key IS NULL AND scs._latest))
           LEFT JOIN lms ON hcs.hub_coursesection_key = lms.hub_coursesection_key AND lms.latest
           LEFT JOIN (
          SELECT DISTINCT
                 external_id
               , LAST_VALUE(lms_sync_course_scores)
                            IGNORE NULLS OVER (PARTITION BY external_id ORDER BY _fivetran_synced) AS lms_sync_course_scores
               , LAST_VALUE(lms_sync_activity_scores)
                            IGNORE NULLS OVER (PARTITION BY external_id ORDER BY _fivetran_synced) AS lms_sync_activity_scores
          FROM mindtap.prod_nb.gradebook
      ) g ON hcs.context_id = g.external_id
           LEFT JOIN el ON hcs.context_id = el.context_id AND el.latest
           LEFT JOIN prod.datavault.sat_coursesection scs2 ON scs2.course_key = hcs.context_id
           LEFT JOIN (
          SELECT DISTINCT
                 COALESCE(sc.course_key, hc.context_id)                                                                                 AS course_identifier
               , LAST_VALUE(COALESCE(hi.institution_id, hi2.institution_id))
                            IGNORE NULLS OVER (PARTITION BY course_identifier ORDER BY sc._ldts,lci._ldts,hi2._ldts,hi2.institution_id) AS institution_id
          FROM prod.datavault.hub_coursesection hc
               LEFT JOIN prod.datavault.sat_coursesection sc
                         ON sc.hub_coursesection_key = hc.hub_coursesection_key AND sc._latest
               LEFT JOIN (
              SELECT DISTINCT *
              FROM prod.datavault.hub_institution hi
                   INNER JOIN prod.datavault.sat_institution_saws si
                              ON si.hub_institution_key = hi.hub_institution_key AND si._latest
          ) hi ON hi.institution_id = sc.institution_id
               LEFT JOIN prod.datavault.link_coursesection_institution lci
                         ON lci.hub_coursesection_key = hc.hub_coursesection_key
               LEFT JOIN (
              SELECT DISTINCT hi.*
              FROM prod.datavault.hub_institution hi
                   INNER JOIN prod.datavault.sat_institution_saws si
                              ON si.hub_institution_key = hi.hub_institution_key AND si._latest
          ) hi2 ON lci.hub_institution_key = hi2.hub_institution_key
      ) inst ON inst.course_identifier = COALESCE(scs.course_key, hcs.context_id)
           LEFT JOIN course_creation ON hcs.context_id = course_creation.context_id
      WHERE (scs.course_key IS NOT NULL OR scs2.course_key IS NULL)
    ;;
    sql_trigger_value: select count(*) from prod.datavault.sat_coursesection ;;
  }

  dimension: course_identifier {
    hidden: no
    primary_key: yes
    description: "Course Key if it exists for a section, otherwise the context id"
    link: {
      label: "Student Activity Timeline"
      url:"https://cengage.looker.com/dashboards-next/1058?course_key={{ course_key._value }}"
    }

  }

  dimension: context_id  {label:"Context ID" hidden:yes}

  dimension: course_key {
    hidden:no
    link: {
      label: "Student Activity Dashboard"
      url:"https://cengage.looker.com/dashboards-next/1058?course_key={{ course_key._value }}"
      }
    link: {
      label: "Student Activity Timeline"
      url:"https://cengage.looker.com/looks/6069?filters[course_info.course_key]={{ course_key._value }}"
    }
    }

  dimension: course_name {
    link: {
      label: "Student Activity Timeline"
      url:"https://cengage.looker.com/looks/6069?filters[course_info.course_key]={{ course_key._value }}"
    }
  }

  dimension: course_created_by_category {
    group_label: "Course Creation"
    case: {
      when: {label: "Created By Cengage Employee" sql: course_creation_is_impersonated OR course_creation_internal;;}
      when: {label: "Created By Faculty" sql: course_creation_self_serve;;}
      when: {label: "Created Via Enterprise License" sql: LEFT(${course_key}, 2) = 'EL';;}
      when: {label: "Created Via K12 Rostering" sql: ${course_created_by_user} = 'app_k12_rostering';;}
      when: {label: "Created Via Magellan" sql: ${course_created_by_user} = 'app_crms_servicedirect';;}
      when: {label: "Created Via Gateway" sql: ${course_created_by_user} = 'app_the_gateway';;}
      when: {label: "Created Via WebAssign" sql: ${course_created_by_user} = 'app_web_assign';;}
      when: {label: "Created Via CNOW" sql: ${course_created_by_user} IN ('app_cnow_v8', 'app_cnow_v7');;}
      when: {label: "Created Via SAM" sql: ${course_created_by_user} = 'app_gnm_sam';;}
      when: {label: "Created Via Aplia" sql: ${course_created_by_user} = 'app_aplia_sso';;}
      when: {label: "Created Via OLR Admin" sql: ${course_created_by_user} = 'olradminu';;}
      when: {label: "UNKNOWN (app_gnm_ng)" sql: ${course_created_by_user} = 'app_gnm_ng';;}
      when: {label: "UNKNOWN (app_cengage_sso)" sql: ${course_created_by_user} = 'app_cengage_sso';;}
      when: {label: "UNKNOWN (app_fx)" sql: ${course_created_by_user} = 'app_fx';;}
      when: {label: "UNKNOWN (app_wms)" sql: ${course_created_by_user} = 'app_wms';;}
      else: "UNKNOWN"
    }
  }

  dimension: course_creation_user_type {group_label: "Course Creation" hidden:yes}
  dimension: course_creation_impersonator_user_type {group_label: "Course Creation" hidden:yes}

  dimension: course_created_by_user {group_label: "Course Creation"hidden:yes}

  dimension_group: begin_date {
    label: "Course Start"
    type: time
    sql: CONVERT_TIMEZONE('EST', ${TABLE}.begin_date::DATE) ;;
  }

  dimension_group: end_date {
    label: "Course End"
    type: time
    sql: CONVERT_TIMEZONE('EST', ${TABLE}.end_date::DATE) ;;
  }

  dimension: active {
    label: "Is Course Active"
    type:yesno
    description: "Course start date in the past and course end date in the future."
  }

  dimension: deleted {
    label: "Is Course Deleted"
    type:yesno
    description: "OLR course section has been deleted"
  }

  dimension_group: grace_period_end_date  {
    label: "Grace Period End"
    type: time
  }

  dimension_group: created_on  {
    label: "Course Created"
    type: time
  }

  dimension: is_gateway_course {type:yesno hidden:yes}

  dimension: course_master {
    label: "Is Course Master"
    type: yesno
    description: "Is a Master Course"
  }

  dimension: course_cgi {
    label: "Course CGI"
  }

  dimension: iac_isbn {
    hidden: yes
  }

  dimension: is_demo {
    type:yesno
    label: "Is Demo Course"
    hidden: yes
  }

  dimension: is_real_course {
    type: yesno
    label: "Is Real Course"
    description: "Course for actual students rather than a demo/internal course"
    sql: NOT ${is_demo} ;;
  }

  dimension: lms_type_all {
    label: "LMS Type"
    description: "Blackboard, Canvas, etc."
    group_label: "LMS Integration"
  }

  dimension: lms_version {
    label: "LMS Version"
    group_label: "LMS Integration"
  }

  dimension: integration_type {
    label: "LMS Integration Type"
    group_label: "LMS Integration"
  }

  dimension: lms_context_id {
    label: "LMS Context ID"
    description: "Context ID of LMS Course"
    group_label: "LMS Integration"
  }

  dimension: canvas_course_id {
    label: "Canvas Course ID"
    description: "Course ID of Canvas Course"
    group_label: "LMS Integration"
  }

  dimension: lis_course_source_id {
    label: "SIS Course ID"
    description: "SIS ID of LMS Course"
    group_label: "LMS Integration"
  }


  dimension: mt_lms_sync_course_scores {type:yesno hidden:yes}

  dimension: mt_lms_sync_activity_scores  {type:yesno hidden:yes}

  dimension: is_lms_integrated {
    type:yesno
    label: "Is LMS Integrated"
    description: "Course is LMS integrated"
    group_label: "LMS Integration"
  }

  dimension: lms_grade_sync {
    label: "LMS Grade Sync"
    description: "Type of MindTap LMS grade sync, i.e. Activity Level or Course Level"
    group_label: "LMS Integration"
  }

  dimension: cui {
    type:yesno
    label: "Is CUI"
    description: "Course is part of a CUI deal"
    group_label: "Institional Access Deal"
  }

  dimension: ia {
    type:yesno
    label: "Is IA"
    description: "Course is part of an IA deal"
    group_label: "Institional Access Deal"
  }

  dimension: institutional_license_type {
    description: "IA or CUI"
    group_label: "Institional Access Deal"
  }

  dimension: enrollments_count {
    group_label: "Course User Counts"
    label: "Total Course Enrollments"
    type: number
    description: "Total number of enrollments on course"
  }

  dimension: enrollments_count_tier {
    group_label: "Course User Counts"
    label: "Total Course Enrollments (buckets)"
    type: tier
    tiers: [5, 10, 30, 50, 100]
    style: integer
    sql: ${enrollments_count} ;;
  }

  dimension: institution_id {hidden:yes}

  dimension: section_product_type {}

  measure: count {
    type: count
    label: "# Courses"
  }

  measure: active_course_sections {
    label: "# Active Course Sections"
    description: "Count of Course Sections where today is between the start and end date of the course section"
    type: count_distinct
    sql: CASE WHEN ${active} THEN ${course_key} END ;;
  }

  measure: active_course_list {
    label: "List of Active Courses"
    type: string
    sql: CASE
          WHEN COUNT(DISTINCT CASE WHEN ${active} THEN ${course_identifier} END) > 10 THEN ' More than 10 courses... '
          ELSE
          LISTAGG(DISTINCT CASE WHEN ${active} THEN ${course_name} END, ', ')
            WITHIN GROUP (ORDER BY CASE WHEN ${active} THEN ${course_name} END)
        END ;;
    description: "List of active courses by name"
  }

}
