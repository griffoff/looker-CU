explore: guid_date_paid {}

view: guid_date_paid {
  derived_table: {
    sql:
       WITH paid_users AS (
        (SELECT DISTINCT user_sso_guid, activation_date::DATE AS paid_start, course_end_date::DATE AS paid_end
        FROM PROD.CU_USER_ANALYSIS.USER_COURSES)
        UNION
        (SELECT DISTINCT COALESCE(linked_guid,current_guid) AS user_sso_guid, subscription_start::date AS paid_start, subscription_end::date AS paid_end
        FROM PROD.DATAVAULT.Sat_Subscription_SAP subevent
        INNER JOIN PROD.DATAVAULT.HUB_USER ON subevent.current_guid = HUB_USER.UID
        LEFT JOIN PROD.DATAVAULT.Sat_User ON HUB_USER.UID = sat_user.linked_guid AND sat_user.active
        LEFT JOIN prod.public.offset_transactions offset_transactions ON subevent.CONTRACT_ID = offset_transactions.CONTRACT_ID
                                                                          AND (offset_transactions._LDTS >= TO_DATE('16-Dec-2018') AND offset_transactions._LDTS < TO_DATE('01-Jan-2019') )
                                                                            AND offset_transactions.subscription_state in ('full_access')

        WHERE _latest AND subscription_plan_id ilike 'Full-Access%' AND subevent.SUBSCRIPTION_STATE NOT IN ('Cancelled','Pending')
        AND offset_transactions.CONTRACT_ID is null)
      )
      SELECT dim_date.datevalue as date, user_sso_guid, TRUE as paid_flag

      FROM ${dim_date.SQL_TABLE_NAME} dim_date
      LEFT JOIN paid_users ON dim_date.datevalue BETWEEN paid_start AND paid_end
      WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()

       ;;
      persist_for: "24 hours"
  }


#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}.USER_SSO_GUID ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: paid_flag {
    type: yesno
    sql: ${TABLE}.paid_flag ;;
  }

#
#   dimension: pk {
#     type: number
#     sql: ${TABLE}."PK" ;;
#   }
#
#   dimension: r {
#     type: number
#     sql: ${TABLE}."R" ;;
#   }
#
#   set: detail {
#     fields: [user_sso_guid, active_date, olr_course_key, pk, r]
#   }
}
