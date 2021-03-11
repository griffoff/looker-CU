# view: cu_enterprise_licenses {
#   derived_table: {
#     sql: Select lic.*,el.course_Context_id as cc, 'yes' AS CUI_Course
#       from UPLOADS.CU.ENTERPRISE_LICENSES_24Jun lic
#       left join UPloads.CU.EL_Course_Mapping_24JUn el
#       ON lic.context_id = el.el_context_id
#       where created_by Not like 'anshuman.sharma@contractor.cengage.com' OR institution_entity_id::STRING NOT IN ('29235743', '4303', 'CS2008', '203410', '213054', '7924')
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#     hidden: yes
#   }

#   dimension: CUI_Course {
#     label: "CUI Course Flag"
#     sql: ${TABLE}.CUI_Course;;
# #     sql: ${CUI_Course} ;;
#     type: string
#   }

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#     hidden: yes
#   }

#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#     hidden: yes
#   }

#   dimension: context_id {
#     type: string
#     sql: ${TABLE}."CONTEXT_ID" ;;
#   }

#   dimension: online_product_isbn {
#     type: number
#     sql: ${TABLE}."ONLINE_PRODUCT_ISBN" ;;
#   }

#   dimension: course_name {
#     type: string
#     sql: ${TABLE}."COURSE_NAME" ;;
#   }

#   dimension: institution_entity_id {
#     type: number
#     sql: ${TABLE}."INSTITUTION_ENTITY_ID" ;;
#   }

#   dimension: institution_name {
#     type: string
#     sql: ${TABLE}."INSTITUTION_NAME" ;;
#   }

#   dimension: el_contract_id {
#     type: string
#     sql: ${TABLE}."EL_CONTRACT_ID" ;;
#   }

#   dimension: magellan_oppty_id {
#     type: string
#     sql: ${TABLE}."MAGELLAN_OPPTY_ID" ;;
#   }

#   dimension: el_classtest {
#     type: string
#     sql: ${TABLE}."EL_CLASSTEST" ;;
#   }

#   dimension: el_type {
#     type: string
#     sql: ${TABLE}."EL_TYPE" ;;
#   }

#   dimension_group: end_date {
#     type: time
#     sql: ${TABLE}."END_DATE" ;;
#   }

#   dimension: el_max_seats {
#     type: number
#     sql: ${TABLE}."EL_MAX_SEATS" ;;
#   }

#   dimension: el_sales_rep_name_1 {
#     type: string
#     sql: ${TABLE}."EL_SALES_REP_NAME_1" ;;
#   }

#   dimension: el_sales_rep_email_1 {
#     type: string
#     sql: ${TABLE}."EL_SALES_REP_EMAIL_1" ;;
#   }

#   dimension: el_sales_rep_name_2 {
#     type: string
#     sql: ${TABLE}."EL_SALES_REP_NAME_2" ;;
#   }

#   dimension: el_sales_rep_email_2 {
#     type: string
#     sql: ${TABLE}."EL_SALES_REP_EMAIL_2" ;;
#   }

#   dimension: el_sales_rep_name_3 {
#     type: string
#     sql: ${TABLE}."EL_SALES_REP_NAME_3" ;;
#   }

#   dimension: el_sales_rep_email_3 {
#     type: string
#     sql: ${TABLE}."EL_SALES_REP_EMAIL_3" ;;
#   }

#   dimension: el_cust_contact_1 {
#     type: string
#     sql: ${TABLE}."EL_CUST_CONTACT_1" ;;
#   }

#   dimension: el_cust_contact_email_1 {
#     type: string
#     sql: ${TABLE}."EL_CUST_CONTACT_EMAIL_1" ;;
#   }

#   dimension: el_cust_contact_2 {
#     type: string
#     sql: ${TABLE}."EL_CUST_CONTACT_2" ;;
#   }

#   dimension: el_cust_contact_email_2 {
#     type: string
#     sql: ${TABLE}."EL_CUST_CONTACT_EMAIL_2" ;;
#   }

#   dimension: el_cust_contact_3 {
#     type: string
#     sql: ${TABLE}."EL_CUST_CONTACT_3" ;;
#   }

#   dimension: el_cust_contact_email_3 {
#     type: string
#     sql: ${TABLE}."EL_CUST_CONTACT_EMAIL_3" ;;
#   }

#   dimension_group: created_on {
#     type: time
#     sql: ${TABLE}."CREATED_ON" ;;
#   }

#   dimension: created_by {
#     type: string
#     sql: ${TABLE}."CREATED_BY" ;;
#   }

#   dimension_group: last_updated_on {
#     type: time
#     sql: ${TABLE}."LAST_UPDATED_ON" ;;
#   }

#   dimension: last_updated_by {
#     type: string
#     sql: ${TABLE}."LAST_UPDATED_BY" ;;
#   }

#   dimension: cu_enabled {
#     type: string
#     sql: ${TABLE}."CU_ENABLED" ;;
#   }

#   dimension: cu_isbn {
#     type: string
#     sql: ${TABLE}."CU_ISBN" ;;
#   }

#   dimension: el_context_id {
#     type: string
#     sql: ${TABLE}."EL_CONTEXT_ID" ;;
#   }

#   dimension: course_context_id {
#     type: string
#     sql: ${TABLE}."COURSE_CONTEXT_ID" ;;
#   }

#   dimension_group: _fivetran_synced {
#     type: time
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#     hidden: yes
#   }

#   dimension: cc {
#     type: string
#     sql: ${TABLE}."CC" ;;
#     hidden: yes
#   }

#   set: detail {
#     fields: [
#       _file,
#       _line,
#       context_id,
#       online_product_isbn,
#       course_name,
#       institution_entity_id,
#       institution_name,
#       el_contract_id,
#       magellan_oppty_id,
#       el_classtest,
#       el_type,
#       end_date_time,
#       el_max_seats,
#       el_sales_rep_name_1,
#       el_sales_rep_email_1,
#       el_sales_rep_name_2,
#       el_sales_rep_email_2,
#       el_sales_rep_name_3,
#       el_sales_rep_email_3,
#       el_cust_contact_1,
#       el_cust_contact_email_1,
#       el_cust_contact_2,
#       el_cust_contact_email_2,
#       el_cust_contact_3,
#       el_cust_contact_email_3,
#       created_on_time,
#       created_by,
#       last_updated_on_time,
#       last_updated_by,
#       cu_enabled,
#       cu_isbn,
#       el_context_id,
#       course_context_id,
#       _fivetran_synced_time,
#       cc
#     ]
#   }
# }
