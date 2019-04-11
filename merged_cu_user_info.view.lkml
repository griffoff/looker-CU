include: "cu_user_info.view"
view: merged_cu_user_info {
  extends: [cu_user_info]

  derived_table: {
    sql:
      WITH user_info AS (
      SELECT
        *
--         ,ROW_NUMBER() OVER (PARTITION BY merged_guid ORDER BY cu_start_sso DESC) as r
--       FROM UPLOADS.CU.CU_USER_INFO
         FROM ${cu_user_info.SQL_TABLE_NAME}
      )
      SELECT *
      FROM user_info
--      WHERE r = 1
    ;;
  }

  dimension: user_sso_guid {
    label: "User SSO GUID"
    sql: ${TABLE}.merged_guid ;;
    primary_key: yes
    hidden: yes
  }

  dimension: guid {
    hidden: yes
  }

  dimension: opt_out {
    group_label: "User Info - Marketing"
    type: string
    case: {
      when: {label: "Yes" sql: LEFT( ${TABLE}.opt_out, 1) = 'Y';;}
      when: {label: "No" sql: LEFT(${TABLE}.opt_out, 1) = 'N';;}
      else: "UNKNOWN"
    }
  }

  dimension: no_contact_user {
    group_label: "User Info - Marketing"
    type: string
    case: {
      when: {label: "Yes" sql: LEFT(${TABLE}.no_contact_user, 1) = 'Y';;}
      when: {label: "No" sql: LEFT(${TABLE}.no_contact_user, 1) = 'N';;}
      else: "UNKNOWN"
    }
  }

}
