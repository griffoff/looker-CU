view: gateway_lms_course_sections {

  derived_table: {
    sql:
    SELECT c.lms_type, c.lms_version, c.olr_context_id, c.lms_context_id, c.gateway_institution_id ,c.school_entity_id, c.deleted, s.iac_isbn, s.section_product_type
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

  dimension: deployment_linked_to_course {
    sql: concat(${TABLE}.gateway_institution_id,${TABLE}.iac_isbn,${TABLE}.lms_context_id) ;;
    hidden: yes
  }

  dimension: lms_type {
    label: "LMS Type"
    hidden: yes
    }

  dimension: section_product_type {hidden: yes}

  dimension: olr_context_id {hidden:yes}

  measure: deployment_count {
    type: count_distinct
    sql: ${deployment} ;;
    label: "# LMS Deployments"
    description: "Deployment = institution ID + IAC ISBN combination"
  }

  measure: deployment_linked_to_course_count {
    type: count_distinct
    sql: ${deployment_linked_to_course} ;;
    hidden: yes
  }

  measure: lms_context_id_count {
    type: count_distinct
    sql: ${TABLE}.lms_context_id ;;
    hidden: yes
  }

  measure: average_deployments_per_lms_context_id {
    type: number
    sql: ${deployment_linked_to_course_count} / nullif(${lms_context_id_count},0)  ;;
    description: "Count of deployments divided by count of LMS context IDs (deployment = institution ID + IAC ISBN + LMS context ID combination)"
}

}
