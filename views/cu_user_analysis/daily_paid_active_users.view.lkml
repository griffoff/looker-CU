view: daily_paid_active_users {
  derived_table: {
#     derived table w/ date, paid user count, paid student count, paid instructor count
#  from dim_date left join user_courses left join subscriptions
# where date between course activation and course end
# or date between subsc start and subscr end
    sql:
      WITH paid_users as (
        (SELECT DISTINCT user_sso_guid, activation_date::date as paid_start, course_end_date::date as paid_end
        FROM PROD.CU_USER_ANALYSIS.USER_COURSES)
        UNION
        (SELECT DISTINCT current_guid as user_sso_guid, subscription_start::date as paid_start, subscription_end::date as paid_end
        FROM PROD.DATAVAULT.Sat_Subscription_SAP subevent
        LEFT JOIN prod.public.offset_transactions offset_transactions ON subevent.CONTRACT_ID = offset_transactions.CONTRACT_ID
                                                                          AND (offset_transactions._LDTS >= TO_DATE('16-Dec-2018') AND offset_transactions._LDTS < TO_DATE('01-Jan-2019') )
                                                                            AND offset_transactions.subscription_state in ('full_access')

        WHERE _latest AND subscription_plan_id ilike 'Full-Access%'
        AND offset_transactions.CONTRACT_ID is null)
      )
      SELECT dim_date.datevalue as date
        ,COUNT(DISTINCT user_sso_guid) as paid_user_count
      FROM ${dim_date.SQL_TABLE_NAME} dim_date
      LEFT JOIN paid_users ON dim_date.datevalue BETWEEN paid_start AND paid_end
      WHERE dim_date.datevalue BETWEEN '2018-01-01' AND CURRENT_DATE()
      GROUP BY 1
      ;;

      persist_for: "24 hours"
    }

    dimension: date {primary_key: yes}

    measure: paid_user_count {
      label: "# Paid Users"
      description: "# Users with a full access CU subscription or an active paid course"
      type: number
      sql: AVG(${TABLE}.paid_user_count) ;;
      value_format_name: decimal_0
    }
}
