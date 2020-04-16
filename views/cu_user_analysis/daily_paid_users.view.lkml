view: daily_paid_users {
  derived_table: {
#     derived table w/ date, paid user count, paid student count, paid instructor count
#  from dim_date left join user_courses left join subscriptions
# where date between course activation and course end
# or date between subsc start and subscr end
    sql:
      SELECT date, count(distinct user_sso_guid) as paid_user_count
      FROM ${guid_date_paid.SQL_TABLE_NAME}
      GROUP BY 1
      ;;

      persist_for: "24 hours"
    }

    dimension: date {
      type: date
      primary_key: yes}

    measure: paid_user_count {
      label: "# Paid Users"
      description: "# Users with a full access CU subscription or an active paid course (if more than one day is included in filter, this shows the average over the chosen period)"
      type: number
      sql: AVG(${TABLE}.paid_user_count) ;;
      value_format_name: decimal_0
    }
}
