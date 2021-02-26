include: "//dm-bpl/dm-shared/*.view"
include: "course_section_usage_facts.view"
include: "product_info.view"
include: "custom_course_key_cohort_filter.view"
include: "gateway_lms_course_sections.view"

explore: course_info {
  hidden:yes

  always_filter: {
    filters:[
      course_info.is_real_course: "Yes"
    ]
  }

  join: dim_course_start_date  {
    sql_on: ${course_info.begin_date_raw} = ${dim_course_start_date.date_value};;
    relationship: many_to_one
  }

  join: dim_course_end_date  {
    sql_on: ${course_info.begin_date_raw} = ${dim_course_end_date.date_value};;
    relationship: many_to_one
  }

  join: product_info {
    sql_on: ${course_info.iac_isbn} = ${product_info.isbn13} ;;
    relationship: many_to_one
  }

  join: course_section_usage_facts {
    sql_on:  ${course_info.course_key} = ${course_section_usage_facts.course_key} ;;
    relationship: one_to_one
    view_label: "Course / Section Details"
  }

  join: custom_course_key_cohort_filter {
    view_label: "** Custom Course Key Cohort Filter **"
    sql_on: ${course_info.course_key} = ${custom_course_key_cohort_filter.course_key} ;;
    # type: left_outer
    relationship: many_to_many
  }

  join: gateway_lms_course_sections {
    sql_on: ${course_info.course_key} = ${gateway_lms_course_sections.olr_context_id};;
    relationship: one_to_one
    view_label: "Course / Section Details"
  }

}

