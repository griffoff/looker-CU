view: subscription_events {
    derived_table: {
      sql: with state AS (
            SELECT
                TO_CHAR(TO_DATE(raw_subscription_event."SUBSCRIPTION_START" ), 'YYYY-MM-DD') AS sub_start_date
                ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time DESC) AS latest_record
                ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time ASC) AS earliest_record
                ,LEAD(subscription_state) over(partition by user_sso_guid order by local_time) as change_in_state
                ,LEAD(subscription_start) over(partition by user_sso_guid order by local_time) as change_in_start_date
                ,*
            FROM Unlimited.Raw_Subscription_event
            )

            ,current_subscription_state AS (
            WITH
              recent_guid_time AS
              (SELECT
                user_sso_guid
                ,MAX(subscription_start) AS recent_time
              FROM prod.unlimited.raw_subscription_event
              GROUP BY 1)

              SELECT
                rgt.user_sso_guid
                ,rgt.recent_time
                ,rse.subscription_state AS current_subscription_state
              FROM prod.unlimited.raw_subscription_event rse
              JOIN recent_guid_time rgt
              ON rse.user_sso_guid = rgt.user_sso_guid
              AND rse.subscription_start = rgt.recent_time
              )

            ,starting_subscription_state AS (
            WITH
              start_guid_time AS (
                SELECT
                  user_sso_guid
                  ,MIN(subscription_start) start_time
                FROM prod.unlimited.raw_subscription_event
                GROUP BY 1)

                SELECT
                  sgt.user_sso_guid
                  ,sgt.start_time
                  ,rse.subscription_state AS starting_subscription_state
                FROM prod.unlimited.raw_subscription_event rse
                JOIN start_guid_time sgt
                ON rse.user_sso_guid = sgt.user_sso_guid
                AND rse.subscription_start = sgt.start_time
                )

            ,first_login AS (
             WITH
              recent_guid_time AS
              (SELECT
                userssoguid
                ,MIN(TO_DATE(TO_TIMESTAMP(((VISITSTARTTIME*1000) + hits_time )/1000)  )) AS first_login
              FROM prod.raw_ga.ga_dashboarddata
              WHERE eventcategory = 'Dashboard'
              GROUP BY 1)

              SELECT
                rgt.userssoguid AS user_sso_guid
                ,rgt.first_login
              FROM prod.unlimited.raw_subscription_event rse
              JOIN recent_guid_time rgt
              ON rse.user_sso_guid = rgt.user_sso_guid
              AND rse.subscription_start = rgt.recent_time
              )


            SELECT
              s.*
              ,CASE WHEN latest_record = 1 THEN 'yes' ELSE 'no' END AS latest_filter
              ,CASE WHEN earliest_record = 1 THEN 'yes' ELSE 'no' END AS earliest_filter
              ,css.current_subscription_state
              ,css.recent_time AS current_subscription_start_date
              ,sss.starting_subscription_state
              ,sss.start_time AS first_subscription_event
            FROM state s
            JOIN current_subscription_state css
            ON s.user_sso_guid = css.user_sso_guid
            JOIN starting_subscription_state sss
             ON s.user_sso_guid = sss.user_sso_guid
            WHERE s.user_sso_guid NOT IN (SELECT user_sso_guid FROM unlimited.vw_user_blacklist);;

            persist_for: "24 hours"
    }


    dimension: current_subscription_state {
      type: string

    }


    dimension: starting_subscription_state {
      type: string

    }

    dimension: _hash {
      type: string
      sql: ${TABLE}."_HASH" ;;
      hidden: yes
    }

    dimension: first_subscription_event  {
      type: date
    }


    dimension: latest_subscription {
      label: "Current subscription status"
      description: "filter used to retrive the latest subscription status for a user"
      type: yesno
      sql: ${TABLE}.latest_filter = 'yes'  ;;
    }

    dimension: earliest_subscription {
      label: "Earliest subcription status"
      description: "filter used to retrive the earliest subscription status for a user"
      type: yesno
      sql: ${TABLE}.earliest_filter = 'yes'  ;;
    }

    dimension: change_in_state {
      label: "Subscription State Change"
      sql: ${TABLE}.change_in_state ;;
    }

    dimension: change_in_start_date {
      label: "Subscription Start Date Change"
      sql: ${TABLE}.change_in_start_date ;;
    }

    dimension_group: _ldts {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."_LDTS" ;;
      hidden: yes
    }

    dimension: _rsrc {
      type: string
      sql: ${TABLE}."_RSRC" ;;
      hidden: yes
    }

    dimension: contract_id {
      type: string
      sql: ${TABLE}."CONTRACT_ID" ;;
    }

    dimension_group: local {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."LOCAL_TIME" ;;
    }

    dimension: message_format_version {
      type: number
      sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
      hidden: yes
    }

    dimension: message_type {
      type: string
      sql: ${TABLE}."MESSAGE_TYPE" ;;
      hidden: yes
    }

    dimension: platform_environment {
      type: string
      sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
      hidden: yes
    }

    dimension: product_platform {
      type: string
      sql: ${TABLE}."PRODUCT_PLATFORM" ;;
      hidden: yes
    }

    dimension_group: subscription_end {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."SUBSCRIPTION_END" ;;
    }

    dimension_group: subscription_start {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."SUBSCRIPTION_START" ;;
    }



    dimension: subscription_state {
      type: string
      sql: ${TABLE}."SUBSCRIPTION_STATE";;
    }

    dimension: user_environment {
      type: string
      sql: ${TABLE}."USER_ENVIRONMENT" ;;
      hidden: yes
    }

    dimension: user_sso_guid {
      type: string
      sql: ${TABLE}."USER_SSO_GUID" ;;
    }

    dimension: days_until_expiry {
      type: number
      sql: datediff(day, current_timestamp(), ${subscription_end_raw})  ;;
    }

    dimension: days_since_first_login {
      type: number
      sql: datediff(day, ${first_login_date}, current_timestamp())  ;;
    }

    dimension: action_age_in_days_since_first_login{
      type: number
      sql: datediff(day, ${first_login_date}, to_timestamp(${ga_dashboarddata.visitstarttime})) ;;



#     dimension: days_since_subscription_start {
#     type: number
#     sql: datediff(day, ${subscription_start_date}, to_timestamp(${ga_dashboarddata.visitstarttime}))
#     ;;
    }

    measure: count {
      type: count
      drill_fields: []
    }

    measure: count_days {
      type: count_distinct
      sql: ${action_age_in_days_since_first_login} ;;
    }

    measure: count_subscription {
      label: "# subscriptions"
      type: count_distinct
      sql: ${TABLE}.user_sso_guid ;;
      drill_fields: [detail*]
    }

    set: detail {
      fields: [
        user_sso_guid,
        local_time,
        contract_id,
        subscription_state,
        subscription_start_date
      ]
    }

  }
