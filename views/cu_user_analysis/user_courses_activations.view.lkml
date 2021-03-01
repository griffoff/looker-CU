explore: user_courses_activations {
  hidden: yes

}

view: user_courses_activations {
  derived_table: {
    sql:
    WITH dates AS (
    SELECT date_value as date, GOVERNMENTDEFINEDACADEMICTERM AS season, GOVERNMENTDEFINEDACADEMICTERMYEAR AS term_year, GOVERNMENTDEFINEDACADEMICTERMID as season_no
    FROM bpl_mart.prod.dim_date
    WHERE date_value between '2018-08-01' and current_date()
    )
    ,courses as (
    Select user_sso_guid, course_key, activation_date, course_end_date, cu_flag
    --, (cu_subscription_id IS NOT NULL AND cu_subscription_id <> 'TRIAL') OR cui_flag = 'Y' as cu_flag
    from ${user_courses.SQL_TABLE_NAME}
    )

    ,users as (
    select
      user_sso_guid, max(cu_flag) as current_cu_status
    from courses c
    where current_date() between c.activation_date and case when c.course_end_date <= c.activation_date then dateadd(w,16,c.activation_date) else c.course_end_date end
    group by user_sso_guid
    )

    select distinct
      d.date
      , d.season
      , d.term_year
      , d.season_no
      , c.user_sso_guid
      , concat(c.user_sso_guid,course_key) as activation_key
      , cu_flag
      , current_cu_status
      , case when cu_flag = true then activation_key end as cu_activation_key
      , case when cu_flag = false then activation_key end as non_cu_activation_key
      , case when cu_flag = true then c.user_sso_guid end as cu_user_sso_guid
      , case when cu_flag = false then c.user_sso_guid end as non_cu_user_sso_guid


    from dates d
    inner join courses c on d.date between c.activation_date and case when c.course_end_date <= c.activation_date then dateadd(w,16,c.activation_date) else c.course_end_date end
    left join users u on u.user_sso_guid = c.user_sso_guid
    ;;
    datagroup_trigger: daily_refresh
  }

  dimension_group: date {
    view_label: "Date"
    label: "Calendar"
    hidden: no
    type:time
    timeframes: [raw,date,week,month,year]
  }

  dimension: season {
    order_by_field: season_no
    hidden:no
    }

  dimension: term_year {hidden:no}
  dimension: season_no {hidden:no}

  measure: cu_activation_key {
    type: count_distinct
    value_format_name: decimal_0
    label: "CU Activations"
  }

  measure: non_cu_activation_key {
    type: count_distinct
    value_format_name: decimal_0
    label: "Non-CU Activations"
    }

    measure: cu_users_average_activations {
      type: number
      sql: count(distinct ${TABLE}.cu_activation_key) / count(distinct ${TABLE}.cu_user_sso_guid) ;;
      value_format_name: decimal_2
    }

  measure: non_cu_users_average_activations {
    type: number
    sql: count(distinct ${TABLE}.non_cu_activation_key) / count(distinct ${TABLE}.non_cu_user_sso_guid) ;;
    value_format_name: decimal_2
  }

  }
