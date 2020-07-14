explore:  gateway_lms_course_sections {}
view: gateway_lms_course_sections {

  derived_table: {
    sql:
    SELECT c.lms_type, c.olr_context_id, c.lms_context_id, c.gateway_institution_id, c.deleted, s.iac_isbn, s.section_product_type
    FROM gateway.prod.course c
    INNER JOIN olr.prod.section_v4 s ON c.olr_context_id = s.context_id AND NOT s.deleted
    WHERE NOT c.deleted
    ;;

    persist_for: "60 minutes"
  }

  dimension: deployment {
    sql: concat(${TABLE}.gateway_institution_id,${TABLE}.iac_isbn) ;;
    hidden: yes
  }

  dimension: lms_type {label: "LMS Type"}

  dimension: section_product_type {hidden: yes}

  dimension: olr_context_id {hidden:yes}

  measure: deployment_count {
    type: count_distinct
    sql: ${deployment} ;;
    label: "# LMS Deployments"
    description: "Deployment = use of an LMS in a course section"
  }

  measure: lms_context_id_count {
    type: count_distinct
    sql: ${TABLE}.lms_context_id ;;
    hidden: yes
  }

  measure: average_deployments_per_lms_context_id {
    type: number
    sql: ${deployment_count} / nullif(${lms_context_id_count},0)  ;;
}

 }
