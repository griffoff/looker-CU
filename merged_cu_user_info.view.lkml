include: "cu_user_info.view"
view: merged_cu_user_info {
  extends: [cu_user_info]

  derived_table: {
    sql:
      WITH user_info AS (
      SELECT
        *
        ,ROW_NUMBER() OVER (PARTITION BY merged_guid ORDER BY cu_start_sso DESC) as r
      FROM UPLOADS.CU.CU_USER_INFO
      )
      SELECT *
      FROM user_info
      WHERE r = 1
    ;;
  }

  dimension: user_sso_guid {
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: yes
  }

  dimension: opt_out {
    type: string
    case: {
      when: {label: "Yes" sql: ${TABLE}.opt_out = 'Y';;}
      when: {label: "No" sql: ${TABLE}.opt_out = 'N';;}
      else: "UNKNOWN"
    }
  }

  dimension: no_contact_user {
    type: string
    case: {
      when: {label: "Yes" sql: ${TABLE}.no_contact_user = 'Y';;}
      when: {label: "No" sql: ${TABLE}.no_contact_user = 'N';;}
      else: "UNKNOWN"
    }
  }

}