view: course_info_base {
  #extends: [base]
  extension: required
  view_label: "Course / Section Details"
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
        SELECT
          context_id
          , (sel.cu_enabled OR iac_isbn13 IN ('0000357700006', '0000357700013', '0000357700020')) AS cui
          , NOT cui AS ia
          , ROW_NUMBER() OVER (PARTITION BY context_id ORDER BY sel.begin_date DESC) = 1 AS latest
        FROM prod.datavault.hub_coursesection hcs
        INNER JOIN prod.datavault.sat_coursesection scs ON hcs.hub_coursesection_key = scs.hub_coursesection_key AND scs._latest
        INNER JOIN prod.datavault.link_coursesection_eltosectionmapping lecsm ON hcs.hub_coursesection_key = lecsm.hub_coursesection_key
        INNER JOIN PROD.DATAVAULT.LINK_ENTERPRISELICENSE_ELTOSECTIONMAPPING lelsm ON lelsm.HUB_ELTOSECTIONMAPPING_KEY = lecsm.HUB_ELTOSECTIONMAPPING_KEY
        INNER JOIN prod.datavault.sat_enterpriselicense sel ON lelsm.hub_enterpriselicense_key = sel.hub_enterpriselicense_key
          AND sel._latest
          AND scs.begin_date BETWEEN sel.begin_date AND sel.end_date
        INNER JOIN prod.datavault.sat_eltosectionmapping secsm ON lecsm.hub_eltosectionmapping_key = secsm.hub_eltosectionmapping_key
          AND secsm._latest
      )
      , lms AS (
        SELECT
          hcs.hub_coursesection_key
          , COALESCE(scg.lms_type, a.kind) AS lms_type
          , 'v' || NULLIF(scg.lms_version, '') AS lms_version
          , scg.integration_type
          , LEAD(1) OVER (PARTITION BY hcs.hub_coursesection_key ORDER BY COALESCE(scg.created_at, a.created_at) DESC) IS NULL AS latest
          , scg.canvas_course_id
          , scg.lms_context_id
          , scg.lis_course_source_id
        FROM prod.datavault.hub_coursesection hcs
        LEFT JOIN prod.datavault.link_coursesectiongateway_coursesection lcsg ON hcs.hub_coursesection_key = lcsg.hub_coursesection_key
        LEFT JOIN prod.datavault.sat_coursesection_gateway scg ON lcsg.hub_coursesectiongateway_key = scg.hub_coursesectiongateway_key AND scg._latest
        LEFT JOIN webassign.wa_app_v4net.sections s ON hcs.context_id = s.olr_context_id
        LEFT JOIN webassign.wa_app_v4net.courses crs ON crs.id = s.course
        LEFT JOIN webassign.wa_app_v4net.schools sch ON sch.id = crs.school
        LEFT JOIN webassign.wa_app_v4net.partner_applications a ON a.school_id = sch.id
        WHERE scg.lms_type IS NOT NULL
          OR a.kind IS NOT NULL
      )
      SELECT DISTINCT
        hcs.context_id
        , scs.course_key
        , COALESCE(scs.course_key,hcs.context_id) AS course_identifier
        , scs.course_name
        , scs.begin_date
        , scs.end_date
        , scs.iac_isbn
        , scs.begin_date::DATE <= CURRENT_DATE() AND scs.end_date >= CURRENT_DATE()::DATE AS active
        , coalesce(scs.deleted,false) AS deleted
        , scs.grace_period_end_date
        , scs.is_gateway_course
        , COALESCE(TRY_CAST(scs.course_master AS BOOLEAN),FALSE) AS course_master
        , scs.course_cgi
        , COALESCE(scs.is_demo,FALSE) AS is_demo
        , COALESCE(
          UPPER(DECODE(lms.lms_type, 'BB', 'Blackboard', lms.lms_type))
          , CASE WHEN scs.is_gateway_course THEN 'UNKNOWN LMS' ELSE 'NOT LMS INTEGRATED' END
        ) AS lms_type_all
        , lms_type_all <> 'NOT LMS INTEGRATED' AS is_lms_integrated
        , lms.lms_version
        , COALESCE(
          lms.integration_type
          , CASE WHEN lms_type_all = 'UNKNOWN LMS' THEN 'UNKNOWN LMS' WHEN is_lms_integrated THEN 'UNKNOWN INTEGRATION TYPE' ELSE 'NOT LMS INTEGRATED' END
        ) AS integration_type
        , lms.lms_type IS NOT NULL AND g.lms_sync_course_scores AS mt_lms_sync_course_scores
        , lms.lms_type IS NOT NULL AND g.lms_sync_activity_scores AS mt_lms_sync_activity_scores
        , CASE
          WHEN NOT is_lms_integrated THEN 'N/A'
          WHEN mt_lms_sync_course_scores THEN 'Course Level'
          WHEN mt_lms_sync_activity_scores THEN 'Activity Level'
          WHEN NOT mt_lms_sync_course_scores AND NOT mt_lms_sync_activity_scores THEN 'No score sync'
          ELSE 'Non Mindtap LMS'
        END AS lms_grade_sync
        , COALESCE(el.cui, FALSE) AS cui
        , COALESCE(el.ia, FALSE) AS ia
        , CASE WHEN cui then 'CUI' WHEN ia THEN 'IA' ELSE 'No License' END AS institutional_license_type
        , COUNT(DISTINCT hub_enrollment_key) as enrollments_count
      FROM prod.datavault.hub_coursesection hcs
      LEFT JOIN (
        SELECT DISTINCT sc.*, LEAD(1) OVER(PARTITION BY course_key ORDER BY context_id = course_key DESC, _effective_from) IS NULL AS _latest_by_course_key
        FROM prod.datavault.sat_coursesection sc
        INNER JOIN prod.datavault.hub_coursesection hc on hc.hub_coursesection_key = sc.hub_coursesection_key
      ) scs ON hcs.hub_coursesection_key = scs.hub_coursesection_key AND (scs._latest_by_course_key OR (scs.course_key IS NULL AND scs._latest))
      LEFT JOIN lms ON hcs.hub_coursesection_key = lms.hub_coursesection_key AND lms.latest
      LEFT JOIN (
        SELECT distinct
          external_id
          , LAST_VALUE(lms_sync_course_scores) IGNORE NULLS OVER(PARTITION BY external_id ORDER BY _fivetran_synced) AS lms_sync_course_scores
          , LAST_VALUE(lms_sync_activity_scores) IGNORE NULLS OVER(PARTITION BY external_id ORDER BY _fivetran_synced) AS lms_sync_activity_scores
        FROM mindtap.prod_nb.gradebook
      ) g ON hcs.context_id = g.external_id
      LEFT JOIN el ON hcs.CONTEXT_ID = el.context_id AND el.latest
      LEFT JOIN prod.DATAVAULT.SAT_COURSESECTION scs2 on scs2.COURSE_KEY = hcs.CONTEXT_ID
      LEFT JOIN prod.datavault.link_user_coursesection luc ON luc.hub_coursesection_key = hcs.hub_coursesection_key
      WHERE scs.course_key IS NOT NULL OR scs2.course_key IS NULL
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
    ;;
    sql_trigger_value: select count(*) from prod.datavault.sat_coursesection ;;
  }

  dimension: course_identifier {
    hidden: no
    primary_key: yes
    description: "Course Key if it exists for a section, otherwise the context id"
  }

  dimension: context_id  {label:"Context ID" hidden:yes}

  dimension: course_key {hidden:no}

  dimension: course_name {}

  dimension_group: begin_date {
    label: "Course Start"
    type: time
  }

  dimension_group: end_date {
    label: "Course End"
    type: time
  }

  dimension: active {
    label: "Course Active"
    type:yesno
    description: "Course start date in the past and course end date in the future."
    }

  dimension: deleted {
    label: "Course Deleted"
    type:yesno
    description: "OLR course section has been deleted"
    }

  dimension_group: grace_period_end_date  {
    label: "Grace Period End"
    type: time
  }

  dimension: is_gateway_course {type:yesno hidden:yes}

  dimension: course_master {
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
    label: "Real Course"
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
    label: "CUI"
    description: "Course is part of a CUI deal"
    group_label: "Institional Access Deal"
  }

  dimension: ia {
    type:yesno
    label: "IA"
    description: "Course is part of an IA deal"
    group_label: "Institional Access Deal"
  }

  dimension: institutional_license_type {
    description: "IA or CUI"
    group_label: "Institional Access Deal"
  }

  dimension: enrollments_count {
    label: "Total Course Enrollments"
    type: number
    description: "Total number of enrollments on course"
  }

  measure: count {
    type: count
    label: "# Courses"
  }

  measure: active_course_sections {
    type: count_distinct
    sql: CASE WHEN ${active} THEN ${course_key} END ;;
  }

}
