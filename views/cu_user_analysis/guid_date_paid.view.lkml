explore: guid_date_paid {}

view: guid_date_paid {
  derived_table: {
    sql:
    WITH paid_users AS (
    (SELECT DISTINCT user_sso_guid, activation_date::DATE AS paid_start, course_end_date::DATE AS paid_end
     FROM prod.cu_user_analysis.user_courses)
    UNION
    (SELECT DISTINCT COALESCE(linked_guid, current_guid) AS user_sso_guid,
                     subscription_start::DATE            AS paid_start,
                     subscription_end::DATE              AS paid_end
     FROM prod.datavault.sat_subscription_sap subevent
              INNER JOIN prod.datavault.hub_user ON subevent.current_guid = hub_user.UID
              LEFT JOIN prod.datavault.sat_user ON hub_user.UID = sat_user.linked_guid AND sat_user.active
              LEFT JOIN prod.public.offset_transactions offset_transactions
                        ON subevent.CONTRACT_ID = offset_transactions.CONTRACT_ID
                            AND (offset_transactions._LDTS >= TO_DATE('16-Dec-2018') AND
                                 offset_transactions._LDTS < TO_DATE('01-Jan-2019'))
                            AND offset_transactions.subscription_state in ('full_access')
     WHERE _latest
       AND subscription_plan_id ILIKE 'Full-Access%'
       AND subevent.SUBSCRIPTION_STATE NOT IN ('Cancelled', 'Pending')
       AND offset_transactions.contract_id IS NULL)
)
SELECT dim_date.datevalue as date, user_sso_guid, TRUE AS paid_flag
FROM ${dim_date.SQL_TABLE_NAME} dim_date
         LEFT JOIN paid_users ON dim_date.datevalue BETWEEN paid_start AND paid_end
WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
    ;;
    persist_for: "24 hours"
  }

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

}
